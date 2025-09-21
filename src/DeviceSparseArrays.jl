module DeviceSparseArrays

using LinearAlgebra
import LinearAlgebra: wrap
using SparseArrays
import SparseArrays: getcolptr, getrowval, getnzval, nonzeroinds

import ArrayInterface: allowed_getindex, allowed_setindex!

import KernelAbstractions
import KernelAbstractions: @kernel, @atomic, @index, get_backend, synchronize
using AcceleratedKernels

import Adapt: @adapt_structure

export AbstractDeviceSparseArray,
    AbstractDeviceSparseVector, AbstractDeviceSparseMatrix, AbstractDeviceSparseVecOrMat

export DeviceSparseVector, DeviceSparseMatrixCSC, DeviceSparseMatrixCSR

include("core.jl")
include("vector.jl")
include("matrix_csc.jl")
include("matrix_csr.jl")

end # module
