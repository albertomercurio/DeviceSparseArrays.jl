# DeviceSparseVector implementation

"""
    DeviceSparseVector{Tv,Ti,IndT<:AbstractVector{Ti},ValT<:AbstractVector{Tv}} <: AbstractDeviceSparseVector{Tv,Ti}

Sparse vector with generic index and value storage containers which may reside
on different devices. The logical length is stored along with index/value buffers.

# Fields
- `n::Ti`          - logical length of the vector
- `nzind::IndT`    - indices of stored (typically nonzero) entries (1-based)
- `nzval::ValT`    - stored values

Constructors validate that the index and value vectors have matching length.
"""
struct DeviceSparseVector{Tv,Ti,IndT<:AbstractVector{Ti},ValT<:AbstractVector{Tv}} <:
       AbstractDeviceSparseVector{Tv,Ti}
    n::Int
    nzind::IndT
    nzval::ValT

    function DeviceSparseVector(
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

        return new{Tv,Ti,IndT,ValT}(Int(n), copy(nzind), copy(nzval))
    end
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
function Base.copyto!(dest::DeviceSparseVector, src::DeviceSparseVector)
    _prep_sparsevec_copy_dest!(dest, length(src), nnz(src))
    copyto!(nonzeroinds(dest), 1, nonzeroinds(src), 1, nnz(src))
    copyto!(nonzeros(dest), 1, nonzeros(src), 1, nnz(src))
    return dest
end

Base.similar(V::DeviceSparseVector, ::Type{Tv2}) where {Tv2} =
    DeviceSparseVector(V.n, copy(V.nzind), similar(V.nzval, Tv2))

function Base.:(*)(α::Number, V::DeviceSparseVector)
    return DeviceSparseVector(V.n, copy(V.nzind), α .* V.nzval)
end
Base.:(*)(V::DeviceSparseVector, α::Number) = α * V
Base.:(/)(V::DeviceSparseVector, α::Number) = (1 / α) * V

function Base.:-(V::DeviceSparseVector)
    return DeviceSparseVector(V.n, copy(V.nzind), -V.nzval)
end

Base.conj(V::DeviceSparseVector{<:Real}) = V
function Base.conj(V::DeviceSparseVector{<:Complex})
    return DeviceSparseVector(V.n, copy(V.nzind), conj.(V.nzval))
end

Base.real(V::DeviceSparseVector{<:Real}) = V
function Base.real(V::DeviceSparseVector{<:Complex})
    return DeviceSparseVector(V.n, copy(V.nzind), real.(V.nzval))
end

Base.imag(V::DeviceSparseVector{<:Real}) = zero(V)
function Base.imag(V::DeviceSparseVector{<:Complex})
    return DeviceSparseVector(V.n, copy(V.nzind), imag.(V.nzval))
end

function LinearAlgebra.norm(V::DeviceSparseVector, p::Real = 2)
    return norm(nonzeros(V), p)
end

# TODO: Remove this method when the function in LinearAlgebra is fixed
function LinearAlgebra.normalize(V::DeviceSparseVector, p::Real = 2)
    nrm = norm(V, p)
    V2 = copymutable_oftype(V, float(Base.promote_eltype(V, nrm)))
    return __normalize!(V2, nrm)
end

function LinearAlgebra.dot(x::DeviceSparseVector, y::DenseVector)
    length(x) == length(y) || throw(
        DimensionMismatch(
            "Vector x has a length $(length(x)) but y has a length $(length(y))",
        ),
    )

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

# Copied from SparseArrays.jl
function _prep_sparsevec_copy_dest!(A::DeviceSparseVector, lB, nnzB)
    lA = length(A)
    lA >= lB || throw(BoundsError())
    # If the two vectors have the same length then all the elements in A will be overwritten.
    if length(A) == lB
        resize!(nonzeros(A), nnzB)
        resize!(nonzeroinds(A), nnzB)
    else
        throw(ArgumentError("Cannot copy to a sparse vector of different length"))
    end
end
