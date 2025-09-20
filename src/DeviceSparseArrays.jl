module DeviceSparseArrays

using SparseArrays
using KernelAbstractions
using AcceleratedKernels

export AbstractDeviceSparseArray,
    AbstractDeviceSparseVector, AbstractDeviceSparseMatrix, AbstractDeviceSparseVecOrMat

export DeviceSparseVector, DeviceSparseMatrixCSC

include("core.jl")
include("vector.jl")
include("matrix_csc.jl")

end # module
