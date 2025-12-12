# DeviceSparseMatrixCSR implementation

"""
    DeviceSparseMatrixCSR{Tv,Ti,RowPtrT,ColValT,NzValT} <: AbstractDeviceSparseMatrix{Tv,Ti}

Compressed Sparse Row (CSR) matrix with generic storage vectors for row
pointer, column indices, and nonzero values. Buffer types (e.g. `Vector`, GPU array
types) enable dispatch on device characteristics.

# Fields
- `m::Int`               - number of rows
- `n::Int`               - number of columns
- `rowptr::RowPtrT`      - row pointer array (length m+1)
- `colval::ColValT`      - column indices of stored entries
- `nzval::NzValT`        - stored values
"""
struct DeviceSparseMatrixCSR{
    Tv,
    Ti,
    RowPtrT<:AbstractVector{Ti},
    ColValT<:AbstractVector{Ti},
    NzValT<:AbstractVector{Tv},
} <: AbstractDeviceSparseMatrix{Tv,Ti}
    m::Int
    n::Int
    rowptr::RowPtrT
    colval::ColValT
    nzval::NzValT

    function DeviceSparseMatrixCSR(
        m::Integer,
        n::Integer,
        rowptr::RowPtrT,
        colval::ColValT,
        nzval::NzValT,
    ) where {
        Tv,
        Ti,
        RowPtrT<:AbstractVector{Ti},
        ColValT<:AbstractVector{Ti},
        NzValT<:AbstractVector{Tv},
    }
        get_backend(rowptr) == get_backend(colval) == get_backend(nzval) ||
            throw(ArgumentError("All storage vectors must be on the same device/backend."))

        m >= 0 || throw(ArgumentError("m must be non-negative"))
        n >= 0 || throw(ArgumentError("n must be non-negative"))
        SparseArrays.sparse_check_Ti(m, n, Ti)
        # SparseArrays.sparse_check(m, rowptr, colval, nzval) # TODO: this uses scalar indexing

        length(rowptr) == m + 1 || throw(ArgumentError("rowptr length must be m+1"))
        length(colval) == length(nzval) ||
            throw(ArgumentError("colval and nzval must have same length"))

        return new{Tv,Ti,RowPtrT,ColValT,NzValT}(
            Int(m),
            Int(n),
            copy(rowptr),
            copy(colval),
            copy(nzval),
        )
    end
end

Adapt.adapt_structure(to, A::DeviceSparseMatrixCSR) = DeviceSparseMatrixCSR(
    A.m,
    A.n,
    Adapt.adapt_structure(to, A.rowptr),
    Adapt.adapt_structure(to, A.colval),
    Adapt.adapt_structure(to, A.nzval),
)

Base.size(A::DeviceSparseMatrixCSR) = (A.m, A.n)
Base.length(A::DeviceSparseMatrixCSR) = A.m * A.n
Base.copy(A::DeviceSparseMatrixCSR) =
    DeviceSparseMatrixCSR(A.m, A.n, copy(A.rowptr), copy(A.colval), copy(A.nzval))

Base.collect(A::DeviceSparseMatrixCSR) = collect(SparseMatrixCSC(A))

function Base.zero(A::DeviceSparseMatrixCSR)
    rowptr = similar(A.rowptr)
    rowval = similar(A.colval, 0)
    nzval = similar(A.nzval, 0)
    fill!(rowptr, one(eltype(rowptr)))
    return DeviceSparseMatrixCSR(A.m, A.n, rowptr, rowval, nzval)
end

function Base.:(*)(α::Number, A::DeviceSparseMatrixCSR)
    return DeviceSparseMatrixCSR(
        A.m,
        A.n,
        copy(getrowptr(A)),
        copy(colvals(A)),
        α .* nonzeros(A),
    )
end
Base.:(*)(A::DeviceSparseMatrixCSR, α::Number) = α * A
Base.:(/)(A::DeviceSparseMatrixCSR, α::Number) = (1 / α) * A

function Base.:-(A::DeviceSparseMatrixCSR)
    return DeviceSparseMatrixCSR(A.m, A.n, copy(A.rowptr), copy(A.colval), -A.nzval)
end

Base.conj(A::DeviceSparseMatrixCSR{<:Real}) = A
function Base.conj(A::DeviceSparseMatrixCSR{<:Complex})
    return DeviceSparseMatrixCSR(A.m, A.n, copy(A.rowptr), copy(A.colval), conj.(A.nzval))
end

Base.real(A::DeviceSparseMatrixCSR{<:Real}) = A
function Base.real(A::DeviceSparseMatrixCSR{<:Complex})
    return DeviceSparseMatrixCSR(A.m, A.n, copy(A.rowptr), copy(A.colval), real.(A.nzval))
end

Base.imag(A::DeviceSparseMatrixCSR{<:Real}) = zero(A)
function Base.imag(A::DeviceSparseMatrixCSR{<:Complex})
    return DeviceSparseMatrixCSR(A.m, A.n, copy(A.rowptr), copy(A.colval), imag.(A.nzval))
end

SparseArrays.nonzeros(A::DeviceSparseMatrixCSR) = A.nzval
getrowptr(A::DeviceSparseMatrixCSR) = A.rowptr
colvals(A::DeviceSparseMatrixCSR) = A.colval
getcolval(A::DeviceSparseMatrixCSR) = colvals(A)
SparseArrays.getnzval(A::DeviceSparseMatrixCSR) = nonzeros(A)
function SparseArrays.nzrange(A::DeviceSparseMatrixCSR, row::Integer)
    get_backend(A) isa KernelAbstractions.CPU ||
        throw(ArgumentError("nzrange is only supported on CPU backend"))
    return getrowptr(A)[row]:(getrowptr(A)[row+1]-1)
end

function LinearAlgebra.tr(A::DeviceSparseMatrixCSR)
    m, n = size(A)
    m == n || throw(DimensionMismatch("Matrix must be square to compute the trace."))

    # TODO: use AK.mapreduce instead?
    backend = get_backend(A)

    @kernel function kernel_tr(res, @Const(rowptr), @Const(colval), @Const(nzval))
        row = @index(Global)

        @inbounds for j = rowptr[row]:(rowptr[row+1]-1)
            if colval[j] == row
                @atomic res[1] += nzval[j]
            end
        end
    end

    res = similar(nonzeros(A), 1)
    fill!(res, zero(eltype(A)))

    kernel = kernel_tr(backend)
    kernel(res, getrowptr(A), getcolval(A), nonzeros(A); ndrange = (m,))

    return allowed_getindex(res, 1)
end

# Matrix-Vector and Matrix-Matrix multiplication
for (wrapa, transa, conja, unwrapa, whereT1) in trans_adj_wrappers(:DeviceSparseMatrixCSR)
    for (wrapb, transb, conjb, unwrapb, whereT2) in trans_adj_wrappers(:DenseVecOrMat)
        TypeA = wrapa(:(T1))
        TypeB = wrapb(:(T2))
        TypeC = :(DenseVecOrMat{T3})

        kernel_spmatmul! = transa ? :kernel_spmatmul_csr_T! : :kernel_spmatmul_csr_N!

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
                getrowptr(_A),
                getcolval(_A),
                getnzval(_A),
                _B,
                α,
                Val{$conja}(),
                Val{$conjb}(),
                Val{$transb}();
                ndrange = (size(C, 2), size(_A, 1)),
            )

            return C
        end
    end
end

# Three-argument dot product: dot(x, A, y) = x' * A * y
for (wrapa, transa, conja, unwrapa, whereT1) in trans_adj_wrappers(:DeviceSparseMatrixCSR)
    TypeA = wrapa(:(T1))

    kernel_dot! = transa ? :kernel_workgroup_dot_csr_T! : :kernel_workgroup_dot_csr_N!

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

        m = size(_A, 1)
        rowptr = getrowptr(_A)
        colval = getcolval(_A)
        nzval = getnzval(_A)

        backend = backend_A

        group_size = 256
        n_groups = min(cld(m, group_size), 256)
        total_workitems = group_size * n_groups

        # Allocate array for block results (one per workgroup)
        block_results = similar(nzval, T, n_groups)

        # Launch kernel with workgroup configuration
        kernel! = $kernel_dot!(backend, group_size)
        kernel!(
            block_results,
            x,
            rowptr,
            colval,
            nzval,
            y,
            m,
            Val{$conja}();
            ndrange = (total_workitems,),
        )

        # Final reduction: sum all block results
        return sum(block_results)
    end
end

# Helper function for adding DeviceSparseMatrixCSR to dense matrix
function _add_sparse_to_dense!(C::DenseMatrix, A::DeviceSparseMatrixCSR)
    backend = get_backend(A)
    m = size(A, 1)

    kernel! = kernel_add_sparse_to_dense_csr!(backend)
    kernel!(C, getrowptr(A), getcolval(A), getnzval(A); ndrange = (m,))

    return C
end

"""
    kron(A::DeviceSparseMatrixCSR, B::DeviceSparseMatrixCSR)

Compute the Kronecker product of two sparse matrices in CSR format.

The Kronecker product is computed by converting to COO format, computing the 
product, and converting back to CSR format.

# Examples
```jldoctest
julia> using DeviceSparseArrays, SparseArrays

julia> A_coo = DeviceSparseMatrixCOO(sparse([1, 2], [1, 2], [1.0, 2.0], 2, 2));

julia> B_coo = DeviceSparseMatrixCOO(sparse([1, 2], [1, 2], [3.0, 4.0], 2, 2));

julia> A = DeviceSparseMatrixCSR(A_coo);

julia> B = DeviceSparseMatrixCSR(B_coo);

julia> C = kron(A, B);

julia> size(C)
(4, 4)

julia> nnz(C)
4
```
"""
function LinearAlgebra.kron(A::DeviceSparseMatrixCSR, B::DeviceSparseMatrixCSR)
    # Convert to COO, compute kron, convert back to CSR
    A_coo = DeviceSparseMatrixCOO(A)
    B_coo = DeviceSparseMatrixCOO(B)
    C_coo = kron(A_coo, B_coo)
    return DeviceSparseMatrixCSR(C_coo)
end
