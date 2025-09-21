module DeviceSparseArrays

using LinearAlgebra
import LinearAlgebra: wrap
using SparseArrays
import SparseArrays: getcolptr, getrowval, getnzval

import ArrayInterface: allowed_getindex, allowed_setindex!

import KernelAbstractions
import KernelAbstractions: @kernel, @atomic, @index, get_backend
using AcceleratedKernels

export AbstractDeviceSparseArray,
    AbstractDeviceSparseVector, AbstractDeviceSparseMatrix, AbstractDeviceSparseVecOrMat

export DeviceSparseVector, DeviceSparseMatrixCSC

include("core.jl")
include("vector.jl")
include("matrix_csc.jl")

end # module
