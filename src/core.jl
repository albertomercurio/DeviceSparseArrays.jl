# Abstract sparse hierarchy and common aliases

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
const AbstractDeviceSparseVecOrMat{Tv,Ti} =
    Union{AbstractDeviceSparseVector{Tv,Ti},AbstractDeviceSparseMatrix{Tv,Ti}}

Base.sum(A::AbstractDeviceSparseArray) = sum(nonzeros(A))

function LinearAlgebra.rmul!(A::AbstractDeviceSparseArray, x::Number)
    rmul!(nonzeros(A), x)
    return A
end
function LinearAlgebra.lmul!(x::Number, A::AbstractDeviceSparseArray)
    lmul!(x, nonzeros(A))
    return A
end

function LinearAlgebra.rdiv!(A::AbstractDeviceSparseArray, x::Number)
    rdiv!(nonzeros(A), x)
    return A
end

Base.:+(A::AbstractDeviceSparseArray) = copy(A)

Base.:*(A::AbstractDeviceSparseArray, J::UniformScaling) = A * J.λ
Base.:*(J::UniformScaling, A::AbstractDeviceSparseArray) = J.λ * A

SparseArrays.getnzval(A::AbstractDeviceSparseArray) = nonzeros(A)
function SparseArrays.nnz(A::AbstractDeviceSparseArray)
    length(nonzeros(A))
end

KernelAbstractions.get_backend(A::AbstractDeviceSparseArray) = get_backend(nonzeros(A))

trans_adj_wrappers(fmt) = (
    (T -> :($fmt{$T}), false, identity, identity, :(T1)),
    (T -> :(Transpose{$T,<:$fmt{$T}}), true, identity, A -> :(parent($A)), :(T1<:Real)),
    (
        T -> :(Adjoint{$T,<:$fmt{$T}}),
        true,
        x -> :(conj($x)),
        A -> :(parent($A)),
        :(T1<:Complex),
    ),
)
