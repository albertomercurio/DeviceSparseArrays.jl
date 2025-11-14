function shared_test_kron(
    op,
    array_type::String,
    int_types::Tuple,
    float_types::Tuple,
    complex_types::Tuple,
)
    @testset "Kronecker Product" verbose=true begin
        shared_test_kron_coo(op, array_type, int_types, float_types, complex_types)
        shared_test_kron_csc(op, array_type, int_types, float_types, complex_types)
        shared_test_kron_csr(op, array_type, int_types, float_types, complex_types)
        shared_test_kron_mixed(op, array_type, int_types, float_types, complex_types)
    end
end

function shared_test_kron_coo(
    op,
    array_type::String,
    int_types::Tuple,
    float_types::Tuple,
    complex_types::Tuple,
)
    @testset "COO format" begin
        for T in (int_types..., float_types..., complex_types...)
            # Test basic Kronecker product
            A_sparse = sparse([1, 2], [1, 2], T[1, 2], 2, 2)
            B_sparse = sparse([1, 2], [1, 2], T[3, 4], 2, 2)
            
            A = adapt(op, DeviceSparseMatrixCOO(A_sparse))
            B = adapt(op, DeviceSparseMatrixCOO(B_sparse))
            
            C = kron(A, B)
            C_expected = kron(A_sparse, B_sparse)
            
            @test size(C) == size(C_expected)
            @test nnz(C) == nnz(C_expected)
            @test SparseMatrixCSC(C) ≈ C_expected
            @test C isa DeviceSparseMatrixCOO
            
            # Test with different sizes
            A_sparse = sprand(T, 3, 4, 0.5)
            B_sparse = sprand(T, 2, 3, 0.5)
            
            A = adapt(op, DeviceSparseMatrixCOO(A_sparse))
            B = adapt(op, DeviceSparseMatrixCOO(B_sparse))
            
            C = kron(A, B)
            C_expected = kron(A_sparse, B_sparse)
            
            @test size(C) == size(C_expected)
            @test nnz(C) == nnz(C_expected)
            @test SparseMatrixCSC(C) ≈ C_expected
            
            # Test with empty matrix
            A_sparse = spzeros(T, 2, 2)
            B_sparse = sparse([1], [1], T[5], 2, 2)
            
            A = adapt(op, DeviceSparseMatrixCOO(A_sparse))
            B = adapt(op, DeviceSparseMatrixCOO(B_sparse))
            
            C = kron(A, B)
            C_expected = kron(A_sparse, B_sparse)
            
            @test size(C) == size(C_expected)
            @test nnz(C) == 0
            @test SparseMatrixCSC(C) ≈ C_expected
        end
    end
end

function shared_test_kron_csc(
    op,
    array_type::String,
    int_types::Tuple,
    float_types::Tuple,
    complex_types::Tuple,
)
    @testset "CSC format" begin
        for T in (int_types..., float_types..., complex_types...)
            # Test basic Kronecker product
            A_sparse = sparse([1, 2], [1, 2], T[1, 2], 2, 2)
            B_sparse = sparse([1, 2], [1, 2], T[3, 4], 2, 2)
            
            A = adapt(op, DeviceSparseMatrixCSC(A_sparse))
            B = adapt(op, DeviceSparseMatrixCSC(B_sparse))
            
            C = kron(A, B)
            C_expected = kron(A_sparse, B_sparse)
            
            @test size(C) == size(C_expected)
            @test nnz(C) == nnz(C_expected)
            @test SparseMatrixCSC(C) ≈ C_expected
            @test C isa DeviceSparseMatrixCSC
            
            # Test with different sizes
            A_sparse = sprand(T, 3, 4, 0.5)
            B_sparse = sprand(T, 2, 3, 0.5)
            
            A = adapt(op, DeviceSparseMatrixCSC(A_sparse))
            B = adapt(op, DeviceSparseMatrixCSC(B_sparse))
            
            C = kron(A, B)
            C_expected = kron(A_sparse, B_sparse)
            
            @test size(C) == size(C_expected)
            @test nnz(C) == nnz(C_expected)
            @test SparseMatrixCSC(C) ≈ C_expected
        end
    end
end

function shared_test_kron_csr(
    op,
    array_type::String,
    int_types::Tuple,
    float_types::Tuple,
    complex_types::Tuple,
)
    @testset "CSR format" begin
        for T in (int_types..., float_types..., complex_types...)
            # Test basic Kronecker product
            A_sparse = sparse([1, 2], [1, 2], T[1, 2], 2, 2)
            B_sparse = sparse([1, 2], [1, 2], T[3, 4], 2, 2)
            
            A = adapt(op, DeviceSparseMatrixCSR(DeviceSparseMatrixCOO(A_sparse)))
            B = adapt(op, DeviceSparseMatrixCSR(DeviceSparseMatrixCOO(B_sparse)))
            
            C = kron(A, B)
            C_expected = kron(A_sparse, B_sparse)
            
            @test size(C) == size(C_expected)
            @test nnz(C) == nnz(C_expected)
            @test Matrix(SparseMatrixCSC(C)) ≈ Matrix(C_expected)
            @test C isa DeviceSparseMatrixCSR
            
            # Test with different sizes
            A_sparse = sprand(T, 3, 4, 0.5)
            B_sparse = sprand(T, 2, 3, 0.5)
            
            A = adapt(op, DeviceSparseMatrixCSR(DeviceSparseMatrixCOO(A_sparse)))
            B = adapt(op, DeviceSparseMatrixCSR(DeviceSparseMatrixCOO(B_sparse)))
            
            C = kron(A, B)
            C_expected = kron(A_sparse, B_sparse)
            
            @test size(C) == size(C_expected)
            @test nnz(C) == nnz(C_expected)
            @test Matrix(SparseMatrixCSC(C)) ≈ Matrix(C_expected)
        end
    end
end

function shared_test_kron_mixed(
    op,
    array_type::String,
    int_types::Tuple,
    float_types::Tuple,
    complex_types::Tuple,
)
    @testset "Mixed formats" begin
        for T in (float_types..., complex_types...)
            # Test CSC × COO
            A_sparse = sprand(T, 3, 3, 0.5)
            B_sparse = sprand(T, 2, 2, 0.5)
            
            A = adapt(op, DeviceSparseMatrixCSC(A_sparse))
            B = adapt(op, DeviceSparseMatrixCOO(B_sparse))
            
            C = kron(A, B)
            C_expected = kron(A_sparse, B_sparse)
            
            @test size(C) == size(C_expected)
            @test nnz(C) == nnz(C_expected)
            @test Matrix(SparseMatrixCSC(C)) ≈ Matrix(C_expected)
            @test C isa DeviceSparseMatrixCSC  # Result type follows first argument
            
            # Test COO × CSR
            A = adapt(op, DeviceSparseMatrixCOO(A_sparse))
            B = adapt(op, DeviceSparseMatrixCSR(DeviceSparseMatrixCOO(B_sparse)))
            
            C = kron(A, B)
            C_expected = kron(A_sparse, B_sparse)
            
            @test size(C) == size(C_expected)
            @test nnz(C) == nnz(C_expected)
            @test Matrix(SparseMatrixCSC(C)) ≈ Matrix(C_expected)
            @test C isa DeviceSparseMatrixCOO  # Result type follows first argument
            
            # Test type promotion
            A_int = sparse([1, 2], [1, 2], Int32[1, 2], 2, 2)
            B_float = sparse([1, 2], [1, 2], Float64[3.0, 4.0], 2, 2)
            
            A = adapt(op, DeviceSparseMatrixCSC(A_int))
            B = adapt(op, DeviceSparseMatrixCSC(B_float))
            
            C = kron(A, B)
            C_expected = kron(A_int, B_float)
            
            @test eltype(C) == Float64
            @test Matrix(SparseMatrixCSC(C)) ≈ Matrix(C_expected)
        end
    end
end

function shared_test_kron_quality(op, T::Type)
    # Quality test for JET
    A = sprand(T, 5, 5, 0.3)
    B = sprand(T, 3, 3, 0.4)
    
    dA_coo = adapt(op, DeviceSparseMatrixCOO(A))
    dB_coo = adapt(op, DeviceSparseMatrixCOO(B))
    
    dA_csc = adapt(op, DeviceSparseMatrixCSC(A))
    dB_csc = adapt(op, DeviceSparseMatrixCSC(B))
    
    # Test COO kron
    C_coo = kron(dA_coo, dB_coo)
    
    # Test CSC kron
    C_csc = kron(dA_csc, dB_csc)
    
    # Test mixed format
    C_mixed = kron(dA_csc, dB_coo)
    
    return nothing
end
