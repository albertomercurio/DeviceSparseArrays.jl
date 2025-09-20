# DeviceSparseMatrixCSC implementation

"""
    DeviceSparseMatrixCSC{Tv,Ti,ColPtrT<RowValT,NzValT} <: AbstractDeviceSparseMatrixCSC{Tv,Ti}

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
        m >= 0 || throw(ArgumentError("m must be non-negative"))
        n >= 0 || throw(ArgumentError("n must be non-negative"))
        length(colptr) == n + 1 || throw(ArgumentError("colptr length must be n+1"))
        length(rowval) == length(nzval) ||
            throw(ArgumentError("rowval and nzval must have same length"))
        nnz = length(nzval)
        first(colptr) == one(Ti) || throw(ArgumentError("colptr[1] must be 1"))
        last(colptr) == nnz + 1 || throw(ArgumentError("colptr[end] must equal nnz + 1"))
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

Base.size(A::DeviceSparseMatrixCSC) = (A.m, A.n)
Base.length(A::DeviceSparseMatrixCSC) = A.m * A.n
SparseArrays.nonzeros(A::DeviceSparseMatrixCSC) = A.nzval
SparseArrays.getcolptr(A::DeviceSparseMatrixCSC) = A.colptr
SparseArrays.rowvals(A::DeviceSparseMatrixCSC) = A.rowval
Base.copy(A::DeviceSparseMatrixCSC) =
    DeviceSparseMatrixCSC(A.m, A.n, copy(A.colptr), copy(A.rowval), copy(A.nzval))
