module DeviceSparseArrays

using LinearAlgebra
import LinearAlgebra: wrap, copymutable_oftype, __normalize!
using SparseArrays
import SparseArrays: getcolptr, getrowval, getnzval, nonzeroinds

import ArrayInterface: allowed_getindex, allowed_setindex!

import KernelAbstractions
import KernelAbstractions: @kernel, @atomic, @index, get_backend, synchronize
using AcceleratedKernels

import Adapt

export AbstractDeviceSparseArray,
    AbstractDeviceSparseVector, AbstractDeviceSparseMatrix, AbstractDeviceSparseVecOrMat

export DeviceSparseVector,
    DeviceSparseMatrixCSC, DeviceSparseMatrixCSR, DeviceSparseMatrixCOO

include("core.jl")
include("helpers.jl")
include("vector.jl")
include("matrix_csc.jl")
include("matrix_csr.jl")
include("matrix_coo.jl")

end # module
