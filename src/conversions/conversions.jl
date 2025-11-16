# Conversions between CSC, CSR, and COO sparse matrix formats
# All conversions operate on-device

# ============================================================================
# CSC ↔ COO Conversions
# ============================================================================

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

function DeviceSparseMatrixCSC(A::DeviceSparseMatrixCOO{Tv,Ti}) where {Tv,Ti}
    m, n = size(A)
    nnz_count = nnz(A)

    backend = get_backend(A.nzval)

    # Create keys for sorting: column first, then row
    keys = similar(A.rowind, Ti, nnz_count)

    # Create keys on device
    kernel! = kernel_make_csc_keys!(backend)
    kernel!(keys, A.rowind, A.colind, m; ndrange = (nnz_count,))

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
