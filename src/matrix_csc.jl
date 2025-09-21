# DeviceSparseMatrixCSC implementation

"""
    DeviceSparseMatrixCSC{Tv,Ti,ColPtrT<RowValT,NzValT} <: AbstractDeviceSparseMatrix{Tv,Ti}

Compressed Sparse Column (CSC) matrix with generic storage vectors for column
pointer, row indices, and nonzero values. Buffer types (e.g. `Vector`, GPU array
types) enable dispatch on device characteristics.

Fields:
  m::Int               - number of rows
  n::Int               - number of columns
  colptr::ColPtrT      - column pointer array (length n+1)
  rowval::RowValT      - row indices of stored entries
  nzval::NzValT        - stored values
"""
struct DeviceSparseMatrixCSC{
    Tv,
    Ti<:Integer,
    ColPtrT<:AbstractVector{Ti},
    RowValT<:AbstractVector{Ti},
    NzValT<:AbstractVector{Tv},
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
        ColPtrT<:AbstractVector{Ti},
        RowValT<:AbstractVector{Ti},
        NzValT<:AbstractVector{Tv},
    }
        get_backend(colptr) == get_backend(rowval) == get_backend(nzval) ||
            throw(ArgumentError("All storage vectors must be on the same device/backend."))

        m >= 0 || throw(ArgumentError("m must be non-negative"))
        n >= 0 || throw(ArgumentError("n must be non-negative"))
        SparseArrays.sparse_check_Ti(m, n, Ti)
        # SparseArrays.sparse_check(n, colptr, rowval, nzval) # TODO: this uses scalar indexing

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
    DeviceSparseMatrixCSC{Tv,Ti,ColPtrT,RowValT,NzValT}(m, n, colptr, rowval, nzval)
end

DeviceSparseMatrixCSC(A::SparseMatrixCSC) =
    DeviceSparseMatrixCSC(A.m, A.n, A.colptr, A.rowval, A.nzval)
SparseMatrixCSC(A::DeviceSparseMatrixCSC) =
    SparseMatrixCSC(A.m, A.n, collect(A.colptr), collect(A.rowval), collect(A.nzval))

@adapt_structure DeviceSparseMatrixCSC

Base.size(A::DeviceSparseMatrixCSC) = (A.m, A.n)
Base.length(A::DeviceSparseMatrixCSC) = A.m * A.n
Base.copy(A::DeviceSparseMatrixCSC) =
    DeviceSparseMatrixCSC(A.m, A.n, copy(A.colptr), copy(A.rowval), copy(A.nzval))

Base.collect(A::DeviceSparseMatrixCSC) = collect(SparseMatrixCSC(A))

function Base.:(*)(α::Number, A::DeviceSparseMatrixCSC)
    return DeviceSparseMatrixCSC(A.m, A.n, getcolptr(A), rowvals(A), α .* nonzeros(A))
end
Base.:(*)(A::DeviceSparseMatrixCSC, α::Number) = α * A
Base.:(/)(A::DeviceSparseMatrixCSC, α::Number) = (1 / α) * A # rdiv!(copy(A), α) (not supported on JLArray)

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
for (wrapa, transa, opa, unwrapa) in trans_adj_wrappers(:DeviceSparseMatrixCSC)
    for (wrapb, transb, opb, unwrapb) in trans_adj_wrappers(:DenseVecOrMat)
        TypeA = wrapa(:(T1))
        TypeB = wrapb(:(T2))
        TypeC = :(DenseVecOrMat{T3})

        kernel_spmatmul! = transa ? :kernel_spmatmul_T! : :kernel_spmatmul_N!

        indB = transb ? (i, j) -> :(($j, $i)) : (i, j) -> :(($i, $j)) # transpose indices

        @eval function LinearAlgebra.mul!(
            C::$TypeC,
            A::$TypeA,
            B::$TypeB,
            α::Number,
            β::Number,
        ) where {T1,T2,T3}
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

            promote_type(T2, T3, eltype(α), eltype(β)) <: T1 || throw(
                ArgumentError(
                    "element types of B, C, α, and β must be promotable to the element type of A",
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

            @kernel function kernel_spmatmul_N!(
                C,
                @Const(colptr),
                @Const(rowval),
                @Const(nzval),
                @Const(B)
            )
                k, col = @index(Global, NTuple)

                Bi, Bj = $(indB(:col, :k))

                @inbounds axj = $(opb(:(B[Bi, Bj]))) * α
                @inbounds for j = colptr[col]:(colptr[col+1]-1) # nzrange(A, col)
                    @atomic C[rowval[j], k] += $(opa(:(nzval[j]))) * axj
                end
            end

            @kernel function kernel_spmatmul_T!(
                C,
                @Const(colptr),
                @Const(rowval),
                @Const(nzval),
                @Const(B)
            )
                k, col = @index(Global, NTuple)

                tmp = zero(eltype(C))
                @inbounds for j = colptr[col]:(colptr[col+1]-1) # nzrange(A, col)
                    Bi, Bj = $(indB(:(rowval[j]), :k))
                    tmp += $(opa(:(nzval[j]))) * $(opb(:(B[Bi, Bj])))
                end
                @inbounds C[col, k] += tmp * α
            end

            β != one(β) && LinearAlgebra._rmul_or_fill!(C, β)

            kernel! = $kernel_spmatmul!(backend_A)
            kernel!(
                C,
                getcolptr(_A),
                getrowval(_A),
                getnzval(_A),
                _B;
                ndrange = (size(C, 2), size(_A, 2)),
            )

            return C
        end
    end
end
