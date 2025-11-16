@kernel inbounds=true function kernel_spmatmul_csc_N!(
    C,
    @Const(colptr),
    @Const(rowval),
    @Const(nzval),
    @Const(B),
    α,
    ::Val{CONJA},
    ::Val{CONJB},
    ::Val{TRANSB},
) where {CONJA,CONJB,TRANSB}
    k, col = @index(Global, NTuple)

    Bi, Bj = TRANSB ? (k, col) : (col, k)

    valb = CONJB ? conj(B[Bi, Bj]) : B[Bi, Bj]
    axj = valb * α
    for j = colptr[col]:(colptr[col+1]-1) # nzrange(A, col)
        vala = CONJA ? conj(nzval[j]) : nzval[j]
        @atomic C[rowval[j], k] += vala * axj
    end
end

@kernel inbounds=true function kernel_spmatmul_csc_T!(
    C,
    @Const(colptr),
    @Const(rowval),
    @Const(nzval),
    @Const(B),
    α,
    ::Val{CONJA},
    ::Val{CONJB},
    ::Val{TRANSB},
) where {CONJA,CONJB,TRANSB}
    k, col = @index(Global, NTuple)

    tmp = zero(eltype(C))
    for j = colptr[col]:(colptr[col+1]-1) # nzrange(A, col)
        Bi, Bj = TRANSB ? (k, rowval[j]) : (rowval[j], k)
        vala = CONJA ? conj(nzval[j]) : nzval[j]
        valb = CONJB ? conj(B[Bi, Bj]) : B[Bi, Bj]
        tmp += vala * valb
    end
    @inbounds C[col, k] += tmp * α
end

@kernel inbounds=true unsafe_indices=true function kernel_workgroup_dot_csc_N!(
    block_results,
    @Const(x),
    @Const(colptr),
    @Const(rowval),
    @Const(nzval),
    @Const(y),
    @Const(n),
    ::Val{CONJA},
) where {CONJA}
    # Get work-item and workgroup indices
    local_id = @index(Local, Linear)
    group_id = @index(Group, Linear)
    global_id = @index(Global, Linear)

    workgroup_size = @uniform @groupsize()[1]
    stride = @uniform @ndrange()[1]

    # Allocate shared memory for workgroup reduction
    shared = @localmem(eltype(block_results), workgroup_size)

    # Each work-item accumulates its contribution from columns with stride
    local_sum = zero(eltype(block_results))
    for col = global_id:stride:n
        for j = colptr[col]:(colptr[col+1]-1)
            vala = CONJA ? conj(nzval[j]) : nzval[j]
            local_sum += dot(x[rowval[j]], vala, y[col])
        end
    end

    # Store local sum in shared memory
    shared[local_id] = local_sum
    @synchronize()

    if local_id == 1
        sum = zero(eltype(block_results))
        for i = 1:workgroup_size
            sum += shared[i]
        end
        block_results[group_id] = sum
    end
end

@kernel inbounds=true unsafe_indices=true function kernel_workgroup_dot_csc_T!(
    block_results,
    @Const(x),
    @Const(colptr),
    @Const(rowval),
    @Const(nzval),
    @Const(y),
    @Const(n),
    ::Val{CONJA},
) where {CONJA}
    # Get work-item and workgroup indices
    local_id = @index(Local, Linear)
    group_id = @index(Group, Linear)
    global_id = @index(Global, Linear)

    workgroup_size = @uniform @groupsize()[1]
    stride = @uniform @ndrange()[1]

    # Allocate shared memory for workgroup reduction
    shared = @localmem(eltype(block_results), workgroup_size)

    # Each work-item accumulates its contribution from columns with stride
    local_sum = zero(eltype(block_results))
    for col = global_id:stride:n
        for j = colptr[col]:(colptr[col+1]-1)
            vala = CONJA ? conj(nzval[j]) : nzval[j]
            local_sum += dot(x[col], vala, y[rowval[j]])
        end
    end

    # Store local sum in shared memory
    shared[local_id] = local_sum
    @synchronize()

    if local_id == 1
        sum = zero(eltype(block_results))
        for i = 1:workgroup_size
            sum += shared[i]
        end
        block_results[group_id] = sum
    end
end

# Kernel for adding sparse matrix to dense matrix (CSC format)
@kernel inbounds=true function kernel_add_sparse_to_dense_csc!(
    C,
    @Const(colptr),
    @Const(rowval),
    @Const(nzval),
)
    col = @index(Global)

    @inbounds for j = colptr[col]:(colptr[col+1]-1)
        C[rowval[j], col] += nzval[j]
    end
end

# Kernel for counting non-zeros per column when adding two CSC matrices
@kernel inbounds=true function kernel_count_nnz_per_col_csc!(
    nnz_per_col,
    @Const(colptr_A),
    @Const(rowval_A),
    @Const(colptr_B),
    @Const(rowval_B),
)
    col = @index(Global)

    i_A = colptr_A[col]
    i_B = colptr_B[col]
    end_A = colptr_A[col+1]
    end_B = colptr_B[col+1]

    count = 0
    while i_A < end_A && i_B < end_B
        row_A = rowval_A[i_A]
        row_B = rowval_B[i_B]
        if row_A < row_B
            count += 1
            i_A += 1
        elseif row_A > row_B
            count += 1
            i_B += 1
        else  # row_A == row_B
            count += 1
            i_A += 1
            i_B += 1
        end
    end

    # Add remaining entries from A
    count += (end_A - i_A)
    # Add remaining entries from B
    count += (end_B - i_B)

    nnz_per_col[col] = count
end

# Kernel for merging two CSC matrices (addition)
@kernel inbounds=true function kernel_merge_csc!(
    rowval_C,
    nzval_C,
    @Const(colptr_C),
    @Const(colptr_A),
    @Const(rowval_A),
    @Const(nzval_A),
    @Const(colptr_B),
    @Const(rowval_B),
    @Const(nzval_B),
)
    col = @index(Global)

    i_A = colptr_A[col]
    i_B = colptr_B[col]
    i_C = colptr_C[col]
    end_A = colptr_A[col+1]
    end_B = colptr_B[col+1]

    while i_A < end_A && i_B < end_B
        row_A = rowval_A[i_A]
        row_B = rowval_B[i_B]
        if row_A < row_B
            rowval_C[i_C] = row_A
            nzval_C[i_C] = nzval_A[i_A]
            i_A += 1
            i_C += 1
        elseif row_A > row_B
            rowval_C[i_C] = row_B
            nzval_C[i_C] = nzval_B[i_B]
            i_B += 1
            i_C += 1
        else  # row_A == row_B
            rowval_C[i_C] = row_A
            nzval_C[i_C] = nzval_A[i_A] + nzval_B[i_B]
            i_A += 1
            i_B += 1
            i_C += 1
        end
    end

    # Copy remaining entries from A
    while i_A < end_A
        rowval_C[i_C] = rowval_A[i_A]
        nzval_C[i_C] = nzval_A[i_A]
        i_A += 1
        i_C += 1
    end

    # Copy remaining entries from B
    while i_B < end_B
        rowval_C[i_C] = rowval_B[i_B]
        nzval_C[i_C] = nzval_B[i_B]
        i_B += 1
        i_C += 1
    end
end
