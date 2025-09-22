```@meta
CurrentModule = DeviceSparseArrays
```

# DeviceSparseArrays

Documentation for [DeviceSparseArrays](https://github.com/albertomercurio/DeviceSparseArrays.jl).

## Overview

`DeviceSparseArrays` provides backend-agnostic sparse array container types whose
internal storage vectors may live on different devices (CPU / accelerators). The
initial implementation supplies:

* [`DeviceSparseVector`](@ref) – sparse vector with generic index & value buffers.
* [`DeviceSparseMatrixCSC`](@ref) – Compressed Sparse Column matrix with parametric column pointer, row index, and nonzero value buffers.
* [`DeviceSparseMatrixCSR`](@ref) – Compressed Sparse Row matrix with parametric row pointer, column index, and nonzero value buffers.

These types mirror the Base `SparseVector` / `SparseMatrixCSC` interfaces for introspection (`size`, `length`, `nonzeros`, etc.) and can roundtrip convert to and from the Base representations.

## Quick Start

### Basic Usage

```@example example
using DeviceSparseArrays, SparseArrays

# Create a sparse vector
V = sparsevec([2,5], [1.0, 3.5], 6)
dV = DeviceSparseVector(V)  # construct backend-agnostic version on the CPU

@show size(dV)
@show SparseVector(dV) == V

# Create a sparse matrix
A = sparse([1,2,1],[1,1,2],[2.0,3.0,4.0], 2, 2)
dA = DeviceSparseMatrixCSC(A)

@show size(dA)
@show SparseMatrixCSC(dA) == A
```

### Matrix-Vector Multiplication

```@example example
# Create a sparse matrix
A_sparse = sparse([1,2,1,3],[1,1,2,3],[2.0,3.0,4.0,5.0], 3, 3)
@show A_sparse

# Convert to DeviceSparseMatrixCSC
A_device = DeviceSparseMatrixCSC(A_sparse)

# Create a vector
b = [1.0, 2.0, 3.0]

# Matrix-vector multiplication
c = A_device * b
@show c

# Verify result matches standard sparse matrix
@show A_sparse * b == c
```

### Backend Adaptation with JLArrays

`JLArrays.jl` provides a CPU fallback backend for testing and CI purposes. Here we use it to demonstrate backend adaptation with `Adapt.jl`.

```@example example
using JLArrays
using Adapt: adapt

# Create a sparse matrix
A_sparse = sprand(Float64, 5, 4, 0.6)

# Convert to DeviceSparseMatrixCSC
A_device = DeviceSparseMatrixCSC(A_sparse)

# Adapt to JLArray backend (CPU fallback for CI)
A_jl = adapt(JLArray, A_device)

# Create vector on same backend
b = rand(Float64, 4)
b_jl = JLArray(b)

# Matrix-vector multiplication on JLArray backend
c_jl = A_jl * b_jl

# Results should match
@show collect(c_jl) ≈ A_sparse * b
```

### CSR Matrix Format

`DeviceSparseArrays.jl` also supports the Compressed Sparse Row (CSR) format via the `DeviceSparseMatrixCSR` type. It can be used similarly to the CSC format. 

```@example example
# Create a sparse matrix
A_sparse = sparse([1,2,1,3],[1,1,2,3],[2.0,3.0,4.0,5.0], 3, 3)

# Convert to CSR format
A_csr = DeviceSparseMatrixCSR(A_sparse)
@show size(A_csr)

# Convert back to standard sparse matrix
@show SparseMatrixCSC(A_csr) == A_sparse

# Matrix-vector multiplication with CSR
b = [1.0, 2.0, 3.0]
c = A_csr * b
@show c
```

## Future Work

Planned extensions include COO formats, sparse-dense and sparse-sparse
linear algebra kernels leveraging `KernelAbstractions.jl` / `AcceleratedKernels.jl`, and device-specific adaptations via dispatch on the internal buffer types.

## See Also

- [API Reference](@ref) for complete function documentation
