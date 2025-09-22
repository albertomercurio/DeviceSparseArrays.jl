

function shared_test_matrix_csr(op, array_type::String)
    @testset "DeviceSparseMatrixCSR $array_type" verbose=true begin
        @testset "Conversion" begin
            A = spzeros(Float32, 0, 0)
            rows = [1, 2, 1]
            cols = [1, 1, 2]
            vals = [1.0, 2.0, 3.0]
            B = sparse(rows, cols, vals, 2, 2)

            # test only conversion SparseMatrixCSC <-> DeviceSparseMatrixCSR
            if op === Array
                dA = DeviceSparseMatrixCSR(A)
                @test size(dA) == (0, 0)
                @test length(dA) == 0
                @test collect(nonzeros(dA)) == Float32[]
                @test SparseMatrixCSC(dA) == A
            end

            # Convert CSC to CSR pattern by transposing
            B_csr = SparseMatrixCSC(transpose(B))  # Get the CSR storage pattern
            dB = adapt(op, DeviceSparseMatrixCSR(transpose(B_csr)))
            @test size(dB) == (2, 2)
            @test length(dB) == 4
            @test nnz(dB) == 3
            @test collect(nonzeros(dB)) == collect(B_csr.nzval)
            @test collect(colvals(dB)) == collect(B_csr.rowval)
            @test collect(getrowptr(dB)) == collect(B_csr.colptr)
            @test SparseMatrixCSC(dB) == B

            @test_throws ArgumentError DeviceSparseMatrixCSR(
                2,
                2,
                op([1, 3]),
                op([1]),
                op([1.0]),
            )
        end

        @testset "Basic LinearAlgebra" begin
            for T in (Int32, Int64, Float32, Float64, ComplexF32, ComplexF64)
                A = sprand(T, 1000, 1000, 0.01)
                # Convert to CSR storage pattern
                A_csr = SparseMatrixCSC(transpose(A))
                dA = adapt(op, DeviceSparseMatrixCSR(transpose(A_csr)))

                @test sum(dA) ≈ sum(A)

                if T in (ComplexF32, ComplexF64)
                    # The kernel functions may use @atomic, which does not support Complex types in JLArray
                    continue
                end

                @test tr(dA) ≈ tr(A)
            end
        end

        @testset "Matrix-Vector multiplication" begin
            for T in (Int32, Int64, Float64, ComplexF32, ComplexF64)
                for (op_A, op_B) in Iterators.product(
                    (identity, transpose, adjoint),
                    (identity, transpose, adjoint),
                )
                    if T in (ComplexF32, ComplexF64) && op_A !== identity
                        # The mul! function uses @atomic for CSR matrices, which does not support Complex types
                        continue
                    end
                    dims_A = op_A === identity ? (100, 80) : (80, 100)
                    dims_B = op_B === identity ? (80, 50) : (50, 80)

                    A = sprand(T, dims_A..., 0.1)
                    B = rand(T, dims_B...)
                    b = rand(T, 80)
                    c = op_A(A) * b
                    C = op_A(A) * op_B(B)

                    # Convert to CSR storage pattern
                    A_csr = SparseMatrixCSC(transpose(A))
                    dA = adapt(op, DeviceSparseMatrixCSR(transpose(A_csr)))

                    # Matrix-Scalar multiplication
                    if T != Int32
                        @test collect(2 * dA) ≈ 2 * collect(A)
                        @test collect(dA * 2) ≈ collect(A * 2)
                        @test collect(dA / 2) ≈ collect(A / 2)
                    end

                    # Matrix-Vector multiplication
                    db = op(b)
                    dc = op_A(dA) * db
                    @test collect(dc) ≈ c
                    dc2 = similar(dc)
                    mul!(dc2, op_A(dA), db)
                    @test collect(dc2) ≈ c

                    # Matrix-Matrix multiplication
                    dB = op(B)
                    dC = op_A(dA) * op_B(dB)
                    @test collect(dC) ≈ C
                    dC2 = similar(dB, size(C)...)
                    mul!(dC2, op_A(dA), op_B(dB))
                    @test collect(dC2) ≈ C
                end
            end
        end
    end
end
