# Conversions between CSC, CSR, and COO sparse matrix formats
# All conversions operate on-device

# ============================================================================
# CSC ↔ COO Conversions
# ============================================================================

"""
    DeviceSparseMatrixCOO(A::DeviceSparseMatrixCSC)

Convert a Compressed Sparse Column (CSC) matrix to Coordinate (COO) format.

The conversion preserves all matrix data and maintains backend compatibility.
The result will be on the same backend (CPU/GPU) as the input matrix.

# Examples
```julia
using DeviceSparseArrays, SparseArrays

# Create a CSC matrix
A_sparse = sparse([1, 2, 3], [1, 2, 3], [1.0, 2.0, 3.0], 3, 3)
A_csc = DeviceSparseMatrixCSC(A_sparse)

# Convert to COO format
A_coo = DeviceSparseMatrixCOO(A_csc)
```
"""
function DeviceSparseMatrixCOO(A::DeviceSparseMatrixCSC{Tv,Ti}) where {Tv,Ti}
    m, n = size(A)
    nnz_count = nnz(A)

    backend = get_backend(A.nzval)

    # Allocate output arrays on the same backend
    rowind = similar(A.rowval, Ti, nnz_count)
    colind = similar(A.rowval, Ti, nnz_count)
    nzval = similar(A.nzval, Tv, nnz_count)

    # Use kernel to convert CSC to COO
    kernel! = kernel_csc_to_coo!(backend)
    kernel!(rowind, colind, nzval, A.colptr, A.rowval, A.nzval; ndrange = (n,))

    return DeviceSparseMatrixCOO(m, n, rowind, colind, nzval)
end

"""
    DeviceSparseMatrixCSC(A::DeviceSparseMatrixCOO)

Convert a Coordinate (COO) matrix to Compressed Sparse Column (CSC) format.

The conversion sorts the COO entries by column (then by row within each column)
and builds the column pointer structure. The result maintains backend compatibility
with the input matrix.

# Examples
```julia
using DeviceSparseArrays, SparseArrays

# Create a COO matrix
A_sparse = sparse([1, 2, 3], [1, 2, 3], [1.0, 2.0, 3.0], 3, 3)
A_coo = DeviceSparseMatrixCOO(A_sparse)

# Convert to CSC format
A_csc = DeviceSparseMatrixCSC(A_coo)
```
"""
function DeviceSparseMatrixCSC(A::DeviceSparseMatrixCOO{Tv,Ti}) where {Tv,Ti}
    m, n = size(A)
    nnz_count = nnz(A)

    backend = get_backend(A.nzval)

    # Create keys for sorting: column first, then row
    keys = similar(A.rowind, Ti, nnz_count)

    # Create keys on device
    kernel! = kernel_make_csc_keys!(backend)
    kernel!(keys, A.rowind, A.colind, n; ndrange = (nnz_count,))

    perm = AcceleratedKernels.sortperm(keys)

    # Apply permutation to get sorted arrays
    rowind_sorted = A.rowind[perm]
    colind_sorted = A.colind[perm]
    nzval_sorted = A.nzval[perm]

    # Build colptr on device using a histogram approach
    colptr = similar(A.colind, Ti, n + 1)
    fill!(colptr, zero(Ti))

    # Count entries per column
    kernel! = kernel_count_per_col!(backend)
    kernel!(colptr, colind_sorted; ndrange = (nnz_count,))

    # Compute cumulative sum
    allowed_setindex!(colptr, 1, 1) # TODO: Is there a better way to do this?
    colptr[2:end] .= AcceleratedKernels.cumsum(colptr[2:end]) .+ 1

    return DeviceSparseMatrixCSC(m, n, colptr, rowind_sorted, nzval_sorted)
end

# ============================================================================
# CSR ↔ COO Conversions
# ============================================================================

"""
    DeviceSparseMatrixCOO(A::DeviceSparseMatrixCSR)

Convert a Compressed Sparse Row (CSR) matrix to Coordinate (COO) format.

The conversion preserves all matrix data and maintains backend compatibility.
The result will be on the same backend (CPU/GPU) as the input matrix.

# Examples
```julia
using DeviceSparseArrays, SparseArrays

# Create a CSR matrix
A_sparse = sparse([1, 2, 3], [1, 2, 3], [1.0, 2.0, 3.0], 3, 3)
A_csr = DeviceSparseMatrixCSR(A_sparse)

# Convert to COO format
A_coo = DeviceSparseMatrixCOO(A_csr)
```
"""
function DeviceSparseMatrixCOO(A::DeviceSparseMatrixCSR{Tv,Ti}) where {Tv,Ti}
    m, n = size(A)
    nnz_count = nnz(A)

    backend = get_backend(A.nzval)

    # Allocate output arrays on the same backend
    rowind = similar(A.colval, Ti, nnz_count)
    colind = similar(A.colval, Ti, nnz_count)
    nzval = similar(A.nzval, Tv, nnz_count)

    # Use kernel to convert CSR to COO
    kernel! = kernel_csr_to_coo!(backend)
    kernel!(rowind, colind, nzval, A.rowptr, A.colval, A.nzval; ndrange = (m,))

    return DeviceSparseMatrixCOO(m, n, rowind, colind, nzval)
end

"""
    DeviceSparseMatrixCSR(A::DeviceSparseMatrixCOO)

Convert a Coordinate (COO) matrix to Compressed Sparse Row (CSR) format.

The conversion sorts the COO entries by row (then by column within each row)
and builds the row pointer structure. The result maintains backend compatibility
with the input matrix.

# Examples
```julia
using DeviceSparseArrays, SparseArrays

# Create a COO matrix
A_sparse = sparse([1, 2, 3], [1, 2, 3], [1.0, 2.0, 3.0], 3, 3)
A_coo = DeviceSparseMatrixCOO(A_sparse)

# Convert to CSR format
A_csr = DeviceSparseMatrixCSR(A_coo)
```
"""
function DeviceSparseMatrixCSR(A::DeviceSparseMatrixCOO{Tv,Ti}) where {Tv,Ti}
    m, n = size(A)
    nnz_count = nnz(A)

    backend = get_backend(A.nzval)

    # Create keys for sorting: row first, then column
    keys = similar(A.rowind, Ti, nnz_count)

    # Create keys on device
    kernel! = kernel_make_csr_keys!(backend)
    kernel!(keys, A.rowind, A.colind, n; ndrange = (nnz_count,))

    # Sort - use AcceleratedKernels
    perm = AcceleratedKernels.sortperm(keys)

    # Apply permutation to get sorted arrays
    rowind_sorted = A.rowind[perm]
    colind_sorted = A.colind[perm]
    nzval_sorted = A.nzval[perm]

    # Build rowptr on device using a histogram approach
    rowptr = similar(A.rowind, Ti, m + 1)
    fill!(rowptr, zero(Ti))

    # Count entries per row
    kernel! = kernel_count_per_row!(backend)
    kernel!(rowptr, rowind_sorted; ndrange = (nnz_count,))

    # Compute cumulative sum
    allowed_setindex!(rowptr, 1, 1) # TODO: Is there a better way to do this?
    rowptr[2:end] .= AcceleratedKernels.cumsum(rowptr[2:end]) .+ 1

    return DeviceSparseMatrixCSR(m, n, rowptr, colind_sorted, nzval_sorted)
end
