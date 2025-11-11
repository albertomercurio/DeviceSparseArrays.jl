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
