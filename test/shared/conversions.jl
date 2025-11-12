function shared_test_conversions(
    op,
    array_type::String,
    int_types::Tuple,
    float_types::Tuple,
    complex_types::Tuple,
)
    @testset "Format Conversions $array_type" verbose=true begin
        # Many conversion functions rely on AcceleratedKernels sortperm
        # which is not supported on JLBackend. Therefore, we skip conversion
        # tests for JLArray.
        if array_type != "JLArray"
            # Test CSC → COO → CSC round-trip
            @testset "CSC ↔ COO" begin
                A = sparse(
                    [1, 2, 3, 1, 2],
                    [1, 2, 3, 2, 3],
                    float_types[end][1.0, 2.0, 3.0, 4.0, 5.0],
                    3,
                    3,
                )

                # CSC → COO
                A_csc = adapt(op, DeviceSparseMatrixCSC(A))
                A_coo_from_csc = DeviceSparseMatrixCOO(A_csc)
                @test collect(SparseMatrixCSC(A_coo_from_csc)) ≈ collect(A)

                # COO → CSC
                A_coo = adapt(op, DeviceSparseMatrixCOO(A))
                A_csc_from_coo = DeviceSparseMatrixCSC(A_coo)
                @test collect(SparseMatrixCSC(A_csc_from_coo)) ≈ collect(A)

                # Round-trip
                A_csc_roundtrip = DeviceSparseMatrixCSC(DeviceSparseMatrixCOO(A_csc))
                @test collect(SparseMatrixCSC(A_csc_roundtrip)) ≈ collect(A)
            end

            # Test CSR → COO → CSR round-trip
            @testset "CSR ↔ COO" begin
                A = sparse(
                    [1, 2, 3, 1, 2],
                    [1, 2, 3, 2, 3],
                    float_types[end][1.0, 2.0, 3.0, 4.0, 5.0],
                    3,
                    3,
                )

                # CSR → COO
                A_csr = adapt(op, DeviceSparseMatrixCSR(A))
                A_coo_from_csr = DeviceSparseMatrixCOO(A_csr)
                @test collect(SparseMatrixCSC(A_coo_from_csr)) ≈ collect(A)

                # COO → CSR
                A_coo = adapt(op, DeviceSparseMatrixCOO(A))
                A_csr_from_coo = DeviceSparseMatrixCSR(A_coo)
                @test collect(SparseMatrixCSC(A_csr_from_coo)) ≈ collect(A)

                # Round-trip
                A_csr_roundtrip = DeviceSparseMatrixCSR(DeviceSparseMatrixCOO(A_csr))
                @test collect(SparseMatrixCSC(A_csr_roundtrip)) ≈ collect(A)
            end

            # Test with different data types
            @testset "Different Types" begin
                # Test with Float32
                A_f32 = sparse([1, 2], [1, 2], float_types[1][1.0f0, 2.0f0], 2, 2)
                A_csc_f32 = adapt(op, DeviceSparseMatrixCSC(A_f32))
                A_coo_f32 = DeviceSparseMatrixCOO(A_csc_f32)
                @test collect(SparseMatrixCSC(A_coo_f32)) ≈ collect(A_f32)

                # Test with ComplexF64
                A_c64 = sparse([1, 2], [1, 2], complex_types[end][1.0+im, 2.0-im], 2, 2)
                A_csr_c64 = adapt(op, DeviceSparseMatrixCSR(A_c64))
                A_coo_c64 = DeviceSparseMatrixCOO(A_csr_c64)
                @test collect(SparseMatrixCSC(A_coo_c64)) ≈ collect(A_c64)
            end

            # Test with empty matrices
            @testset "Edge Cases" begin
                # Empty matrix
                A_empty = spzeros(float_types[end], 3, 3)
                A_csc_empty = adapt(op, DeviceSparseMatrixCSC(A_empty))
                A_coo_empty = DeviceSparseMatrixCOO(A_csc_empty)
                @test nnz(A_coo_empty) == 0
                @test size(A_coo_empty) == (3, 3)

                # Single element
                A_single = sparse([1], [1], float_types[end][42.0], 1, 1)
                A_csr_single = adapt(op, DeviceSparseMatrixCSR(A_single))
                A_coo_single = DeviceSparseMatrixCOO(A_csr_single)
                @test collect(SparseMatrixCSC(A_coo_single)) ≈ collect(A_single)
            end

            # Test large matrix conversion
            @testset "Large Matrix" begin
                A_large = sprand(float_types[end], 100, 100, 0.05)

                # CSC → COO → CSC
                A_csc_large = adapt(op, DeviceSparseMatrixCSC(A_large))
                A_coo_large = DeviceSparseMatrixCOO(A_csc_large)
                A_csc_back = DeviceSparseMatrixCSC(A_coo_large)
                @test collect(SparseMatrixCSC(A_csc_back)) ≈ collect(A_large)

                # CSR → COO → CSR
                A_csr_large = adapt(op, DeviceSparseMatrixCSR(A_large))
                A_coo_large2 = DeviceSparseMatrixCOO(A_csr_large)
                A_csr_back = DeviceSparseMatrixCSR(A_coo_large2)
                @test collect(SparseMatrixCSC(A_csr_back)) ≈ collect(A_large)
            end
        end
    end
end
