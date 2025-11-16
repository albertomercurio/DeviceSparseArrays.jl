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

            # Test CSC ↔ COO conversions
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

            # Test CSR ↔ COO conversions
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

            # Test CSC ↔ CSR conversions (through COO internally)
            @testset "CSC ↔ CSR" begin
                # CSC → CSR
                A_csc = adapt(op, DeviceSparseMatrixCSC(A))
                A_csr_from_csc = DeviceSparseMatrixCSR(A_csc)
                @test collect(SparseMatrixCSC(A_csr_from_csc)) ≈ collect(A)

                # CSR → CSC
                A_csr = adapt(op, DeviceSparseMatrixCSR(A))
                A_csc_from_csr = DeviceSparseMatrixCSC(A_csr)
                @test collect(SparseMatrixCSC(A_csc_from_csr)) ≈ collect(A)

                # Round-trip
                A_csc_roundtrip = DeviceSparseMatrixCSC(DeviceSparseMatrixCSR(A_csc))
                @test collect(SparseMatrixCSC(A_csc_roundtrip)) ≈ collect(A)
            end

            # Test conversions from/to SparseMatrixCSC
            @testset "SparseMatrixCSC Conversions" begin
                # SparseMatrixCSC → DeviceSparseMatrixCSC → SparseMatrixCSC
                A_csc = DeviceSparseMatrixCSC(A)
                A_csc_device = adapt(op, A_csc)
                @test collect(SparseMatrixCSC(A_csc_device)) ≈ collect(A)

                # SparseMatrixCSC → DeviceSparseMatrixCSR → SparseMatrixCSC
                A_csr = DeviceSparseMatrixCSR(A)
                A_csr_device = adapt(op, A_csr)
                @test collect(SparseMatrixCSC(A_csr_device)) ≈ collect(A)

                # SparseMatrixCSC → DeviceSparseMatrixCOO → SparseMatrixCSC
                A_coo = DeviceSparseMatrixCOO(A)
                A_coo_device = adapt(op, A_coo)
                @test collect(SparseMatrixCSC(A_coo_device)) ≈ collect(A)
            end

            # Test transpose conversions
            @testset "Transpose Conversions" begin
                # CSC transpose
                A_csc = adapt(op, DeviceSparseMatrixCSC(A))
                A_csc_t = transpose(A_csc)
                @test collect(SparseMatrixCSC(A_csc_t)) ≈ collect(transpose(A))

                # CSR transpose
                A_csr = adapt(op, DeviceSparseMatrixCSR(A))
                A_csr_t = transpose(A_csr)
                @test collect(SparseMatrixCSC(A_csr_t)) ≈ collect(transpose(A))

                # CSR transpose → CSC conversion (direct path)
                A_csc_from_csr_t = DeviceSparseMatrixCSC(A_csr_t)
                @test collect(SparseMatrixCSC(A_csc_from_csr_t)) ≈ collect(transpose(A))

                # CSC transpose → CSR conversion
                A_csr_from_csc_t = DeviceSparseMatrixCSR(A_csc_t)
                @test collect(SparseMatrixCSC(A_csr_from_csc_t)) ≈ collect(transpose(A))
            end

            # Test adjoint conversions with complex matrices
            @testset "Adjoint Conversions" begin
                Tvc = complex_types[end]
                A_complex = SparseMatrixCSC{Tvc,Ti}(sprand(ComplexF64, 100, 200, 0.05))

                # CSC adjoint
                A_csc = adapt(op, DeviceSparseMatrixCSC(A_complex))
                A_csc_adj = adjoint(A_csc)
                @test collect(SparseMatrixCSC(A_csc_adj)) ≈ collect(adjoint(A_complex))

                # CSR adjoint
                A_csr = adapt(op, DeviceSparseMatrixCSR(A_complex))
                A_csr_adj = adjoint(A_csr)
                @test collect(SparseMatrixCSC(A_csr_adj)) ≈ collect(adjoint(A_complex))

                # CSR adjoint → CSC conversion (direct path)
                A_csc_from_csr_adj = DeviceSparseMatrixCSC(A_csr_adj)
                @test collect(SparseMatrixCSC(A_csc_from_csr_adj)) ≈
                      collect(adjoint(A_complex))

                # CSC adjoint → CSR conversion
                A_csr_from_csc_adj = DeviceSparseMatrixCSR(A_csc_adj)
                @test collect(SparseMatrixCSC(A_csr_from_csc_adj)) ≈
                      collect(adjoint(A_complex))
            end

            # Test edge cases
            @testset "Edge Cases" begin
                # Empty matrix
                A_empty = spzeros(Tv, Ti, 3, 4)
                A_csc_empty = adapt(op, DeviceSparseMatrixCSC(A_empty))
                A_coo_empty = DeviceSparseMatrixCOO(A_csc_empty)
                @test nnz(A_coo_empty) == 0
                @test size(A_coo_empty) == (3, 4)

                # Empty matrix CSR conversion
                A_csr_empty = DeviceSparseMatrixCSR(A_csc_empty)
                @test nnz(A_csr_empty) == 0
                @test size(A_csr_empty) == (3, 4)

                # Single element matrix
                A_single = sparse([1], [2], [Tv(5.0)], 3, 4)
                A_csc_single = adapt(op, DeviceSparseMatrixCSC(A_single))
                A_coo_single = DeviceSparseMatrixCOO(A_csc_single)
                @test nnz(A_coo_single) == 1
                @test collect(SparseMatrixCSC(A_coo_single)) ≈ collect(A_single)

                # Single element CSR conversion
                A_csr_single = DeviceSparseMatrixCSR(A_csc_single)
                @test nnz(A_csr_single) == 1
                @test collect(SparseMatrixCSC(A_csr_single)) ≈ collect(A_single)

                # Full row matrix
                A_row = sparse([1, 1, 1, 1], [1, 2, 3, 4], Tv[1, 2, 3, 4], 3, 4)
                A_csc_row = adapt(op, DeviceSparseMatrixCSC(A_row))
                A_csr_row = DeviceSparseMatrixCSR(A_csc_row)
                @test collect(SparseMatrixCSC(A_csr_row)) ≈ collect(A_row)

                # Full column matrix
                A_col = sparse([1, 2, 3], [2, 2, 2], Tv[1, 2, 3], 3, 4)
                A_csc_col = adapt(op, DeviceSparseMatrixCSC(A_col))
                A_csr_col = DeviceSparseMatrixCSR(A_csc_col)
                @test collect(SparseMatrixCSC(A_csr_col)) ≈ collect(A_col)
            end
        end
    end
end
