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

const AbstractDeviceSparseMatrixInclAdjointAndTranspose = Union{
    AbstractDeviceSparseMatrix,
    Adjoint{<:Any,<:AbstractDeviceSparseMatrix},
    Transpose{<:Any,<:AbstractDeviceSparseMatrix},
}

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

# called by `show(io, MIME("text/plain"), ::AbstractDeviceSparseMatrixInclAdjointAndTranspose)`
function Base.print_array(io::IO, A::AbstractDeviceSparseMatrixInclAdjointAndTranspose)
    S = SparseMatrixCSC(A)
    if max(size(S)...) < 16
        Base.print_matrix(io, S)
    else
        _show_with_braille_patterns(io, S)
    end
end

# Generic addition between AbstractDeviceSparseMatrix and DenseMatrix
function Base.:+(A::AbstractDeviceSparseMatrix, B::DenseMatrix)
    size(A) == size(B) || throw(
        DimensionMismatch(
            "dimensions must match: A has dims $(size(A)), B has dims $(size(B))",
        ),
    )

    backend_A = get_backend(A)
    backend_B = get_backend(B)

    backend_A == backend_B || throw(ArgumentError("Both arrays must have the same backend"))

    # Create a copy of B to avoid modifying the input
    C = copy(B)

    # Add the sparse values to C
    _add_sparse_to_dense!(C, A)

    return C
end

Base.:+(B::DenseMatrix, A::AbstractDeviceSparseMatrix) = A + B

# Keep this at the end of the file
trans_adj_wrappers(fmt) = (
    (T -> :($fmt{$T}), false, false, identity, T -> :($T)),
    (T -> :(Transpose{$T,<:$fmt{$T}}), true, false, A -> :(parent($A)), T -> :($T<:Real)),
    (
        T -> :(Transpose{$T,<:$fmt{$T}}),
        true,
        false,
        A -> :(parent($A)),
        T -> :($T<:Complex),
    ),
    (T -> :(Adjoint{$T,<:$fmt{$T}}), true, true, A -> :(parent($A)), T -> :($T)),
)
