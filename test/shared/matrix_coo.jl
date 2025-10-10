function shared_test_matrix_coo(op, array_type::String)
    @testset "DeviceSparseMatrixCOO $array_type" verbose=true begin
        shared_test_conversion_matrix_coo(op, array_type)
        shared_test_linearalgebra_matrix_coo(op, array_type)
    end
end

function shared_test_conversion_matrix_coo(op, array_type::String)
    @testset "Conversion" begin
        A = spzeros(Float32, 0, 0)
        rows = [1, 2, 1]
        cols = [1, 1, 2]
        vals = [1.0, 2.0, 3.0]
        B = sparse(rows, cols, vals, 2, 2)

        # test only conversion SparseMatrixCSC <-> DeviceSparseMatrixCOO
        if op === Array
            dA = DeviceSparseMatrixCOO(A)
            @test size(dA) == (0, 0)
            @test length(dA) == 0
            @test collect(nonzeros(dA)) == Float32[]
            @test SparseMatrixCSC(dA) == A
        end

        dA = adapt(op, DeviceSparseMatrixCOO(A))
        @test size(dA) == (0, 0)
        @test length(dA) == 0
        @test nnz(dA) == 0
        @test collect(nonzeros(dA)) == Float32[]

        dB = adapt(op, DeviceSparseMatrixCOO(B))
        @test size(dB) == (2, 2)
        @test length(dB) == 4
        @test nnz(dB) == 3
        # COO format stores entries in column-major order (from CSC conversion)
        @test collect(nonzeros(dB)) == collect(nonzeros(B))
        @test SparseMatrixCSC(dB) == B

        @test_throws ArgumentError DeviceSparseMatrixCOO(
            2,
            2,
            op([1]),
            op([1]),
            op([1.0, 2.0]),
        )
    end
end

function shared_test_linearalgebra_matrix_coo(op, array_type::String)
    @testset "Dot and Trace" begin
        for T in (Int32, Int64, Float32, Float64, ComplexF32, ComplexF64)
            A = sprand(T, 1000, 1000, 0.01)
            dA = adapt(op, DeviceSparseMatrixCOO(A))

            @test sum(dA) ≈ sum(A)

            if T in (ComplexF32, ComplexF64)
                # The kernel functions may use @atomic, which does not support Complex types in JLArray
                continue
            end

            @test tr(dA) ≈ tr(A)
        end
    end

    @testset "Scalar Operations" begin
        for T in (Int32, Int64, Float32, Float64, ComplexF32, ComplexF64)
            A = sprand(T, 45, 35, 0.1)
            dA = adapt(op, DeviceSparseMatrixCOO(A))

            α = T <: Complex ? T(2.0 + 1.5im) : (T <: Integer ? T(2) : T(1.8))

            # Test scalar multiplication
            scaled_left = α * dA
            scaled_right = dA * α
            @test nnz(scaled_left) == nnz(dA)
            @test nnz(scaled_right) == nnz(dA)
            @test collect(nonzeros(scaled_left)) ≈ α .* collect(nonzeros(dA))
            @test collect(nonzeros(scaled_right)) ≈ collect(nonzeros(dA)) .* α

            # Test scalar division
            if !(T <: Integer)  # Skip division for integer types
                divided = dA / α
                @test nnz(divided) == nnz(dA)
                @test collect(nonzeros(divided)) ≈ collect(nonzeros(dA)) ./ α
            end
        end
    end

    @testset "Unary Operations" begin
        for T in (Float32, Float64, ComplexF32, ComplexF64)
            A = sprand(T, 28, 22, 0.15)
            dA = adapt(op, DeviceSparseMatrixCOO(A))

            # Test unary plus
            pos_A = +dA
            @test nnz(pos_A) == nnz(dA)
            @test collect(nonzeros(pos_A)) ≈ collect(nonzeros(dA))

            # Test unary minus
            neg_A = -dA
            @test nnz(neg_A) == nnz(dA)
            @test collect(nonzeros(neg_A)) ≈ -collect(nonzeros(dA))

            # Test complex operations
            if T <: Complex
                conj_A = conj(dA)
                real_A = real(dA)
                imag_A = imag(dA)

                @test nnz(conj_A) == nnz(dA)
                @test eltype(conj_A) == T
                @test collect(nonzeros(conj_A)) ≈ conj.(collect(nonzeros(dA)))

                @test eltype(real_A) == real(T)
                @test collect(nonzeros(real_A)) ≈ real.(collect(nonzeros(dA)))

                @test eltype(imag_A) == real(T)
                @test collect(nonzeros(imag_A)) ≈ imag.(collect(nonzeros(dA)))
            else
                # For real types
                conj_A = conj(dA)
                real_A = real(dA)
                imag_A = imag(dA)

                @test conj_A === dA  # Should return same object for real types
                @test real_A === dA  # Should return same object for real types
                @test nnz(imag_A) == 0  # Imaginary part of real should be zero sparse
            end
        end
    end

    @testset "UniformScaling Multiplication" begin
        for T in (Float32, Float64, ComplexF32, ComplexF64)
            A = sprand(T, 18, 18, 0.2)
            dA = adapt(op, DeviceSparseMatrixCOO(A))

            # Test A * I (identity)
            result_I = dA * I
            @test nnz(result_I) == nnz(dA)
            @test collect(nonzeros(result_I)) ≈ collect(nonzeros(dA))

            # Test I * A (identity)
            result_I2 = I * dA
            @test nnz(result_I2) == nnz(dA)
            @test collect(nonzeros(result_I2)) ≈ collect(nonzeros(dA))

            # Test with scaled identity
            α = T <: Complex ? T(1.5 - 0.8im) : T(2.2)
            result_αI = dA * (α * I)
            @test nnz(result_αI) == nnz(dA)
            @test collect(nonzeros(result_αI)) ≈ α .* collect(nonzeros(dA))
        end
    end

    @testset "Matrix-Scalar, Matrix-Vector and Matrix-Matrix multiplication" begin
        for T in (Int32, Int64, Float64, ComplexF32, ComplexF64)
            for (op_A, op_B) in Iterators.product(
                (identity, transpose, adjoint),
                (identity, transpose, adjoint),
            )
                if T in (ComplexF32, ComplexF64)
                    # The mul! function uses @atomic for COO matrices, which does not support Complex types
                    continue
                end
                dims_A = op_A === identity ? (100, 80) : (80, 100)
                dims_B = op_B === identity ? (80, 50) : (50, 80)

                A = sprand(T, dims_A..., 0.1)
                B = rand(T, dims_B...)
                b = rand(T, 80)
                c = op_A(A) * b
                C = op_A(A) * op_B(B)

                dA = adapt(op, DeviceSparseMatrixCOO(A))

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
