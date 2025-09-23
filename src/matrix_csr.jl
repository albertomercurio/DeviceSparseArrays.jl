# DeviceSparseMatrixCSR implementation

"""
    DeviceSparseMatrixCSR{Tv,Ti,RowPtrT<:ColValT,NzValT} <: AbstractDeviceSparseMatrix{Tv,Ti}

Compressed Sparse Row (CSR) matrix with generic storage vectors for row
pointer, column indices, and nonzero values. Buffer types (e.g. `Vector`, GPU array
types) enable dispatch on device characteristics.

Fields:
  m::Int               - number of rows
  n::Int               - number of columns
  rowptr::RowPtrT      - row pointer array (length m+1)
  colval::ColValT      - column indices of stored entries
  nzval::NzValT        - stored values
"""
struct DeviceSparseMatrixCSR{
    Tv,
    Ti<:Integer,
    RowPtrT<:AbstractVector,
    ColValT<:AbstractVector,
    NzValT<:AbstractVector,
} <: AbstractDeviceSparseMatrix{Tv,Ti}
    m::Int
    n::Int
    rowptr::RowPtrT
    colval::ColValT
    nzval::NzValT
    function DeviceSparseMatrixCSR{Tv,Ti,RowPtrT,ColValT,NzValT}(
        m::Integer,
        n::Integer,
        rowptr::RowPtrT,
        colval::ColValT,
        nzval::NzValT,
    ) where {
        Tv,
        Ti<:Integer,
        RowPtrT<:AbstractVector,
        ColValT<:AbstractVector,
        NzValT<:AbstractVector,
    }
        get_backend(rowptr) == get_backend(colval) == get_backend(nzval) ||
            throw(ArgumentError("All storage vectors must be on the same device/backend."))

        m >= 0 || throw(ArgumentError("m must be non-negative"))
        n >= 0 || throw(ArgumentError("n must be non-negative"))
        SparseArrays.sparse_check_Ti(m, n, Ti)
        # SparseArrays.sparse_check(m, rowptr, colval, nzval) # TODO: this uses scalar indexing

        _check_type(Ti, rowptr) || throw(ArgumentError("rowptr must be of type $Ti"))
        _check_type(Ti, colval) || throw(ArgumentError("colval must be of type $Ti"))
        _check_type(Tv, nzval) || throw(ArgumentError("nzval must be of type $Tv"))

        length(rowptr) == m + 1 || throw(ArgumentError("rowptr length must be m+1"))
        length(colval) == length(nzval) ||
            throw(ArgumentError("colval and nzval must have same length"))

        return new(Int(m), Int(n), rowptr, colval, nzval)
    end
end

function DeviceSparseMatrixCSR(
    m::Integer,
    n::Integer,
    rowptr::RowPtrT,
    colval::ColValT,
    nzval::NzValT,
) where {
    RowPtrT<:AbstractVector{Ti},
    ColValT<:AbstractVector{Ti},
    NzValT<:AbstractVector{Tv},
} where {Ti<:Integer,Tv}
    Ti2 = _get_eltype(rowptr)
    Tv2 = _get_eltype(nzval)
    DeviceSparseMatrixCSR{Tv2,Ti2,RowPtrT,ColValT,NzValT}(m, n, rowptr, colval, nzval)
end

function DeviceSparseMatrixCSR(A::Transpose{Tv,<:SparseMatrixCSC}) where {Tv}
    At = A.parent
    DeviceSparseMatrixCSR(size(A, 1), size(A, 2), At.colptr, rowvals(At), nonzeros(At))
end

# Conversion functions between CSC and CSR
function DeviceSparseMatrixCSR(A::SparseMatrixCSC)
    # TODO: Implement a direct CSC to CSR conversion without going through transposition
    At = transpose(A)
    At_sparse = transpose(SparseMatrixCSC(At))
    return DeviceSparseMatrixCSR(At_sparse)
end

function SparseMatrixCSC(A::DeviceSparseMatrixCSR)
    # Convert CSR to CSC by creating transposed CSC and then transposing back
    At_csc =
        SparseMatrixCSC(A.n, A.m, collect(A.rowptr), collect(A.colval), collect(A.nzval))
    return SparseMatrixCSC(transpose(At_csc))
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
for (wrapa, transa, opa, unwrapa) in trans_adj_wrappers(:DeviceSparseMatrixCSR)
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

            @kernel function kernel_spmatmul_N!(
                C,
                @Const(rowptr),
                @Const(colval),
                @Const(nzval),
                @Const(B)
            )
                k, row = @index(Global, NTuple)

                tmp = zero(eltype(C))
                @inbounds for j = rowptr[row]:(rowptr[row+1]-1) # nzrange(A, row)
                    Bi, Bj = $(indB(:(colval[j]), :k))
                    tmp += $(opa(:(nzval[j]))) * $(opb(:(B[Bi, Bj])))
                end
                @inbounds C[row, k] += tmp * α
            end

            @kernel function kernel_spmatmul_T!(
                C,
                @Const(rowptr),
                @Const(colval),
                @Const(nzval),
                @Const(B)
            )
                k, row = @index(Global, NTuple)

                Bi, Bj = $(indB(:row, :k))

                @inbounds axj = $(opb(:(B[Bi, Bj]))) * α
                @inbounds for j = rowptr[row]:(rowptr[row+1]-1) # nzrange(A, row)
                    @atomic C[colval[j], k] += $(opa(:(nzval[j]))) * axj
                end
            end

            β != one(β) && LinearAlgebra._rmul_or_fill!(C, β)

            kernel! = $kernel_spmatmul!(backend_A)
            kernel!(
                C,
                getrowptr(_A),
                getcolval(_A),
                getnzval(_A),
                _B;
                ndrange = (size(C, 2), size(_A, 1)),
            )

            return C
        end
    end
end
