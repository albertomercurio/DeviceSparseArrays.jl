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
