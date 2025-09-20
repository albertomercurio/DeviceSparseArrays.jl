# DeviceSparseArrays

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://albertomercurio.github.io/DeviceSparseArrays.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://albertomercurio.github.io/DeviceSparseArrays.jl/dev/)
[![Build Status](https://github.com/albertomercurio/DeviceSparseArrays.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/albertomercurio/DeviceSparseArrays.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/albertomercurio/DeviceSparseArrays.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/albertomercurio/DeviceSparseArrays.jl)
[![Aqua](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl)

DeviceSparseArrays.jl is a Julia package that provides backend-agnostic sparse array types and operations for CPU, GPU, and other accelerators. It aims to offer a unified interface for sparse data structures that can seamlessly operate across different hardware backends. For example, a `DeviceSparseMatrixCSC` type could represent a sparse matrix stored in Compressed Sparse Column format, where the underlying data could reside in CPU, GPU, or any other memory type, dispatching specific implementations based on the target device. This allows users to write code that is portable and efficient across various hardware platforms without needing to change their code for different backends. The aim of the package is to support a wide range of different sparse formats (e.g., CSC, CSR, COO) as well as different backends like:
- CPU (using standard Julia arrays)
- GPU (using [CUDA.jl](https://github.com/JuliaGPU/CUDA.jl), [AMDGPU.jl](https://github.com/JuliaGPU/AMDGPU.jl), [oneAPI.jl](https://github.com/JuliaGPU/oneAPI.jl), [Metal.jl](https://github.com/JuliaGPU/Metal.jl), etc.)
- [Reactant.jl](https://github.com/EnzymeAD/Reactant.jl) (for XLA acceleration)
- [FixedSizeArrays.jl](https://github.com/JuliaArrays/FixedSizeArrays.jl) (for arrays with statically known sizes)
- Other accelerators as they become supported in the Julia ecosystem

The package aims to use [KernelAbstractions.jl](https://github.com/JuliaGPU/KernelAbstractions.jl) or [AcceleratedKernels.jl](https://github.com/JuliaGPU/AcceleratedKernels.jl) to provide a consistent interface for kernel execution across different hardware backends.

## Installation
You can install the package using Julia's package manager. In the Julia REPL, run:
```julia
using Pkg
Pkg.add(url="https://github.com/albertomercurio/DeviceSparseArrays.jl")
```

## Contributing
Contributions are welcome!

## License
This package is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Acknowledgments
This package was inspired by the need for a unified approach to handling sparse arrays across different hardware backends in Julia. It leverages existing packages like [KernelAbstractions.jl](https://github.com/JuliaGPU/KernelAbstractions.jl) and [AcceleratedKernels.jl](https://github.com/JuliaGPU/AcceleratedKernels.jl) to provide a consistent interface for kernel execution.
We also acknowledge the contributions of the Julia community in providing tools and libraries that make this work possible.

