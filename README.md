# DeviceSparseArrays

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://albertomercurio.github.io/DeviceSparseArrays.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://albertomercurio.github.io/DeviceSparseArrays.jl/dev/)
[![Build Status](https://github.com/albertomercurio/DeviceSparseArrays.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/albertomercurio/DeviceSparseArrays.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/albertomercurio/DeviceSparseArrays.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/albertomercurio/DeviceSparseArrays.jl)
[![Aqua](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl)

DeviceSparseArrays.jl is a Julia package that provides backend-agnostic sparse array types and operations for CPU, GPU, and other accelerators. It aims to offer a unified interface for sparse data structures that can seamlessly operate across different hardware backends. For example, a `DeviceSparseMatrixCSC` type could represent a sparse matrix stored in Compressed Sparse Column format, where the underlying data could reside in CPU, GPU, or any other memory type, dispatching specific implementations based on the target device. This allows users to write code that is portable and efficient across various hardware platforms without needing to change their code for different backends. The aim of the package is to support a wide range of different sparse formats (e.g., CSC, CSR, COO) as well as different backends like:
- CPU (using standard Julia arrays)
- GPU (using [CUDA.jl](https://github.com/JuliaGPU/CUDA.jl), [AMDGPU.jl](https://github.com/JuliaGPU/AMDGPU.jl), [oneAPI.jl](https://github.com/JuliaGPU/oneAPI.jl), [Metal.jl](https://github.com/JuliaGPU/Metal.jl), etc.)
- [DistributedArrays.jl](https://github.com/JuliaParallel/DistributedArrays.jl) (for distributed computing)
- [Dagger.jl](https://github.com/JuliaParallel/Dagger.jl) (for task parallelism)
- [CuNumeric.jl](https://github.com/JuliaLegate/cuNumeric.jl) (for distributed GPU computing)
- [Reactant.jl](https://github.com/EnzymeAD/Reactant.jl) (for XLA acceleration)
- [StaticArrays.jl](https://github.com/JuliaArrays/StaticArrays.jl) (for small, stack-allocated arrays)
- [FixedSizeArrays.jl](https://github.com/JuliaArrays/FixedSizeArrays.jl) (for arrays with statically known sizes)
- Other accelerators as they become supported in the Julia ecosystem

The package aims to use [KernelAbstractions.jl](https://github.com/JuliaGPU/KernelAbstractions.jl) or [AcceleratedKernels.jl](https://github.com/JuliaGPU/AcceleratedKernels.jl) to provide a consistent interface for kernel execution across different hardware backends.

## Installation
You can install the package using Julia's package manager. In the Julia REPL, run:
```julia
using Pkg
Pkg.add(url="https://github.com/albertomercurio/DeviceSparseArrays.jl")
```

## Usage Examples

### Basic Usage with CSC Matrices

```julia
using DeviceSparseArrays
using SparseArrays
using LinearAlgebra

# Create a 100x80 sparse matrix with 10% sparsity
A_sparse = sprand(Float64, 100, 80, 0.1)

# Convert to DeviceSparseMatrixCSC (CPU by default)
A_device = DeviceSparseMatrixCSC(A_sparse)

# Create a vector for matrix-vector multiplication
b = rand(Float64, 3)

# Perform matrix-vector multiplication
c = A_device * b

# You can also use the in-place mul! function
c_result = similar(b)
mul!(c_result, A_device, b)
```

### GPU Backend Usage

```julia
# For CUDA backend
using CUDA
A_cuda = adapt(CuArray, A_device)
b_cuda = CuArray(b)
c_cuda = A_cuda * b_cuda

# For Metal backend (on Apple Silicon)
using Metal
A_metal = adapt(MtlArray, A_device)
b_metal = MtlArray(b)
c_metal = A_metal * b_metal

# For Reactant backend (XLA acceleration)
using Reactant
A_reactant = adapt(Reactant.ConcreteRArray, A_device)
b_reactant = Reactant.ConcreteRArray(b)
c_reactant = A_reactant * b_reactant
```

### CSR Matrix Format

```julia
# Create a sparse matrix and convert to CSR format
A_sparse = sprand(Float64, 100, 80, 0.1)  # 100x80 matrix with 10% sparsity
A_csr = DeviceSparseMatrixCSR(A_sparse)

# Convert to different backends
A_csr_cuda = adapt(CuArray, A_csr)
A_csr_metal = adapt(MtlArray, A_csr)
A_csr_reactant = adapt(Reactant.ConcreteRArray, A_csr)

# Matrix-vector multiplication with CSR format
b = rand(Float64, 80)
b_device = CuArray(b)  # or MtlArray(b), etc.
c = A_csr_cuda * b_device
```

## Contributing
Contributions are welcome!

## License
This package is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Acknowledgments
This package was inspired by the need for a unified approach to handling sparse arrays across different hardware backends in Julia. It leverages existing packages like [KernelAbstractions.jl](https://github.com/JuliaGPU/KernelAbstractions.jl) and [AcceleratedKernels.jl](https://github.com/JuliaGPU/AcceleratedKernels.jl) to provide a consistent interface for kernel execution.
We also acknowledge the contributions of the Julia community in providing tools and libraries that make this work possible.

