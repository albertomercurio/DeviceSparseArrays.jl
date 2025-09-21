function shared_test_vector_quality(op, T; kwargs...) end

function shared_test_matrix_csc_quality(op, T; kwargs...)
    shared_test_matrix_csc_quality_basic_linearalgebra(op, T; kwargs...)
    shared_test_matrix_csc_quality_spmv_spmm(op, T; kwargs...)
end

function shared_test_matrix_csc_quality_basic_linearalgebra(op, T; kwargs...)
    A = sprand(T, 1000, 1000, 0.01)
    dA = DeviceSparseMatrixCSC(A.m, A.n, op(getcolptr(A)), op(rowvals(A)), op(nonzeros(A)))

    sum(dA)

    if T in (ComplexF32, ComplexF64)
        # The kernel functions may use @atomic for CSC matrices, which does not support Complex types in JLArray
        return nothing
    end

    tr(dA)

    return nothing
end

function shared_test_matrix_csc_quality_spmv_spmm(op, T; kwargs...)
    op_A = kwargs[:op_A]
    op_B = kwargs[:op_B]

    if T in (ComplexF32, ComplexF64) && op_A === identity
        # The mul! function uses @atomic for CSC matrices, which does not support Complex types
        return nothing
    end
    dims_A = op_A === identity ? (100, 80) : (80, 100)
    dims_B = op_B === identity ? (80, 50) : (50, 80)

    A = sprand(T, dims_A..., 0.1)
    B = rand(T, dims_B...)
    b = rand(T, 80)

    dA = DeviceSparseMatrixCSC(
        size(A, 1),
        size(A, 2),
        op(getcolptr(A)),
        op(rowvals(A)),
        op(nonzeros(A)),
    )
    dB = op(B)
    db = op(b)

    # Matrix-Vector and Matrix-Matrix multiplication
    op_A(dA) * db
    op_A(dA) * op_B(dB)

    return nothing
end

function shared_test_matrix_csr_quality(op, T; kwargs...)
    shared_test_matrix_csr_quality_basic_linearalgebra(op, T; kwargs...)
    shared_test_matrix_csr_quality_spmv(op, T; kwargs...)
end

function shared_test_matrix_csr_quality_basic_linearalgebra(op, T; kwargs...)
    A = sprand(T, 1000, 1000, 0.01)
    # Convert to CSR storage pattern
    A_csr = SparseMatrixCSC(transpose(A))
    dA = DeviceSparseMatrixCSR(
        A.m,
        A.n,
        op(A_csr.colptr),  # rowptr
        op(A_csr.rowval),  # colval
        op(A_csr.nzval),   # nzval
    )

    sum(dA)

    if T in (ComplexF32, ComplexF64)
        # The kernel functions may use @atomic for CSR matrices, which does not support Complex types in JLArray
        return nothing
    end

    tr(dA)

    return nothing
end

function shared_test_matrix_csr_quality_spmv(op, T; kwargs...)
    op_A = kwargs[:op_A]
    op_B = kwargs[:op_B]

    if T in (ComplexF32, ComplexF64) && op_A !== identity
        # The mul! function uses @atomic for CSR matrices, which does not support Complex types
        return nothing
    end
    dims_A = op_A === identity ? (100, 80) : (80, 100)
    dims_B = op_B === identity ? (80, 50) : (50, 80)

    A = sprand(T, dims_A..., 0.1)
    B = rand(T, dims_B...)
    b = rand(T, 80)

    # Convert to CSR storage pattern
    A_csr = SparseMatrixCSC(transpose(A))
    dA = DeviceSparseMatrixCSR(
        size(A, 1),
        size(A, 2),
        op(getcolptr(A_csr)),
        op(rowvals(A_csr)),
        op(nonzeros(A_csr)),
    )
    dB = op(B)
    db = op(b)

    # Matrix-Vector and Matrix-Matrix multiplication
    op_A(dA) * db
    op_A(dA) * op_B(dB)

    return nothing
end
