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

# Kernel for creating sort keys for COO → CSC conversion
@kernel inbounds=true function kernel_make_csc_keys!(
    keys,
    @Const(rowind),
    @Const(colind),
    @Const(n),
)
    i = @index(Global)
    keys[i] = colind[i] * n + rowind[i]
end

# Kernel for creating sort keys for COO → CSR conversion
@kernel inbounds=true function kernel_make_csr_keys!(
    keys,
    @Const(rowind),
    @Const(colind),
    @Const(m),
)
    i = @index(Global)
    keys[i] = rowind[i] * m + colind[i]
end

# Kernel for counting entries per column (for COO → CSC)
@kernel inbounds=true function kernel_count_per_col!(colptr, @Const(colind_sorted))
    i = @index(Global)
    col = colind_sorted[i]
    @atomic colptr[col+1] += 1
end

# Kernel for counting entries per row (for COO → CSR)
@kernel inbounds=true function kernel_count_per_row!(rowptr, @Const(rowind_sorted))
    i = @index(Global)
    row = rowind_sorted[i]
    @atomic rowptr[row+1] += 1
end
