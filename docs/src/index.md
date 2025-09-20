```@meta
CurrentModule = DeviceSparseArrays
```

# DeviceSparseArrays

Documentation for [DeviceSparseArrays](https://github.com/albertomercurio/DeviceSparseArrays.jl).

## Overview

`DeviceSparseArrays` provides backend-agnostic sparse array container types whose
internal storage vectors may live on different devices (CPU / accelerators). The
initial implementation supplies:

* `DeviceSparseVector` – sparse vector with generic index & value buffers.
* `DeviceSparseMatrixCSC` – Compressed Sparse Column matrix with parametric
	column pointer, row index, and nonzero value buffers.

These types mirror the Base `SparseVector` / `SparseMatrixCSC` interfaces for
introspection (`size`, `length`, `nonzeros`, etc.) and can roundtrip convert to
and from the Base representations.

## Quick Start

```jldoctest
julia> using DeviceSparseArrays, SparseArrays

julia> V = sparsevec([2,5], [1.0, 3.5], 6);

julia> dV = DeviceSparseVector(V);  # construct backend-agnostic version

julia> size(dV)
(6,)

julia> SparseVector(dV) == V
true

julia> A = sparse([1,2,1],[1,1,2],[2.0,3.0,4.0], 2, 2);

julia> dA = DeviceSparseMatrixCSC(A);

julia> size(dA)
(2, 2)

julia> SparseMatrixCSC(dA) == A
true
```

## Future Work

Planned extensions include CSR / COO formats, sparse-dense and sparse-sparse
linear algebra kernels leveraging `KernelAbstractions` / `AcceleratedKernels`,
and device-specific adaptations via dispatch on the internal buffer types.

```@index
```

```@autodocs
Modules = [DeviceSparseArrays]
```
