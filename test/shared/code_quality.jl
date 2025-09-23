function shared_test_vector_quality(op, T; kwargs...)
    shared_test_vector_quality_conversion(op, T; kwargs...)
    shared_test_vector_quality_linearalgebra(op, T; kwargs...)
    shared_test_vector_quality_scalar_operations(op, T; kwargs...)
    shared_test_vector_quality_unary_operations(op, T; kwargs...)
    shared_test_vector_quality_norms(op, T; kwargs...)
end

function shared_test_vector_quality_conversion(op, T; kwargs...)
    sv = SparseVector(10, Int[], T[])
    sv2 = sparsevec([3], [T(2.5)], 8)

    # Test conversion SparseVector <-> DeviceSparseVector
    dsv = adapt(op, DeviceSparseVector(sv))
    size(dsv)
    length(dsv)
    nnz(dsv)
    collect(nonzeros(dsv))
    collect(nonzeroinds(dsv))

    dsv2 = adapt(op, DeviceSparseVector(sv2))
    size(dsv2)
    length(dsv2)
    nnz(dsv2)
    collect(nonzeros(dsv2))
    collect(nonzeroinds(dsv2))
    SparseVector(dsv2)

    return nothing
end

function shared_test_vector_quality_linearalgebra(op, T; kwargs...)
    v = sprand(T, 1000, 0.01)
    y = rand(T, 1000)
    dv = adapt(op, DeviceSparseVector(v))
    dy = op(y)

    sum(dv)

    if T in (ComplexF32, ComplexF64)
        # The kernel functions may use @atomic, which does not support Complex types in JLArray
        return nothing
    end

    dot(dv, dy)
    dot(dy, dv)

    return nothing
end

function shared_test_vector_quality_scalar_operations(op, T; kwargs...)
    v = sprand(T, 100, 0.3)
    dv = adapt(op, DeviceSparseVector(v))

    α = T <: Complex ? T(2.0 + 1.0im) : (T <: Integer ? T(2) : T(2.5))

    # Test scalar multiplication
    scaled_left = α * dv
    scaled_right = dv * α
    nnz(scaled_left) == nnz(dv)
    nnz(scaled_right) == nnz(dv)
    collect(nonzeros(scaled_left)) ≈ α .* collect(nonzeros(dv))
    collect(nonzeros(scaled_right)) ≈ collect(nonzeros(dv)) .* α

    # Test scalar division
    if !(T <: Integer)  # Skip division for integer types
        divided = dv / α
        nnz(divided) == nnz(dv)
        collect(nonzeros(divided)) ≈ collect(nonzeros(dv)) ./ α
    end

    return nothing
end

function shared_test_vector_quality_unary_operations(op, T; kwargs...)
    if !(T <: Union{Float32,Float64,ComplexF32,ComplexF64})
        return nothing
    end

    v = sprand(T, 80, 0.4)
    dv = adapt(op, DeviceSparseVector(v))

    # Test unary plus (inherited from AbstractArray)
    pos_v = +dv
    nnz(pos_v) == nnz(dv)
    collect(nonzeros(pos_v)) ≈ collect(nonzeros(dv))

    # Test unary minus
    neg_v = -dv
    nnz(neg_v) == nnz(dv)
    collect(nonzeros(neg_v)) ≈ -collect(nonzeros(dv))

    # Test complex operations
    if T <: Complex
        conj_v = conj(dv)
        real_v = real(dv)
        imag_v = imag(dv)

        nnz(conj_v) == nnz(dv)
        eltype(conj_v) == T
        collect(nonzeros(conj_v)) ≈ conj.(collect(nonzeros(dv)))

        eltype(real_v) == real(T)
        collect(nonzeros(real_v)) ≈ real.(collect(nonzeros(dv)))

        eltype(imag_v) == real(T)
        collect(nonzeros(imag_v)) ≈ imag.(collect(nonzeros(dv)))
    else
        # For real types
        conj_v = conj(dv)
        real_v = real(dv)
        imag_v = imag(dv)

        conj_v === dv  # Should return same object for real types
        real_v === dv  # Should return same object for real types
        nnz(imag_v) == 0  # Imaginary part of real should be zero sparse
    end

    return nothing
end

function shared_test_vector_quality_norms(op, T; kwargs...)
    if !(T <: Union{Float32,Float64,ComplexF32,ComplexF64})
        return nothing
    end

    v = sprand(T, 50, 0.5)
    dv = adapt(op, DeviceSparseVector(v))

    # Test different norms
    norm2 = norm(dv)
    norm1 = norm(dv, 1)
    norm_inf = norm(dv, Inf)

    norm2 ≈ norm(v, 2)
    norm1 ≈ norm(v, 1)
    norm_inf ≈ norm(v, Inf)

    # Test normalization (skip if zero vector)
    if norm2 > 0
        v_normalized = normalize(dv)
        norm(v_normalized) ≈ 1.0

        # Test in-place normalization
        v_copy = copy(dv)
        normalize!(v_copy)
        norm(v_copy) ≈ 1.0
    end

    return nothing
end

function shared_test_matrix_csc_quality(op, T; kwargs...)
    shared_test_matrix_csc_quality_conversion(op, T; kwargs...)
    shared_test_matrix_csc_quality_basic_linearalgebra(op, T; kwargs...)
    shared_test_matrix_csc_quality_scalar_operations(op, T; kwargs...)
    shared_test_matrix_csc_quality_unary_operations(op, T; kwargs...)
    shared_test_matrix_csc_quality_uniformscaling(op, T; kwargs...)
    shared_test_matrix_csc_quality_spmv_spmm(op, T; kwargs...)
end

function shared_test_matrix_csc_quality_conversion(op, T; kwargs...)
    A = spzeros(T, 0, 0)
    rows = [1, 2, 1]
    cols = [1, 1, 2]
    vals = T.([1.0, 2.0, 3.0])
    B = sparse(rows, cols, vals, 2, 2)

    dA = adapt(op, DeviceSparseMatrixCSC(A))
    size(dA)
    length(dA)
    nnz(dA)
    collect(nonzeros(dA))

    dB = adapt(op, DeviceSparseMatrixCSC(B))
    size(dB)
    length(dB)
    nnz(dB)
    collect(nonzeros(dB))
    collect(rowvals(dB))
    collect(getcolptr(dB))
    SparseMatrixCSC(dB)

    return nothing
end

function shared_test_matrix_csc_quality_scalar_operations(op, T; kwargs...)
    A = sprand(T, 50, 40, 0.1)
    dA = adapt(op, DeviceSparseMatrixCSC(A))

    α = T <: Complex ? T(1.5 - 0.5im) : (T <: Integer ? T(2) : T(2.0))

    # Test scalar multiplication
    scaled_left = α * dA
    scaled_right = dA * α
    nnz(scaled_left)
    nnz(scaled_right)
    collect(nonzeros(scaled_left))
    collect(nonzeros(scaled_right))

    # Test scalar division
    if !(T <: Integer)  # Skip division for integer types
        divided = dA / α
        nnz(divided)
        collect(nonzeros(divided))
    end

    return nothing
end

function shared_test_matrix_csc_quality_unary_operations(op, T; kwargs...)
    if !(T <: Union{Float32,Float64,ComplexF32,ComplexF64})
        return nothing
    end

    A = sprand(T, 30, 25, 0.15)
    dA = adapt(op, DeviceSparseMatrixCSC(A))

    # Test unary plus
    pos_A = +dA
    nnz(pos_A)
    collect(nonzeros(pos_A))

    # Test unary minus
    neg_A = -dA
    nnz(neg_A)
    collect(nonzeros(neg_A))

    # Test complex operations
    if T <: Complex
        conj_A = conj(dA)
        real_A = real(dA)
        imag_A = imag(dA)

        nnz(conj_A)
        eltype(conj_A)
        collect(nonzeros(conj_A))

        eltype(real_A)
        collect(nonzeros(real_A))

        eltype(imag_A)
        collect(nonzeros(imag_A))
    else
        # For real types
        conj_A = conj(dA)
        real_A = real(dA)
        imag_A = imag(dA)

        nnz(imag_A)
    end

    return nothing
end

function shared_test_matrix_csc_quality_uniformscaling(op, T; kwargs...)
    if !(T <: Union{Float32,Float64,ComplexF32,ComplexF64})
        return nothing
    end

    A = sprand(T, 20, 20, 0.2)
    dA = adapt(op, DeviceSparseMatrixCSC(A))

    # Test A * I (identity)
    result_I = dA * I
    nnz(result_I)
    collect(nonzeros(result_I))

    # Test I * A (identity)
    result_I2 = I * dA
    nnz(result_I2)
    collect(nonzeros(result_I2))

    # Test with scaled identity
    α = T <: Complex ? T(2.0 + 1.0im) : T(3.0)
    result_αI = dA * (α * I)
    nnz(result_αI)
    collect(nonzeros(result_αI))

    return nothing
end

function shared_test_matrix_csc_quality_basic_linearalgebra(op, T; kwargs...)
    A = sprand(T, 1000, 1000, 0.01)
    dA = adapt(op, DeviceSparseMatrixCSC(A))

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

    dA = adapt(op, DeviceSparseMatrixCSC(A))
    dB = op(B)
    db = op(b)

    # Matrix-Vector and Matrix-Matrix multiplication
    op_A(dA) * db
    op_A(dA) * op_B(dB)

    return nothing
end

function shared_test_matrix_csr_quality(op, T; kwargs...)
    shared_test_matrix_csr_quality_conversion(op, T; kwargs...)
    shared_test_matrix_csr_quality_basic_linearalgebra(op, T; kwargs...)
    shared_test_matrix_csr_quality_scalar_operations(op, T; kwargs...)
    shared_test_matrix_csr_quality_unary_operations(op, T; kwargs...)
    shared_test_matrix_csr_quality_uniformscaling(op, T; kwargs...)
    shared_test_matrix_csr_quality_spmv(op, T; kwargs...)
end

function shared_test_matrix_csr_quality_conversion(op, T; kwargs...)
    A = spzeros(T, 0, 0)
    rows = [1, 2, 1]
    cols = [1, 1, 2]
    vals = T.([1.0, 2.0, 3.0])
    B = sparse(rows, cols, vals, 2, 2)

    # Test CSR conversion
    B_csr = SparseMatrixCSC(transpose(B))  # Get the CSR storage pattern
    dB = adapt(op, DeviceSparseMatrixCSR(transpose(B_csr)))
    dB2 = adapt(op, DeviceSparseMatrixCSR(B)) # Directly from CSC should also work
    size(dB)
    length(dB)
    nnz(dB)
    collect(nonzeros(dB))
    collect(colvals(dB))
    collect(getrowptr(dB))
    SparseMatrixCSC(dB)
    SparseMatrixCSC(dB2)

    return nothing
end

function shared_test_matrix_csr_quality_basic_linearalgebra(op, T; kwargs...)
    A = sprand(T, 1000, 1000, 0.01)
    # Convert to CSR storage pattern
    A_csr = SparseMatrixCSC(transpose(A))
    dA = adapt(op, DeviceSparseMatrixCSR(transpose(A_csr)))

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
    dA = adapt(op, DeviceSparseMatrixCSR(transpose(A_csr)))
    dB = op(B)
    db = op(b)

    # Matrix-Vector and Matrix-Matrix multiplication
    op_A(dA) * db
    op_A(dA) * op_B(dB)

    return nothing
end

function shared_test_matrix_csr_quality_scalar_operations(op, T; kwargs...)
    A = sprand(T, 40, 30, 0.1)
    dA = adapt(op, DeviceSparseMatrixCSR(A))

    α = T <: Complex ? T(1.0 + 2.0im) : (T <: Integer ? T(2) : T(1.5))

    # Test scalar multiplication
    scaled_left = α * dA
    scaled_right = dA * α
    nnz(scaled_left)
    nnz(scaled_right)
    collect(nonzeros(scaled_left))
    collect(nonzeros(scaled_right))

    # Test scalar division
    if !(T <: Integer)  # Skip division for integer types
        divided = dA / α
        nnz(divided)
        collect(nonzeros(divided))
    end

    return nothing
end

function shared_test_matrix_csr_quality_unary_operations(op, T; kwargs...)
    if !(T <: Union{Float32,Float64,ComplexF32,ComplexF64})
        return nothing
    end

    A = sprand(T, 25, 20, 0.15)
    dA = adapt(op, DeviceSparseMatrixCSR(A))

    # Test unary plus
    pos_A = +dA
    nnz(pos_A)
    collect(nonzeros(pos_A))

    # Test unary minus
    neg_A = -dA
    nnz(neg_A)
    collect(nonzeros(neg_A))

    # Test complex operations
    if T <: Complex
        conj_A = conj(dA)
        real_A = real(dA)
        imag_A = imag(dA)

        nnz(conj_A)
        eltype(conj_A)
        collect(nonzeros(conj_A))

        eltype(real_A)
        collect(nonzeros(real_A))

        eltype(imag_A)
        collect(nonzeros(imag_A))
    else
        # For real types
        conj_A = conj(dA)
        real_A = real(dA)
        imag_A = imag(dA)

        nnz(imag_A)
    end

    return nothing
end

function shared_test_matrix_csr_quality_uniformscaling(op, T; kwargs...)
    if !(T <: Union{Float32,Float64,ComplexF32,ComplexF64})
        return nothing
    end

    A = sprand(T, 15, 15, 0.2)
    dA = adapt(op, DeviceSparseMatrixCSR(A))

    # Test A * I (identity)
    result_I = dA * I
    nnz(result_I)
    collect(nonzeros(result_I))

    # Test I * A (identity)
    result_I2 = I * dA
    nnz(result_I2)
    collect(nonzeros(result_I2))

    # Test with scaled identity
    α = T <: Complex ? T(0.5 - 1.5im) : T(2.5)
    result_αI = dA * (α * I)
    nnz(result_αI)
    collect(nonzeros(result_αI))

    return nothing
end
