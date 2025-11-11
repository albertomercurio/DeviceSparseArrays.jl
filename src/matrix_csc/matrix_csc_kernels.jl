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
