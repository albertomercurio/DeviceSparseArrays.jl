# Kernel for converting CSC to COO format
@kernel inbounds=true function kernel_csc_to_coo!(
    rowind,
    colind,
    nzval_out,
    @Const(colptr),
    @Const(rowval),
    @Const(nzval_in),
)
    col = @index(Global)

    @inbounds for j = colptr[col]:(colptr[col+1]-1)
        rowind[j] = rowval[j]
        colind[j] = col
        nzval_out[j] = nzval_in[j]
    end
end

# Kernel for converting CSR to COO format
@kernel inbounds=true function kernel_csr_to_coo!(
    rowind,
    colind,
    nzval_out,
    @Const(rowptr),
    @Const(colval),
    @Const(nzval_in),
)
    row = @index(Global)

    @inbounds for j = rowptr[row]:(rowptr[row+1]-1)
        rowind[j] = row
        colind[j] = colval[j]
        nzval_out[j] = nzval_in[j]
    end
end
