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
        get_backend(nzind) == get_backend(nzval) || throw(
            ArgumentError("Index and value vectors must be on the same device/backend."),
        )

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

Adapt.adapt_structure(to, V::DeviceSparseVector) = DeviceSparseVector(
    V.n,
    Adapt.adapt_structure(to, V.nzind),
    Adapt.adapt_structure(to, V.nzval),
)

# Basic methods
Base.length(V::DeviceSparseVector) = V.n
Base.size(V::DeviceSparseVector) = (V.n,)
SparseArrays.nonzeros(V::DeviceSparseVector) = V.nzval
SparseArrays.nonzeroinds(V::DeviceSparseVector) = V.nzind
Base.copy(V::DeviceSparseVector) = DeviceSparseVector(V.n, copy(V.nzind), copy(V.nzval))

function LinearAlgebra.dot(x::DeviceSparseVector, y::DenseVector)
    length(x) == length(y) ||
        throw(DimensionMismatch("Vector x has a length $(length(x)) but y has a length $n"))

    T = Base.promote_eltype(x, y)

    backend = get_backend(nonzeros(x))
    get_backend(y) == backend ||
        throw(ArgumentError("Vectors x and y must be on the same device/backend."))

    nzind = nonzeroinds(x)
    nzval = nonzeros(x)

    # TODO: by using the view it throws scalar indexing
    # y_view = @view(y[nzind])
    # return dot(nzval, y_view)

    backend isa KernelAbstractions.CPU && return dot(nzval, @view(y[nzind]))

    @kernel function kernel_dot(res, @Const(nzval), @Const(nzind), @Const(y))
        i = @index(Global)
        @inbounds begin
            @atomic res[1] += dot(nzval[i], y[nzind[i]])
        end
    end

    m = length(nzind)
    res = similar(nzval, T, 1)
    fill!(res, zero(eltype(res)))

    kernel = kernel_dot(backend)
    kernel(res, nzval, nzind, y; ndrange = (m,))

    return allowed_getindex(res, 1)
end
LinearAlgebra.dot(x::DenseVector{T1}, y::DeviceSparseVector{Tv}) where {T1<:Real,Tv<:Real} =
    dot(y, x)
LinearAlgebra.dot(
    x::DenseVector{T1},
    y::DeviceSparseVector{Tv},
) where {T1<:Complex,Tv<:Complex} = conj(dot(y, x))
