@kernel inbounds=true function kernel_spmatmul_csr_N!(
    C,
    @Const(rowptr),
    @Const(colval),
    @Const(nzval),
    @Const(B),
    α,
    ::Val{CONJA},
    ::Val{CONJB},
    ::Val{TRANSB},
) where {CONJA,CONJB,TRANSB}
    k, row = @index(Global, NTuple)

    tmp = zero(eltype(C))
    for j = rowptr[row]:(rowptr[row+1]-1) # nzrange(A, row)
        Bi, Bj = TRANSB ? (k, colval[j]) : (colval[j], k)
        vala = CONJA ? conj(nzval[j]) : nzval[j]
        valb = CONJB ? conj(B[Bi, Bj]) : B[Bi, Bj]
        tmp += vala * valb
    end
    C[row, k] += tmp * α
end

@kernel inbounds=true function kernel_spmatmul_csr_T!(
    C,
    @Const(rowptr),
    @Const(colval),
    @Const(nzval),
    @Const(B),
    α,
    ::Val{CONJA},
    ::Val{CONJB},
    ::Val{TRANSB},
) where {CONJA,CONJB,TRANSB}
    k, row = @index(Global, NTuple)

    Bi, Bj = TRANSB ? (k, row) : (row, k)

    valb = CONJB ? conj(B[Bi, Bj]) : B[Bi, Bj]
    axj = valb * α
    for j = rowptr[row]:(rowptr[row+1]-1) # nzrange(A, row)
        vala = CONJA ? conj(nzval[j]) : nzval[j]
        @atomic C[colval[j], k] += vala * axj
    end
end

@kernel inbounds=true unsafe_indices=true function kernel_workgroup_dot_csr_N!(
    block_results,
    @Const(x),
    @Const(rowptr),
    @Const(colval),
    @Const(nzval),
    @Const(y),
    @Const(m),
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

    # Each work-item accumulates its contribution from rows with stride
    local_sum = zero(eltype(block_results))
    for row = global_id:stride:m
        for j = rowptr[row]:(rowptr[row+1]-1)
            vala = CONJA ? conj(nzval[j]) : nzval[j]
            local_sum += dot(x[row], vala, y[colval[j]])
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

@kernel inbounds=true unsafe_indices=true function kernel_workgroup_dot_csr_T!(
    block_results,
    @Const(x),
    @Const(rowptr),
    @Const(colval),
    @Const(nzval),
    @Const(y),
    @Const(m),
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

    # Each work-item accumulates its contribution from rows with stride
    local_sum = zero(eltype(block_results))
    for row = global_id:stride:m
        for j = rowptr[row]:(rowptr[row+1]-1)
            vala = CONJA ? conj(nzval[j]) : nzval[j]
            local_sum += dot(x[colval[j]], vala, y[row])
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
