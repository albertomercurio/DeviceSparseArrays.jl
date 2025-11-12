# DeviceSparseMatrixCOO implementation

"""
    DeviceSparseMatrixCOO{Tv,Ti,RowIndT<:AbstractVector,ColIndT<:AbstractVector,NzValT<:AbstractVector} <: AbstractDeviceSparseMatrix{Tv,Ti}

Coordinate (COO) sparse matrix with generic storage vectors for row indices,
column indices, and nonzero values. Buffer types (e.g. `Vector`, GPU array
types) enable dispatch on device characteristics.

# Fields
- `m::Int`               - number of rows
- `n::Int`               - number of columns
- `rowind::RowIndT`      - row indices of stored entries
- `colind::ColIndT`      - column indices of stored entries
- `nzval::NzValT`        - stored values
"""
struct DeviceSparseMatrixCOO{
    Tv,
    Ti<:Integer,
    RowIndT<:AbstractVector,
    ColIndT<:AbstractVector,
    NzValT<:AbstractVector,
} <: AbstractDeviceSparseMatrix{Tv,Ti}
    m::Int
    n::Int
    rowind::RowIndT
    colind::ColIndT
    nzval::NzValT
    function DeviceSparseMatrixCOO{Tv,Ti,RowIndT,ColIndT,NzValT}(
        m::Integer,
        n::Integer,
        rowind::RowIndT,
        colind::ColIndT,
        nzval::NzValT,
    ) where {
        Tv,
        Ti<:Integer,
        RowIndT<:AbstractVector,
        ColIndT<:AbstractVector,
        NzValT<:AbstractVector,
    }
        get_backend(rowind) == get_backend(colind) == get_backend(nzval) ||
            throw(ArgumentError("All storage vectors must be on the same device/backend."))

        m >= 0 || throw(ArgumentError("m must be non-negative"))
        n >= 0 || throw(ArgumentError("n must be non-negative"))
        SparseArrays.sparse_check_Ti(m, n, Ti)

        _check_type(Ti, rowind) || throw(ArgumentError("rowind must be of type $Ti"))
        _check_type(Ti, colind) || throw(ArgumentError("colind must be of type $Ti"))
        _check_type(Tv, nzval) || throw(ArgumentError("nzval must be of type $Tv"))

        length(rowind) == length(colind) == length(nzval) ||
            throw(ArgumentError("rowind, colind, and nzval must have same length"))

        return new(Int(m), Int(n), rowind, colind, nzval)
    end
end

function DeviceSparseMatrixCOO(
    m::Integer,
    n::Integer,
    rowind::RowIndT,
    colind::ColIndT,
    nzval::NzValT,
) where {
    RowIndT<:AbstractVector{Ti},
    ColIndT<:AbstractVector{Ti},
    NzValT<:AbstractVector{Tv},
} where {Ti<:Integer,Tv}
    Ti2 = _get_eltype(rowind)
    Tv2 = _get_eltype(nzval)
    DeviceSparseMatrixCOO{Tv2,Ti2,RowIndT,ColIndT,NzValT}(m, n, rowind, colind, nzval)
end

# Conversion from SparseMatrixCSC to COO
function DeviceSparseMatrixCOO(A::SparseMatrixCSC{Tv,Ti}) where {Tv,Ti}
    m, n = size(A)
    nnz_count = nnz(A)

    rowind = Vector{Ti}(undef, nnz_count)
    colind = Vector{Ti}(undef, nnz_count)
    nzval = Vector{Tv}(undef, nnz_count)

    idx = 1
    for col = 1:n
        for j in nzrange(A, col)
            rowind[idx] = rowvals(A)[j]
            colind[idx] = col
            nzval[idx] = nonzeros(A)[j]
            idx += 1
        end
    end

    return DeviceSparseMatrixCOO(m, n, rowind, colind, nzval)
end

# Conversion from DeviceSparseMatrixCSC to DeviceSparseMatrixCOO
"""
    DeviceSparseMatrixCOO(A::DeviceSparseMatrixCSC)

Convert a Compressed Sparse Column (CSC) matrix to Coordinate (COO) format.

The conversion preserves all matrix data and maintains backend compatibility.
The result will be on the same backend (CPU/GPU) as the input matrix.

# Examples
```julia
using DeviceSparseArrays, SparseArrays

# Create a CSC matrix
A_sparse = sparse([1, 2, 3], [1, 2, 3], [1.0, 2.0, 3.0], 3, 3)
A_csc = DeviceSparseMatrixCSC(A_sparse)

# Convert to COO format
A_coo = DeviceSparseMatrixCOO(A_csc)
```
"""
function DeviceSparseMatrixCOO(A::DeviceSparseMatrixCSC{Tv,Ti}) where {Tv,Ti}
    m, n = size(A)
    nnz_count = nnz(A)

    backend = get_backend(A.nzval)

    # Allocate output arrays on the same backend
    rowind = similar(A.rowval, Ti, nnz_count)
    colind = similar(A.rowval, Ti, nnz_count)
    nzval = similar(A.nzval, Tv, nnz_count)

    # Use kernel to convert CSC to COO
    kernel! = kernel_csc_to_coo!(backend)
    kernel!(rowind, colind, nzval, A.colptr, A.rowval, A.nzval; ndrange = (n,))

    return DeviceSparseMatrixCOO(m, n, rowind, colind, nzval)
end

# Conversion from COO to SparseMatrixCSC
function SparseMatrixCSC(A::DeviceSparseMatrixCOO)
    m, n = size(A)
    rowind = collect(A.rowind)
    colind = collect(A.colind)
    nzval = collect(A.nzval)

    return sparse(rowind, colind, nzval, m, n)
end

# Conversion from DeviceSparseMatrixCOO to DeviceSparseMatrixCSC
"""
    DeviceSparseMatrixCSC(A::DeviceSparseMatrixCOO)

Convert a Coordinate (COO) matrix to Compressed Sparse Column (CSC) format.

The conversion sorts the COO entries by column (then by row within each column)
and builds the column pointer structure. The result maintains backend compatibility
with the input matrix.

# Examples
```julia
using DeviceSparseArrays, SparseArrays

# Create a COO matrix
A_sparse = sparse([1, 2, 3], [1, 2, 3], [1.0, 2.0, 3.0], 3, 3)
A_coo = DeviceSparseMatrixCOO(A_sparse)

# Convert to CSC format
A_csc = DeviceSparseMatrixCSC(A_coo)
```
"""
function DeviceSparseMatrixCSC(A::DeviceSparseMatrixCOO{Tv,Ti}) where {Tv,Ti}
    m, n = size(A)
    nnz_count = nnz(A)

    backend = get_backend(A.nzval)

    # Create keys for sorting: column first, then row
    # We use n * rowind + colind to create a unique sortable key
    keys = similar(A.rowind, Ti, nnz_count)

    # Create keys on device
    @kernel inbounds=true function make_keys!(
        keys,
        @Const(rowind),
        @Const(colind),
        @Const(n)
    )
        i = @index(Global)
        keys[i] = colind[i] * n + rowind[i]
    end

    kernel! = make_keys!(backend)
    kernel!(keys, A.rowind, A.colind, n; ndrange = (nnz_count,))

    # Sort on device using AcceleratedKernels
    perm = AcceleratedKernels.sortperm(keys)

    # Apply permutation to get sorted arrays
    rowind_sorted = A.rowind[perm]
    colind_sorted = A.colind[perm]
    nzval_sorted = A.nzval[perm]

    # Build colptr on device using a histogram approach
    colptr = similar(A.colind, Ti, n + 1)
    fill!(colptr, zero(Ti))

    # Count entries per column
    @kernel inbounds=true function count_per_col!(colptr, @Const(colind_sorted))
        i = @index(Global)
        col = colind_sorted[i]
        @atomic colptr[col+1] += 1
    end

    kernel! = count_per_col!(backend)
    kernel!(colptr, colind_sorted; ndrange = (nnz_count,))

    # Set colptr[1] = 1
    if backend isa KernelAbstractions.CPU
        colptr[1] = 1
        # Compute cumulative sum
        for i = 2:(n+1)
            colptr[i] += colptr[i-1]
        end
    else
        # For non-CPU backends, use AcceleratedKernels scan
        colptr[1] = 1
        colptr[2:end] .= AcceleratedKernels.cumsum(colptr[2:end]) .+ 1
    end

    return DeviceSparseMatrixCSC(m, n, colptr, rowind_sorted, nzval_sorted)
end

# Conversion from DeviceSparseMatrixCOO to DeviceSparseMatrixCSR
"""
    DeviceSparseMatrixCSR(A::DeviceSparseMatrixCOO)

Convert a Coordinate (COO) matrix to Compressed Sparse Row (CSR) format.

The conversion sorts the COO entries by row (then by column within each row)
and builds the row pointer structure. The result maintains backend compatibility
with the input matrix.

# Examples
```julia
using DeviceSparseArrays, SparseArrays

# Create a COO matrix
A_sparse = sparse([1, 2, 3], [1, 2, 3], [1.0, 2.0, 3.0], 3, 3)
A_coo = DeviceSparseMatrixCOO(A_sparse)

# Convert to CSR format
A_csr = DeviceSparseMatrixCSR(A_coo)
```
"""
function DeviceSparseMatrixCSR(A::DeviceSparseMatrixCOO{Tv,Ti}) where {Tv,Ti}
    m, n = size(A)
    nnz_count = nnz(A)

    backend = get_backend(A.nzval)

    # Create keys for sorting: row first, then column
    # We use m * colind + rowind to create a unique sortable key
    keys = similar(A.rowind, Ti, nnz_count)

    # Create keys on device
    @kernel inbounds=true function make_keys!(
        keys,
        @Const(rowind),
        @Const(colind),
        @Const(m)
    )
        i = @index(Global)
        keys[i] = rowind[i] * m + colind[i]
    end

    kernel! = make_keys!(backend)
    kernel!(keys, A.rowind, A.colind, m; ndrange = (nnz_count,))

    # Sort on device using AcceleratedKernels
    perm = AcceleratedKernels.sortperm(keys)

    # Apply permutation to get sorted arrays
    rowind_sorted = A.rowind[perm]
    colind_sorted = A.colind[perm]
    nzval_sorted = A.nzval[perm]

    # Build rowptr on device using a histogram approach
    rowptr = similar(A.rowind, Ti, m + 1)
    fill!(rowptr, zero(Ti))

    # Count entries per row
    @kernel inbounds=true function count_per_row!(rowptr, @Const(rowind_sorted))
        i = @index(Global)
        row = rowind_sorted[i]
        @atomic rowptr[row+1] += 1
    end

    kernel! = count_per_row!(backend)
    kernel!(rowptr, rowind_sorted; ndrange = (nnz_count,))

    # Set rowptr[1] = 1
    if backend isa KernelAbstractions.CPU
        rowptr[1] = 1
        # Compute cumulative sum
        for i = 2:(m+1)
            rowptr[i] += rowptr[i-1]
        end
    else
        # For non-CPU backends, use AcceleratedKernels scan
        rowptr[1] = 1
        rowptr[2:end] .= AcceleratedKernels.cumsum(rowptr[2:end]) .+ 1
    end

    return DeviceSparseMatrixCSR(m, n, rowptr, colind_sorted, nzval_sorted)
end

# Conversion from DeviceSparseMatrixCSR to DeviceSparseMatrixCOO
"""
    DeviceSparseMatrixCOO(A::DeviceSparseMatrixCSR)

Convert a Compressed Sparse Row (CSR) matrix to Coordinate (COO) format.

The conversion preserves all matrix data and maintains backend compatibility.
The result will be on the same backend (CPU/GPU) as the input matrix.

# Examples
```julia
using DeviceSparseArrays, SparseArrays

# Create a CSR matrix
A_sparse = sparse([1, 2, 3], [1, 2, 3], [1.0, 2.0, 3.0], 3, 3)
A_csr = DeviceSparseMatrixCSR(A_sparse)

# Convert to COO format
A_coo = DeviceSparseMatrixCOO(A_csr)
```
"""
function DeviceSparseMatrixCOO(A::DeviceSparseMatrixCSR{Tv,Ti}) where {Tv,Ti}
    m, n = size(A)
    nnz_count = nnz(A)

    backend = get_backend(A.nzval)

    # Allocate output arrays on the same backend
    rowind = similar(A.colval, Ti, nnz_count)
    colind = similar(A.colval, Ti, nnz_count)
    nzval = similar(A.nzval, Tv, nnz_count)

    # Use kernel to convert CSR to COO
    kernel! = kernel_csr_to_coo!(backend)
    kernel!(rowind, colind, nzval, A.rowptr, A.colval, A.nzval; ndrange = (m,))

    return DeviceSparseMatrixCOO(m, n, rowind, colind, nzval)
end

Adapt.adapt_structure(to, A::DeviceSparseMatrixCOO) = DeviceSparseMatrixCOO(
    A.m,
    A.n,
    Adapt.adapt_structure(to, A.rowind),
    Adapt.adapt_structure(to, A.colind),
    Adapt.adapt_structure(to, A.nzval),
)

Base.size(A::DeviceSparseMatrixCOO) = (A.m, A.n)
Base.length(A::DeviceSparseMatrixCOO) = A.m * A.n
Base.copy(A::DeviceSparseMatrixCOO) =
    DeviceSparseMatrixCOO(A.m, A.n, copy(A.rowind), copy(A.colind), copy(A.nzval))

Base.collect(A::DeviceSparseMatrixCOO) = collect(SparseMatrixCSC(A))

function Base.zero(A::DeviceSparseMatrixCOO)
    rowind = similar(A.rowind, 0)
    colind = similar(A.colind, 0)
    nzval = similar(A.nzval, 0)
    return DeviceSparseMatrixCOO(A.m, A.n, rowind, colind, nzval)
end

function Base.:(*)(α::Number, A::DeviceSparseMatrixCOO)
    return DeviceSparseMatrixCOO(
        A.m,
        A.n,
        copy(getrowind(A)),
        copy(getcolind(A)),
        α .* nonzeros(A),
    )
end
Base.:(*)(A::DeviceSparseMatrixCOO, α::Number) = α * A
Base.:(/)(A::DeviceSparseMatrixCOO, α::Number) = (1 / α) * A

function Base.:-(A::DeviceSparseMatrixCOO)
    return DeviceSparseMatrixCOO(A.m, A.n, copy(A.rowind), copy(A.colind), -A.nzval)
end

Base.conj(A::DeviceSparseMatrixCOO{<:Real}) = A
function Base.conj(A::DeviceSparseMatrixCOO{<:Complex})
    return DeviceSparseMatrixCOO(A.m, A.n, copy(A.rowind), copy(A.colind), conj.(A.nzval))
end

Base.real(A::DeviceSparseMatrixCOO{<:Real}) = A
function Base.real(A::DeviceSparseMatrixCOO{<:Complex})
    return DeviceSparseMatrixCOO(A.m, A.n, copy(A.rowind), copy(A.colind), real.(A.nzval))
end

Base.imag(A::DeviceSparseMatrixCOO{<:Real}) = zero(A)
function Base.imag(A::DeviceSparseMatrixCOO{<:Complex})
    return DeviceSparseMatrixCOO(A.m, A.n, copy(A.rowind), copy(A.colind), imag.(A.nzval))
end

SparseArrays.nonzeros(A::DeviceSparseMatrixCOO) = A.nzval
getrowind(A::DeviceSparseMatrixCOO) = A.rowind
getcolind(A::DeviceSparseMatrixCOO) = A.colind
SparseArrays.getnzval(A::DeviceSparseMatrixCOO) = nonzeros(A)

function LinearAlgebra.tr(A::DeviceSparseMatrixCOO)
    m, n = size(A)
    m == n || throw(DimensionMismatch("Matrix must be square to compute the trace."))

    backend = get_backend(A)

    @kernel function kernel_tr(res, @Const(rowind), @Const(colind), @Const(nzval))
        i = @index(Global)

        @inbounds if rowind[i] == colind[i]
            @atomic res[1] += nzval[i]
        end
    end

    res = similar(nonzeros(A), 1)
    fill!(res, zero(eltype(A)))

    kernel = kernel_tr(backend)
    kernel(res, getrowind(A), getcolind(A), nonzeros(A); ndrange = (length(nonzeros(A)),))

    return allowed_getindex(res, 1)
end

# Matrix-Vector and Matrix-Matrix multiplication
for (wrapa, transa, conja, unwrapa, whereT1) in trans_adj_wrappers(:DeviceSparseMatrixCOO)
    for (wrapb, transb, conjb, unwrapb, whereT2) in trans_adj_wrappers(:DenseVecOrMat)
        TypeA = wrapa(:(T1))
        TypeB = wrapb(:(T2))
        TypeC = :(DenseVecOrMat{T3})

        kernel_spmatmul! = transa ? :kernel_spmatmul_coo_T! : :kernel_spmatmul_coo_N!

        @eval function LinearAlgebra.mul!(
            C::$TypeC,
            A::$TypeA,
            B::$TypeB,
            α::Number,
            β::Number,
        ) where {$(whereT1(:T1)),$(whereT2(:T2)),T3}
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

            promote_type(T1, T2, eltype(α), eltype(β)) <: T3 || throw(
                ArgumentError(
                    "element types of A, B, α, and β must be promotable to the element type of C",
                ),
            )

            _A = $(unwrapa(:A))
            _B = $(unwrapb(:B))

            backend_C = get_backend(C)
            backend_A = get_backend(_A)
            backend_B = get_backend(_B)

            backend_A == backend_B == backend_C ||
                throw(ArgumentError("All arrays must have the same backend"))

            β != one(β) && LinearAlgebra._rmul_or_fill!(C, β)

            kernel! = $kernel_spmatmul!(backend_A)
            kernel!(
                C,
                getrowind(_A),
                getcolind(_A),
                getnzval(_A),
                _B,
                α,
                Val{$conja}(),
                Val{$conjb}(),
                Val{$transb}();
                ndrange = (size(C, 2), length(nonzeros(_A))),
            )

            return C
        end
    end
end

# Three-argument dot product: dot(x, A, y) = x' * A * y
for (wrapa, transa, conja, unwrapa, whereT1) in trans_adj_wrappers(:DeviceSparseMatrixCOO)
    TypeA = wrapa(:(T1))

    kernel_dot! = transa ? :kernel_workgroup_dot_coo_T! : :kernel_workgroup_dot_coo_N!

    @eval function LinearAlgebra.dot(
        x::AbstractVector{T2},
        A::$TypeA,
        y::AbstractVector{T3},
    ) where {$(whereT1(:T1)),T2,T3}
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

        _A = $(unwrapa(:A))

        backend_x = get_backend(x)
        backend_A = get_backend(_A)
        backend_y = get_backend(y)

        backend_x == backend_A == backend_y ||
            throw(ArgumentError("All arrays must have the same backend"))

        T = promote_type(T1, T2, T3)

        nnz_val = nnz(_A)
        rowind = getrowind(_A)
        colind = getcolind(_A)
        nzval = getnzval(_A)

        backend = backend_A

        group_size = 256
        n_groups = min(cld(nnz_val, group_size), 256)
        total_workitems = group_size * n_groups

        # Allocate array for block results (one per workgroup)
        block_results = similar(nzval, T, n_groups)

        # Launch kernel with workgroup configuration
        kernel! = $kernel_dot!(backend, group_size)
        kernel!(
            block_results,
            x,
            rowind,
            colind,
            nzval,
            y,
            nnz_val,
            Val{$conja}();
            ndrange = (total_workitems,),
        )

        # Final reduction: sum all block results
        return sum(block_results)
    end
end

# Helper function for adding DeviceSparseMatrixCOO to dense matrix
function _add_sparse_to_dense!(C::DenseMatrix, A::DeviceSparseMatrixCOO)
    backend = get_backend(A)
    nnz_val = nnz(A)

    kernel! = kernel_add_sparse_to_dense_coo!(backend)
    kernel!(C, getrowind(A), getcolind(A), getnzval(A); ndrange = (nnz_val,))

    return C
end
