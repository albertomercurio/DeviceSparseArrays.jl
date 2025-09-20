# DeviceSparseVector implementation

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
struct DeviceSparseVector{
    Tv,
    Ti<:Integer,
    IndT<:AbstractVector{Ti},
    ValT<:AbstractVector{Tv},
} <: AbstractDeviceSparseVector{Tv,Ti}
    n::Int
    nzind::IndT
    nzval::ValT
    function DeviceSparseVector{Tv,Ti,IndT,ValT}(
        n::Integer,
        nzind::IndT,
        nzval::ValT,
    ) where {Tv,Ti<:Integer,IndT<:AbstractVector{Ti},ValT<:AbstractVector{Tv}}
        n >= 0 || throw(ArgumentError("The number of elements must be non-negative."))
        length(nzind) == length(nzval) ||
            throw(ArgumentError("index and value vectors must be the same length"))
        return new(Int(n), nzind, nzval)
    end
end

# Param inference constructor
function DeviceSparseVector(
    n::Integer,
    nzind::IndT,
    nzval::ValT,
) where {IndT<:AbstractVector{Ti},ValT<:AbstractVector{Tv}} where {Ti<:Integer,Tv}
    DeviceSparseVector{Tv,Ti,IndT,ValT}(n, nzind, nzval)
end

# Conversions
DeviceSparseVector(V::SparseVector) = DeviceSparseVector(V.n, V.nzind, V.nzval)
SparseVector(V::DeviceSparseVector) = SparseVector(V.n, collect(V.nzind), collect(V.nzval))

# Basic methods
Base.length(V::DeviceSparseVector) = V.n
Base.size(V::DeviceSparseVector) = (V.n,)
SparseArrays.nonzeros(V::DeviceSparseVector) = V.nzval
SparseArrays.nonzeroinds(V::DeviceSparseVector) = V.nzind
Base.copy(V::DeviceSparseVector{Tv,Ti,IndT,ValT}) where {Tv,Ti,IndT,ValT} =
    DeviceSparseVector{Tv,Ti,IndT,ValT}(V.n, copy(V.nzind), copy(V.nzval))
