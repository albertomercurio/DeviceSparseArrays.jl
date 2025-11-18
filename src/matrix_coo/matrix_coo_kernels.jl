@kernel inbounds=true function kernel_spmatmul_coo_N!(
    C,
    @Const(rowind),
    @Const(colind),
    @Const(nzval),
    @Const(B),
    α,
    ::Val{CONJA},
    ::Val{CONJB},
    ::Val{TRANSB},
) where {CONJA,CONJB,TRANSB}
    k, i = @index(Global, NTuple)

    row = rowind[i]
    col = colind[i]
    Bi, Bj = TRANSB ? (k, col) : (col, k)
    vala = CONJA ? conj(nzval[i]) : nzval[i]
    valb = CONJB ? conj(B[Bi, Bj]) : B[Bi, Bj]
    axj = valb * α
    @atomic C[row, k] += vala * axj
end

@kernel inbounds=true function kernel_spmatmul_coo_T!(
    C,
    @Const(rowind),
    @Const(colind),
    @Const(nzval),
    @Const(B),
    α,
    ::Val{CONJA},
    ::Val{CONJB},
    ::Val{TRANSB},
) where {CONJA,CONJB,TRANSB}
    k, i = @index(Global, NTuple)

    row = rowind[i]
    col = colind[i]
    Bi, Bj = TRANSB ? (k, row) : (row, k)
    vala = CONJA ? conj(nzval[i]) : nzval[i]
    valb = CONJB ? conj(B[Bi, Bj]) : B[Bi, Bj]
    axj = valb * α
    @atomic C[col, k] += vala * axj
end

@kernel inbounds=true unsafe_indices=true function kernel_workgroup_dot_coo_N!(
    block_results,
    @Const(x),
    @Const(rowind),
    @Const(colind),
    @Const(nzval),
    @Const(y),
    @Const(nnz_val),
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

    # Each work-item accumulates its contribution from nonzero entries with stride
    local_sum = zero(eltype(block_results))
    for i = global_id:stride:nnz_val
        row = rowind[i]
        col = colind[i]
        vala = CONJA ? conj(nzval[i]) : nzval[i]
        local_sum += dot(x[row], vala, y[col])
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

@kernel inbounds=true unsafe_indices=true function kernel_workgroup_dot_coo_T!(
    block_results,
    @Const(x),
    @Const(rowind),
    @Const(colind),
    @Const(nzval),
    @Const(y),
    @Const(nnz_val),
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

    # Each work-item accumulates its contribution from nonzero entries with stride
    local_sum = zero(eltype(block_results))
    for i = global_id:stride:nnz_val
        row = rowind[i]
        col = colind[i]
        vala = CONJA ? conj(nzval[i]) : nzval[i]
        local_sum += dot(x[col], vala, y[row])
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

# Kernel for adding sparse matrix to dense matrix (COO format)
@kernel inbounds=true function kernel_add_sparse_to_dense_coo!(
    C,
    @Const(rowind),
    @Const(colind),
    @Const(nzval),
)
    i = @index(Global)

    C[rowind[i], colind[i]] += nzval[i]
end

# Kernel for computing Kronecker product in COO format
@kernel inbounds=true function kernel_kron_coo!(
    @Const(rowind_A),
    @Const(colind_A),
    @Const(nzval_A),
    @Const(rowind_B),
    @Const(colind_B),
    @Const(nzval_B),
    rowind_C,
    colind_C,
    nzval_C,
    @Const(m_B::Int),
    @Const(n_B::Int),
)
    idx = @index(Global, Linear)

    nnz_A = length(nzval_A)
    nnz_B = length(nzval_B)

    if idx <= nnz_A * nnz_B
        # Compute which element from A and B we're combining
        idx_A = div(idx - 1, nnz_B) + 1
        idx_B = mod(idx - 1, nnz_B) + 1

        # Get the row and column indices from A and B
        i_A = rowind_A[idx_A]
        j_A = colind_A[idx_A]
        val_A = nzval_A[idx_A]

        i_B = rowind_B[idx_B]
        j_B = colind_B[idx_B]
        val_B = nzval_B[idx_B]

        # Compute the row and column indices in C
        # C[i,j] = A[i_A, j_A] * B[i_B, j_B]
        # where i = (i_A - 1) * m_B + i_B and j = (j_A - 1) * n_B + j_B
        rowind_C[idx] = (i_A - 1) * m_B + i_B
        colind_C[idx] = (j_A - 1) * n_B + j_B
        nzval_C[idx] = val_A * val_B
    end
end

# Kernel for marking duplicate entries in sorted COO format
# Returns a mask where mask[i] = true if entry i should be kept (first occurrence or sum)
@kernel inbounds=true function kernel_mark_unique_coo!(
    keep_mask,
    @Const(rowind),
    @Const(colind),
    @Const(nnz_total),
)
    i = @index(Global)

    if i == 1
        # Always keep the first entry
        keep_mask[i] = true
    elseif i <= nnz_total
        # Keep if different from previous entry
        keep_mask[i] = (rowind[i] != rowind[i-1] || colind[i] != colind[i-1])
    end
end

# Kernel for compacting COO by summing duplicate entries
@kernel inbounds=true function kernel_compact_coo!(
    rowind_out,
    colind_out,
    nzval_out,
    @Const(rowind_in),
    @Const(colind_in),
    @Const(nzval_in),
    @Const(write_indices),
    @Const(nnz_in),
)
    i = @index(Global)

    if i <= nnz_in
        out_idx = write_indices[i]
        
        # If this is a new entry (or first of duplicates), write it
        if i == 1 || (rowind_in[i] != rowind_in[i-1] || colind_in[i] != colind_in[i-1])
            rowind_out[out_idx] = rowind_in[i]
            colind_out[out_idx] = colind_in[i]
            
            # Sum all duplicates
            val_sum = nzval_in[i]
            j = i + 1
            while j <= nnz_in && rowind_in[j] == rowind_in[i] && colind_in[j] == colind_in[i]
                val_sum += nzval_in[j]
                j += 1
            end
            nzval_out[out_idx] = val_sum
        end
    end
end
