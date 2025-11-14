# Kernel for computing Kronecker product in COO format
@kernel function kron_coo_kernel!(
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
