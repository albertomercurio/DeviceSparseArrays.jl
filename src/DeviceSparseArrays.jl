module DeviceSparseArrays

using SparseArrays
using SparseArrays: nonzeros, nonzeroinds, getcolptr, rowvals

using KernelAbstractions
using AcceleratedKernels

export AbstractDeviceSparseArray, AbstractDeviceSparseVector, AbstractDeviceSparseMatrix,
	   AbstractDeviceSparseVecOrMat,
	   AbstractDeviceSparseMatrixCSC, AbstractDeviceSparseMatrixCSR, AbstractDeviceSparseMatrixCOO,
	   DeviceSparseVector, DeviceSparseMatrixCSC

############################
# Abstract sparse hierarchy #
############################

"""
	AbstractDeviceSparseArray{Tv,Ti,N} <: AbstractSparseArray{Tv,Ti,N}

Supertype for sparse arrays that can have their underlying storage on various
devices (CPU, GPU, accelerators). This package keeps the hierarchy backend-agnostic;
dispatch is expected to leverage the concrete types of internal buffers (e.g. `Vector`,
`CuArray`, etc.) rather than an explicit backend flag.
"""
abstract type AbstractDeviceSparseArray{Tv,Ti,N} <: AbstractSparseArray{Tv,Ti,N} end

const AbstractDeviceSparseVector{Tv,Ti} = AbstractDeviceSparseArray{Tv,Ti,1}
const AbstractDeviceSparseMatrix{Tv,Ti} = AbstractDeviceSparseArray{Tv,Ti,2}
const AbstractDeviceSparseVecOrMat{Tv,Ti} = Union{AbstractDeviceSparseVector{Tv,Ti},AbstractDeviceSparseMatrix{Tv,Ti}}

# Format specific abstract matrix types (mirroring SparseArrays.jl naming pattern)
abstract type AbstractDeviceSparseMatrixCSC{Tv,Ti<:Integer} <: AbstractDeviceSparseMatrix{Tv,Ti} end
abstract type AbstractDeviceSparseMatrixCSR{Tv,Ti<:Integer} <: AbstractDeviceSparseMatrix{Tv,Ti} end
abstract type AbstractDeviceSparseMatrixCOO{Tv,Ti<:Integer} <: AbstractDeviceSparseMatrix{Tv,Ti} end

################################
# DeviceSparseVector definition #
################################

"""
	DeviceSparseVector{Tv,Ti,IndT<:AbstractVector{Ti},ValT<:AbstractVector{Tv}} <: AbstractDeviceSparseVector{Tv,Ti}

Sparse vector with generic index and value storage containers which may reside
on different devices. The logical length is stored along with index/value buffers.

Fields:
  n::Ti          - logical length of the vector
  nzind::IndT    - indices of stored (typically nonzero) entries (1-based)
  nzval::ValT    - stored values

Constructors validate that the index and value vectors have matching length.
"""
struct DeviceSparseVector{Tv,Ti<:Integer,IndT<:AbstractVector{Ti},ValT<:AbstractVector{Tv}} <: AbstractDeviceSparseVector{Tv,Ti}
	n::Ti
	nzind::IndT
	nzval::ValT
	function DeviceSparseVector{Tv,Ti,IndT,ValT}(n::Integer, nzind::IndT, nzval::ValT) where {Tv,Ti<:Integer,IndT<:AbstractVector{Ti},ValT<:AbstractVector{Tv}}
		n >= 0 || throw(ArgumentError("The number of elements must be non-negative."))
		length(nzind) == length(nzval) || throw(ArgumentError("index and value vectors must be the same length"))
		return new(convert(Ti, n), nzind, nzval)
	end
end

# Convenient param inference constructor
function DeviceSparseVector(n::Integer, nzind::IndT, nzval::ValT) where {IndT<:AbstractVector{Ti},ValT<:AbstractVector{Tv}} where {Ti<:Integer,Tv}
	DeviceSparseVector{Tv,Ti,IndT,ValT}(n, nzind, nzval)
end

# Conversions to/from Base SparseVector
DeviceSparseVector(V::SparseVector{Tv,Ti}) where {Tv,Ti} = DeviceSparseVector(V.n, V.nzind, V.nzval)
SparseVector(V::DeviceSparseVector{Tv,Ti}) where {Tv,Ti} = SparseVector(V.n, collect(V.nzind), collect(V.nzval))

Base.length(V::DeviceSparseVector) = V.n
Base.size(V::DeviceSparseVector) = (V.n,)
SparseArrays.nonzeros(V::DeviceSparseVector) = V.nzval
SparseArrays.nonzeroinds(V::DeviceSparseVector) = V.nzind
Base.copy(V::DeviceSparseVector{Tv,Ti,IndT,ValT}) where {Tv,Ti,IndT,ValT} = DeviceSparseVector{Tv,Ti,IndT,ValT}(V.n, copy(V.nzind), copy(V.nzval))

####################################
# DeviceSparseMatrixCSC definition #
####################################

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
struct DeviceSparseMatrixCSC{Tv,Ti<:Integer,ColPtrT<:AbstractVector{Ti},RowValT<:AbstractVector{Ti},NzValT<:AbstractVector{Tv}} <: AbstractDeviceSparseMatrixCSC{Tv,Ti}
	m::Int
	n::Int
	colptr::ColPtrT
	rowval::RowValT
	nzval::NzValT
	function DeviceSparseMatrixCSC{Tv,Ti,ColPtrT,RowValT,NzValT}(m::Integer, n::Integer, colptr::ColPtrT, rowval::RowValT, nzval::NzValT) where {Tv,Ti<:Integer,ColPtrT<:AbstractVector{Ti},RowValT<:AbstractVector{Ti},NzValT<:AbstractVector{Tv}}
		m >= 0 || throw(ArgumentError("m must be non-negative"))
		n >= 0 || throw(ArgumentError("n must be non-negative"))
		length(colptr) == n + 1 || throw(ArgumentError("colptr length must be n+1"))
		length(rowval) == length(nzval) || throw(ArgumentError("rowval and nzval must have same length"))
		# Standard CSC invariant: colptr[1] == 1 and colptr[end] == nnz + 1
		nnz = length(nzval)
		first(colptr) == one(Ti) || throw(ArgumentError("colptr[1] must be 1"))
		last(colptr) == nnz + 1 || throw(ArgumentError("colptr[end] must equal nnz + 1"))
		# TODO: Add some checks on rowval entries being in-bounds and sorted within each column
        
		return new(Int(m), Int(n), colptr, rowval, nzval)
	end
end

function DeviceSparseMatrixCSC(m::Integer, n::Integer, colptr::ColPtrT, rowval::RowValT, nzval::NzValT) where {ColPtrT<:AbstractVector{Ti},RowValT<:AbstractVector{Ti},NzValT<:AbstractVector{Tv}} where {Ti<:Integer,Tv}
	DeviceSparseMatrixCSC{Tv,Ti,ColPtrT,RowValT,NzValT}(m, n, colptr, rowval, nzval)
end

# Conversions to/from Base SparseMatrixCSC
DeviceSparseMatrixCSC(A::SparseMatrixCSC{Tv,Ti}) where {Tv,Ti} = DeviceSparseMatrixCSC(A.m, A.n, A.colptr, A.rowval, A.nzval)
SparseMatrixCSC(A::DeviceSparseMatrixCSC{Tv,Ti}) where {Tv,Ti} = SparseMatrixCSC(A.m, A.n, collect(A.colptr), collect(A.rowval), collect(A.nzval))

Base.size(A::DeviceSparseMatrixCSC) = (A.m, A.n)
Base.length(A::DeviceSparseMatrixCSC) = A.m * A.n
SparseArrays.nonzeros(A::DeviceSparseMatrixCSC) = A.nzval
SparseArrays.getcolptr(A::DeviceSparseMatrixCSC) = A.colptr
SparseArrays.rowvals(A::DeviceSparseMatrixCSC) = A.rowval
Base.copy(A::DeviceSparseMatrixCSC{Tv,Ti,ColPtrT,RowValT,NzValT}) where {Tv,Ti,ColPtrT,RowValT,NzValT} = DeviceSparseMatrixCSC{Tv,Ti,ColPtrT,RowValT,NzValT}(A.m, A.n, copy(A.colptr), copy(A.rowval), copy(A.nzval))

end # module
