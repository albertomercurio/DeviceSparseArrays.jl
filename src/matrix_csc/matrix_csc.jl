# DeviceSparseMatrixCSC implementation

"""
    DeviceSparseMatrixCSC{Tv,Ti,ColPtrT<RowValT,NzValT} <: AbstractDeviceSparseMatrix{Tv,Ti}

Compressed Sparse Column (CSC) matrix with generic storage vectors for column
pointer, row indices, and nonzero values. Buffer types (e.g. `Vector`, GPU array
types) enable dispatch on device characteristics.

# Fields
- `m::Int`               - number of rows
- `n::Int`               - number of columns
- `colptr::ColPtrT`      - column pointer array (length n+1)
- `rowval::RowValT`      - row indices of stored entries
- `nzval::NzValT`        - stored values
"""
struct DeviceSparseMatrixCSC{
    Tv,
    Ti<:Integer,
    ColPtrT<:AbstractVector,
    RowValT<:AbstractVector,
    NzValT<:AbstractVector,
} <: AbstractDeviceSparseMatrix{Tv,Ti}
    m::Int
    n::Int
    colptr::ColPtrT
    rowval::RowValT
    nzval::NzValT
    function DeviceSparseMatrixCSC{Tv,Ti,ColPtrT,RowValT,NzValT}(
        m::Integer,
        n::Integer,
        colptr::ColPtrT,
        rowval::RowValT,
        nzval::NzValT,
    ) where {
        Tv,
        Ti<:Integer,
        ColPtrT<:AbstractVector,
        RowValT<:AbstractVector,
        NzValT<:AbstractVector,
    }
        get_backend(colptr) == get_backend(rowval) == get_backend(nzval) ||
            throw(ArgumentError("All storage vectors must be on the same device/backend."))

        m >= 0 || throw(ArgumentError("m must be non-negative"))
        n >= 0 || throw(ArgumentError("n must be non-negative"))
        SparseArrays.sparse_check_Ti(m, n, Ti)
        # SparseArrays.sparse_check(n, colptr, rowval, nzval) # TODO: this uses scalar indexing

        _check_type(Ti, colptr) || throw(ArgumentError("colptr must be of type $Ti"))
        _check_type(Ti, rowval) || throw(ArgumentError("rowval must be of type $Ti"))
        _check_type(Tv, nzval) || throw(ArgumentError("nzval must be of type $Tv"))

        length(colptr) == n + 1 || throw(ArgumentError("colptr length must be n+1"))
        length(rowval) == length(nzval) ||
            throw(ArgumentError("rowval and nzval must have same length"))

        return new(Int(m), Int(n), colptr, rowval, nzval)
    end
end

function DeviceSparseMatrixCSC(
    m::Integer,
    n::Integer,
    colptr::ColPtrT,
    rowval::RowValT,
    nzval::NzValT,
) where {
    ColPtrT<:AbstractVector{Ti},
    RowValT<:AbstractVector{Ti},
    NzValT<:AbstractVector{Tv},
} where {Ti<:Integer,Tv}
    Ti2 = _get_eltype(colptr)
    Tv2 = _get_eltype(nzval)
    DeviceSparseMatrixCSC{Tv2,Ti2,ColPtrT,RowValT,NzValT}(m, n, colptr, rowval, nzval)
end

DeviceSparseMatrixCSC(A::SparseMatrixCSC) =
    DeviceSparseMatrixCSC(A.m, A.n, A.colptr, A.rowval, A.nzval)
SparseMatrixCSC(A::DeviceSparseMatrixCSC) =
    SparseMatrixCSC(A.m, A.n, collect(A.colptr), collect(A.rowval), collect(A.nzval))

Adapt.adapt_structure(to, A::DeviceSparseMatrixCSC) = DeviceSparseMatrixCSC(
    A.m,
    A.n,
    Adapt.adapt_structure(to, A.colptr),
    Adapt.adapt_structure(to, A.rowval),
    Adapt.adapt_structure(to, A.nzval),
)

Base.size(A::DeviceSparseMatrixCSC) = (A.m, A.n)
Base.length(A::DeviceSparseMatrixCSC) = A.m * A.n
Base.copy(A::DeviceSparseMatrixCSC) =
    DeviceSparseMatrixCSC(A.m, A.n, copy(A.colptr), copy(A.rowval), copy(A.nzval))

Base.collect(A::DeviceSparseMatrixCSC) = collect(SparseMatrixCSC(A))

function Base.zero(A::DeviceSparseMatrixCSC)
    colptr = similar(A.colptr)
    rowval = similar(A.rowval, 0)
    nzval = similar(A.nzval, 0)
    fill!(colptr, one(eltype(colptr)))
    return DeviceSparseMatrixCSC(A.m, A.n, colptr, rowval, nzval)
end

function Base.:(*)(α::Number, A::DeviceSparseMatrixCSC)
    return DeviceSparseMatrixCSC(
        A.m,
        A.n,
        copy(getcolptr(A)),
        copy(rowvals(A)),
        α .* nonzeros(A),
    )
end
Base.:(*)(A::DeviceSparseMatrixCSC, α::Number) = α * A
Base.:(/)(A::DeviceSparseMatrixCSC, α::Number) = (1 / α) * A

function Base.:-(A::DeviceSparseMatrixCSC)
    return DeviceSparseMatrixCSC(A.m, A.n, copy(A.colptr), copy(A.rowval), -A.nzval)
end

Base.conj(A::DeviceSparseMatrixCSC{<:Real}) = A
function Base.conj(A::DeviceSparseMatrixCSC{<:Complex})
    return DeviceSparseMatrixCSC(A.m, A.n, copy(A.colptr), copy(A.rowval), conj.(A.nzval))
end

Base.real(A::DeviceSparseMatrixCSC{<:Real}) = A
function Base.real(A::DeviceSparseMatrixCSC{<:Complex})
    return DeviceSparseMatrixCSC(A.m, A.n, copy(A.colptr), copy(A.rowval), real.(A.nzval))
end

Base.imag(A::DeviceSparseMatrixCSC{<:Real}) = zero(A)
function Base.imag(A::DeviceSparseMatrixCSC{<:Complex})
    return DeviceSparseMatrixCSC(A.m, A.n, copy(A.colptr), copy(A.rowval), imag.(A.nzval))
end

SparseArrays.nonzeros(A::DeviceSparseMatrixCSC) = A.nzval
SparseArrays.getcolptr(A::DeviceSparseMatrixCSC) = A.colptr
SparseArrays.rowvals(A::DeviceSparseMatrixCSC) = A.rowval
SparseArrays.getrowval(A::DeviceSparseMatrixCSC) = rowvals(A)
function SparseArrays.nzrange(A::DeviceSparseMatrixCSC, col::Integer)
    get_backend(A) isa KernelAbstractions.CPU ||
        throw(ArgumentError("nzrange is only supported on CPU backend"))
    return getcolptr(A)[col]:(getcolptr(A)[col+1]-1)
end

function LinearAlgebra.tr(A::DeviceSparseMatrixCSC)
    m, n = size(A)
    m == n || throw(DimensionMismatch("Matrix must be square to compute the trace."))

    # TODO: use AK.mapreduce instead?
    backend = get_backend(A)

    @kernel function kernel_tr(res, @Const(colptr), @Const(rowval), @Const(nzval))
        col = @index(Global)

        @inbounds for j = colptr[col]:(colptr[col+1]-1)
            if rowval[j] == col
                @atomic res[1] += nzval[j]
            end
        end
    end

    res = similar(nonzeros(A), 1)
    fill!(res, zero(eltype(A)))

    kernel = kernel_tr(backend)
    kernel(res, getcolptr(A), getrowval(A), getnzval(A); ndrange = (n,))

    return allowed_getindex(res, 1)
end

# Matrix-Vector and Matrix-Matrix multiplication
for (wrapa, transa, conja, unwrapa, whereT1) in trans_adj_wrappers(:DeviceSparseMatrixCSC)
    for (wrapb, transb, conjb, unwrapb, whereT2) in trans_adj_wrappers(:DenseVecOrMat)
        TypeA = wrapa(:(T1))
        TypeB = wrapb(:(T2))
        TypeC = :(DenseVecOrMat{T3})

        kernel_spmatmul! = transa ? :kernel_spmatmul_csc_T! : :kernel_spmatmul_csc_N!

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

            # backend_A isa KernelAbstractions.CPU &&
            #     return SparseArrays._spmatmul!(C, _A, _B, α, β)

            β != one(β) && LinearAlgebra._rmul_or_fill!(C, β)

            kernel! = $kernel_spmatmul!(backend_A)
            kernel!(
                C,
                getcolptr(_A),
                getrowval(_A),
                getnzval(_A),
                _B,
                α,
                Val{$conja}(),
                Val{$conjb}(),
                Val{$transb}();
                ndrange = (size(C, 2), size(_A, 2)),
            )

            return C
        end
    end
end

# Three-argument dot product: dot(x, A, y) = x' * A * y
for (wrapa, transa, conja, unwrapa, whereT1) in trans_adj_wrappers(:DeviceSparseMatrixCSC)
    TypeA = wrapa(:(T1))

    kernel_dot! = transa ? :kernel_workgroup_dot_csc_T! : :kernel_workgroup_dot_csc_N!

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

        n = size(_A, 2)
        colptr = getcolptr(_A)
        rowval = getrowval(_A)
        nzval = getnzval(_A)

        backend = backend_A

        group_size = 256
        n_groups = min(cld(n, group_size), 256)
        total_workitems = group_size * n_groups

        # Allocate array for block results (one per workgroup)
        block_results = similar(nzval, T, n_groups)

        # Launch kernel with workgroup configuration
        kernel! = $kernel_dot!(backend, group_size)
        kernel!(
            block_results,
            x,
            colptr,
            rowval,
            nzval,
            y,
            n,
            Val{$conja}();
            ndrange = (total_workitems,),
        )

        # Final reduction: sum all block results
        return sum(block_results)
    end
end

# Helper function for adding DeviceSparseMatrixCSC to dense matrix
function _add_sparse_to_dense!(C::DenseMatrix, A::DeviceSparseMatrixCSC)
    backend = get_backend(A)
    n = size(A, 2)

    kernel! = kernel_add_sparse_to_dense_csc!(backend)
    kernel!(C, getcolptr(A), getrowval(A), getnzval(A); ndrange = (n,))

    return C
end
