#DeviceSparseMatrixSELL implementation
### Padding for vals is 0 and for col indices is -1 (invalid index)

# TODO: rework to replace SparseGPUMatrixSELL by DeviceSparseMatrixSELL, to be consistent with other formats
# Like DeviceSparseMatrixCSR
""" 
	DeviceSparseMatrixSELL{Tv,Ti,NzValT,ColValT,SlicePtrT} <: AbstractDeviceSparseMatrix{Tv,Ti}
A sparse matrix stored in Sliced ELLPACK (SELL) format on a the device.

# Fields
- `m::Int` 				- Number of rows
- `n::Int` 				- Number of columns
- `slice_ptr::SlicePtrT` - Index of the first element of each slice
- `colval::ColValT` 	- Column indices of non-zero values
- `nzval::NzValT` 		- Non-zero values
- `perm::Vector{Int}` 	- Row permutation to reduce padding (not used yet)
- `slice_size::Int` 	- Number of rows per slice
- `nslices::Int` 		- Number of slices
- `nnz::Int` 			- Number of nonzeros
- `n_stored::Int` 		- Number of stored values (padded)
"""

struct DeviceSparseMatrixSELL{
    Tv,
    Ti<:Integer,
    SlicePtrT<:AbstractVector{Ti},
    ColValT<:AbstractVector{Ti},
    NzValT<:AbstractVector{Tv},
} <: AbstractDeviceSparseMatrix{Tv,Ti}
    m::Int
    n::Int
    slice_ptr::SlicePtrT
    colval::ColValT
    nzval::NzValT
    perm::Vector{Int}
    slice_size::Int
    nslices::Int
    nnz::Int
    n_stored::Int

    function DeviceSparseMatrixSELL{Tv,Ti,SlicePtrT,ColValT,NzValT}(
        m::Integer,
        n::Integer,
        slice_ptr::SlicePtrT,
        colval::ColValT,
        nzval::NzValT,
        perm::Vector{Int},
        slice_size::Integer,
        nslices::Integer,
        nnz::Integer,
        n_stored::Integer,
        #backend::B,
    ) where {
        Tv,
        Ti,
        SlicePtrT<:AbstractVector{Ti},
        ColValT<:AbstractVector{Ti},
        NzValT<:AbstractVector{Tv},
        #B<:KernelAbstractions.Backend,
    }
        get_backend(slice_ptr) == get_backend(colval) == get_backend(nzval) ||
            throw(ArgumentError("All storage vectors must be on the same device/backend."))

        m >= 0 || throw(ArgumentError("m must be non-negative"))
        n >= 0 || throw(ArgumentError("n must be non-negative"))
        SparseArrays.sparse_check_Ti(m, n, Ti)

        _check_type(Ti, slice_ptr) || throw(ArgumentError("slice_ptr must be of type $Ti"))
        _check_type(Ti, colval) || throw(ArgumentError("colval must be of type $Ti"))
        _check_type(Tv, nzval) || throw(ArgumentError("nzval must be of type $Tv"))

        length(slice_ptr) == nslices + 1 ||
            throw(ArgumentError("slice_ptr length must be nslices+1"))
        length(colval) == length(nzval) ||
            throw(ArgumentError("colval and nzval must have same length"))

        new{Tv,Ti,SlicePtrT,ColValT,NzValT}(
            Int(m),
            Int(n),
            slice_ptr,
            colval,
            nzval,
            perm,
            slice_size,
            nslices,
            nnz,
            n_stored,
        )
    end
end

function DeviceSparseMatrixSELL(
    m::Integer,
    n::Integer,
    slice_ptr::SlicePtrT,
    colval::ColValT,
    nzval::NzValT,
    perm::Vector{Int},
    slice_size::Int,
    nslices::Int,
    nnz::Int,
    n_stored::Int,
) where {
    SlicePtrT<:AbstractVector{Ti},
    ColValT<:AbstractVector{Ti},
    NzValT<:AbstractVector{Tv},
} where {Ti<:Integer,Tv}
    Ti2 = _get_eltype(slice_ptr)
    Tv2 = _get_eltype(nzval)
    DeviceSparseMatrixSELL{Tv2,Ti2,SlicePtrT,ColValT,NzValT}(
        m,
        n,
        slice_ptr,
        colval,
        nzval,
        perm,
        slice_size,
        nslices,
        nnz,
        n_stored,
    )
end

# From dense matrix
function DeviceSparseMatrixSELL(
    m::Matrix{Tv},
    slice_size::Int = 32,
    ::Type{Ti} = Int32,
) where {Tv,Ti<:Integer}
    sparse_matrix_csc_t = convert(SparseMatrixCSC{Tv,Ti}, sparse(transpose(m)))
    DeviceSparseMatrixSELL(transpose(sparse_matrix_csc_t), slice_size)
end

# From Transposed CSC
function DeviceSparseMatrixSELL(
    A::Transpose{Tv,<:SparseMatrixCSC{Tv,Ti}},
    slice_size::Int = 32,
) where {Tv,Ti<:Integer}
    A_csr = DeviceSparseMatrixCSR(A)
    return DeviceSparseMatrixSELL(A_csr, slice_size)
end

# From CSC (not efficient)
function DeviceSparseMatrixSELL(A::SparseMatrixCSC)
    At = transpose(A)
    A_sparse = DeviceSparseMatrixCSR(transpose(SparseMatrixCSC(At)))
    return DeviceSparseMatrixSELL(A_sparse)
end


# Main constructor from DeviceSparseMatrixCSR
function DeviceSparseMatrixSELL(
    m::DeviceSparseMatrixCSR{Tv,Ti},
    slice_size::Int = 32,
) where {Tv,Ti<:Integer}
    rowptr = m.rowptr
    colval = m.colval
    nzval = m.nzval
    slice_size = iszero(size(m, 1)) ? 1 : min(slice_size, size(m, 1))
    n_slices = ceil(Int, size(m, 1) / slice_size)
    max_nnz_per_slice = zeros(Int, n_slices)
    nnz_per_row = diff(rowptr)

    # Compute optimal permutation of rows to minimize padding (not used yet)
    #perm = reverse!(sortperm(nnz_per_row[:]))
    perm = collect(1:size(m, 1))
    nnz_per_row = nnz_per_row[perm]

    # Compute the maximum number of nonzeros per row for each slice
    n_stored = 0
    for i = 1:n_slices
        row_start = (i-1) * slice_size + 1
        row_end = min(i * slice_size, size(m, 1))
        max_nnz_per_slice[i] = maximum(nnz_per_row[row_start:row_end])
        n_stored += max_nnz_per_slice[i] * slice_size
    end
    slice_ptr = zeros(Ti, n_slices + 1)
    slice_ptr[1] = 1
    for i = 1:n_slices
        slice_ptr[i+1] = slice_ptr[i] + max_nnz_per_slice[i] * slice_size
    end

    colval_padded = Vector{Ti}(undef, n_stored)
    nzval_padded = Vector{Tv}(undef, n_stored) # zeros(Tv, n_stored) is not type stable for some reason

    for slice = 1:n_slices
        slice_start = (slice - 1) * slice_size + 1
        slice_end = min(slice * slice_size, size(m, 1))
        # Fill the padded sub-matrix for each slice in Row-Major order
        max_nnz = max_nnz_per_slice[slice]

        ### Padding for vals is 0 and for col indices is -1 (invalid index)
        temp_colval = -ones(Ti, slice_size, max_nnz)
        temp_nzval = zeros(Tv, slice_size, max_nnz)
        for row = slice_start:slice_end
            if row > size(m, 1)
                break
            end
            start = rowptr[perm[row]]
            end_ = rowptr[perm[row]+1] - 1
            temp_colval[row-slice_start+1, 1:(end_-start+1)] = colval[start:end_]
            temp_nzval[row-slice_start+1, 1:(end_-start+1)] = nzval[start:end_]
        end
        # Reshape the sub-matrix to make it column-major vector and copy it to final storage
        colval_padded[slice_ptr[slice]:(slice_ptr[slice+1]-1)] =
            reshape(temp_colval, :)
        nzval_padded[slice_ptr[slice]:(slice_ptr[slice+1]-1)] =
            reshape(temp_nzval, :)
    end

    DeviceSparseMatrixSELL(
        size(m, 1),
        size(m, 2),
        slice_ptr,
        colval_padded,
        nzval_padded,
        perm,
        slice_size,
        n_slices,
        nnz(m),
        n_stored,
    )

end

Adapt.adapt_structure(to, A::DeviceSparseMatrixSELL) = DeviceSparseMatrixSELL(
    size(A, 1),
    size(A, 2),
    Adapt.adapt_structure(to, A.slice_ptr),
    Adapt.adapt_structure(to, A.colval),
    Adapt.adapt_structure(to, A.nzval),
    A.perm,
    A.slice_size,
    A.nslices,
    A.nnz,
    A.n_stored,
)

# Base methods for the DeviceSparseMatrixSELL type
Base.size(A::DeviceSparseMatrixSELL) = (A.m, A.n)
Base.size(A::DeviceSparseMatrixSELL, i::Int) = (i == 1) ? A.m : A.n
Base.length(A::DeviceSparseMatrixSELL) = A.m * A.n
Base.show(io::IO, A::DeviceSparseMatrixSELL) = println(
    io,
    "DeviceSparseMatrixSELL{$(eltype(A.nzval)) - $(eltype(A.colval))}($(size(A, 1)), $(size(A, 2))) - $(nnz(A)) explicit elements",
)
Base.display(A::DeviceSparseMatrixSELL) = show(stdout, A)

function Base.collect(A::DeviceSparseMatrixSELL)
    slice_ptr = collect(A.slice_ptr)
    colval = collect(A.colval)
    nzval = collect(A.nzval)

    m, n = size(A)
    dense_A = zeros(eltype(nzval), m, n)
    for slice = 1:A.nslices
        max_nnz = (slice_ptr[slice+1] - slice_ptr[slice]) ÷ A.slice_size
        for row = 1:A.slice_size
            global_row = (slice-1)*A.slice_size + row
            if global_row > m
                break
            end
            for e = 1:max_nnz
                idx = slice_ptr[slice] + (row-1) + (e-1)*A.slice_size
                col = colval[idx]
                if col == -1
                    break
                end
                val = nzval[idx]
                dense_A[global_row, col] = val
            end
        end
    end
    return dense_A
end
Base.copy(A::DeviceSparseMatrixSELL) = DeviceSparseMatrixSELL(
    A.m,
    A.n,
    copy(A.slice_ptr),
    copy(A.colval),
    copy(A.nzval),
    copy(A.perm),
    A.slice_size,
    A.nslices,
    A.nnz,
    A.n_stored,
)

function Base.getindex(A::DeviceSparseMatrixSELL, i::Int, j::Int)
    #@warn "Scalar indexing on a DeviceSparseMatrixSELL is slow. For better performance, vectorize the operation."
    if i < 1 || i > A.m || j < 1 || j > A.n
        throw(BoundsError(A, (i, j)))
    end
    row_offset = i - 1
    # The elements of the row i are stored at col+row_offset for col striding with step = n
    for col = 1:A.n:length(A.colval)
        if col+row_offset < length(A.colval) && A.colval[col+row_offset] == j
            return A.nzval[col+row_offset]
        end
    end
    return zero(eltype(A.nzval))
end

function Base.setindex!(A::DeviceSparseMatrixSELL, v, i::Int, j::Int)
    if i < 1 || i > A.m || j < 1 || j > A.n
        throw(BoundsError(A, (i, j)))
    end
    row_offset = i - 1

    for col = 1:A.n:length(A.colval)
        if A.colval[col+row_offset] == j
            A.nzval[col+row_offset] = v
            return
        end
    end
    throw(
        ArgumentError(
            "Index ($i, $j) is not in the matrix. Adding new values is not supported yet.",
        ),
    ) # TODO : Implement adding new values, but this will always be inefficient in SELL format
end

# SparseArrays functions
SparseArrays.nnz(A::DeviceSparseMatrixSELL) = A.nnz
SparseArrays.nonzeros(A::DeviceSparseMatrixSELL) = A.nzval
colvals(A::DeviceSparseMatrixSELL) = A.colval
#sliceptr(A::DeviceSparseMatrixSELL) = A.slice_ptr

# KA functions
KernelAbstractions.get_backend(A::DeviceSparseMatrixSELL) = get_backend(A.nzval)

# Linear algebra functions
function Base.:-(A::DeviceSparseMatrixSELL)
    return DeviceSparseMatrixSELL(
        A.m,
        A.n,
        copy(A.slice_ptr),
        copy(A.colval),
        -A.nzval,
        copy(A.perm),
        A.slice_size,
        A.nslices,
        A.nnz,
        A.n_stored,
    )
end
Base.conj(A::DeviceSparseMatrixSELL{<:Real}) = A
function Base.conj(A::DeviceSparseMatrixSELL{<:Complex})
    return DeviceSparseMatrixSELL(
        A.m,
        A.n,
        copy(A.slice_ptr),
        copy(A.colval),
        conj.(A.nzval),
        copy(A.perm),
        A.slice_size,
        A.nslices,
        A.nnz,
        A.n_stored,
    )
end
Base.real(A::DeviceSparseMatrixSELL{<:Real}) = A
function Base.real(A::DeviceSparseMatrixSELL{<:Complex})
    return DeviceSparseMatrixSELL(
        A.m,
        A.n,
        copy(A.slice_ptr),
        copy(A.colval),
        real.(A.nzval),
        copy(A.perm),
        A.slice_size,
        A.nslices,
        A.nnz,
        A.n_stored,
    )
end
Base.imag(A::DeviceSparseMatrixSELL{<:Real}) = zero(A)
function Base.imag(A::DeviceSparseMatrixSELL{<:Complex})
    return DeviceSparseMatrixSELL(
        A.m,
        A.n,
        copy(A.slice_ptr),
        copy(A.colval),
        imag.(A.nzval),
        copy(A.perm),
        A.slice_size,
        A.nslices,
        A.nnz,
        A.n_stored,
    )
end
function Base.:(*)(α::Number, A::DeviceSparseMatrixSELL)
    return DeviceSparseMatrixSELL(
        A.m,
        A.n,
        copy(A.slice_ptr),
        copy(A.colval),
        α .* A.nzval,
        copy(A.perm),
        A.slice_size,
        A.nslices,
        A.nnz,
        A.n_stored,
    )
end
Base.:(*)(A::DeviceSparseMatrixSELL, α::Number) = α * A
Base.:(/)(A::DeviceSparseMatrixSELL, α::Number) = (1 / α) * A

function LinearAlgebra.tr(A::DeviceSparseMatrixSELL)
    throw(ArgumentError("Transpose of DeviceSparseMatrixSELL is not implemented yet."))
end

@kernel function sell_spmv_kernel!(
    c,
    @Const(a_col_val),
    @Const(a_nz_val),
    @Const(a_slice_ptr),
    @Const(slice_size),
    @Const(n),
    @Const(b),
    @Const(α),
    @Const(β)
)
    #offset, slice = @index(Global, NTuple)
    #offset = offset - 1
    #row = (slice-1) * slice_size + offset + 1
    row = @index(Global, Linear)
    slice = (row-1) ÷ slice_size + 1
    offset = (row-1) % slice_size
    #if row <= n 
    start = a_slice_ptr[slice] + offset
    stop = a_slice_ptr[slice+1] - 1
    acc = zero(eltype(c))
    for i = start:slice_size:stop
        col = a_col_val[i]
        if col == -1
            break
        end
        acc += a_nz_val[i] * b[col]
    end
    if β == zero(β) # avoid reading c when β == 0, as c may be uninitialized
        c[row] = α * acc
    else
        c[row] = α * acc + β * c[row]
    end
    #end
end

function LinearAlgebra.mul!(
    C::ResVec,
    A::DeviceSparseMatrixSELL{Tv,Ti},
    B::InputVec,
    α::T1,
    β::T2,
) where {
    Tv,
    Ti<:Integer,
    ResType<:Number,
    InputType<:Number,
    ResVec<:AbstractVector{ResType},
    InputVec<:AbstractVector{InputType},
    T1<:Number,
    T2<:Number,
}
    size(A, 2) == size(B, 1) || throw(
        DimensionMismatch(
            "second dimension of A, $(size(A,2)), does not match the first dimension of B, $(size(B,1))",
        ),
    )
    size(A, 1) == size(C, 1) || throw(
        DimensionMismatch(
            "first dimension of A, $(size(A,1)), does not match the first dimension of C, $(size(C,1))",
        ),
    )
    size(B, 2) == size(C, 2) || throw(
        DimensionMismatch(
            "second dimension of B, $(size(B,2)), does not match the second dimension of C, $(size(C,2))",
        ),
    )
    promote_type(T1, T2, Tv, InputType) <: ResType || throw(
        ArgumentError(
            "element types of A, B, α, and β must be promotable to the element type of C - got $Tv, $InputType, $T1, $T2, and $(eltype(C))",
        ),
    )
    backend_C = get_backend(C)
    backend_A = get_backend(A)
    backend_B = get_backend(B)

    backend_A == backend_B == backend_C ||
        throw(ArgumentError("All arrays must have the same backend"))

    # Call the kernel
    kernel! = sell_spmv_kernel!(backend_A)
    kernel!(
        C,
        A.colval,
        A.nzval,
        A.slice_ptr,
        A.slice_size,
        A.n,
        B,
        α,
        β,
        ndrange = size(A, 1),
    )
end

@kernel function sell_spmm_kernel!(
    C,
    @Const(a_col_val),
    @Const(a_nz_val),
    @Const(a_slice_ptr),
    @Const(a_slice_size),
    @Const(B),
    @Const(n),
    @Const(α),
    @Const(β)
)
    # Computes A*B and stores the result in C
    col_B_C, row = @index(Global, NTuple)
    offset = (row-1) % a_slice_size
    slice = (row-1) ÷ a_slice_size + 1
    acc = zero(eltype(C))
    #if row <= n 
    for i = (a_slice_ptr[slice]+offset):a_slice_size:(a_slice_ptr[slice+1]-1)
        col_A = a_col_val[i]
        if col_A == -1
            break
        end
        acc += a_nz_val[i] * B[col_A, col_B_C]
    end
    if β == zero(β) # avoid reading C when β == 0, as C may be uninitialized
        C[row, col_B_C] = α * acc
    else
        C[row, col_B_C] = α * acc + C[row, col_B_C] * β
    end
end

function LinearAlgebra.mul!(
    C::ResMat,
    A::DeviceSparseMatrixSELL{Tv,Ti},
    B::InputMat,
    α::T1,
    β::T2,
) where {
    Tv,
    Ti<:Integer,
    ResType<:Number,
    InputType<:Number,
    ResMat<:AbstractMatrix{ResType},
    InputMat<:AbstractMatrix{InputType},
    T1<:Number,
    T2<:Number,
}
    size(A, 2) == size(B, 1) || throw(
        DimensionMismatch(
            "second dimension of A, $(size(A,2)), does not match the first dimension of B, $(size(B,1))",
        ),
    )
    size(A, 1) == size(C, 1) || throw(
        DimensionMismatch(
            "first dimension of A, $(size(A,1)), does not match the first dimension of C, $(size(C,1))",
        ),
    )
    size(B, 2) == size(C, 2) || throw(
        DimensionMismatch(
            "second dimension of B, $(size(B,2)), does not match the second dimension of C, $(size(C,2))",
        ),
    )
    promote_type(T1, T2, Tv, InputType) <: ResType || throw(
        ArgumentError(
            "element types of A, B, α, and β must be promotable to the element type of C - got $Tv, $InputType, $T1, $T2, and $(eltype(C))",
        ),
    )
    backend_C = get_backend(C)
    backend_A = get_backend(A)
    backend_B = get_backend(B)

    backend_A == backend_B == backend_C ||
        throw(ArgumentError("All arrays must have the same backend"))

    # Call the kernel
    kernel! = sell_spmm_kernel!(backend_A)
    kernel!(
        C,
        A.colval,
        A.nzval,
        A.slice_ptr,
        A.slice_size,
        B,
        A.n,
        α,
        β,
        ndrange = (size(B, 2), size(A, 1)),
    )

end

function LinearAlgebra.mul!(
    C::ResVec,
    A::DeviceSparseMatrixSELL{Tv,Ti},
    B::InputVec,
) where {
    Tv,
    Ti<:Integer,
    ResType<:Number,
    InputType<:Number,
    ResVec<:AbstractVector{ResType},
    InputVec<:AbstractVector{InputType},
}
    return mul!(C, A, B, one(ResType), zero(ResType))
end

@kernel function sell_dot_kernel!(
    C,
    @Const(a_col_val),
    @Const(a_nz_val),
    @Const(a_slice_ptr),
    @Const(a_slice_size),
    @Const(n),
    @Const(X),
    @Const(Y)
)
    # Compute the product C = X * (A * Y)
    row = @index(Global, Linear)
    slice = (row-1) ÷ a_slice_size + 1
    offset = (row-1) % a_slice_size
    #if row <= n 
    start = a_slice_ptr[slice] + offset
    stop = a_slice_ptr[slice+1] - 1
    acc = zero(eltype(C))
    for i = start:a_slice_size:stop
        col = a_col_val[i]
        if col == -1
            break
        end
        conj
        acc += dot(X[row], a_nz_val[i], Y[col])
    end
    C[row] = acc
    #end

end

# 3 argument dot product. TODO: make reduction in kernel to avoid intermediate results
function LinearAlgebra.dot(
    x::AbstractVector{Tx},
    A::DeviceSparseMatrixSELL{Tv,Ti},
    y::AbstractVector{Ty},
) where {Ty,Tv,Ti<:Integer,Tx}
    # x . (A*y)
    size(A, 1) == length(x) || throw(
        DimensionMismatch(
            "first dimension of A, $(size(A,1)), does not match the length of x, $(length(x))",
        ),
    )
    size(A, 2) == length(y) || throw(
        DimensionMismatch(
            "second dimension of A, $(size(A,2)), does not match the length of y, $(length(y))",
        ),
    )
    backend_x = get_backend(x)
    backend_A = get_backend(A)
    backend_y = get_backend(y)

    backend_A == backend_x == backend_y ||
        throw(ArgumentError("All arrays must have the same backend"))

    # Call the kernel
    temp_res = similar(x)
    kernel! = sell_dot_kernel!(backend_A)
    kernel!(
        temp_res,
        A.colval,
        A.nzval,
        A.slice_ptr,
        A.slice_size,
        A.n,
        x,
        y,
        ndrange = size(A, 1),
    )
    return sum(temp_res)
end
