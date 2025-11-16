module DeviceSparseArrays

using LinearAlgebra
import LinearAlgebra: wrap, copymutable_oftype, __normalize!, kron
using SparseArrays
import SparseArrays: SparseVector, SparseMatrixCSC
import SparseArrays: getcolptr, getrowval, getnzval, nonzeroinds

import ArrayInterface: allowed_getindex, allowed_setindex!

import KernelAbstractions
import KernelAbstractions:
    @kernel,
    @atomic,
    @index,
    get_backend,
    synchronize,
    @ndrange,
    @groupsize,
    @localmem,
    @synchronize,
    @private,
    @uniform
using AcceleratedKernels

import Adapt

export AbstractDeviceSparseArray,
    AbstractDeviceSparseVector, AbstractDeviceSparseMatrix, AbstractDeviceSparseVecOrMat

export DeviceSparseVector,
    DeviceSparseMatrixCSC, DeviceSparseMatrixCSR, DeviceSparseMatrixCOO

include("core.jl")
include("helpers.jl")
include("vector/vector.jl")

include("matrix_csc/matrix_csc_kernels.jl")
include("matrix_csc/matrix_csc.jl")

include("matrix_csr/matrix_csr_kernels.jl")
include("matrix_csr/matrix_csr.jl")

include("matrix_coo/matrix_coo_kernels.jl")
include("matrix_coo/matrix_coo.jl")

include("conversions/conversion_kernels.jl")
include("conversions/conversions.jl")

end # module
