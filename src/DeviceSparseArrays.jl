module DeviceSparseArrays

using LinearAlgebra
import LinearAlgebra: wrap
using SparseArrays
import SparseArrays: getcolptr, getrowval, getnzval, nonzeroinds

import ArrayInterface: allowed_getindex, allowed_setindex!

import KernelAbstractions
import KernelAbstractions: @kernel, @atomic, @index, get_backend, synchronize
using AcceleratedKernels

export AbstractDeviceSparseArray,
    AbstractDeviceSparseVector, AbstractDeviceSparseMatrix, AbstractDeviceSparseVecOrMat

export DeviceSparseVector, DeviceSparseMatrixCSC

include("core.jl")
include("vector.jl")
include("matrix_csc.jl")

end # module
