function shared_test_matrix_csc(op, array_type::String)
    @testset "DeviceSparseMatrixCSC $array_type" verbose=true begin
        @testset "Conversion" begin
            A = spzeros(Float32, 0, 0)
            rows = [1, 2, 1]
            cols = [1, 1, 2]
            vals = [1.0, 2.0, 3.0]
            B = sparse(rows, cols, vals, 2, 2)

            # test only conversion SparseMatrixCSC <-> DeviceSparseMatrixCSC
            if op === identity
                dA = DeviceSparseMatrixCSC(A)
                @test size(dA) == (0, 0)
                @test length(dA) == 0
                @test collect(nonzeros(dA)) == Float32[]
                @test SparseMatrixCSC(dA) == A
            end

            dA = DeviceSparseMatrixCSC(
                0,
                0,
                op(getcolptr(A)),
                op(rowvals(A)),
                op(nonzeros(A)),
            )
            @test size(dA) == (0, 0)
            @test length(dA) == 0
            @test nnz(dA) == 0
            @test collect(nonzeros(dA)) == Float32[]

            dB = DeviceSparseMatrixCSC(
                2,
                2,
                op(getcolptr(B)),
                op(rowvals(B)),
                op(nonzeros(B)),
            )
            @test size(dB) == (2, 2)
            @test length(dB) == 4
            @test nnz(dB) == 3
            @test collect(nonzeros(dB)) == collect(nonzeros(B))
            @test collect(rowvals(dB)) == collect(rowvals(B))
            @test collect(getcolptr(dB)) == collect(getcolptr(B))
            @test SparseMatrixCSC(dB) == B

            @test_throws ArgumentError DeviceSparseMatrixCSC(
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
                dA = DeviceSparseMatrixCSC(
                    A.m,
                    A.n,
                    op(getcolptr(A)),
                    op(rowvals(A)),
                    op(nonzeros(A)),
                )

                @test sum(dA) ≈ sum(A)

                if T in (ComplexF32, ComplexF64)
                    # The kernel functions may use @atomic, which does not support Complex types in JLArray
                    continue
                end

                @test tr(dA) ≈ tr(A)
            end
        end

        @testset "Matrix-Scalar, Matrix-Vector and Matrix-Matrix multiplication" begin
            for T in (Int32, Int64, Float64, ComplexF32, ComplexF64)
                for (op_A, op_B) in Iterators.product(
                    (identity, transpose, adjoint),
                    (identity, transpose, adjoint),
                )
                    if T in (ComplexF32, ComplexF64) && op_A === identity
                        # The mul! function uses @atomic for CSC matrices, which does not support Complex types
                        continue
                    end
                    dims_A = op_A === identity ? (100, 80) : (80, 100)
                    dims_B = op_B === identity ? (80, 50) : (50, 80)

                    A = sprand(T, dims_A..., 0.1)
                    B = rand(T, dims_B...)
                    b = rand(T, 80)
                    c = op_A(A) * b
                    C = op_A(A) * op_B(B)

                    dA = DeviceSparseMatrixCSC(
                        size(A, 1),
                        size(A, 2),
                        op(getcolptr(A)),
                        op(rowvals(A)),
                        op(nonzeros(A)),
                    )

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
