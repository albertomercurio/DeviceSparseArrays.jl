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
            Tv = float_types[end]
            Ti = int_types[end]
            A = SparseMatrixCSC{Tv,Ti}(sprand(100, 200, 0.05))

            # Test CSC → COO → CSC round-trip
            @testset "CSC ↔ COO" begin
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

            # Test with empty matrices
            @testset "Edge Cases" begin
                # Empty matrix
                A_empty = spzeros(Tv, Ti, 3, 4)
                A_csc_empty = adapt(op, DeviceSparseMatrixCSC(A_empty))
                A_coo_empty = DeviceSparseMatrixCOO(A_csc_empty)
                @test nnz(A_coo_empty) == 0
                @test size(A_coo_empty) == (3, 4)
            end
        end
    end
end
