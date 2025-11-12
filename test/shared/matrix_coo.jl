function shared_test_matrix_coo(
    op,
    array_type::String,
    int_types::Tuple,
    float_types::Tuple,
    complex_types::Tuple,
)
    @testset "DeviceSparseMatrixCOO $array_type" verbose=true begin
        shared_test_conversion_matrix_coo(
            op,
            array_type,
            int_types,
            float_types,
            complex_types,
        )
        shared_test_linearalgebra_matrix_coo(
            op,
            array_type,
            int_types,
            float_types,
            complex_types,
        )
    end
end

function shared_test_conversion_matrix_coo(
    op,
    array_type::String,
    int_types::Tuple,
    float_types::Tuple,
    complex_types::Tuple,
)
    @testset "Conversion" begin
        A = spzeros(Float32, 0, 0)
        rows = int_types[end][1, 2, 1]
        cols = int_types[end][1, 1, 2]
        vals = float_types[end][1.0, 2.0, 3.0]
        B = sparse(rows, cols, vals, 2, 2)

        # test only conversion SparseMatrixCSC <-> DeviceSparseMatrixCOO
        if op === Array
            dA = DeviceSparseMatrixCOO(A)
            @test size(dA) == (0, 0)
            @test length(dA) == 0
            @test collect(nonzeros(dA)) == int_types[end][]
            @test SparseMatrixCSC(dA) == A
        end

        dA = adapt(op, DeviceSparseMatrixCOO(A))
        @test size(dA) == (0, 0)
        @test length(dA) == 0
        @test nnz(dA) == 0
        @test collect(nonzeros(dA)) == float_types[end][]

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
            op(int_types[end][1]),
            op(int_types[end][1]),
            op(float_types[end][1.0, 2.0]),
        )

        # Test direct conversions between CSC/CSR and COO
        if op === Array
            # Test CSC -> COO -> CSC round-trip
            C = sparse(
                [1, 2, 3, 1, 2],
                [1, 2, 3, 2, 3],
                float_types[end][1.0, 2.0, 3.0, 4.0, 5.0],
                3,
                3,
            )
            dC_csc = DeviceSparseMatrixCSC(C)
            dC_coo_from_csc = DeviceSparseMatrixCOO(dC_csc)
            dC_csc_roundtrip = DeviceSparseMatrixCSC(dC_coo_from_csc)
            @test collect(SparseMatrixCSC(dC_csc_roundtrip)) ≈ collect(C)

            # Test CSR -> COO -> CSR round-trip
            dC_csr = DeviceSparseMatrixCSR(C)
            dC_coo_from_csr = DeviceSparseMatrixCOO(dC_csr)
            dC_csr_roundtrip = DeviceSparseMatrixCSR(dC_coo_from_csr)
            @test collect(SparseMatrixCSC(dC_csr_roundtrip)) ≈ collect(C)

            # Test COO -> CSC consistency
            dC_coo = DeviceSparseMatrixCOO(C)
            dC_csc_from_coo = DeviceSparseMatrixCSC(dC_coo)
            @test collect(SparseMatrixCSC(dC_csc_from_coo)) ≈ collect(C)

            # Test COO -> CSR consistency
            dC_csr_from_coo = DeviceSparseMatrixCSR(dC_coo)
            @test collect(SparseMatrixCSC(dC_csr_from_coo)) ≈ collect(C)
        end
    end
end

function shared_test_linearalgebra_matrix_coo(
    op,
    array_type::String,
    int_types::Tuple,
    float_types::Tuple,
    complex_types::Tuple,
)
    @testset "Sum and Trace" begin
        for T in (int_types..., float_types..., complex_types...)
            A = sprand(T, 1000, 1000, 0.01)
            dA = adapt(op, DeviceSparseMatrixCOO(A))

            @test sum(dA) ≈ sum(A)

            if T in (ComplexF32, ComplexF64)
                # The kernel functions use @atomic, which does not support Complex types
                continue
            end

            @test tr(dA) ≈ tr(A)
        end
    end

    @testset "Three-argument dot" begin
        for T in (int_types..., float_types..., complex_types...)
            if T in (Int32,)
                continue # TODO: Check that Int32 works
            end
            for op_A in (identity, transpose, adjoint)
                m, n = op_A === identity ? (100, 80) : (80, 100)
                A = sprand(T, m, n, 0.1)
                x = rand(T, size(op_A(A), 1))
                y = rand(T, size(op_A(A), 2))

                dA = adapt(op, DeviceSparseMatrixCOO(A))
                dx = op(x)
                dy = op(y)

                result_device = dot(dx, op_A(dA), dy)
                result_expected = dot(x, op_A(A), y)

                @test result_device ≈ result_expected
            end
        end
    end

    @testset "Scalar Operations" begin
        for T in (int_types..., float_types..., complex_types...)
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
        for T in (float_types..., complex_types...)
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
        for T in (float_types..., complex_types...)
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
        for T in (int_types..., float_types..., complex_types...)
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
                    @test collect(dA) / 2 ≈ collect(A) / 2
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

    @testset "Sparse + Dense Matrix Addition" begin
        for T in (int_types..., float_types..., complex_types...)
            m, n = 50, 40
            A = sprand(T, m, n, 0.1)
            B = rand(T, m, n)

            dA = adapt(op, DeviceSparseMatrixCOO(A))
            dB = op(B)

            # Test sparse + dense
            result = dA + dB
            expected = Matrix(A) + B
            @test collect(result) ≈ expected

            # Test dense + sparse (commutative)
            result2 = dB + dA
            @test collect(result2) ≈ expected

            # Test dimension mismatch
            B_wrong = rand(T, m + 1, n)
            dB_wrong = op(B_wrong)
            @test_throws DimensionMismatch dA + dB_wrong
        end
    end
end
