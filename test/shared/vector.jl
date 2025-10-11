function shared_test_vector(
    op,
    array_type::String,
    int_types::Tuple,
    float_types::Tuple,
    complex_types::Tuple,
)
    @testset "DeviceSparseVector $array_type" verbose=true begin
        shared_test_conversion_vector(op, array_type, int_types, float_types, complex_types)
        shared_test_linearalgebra_vector(
            op,
            array_type,
            int_types,
            float_types,
            complex_types,
        )
    end
end

function shared_test_conversion_vector(
    op,
    array_type::String,
    int_types::Tuple,
    float_types::Tuple,
    complex_types::Tuple,
)
    @testset "Conversion" begin
        sv = SparseVector(10, int_types[end][], float_types[end][])
        sv2 = sparsevec(int_types[end][3], float_types[end][2.5], 8)

        # test only conversion SparseVector <-> DeviceSparseVector
        if op === Array
            dsv = DeviceSparseVector(sv)
            @test size(dsv) == (10,)
            @test length(dsv) == 10
            @test SparseVector(dsv) == sv
        end

        dsv = adapt(op, DeviceSparseVector(sv))
        @test size(dsv) == (10,)
        @test length(dsv) == 10
        @test nnz(dsv) == 0
        @test collect(nonzeros(dsv)) == float_types[end][]
        @test collect(nonzeroinds(dsv)) == int_types[end][]

        dsv2 = adapt(op, DeviceSparseVector(sv2))
        @test size(dsv2) == (8,)
        @test length(dsv2) == 8
        @test nnz(dsv2) == 1
        @test collect(nonzeros(dsv2)) == nonzeros(sv2)
        @test collect(nonzeroinds(dsv2)) == [3]
        @test SparseVector(dsv2) == sv2
    end
end

function shared_test_linearalgebra_vector(
    op,
    array_type::String,
    int_types::Tuple,
    float_types::Tuple,
    complex_types::Tuple,
)
    @testset "Dot And Sum" begin
        for T in (int_types..., float_types..., complex_types...)
            v = sprand(T, 1000, 0.01)
            y = rand(T, 1000)
            dv = adapt(op, DeviceSparseVector(v))
            dy = op(y)

            @test sum(dv) ≈ sum(v)

            if T in (ComplexF32, ComplexF64)
                # The kernel functions may use @atomic, which does not support Complex types in JLArray
                continue
            end

            @test dot(dv, dy) ≈ dot(v, y)
            @test dot(dy, dv) ≈ conj(dot(dv, dy))
        end
    end

    @testset "Scalar Operations" begin
        for T in (int_types..., float_types..., complex_types...)
            v = sprand(T, 100, 0.3)
            dv = adapt(op, DeviceSparseVector(v))

            α = T <: Complex ? T(2.0 + 1.0im) : (T <: Integer ? T(2) : T(2.5))

            # Test scalar multiplication
            scaled_left = α * dv
            scaled_right = dv * α
            @test nnz(scaled_left) == nnz(dv)
            @test nnz(scaled_right) == nnz(dv)
            @test collect(nonzeros(scaled_left)) ≈ α .* collect(nonzeros(dv))
            @test collect(nonzeros(scaled_right)) ≈ collect(nonzeros(dv)) .* α

            # Test scalar division
            if !(T <: Integer)  # Skip division for integer types
                divided = dv / α
                @test nnz(divided) == nnz(dv)
                @test collect(nonzeros(divided)) ≈ collect(nonzeros(dv)) ./ α
            end
        end
    end

    @testset "Unary Operations" begin
        for T in (float_types..., complex_types...)
            v = sprand(T, 80, 0.4)
            dv = adapt(op, DeviceSparseVector(v))

            # Test unary plus (inherited from AbstractArray)
            pos_v = +dv
            @test nnz(pos_v) == nnz(dv)
            @test collect(nonzeros(pos_v)) ≈ collect(nonzeros(dv))

            # Test unary minus
            neg_v = -dv
            @test nnz(neg_v) == nnz(dv)
            @test collect(nonzeros(neg_v)) ≈ -collect(nonzeros(dv))

            # Test complex operations
            if T <: Complex
                conj_v = conj(dv)
                real_v = real(dv)
                imag_v = imag(dv)

                @test nnz(conj_v) == nnz(dv)
                @test eltype(conj_v) == T
                @test collect(nonzeros(conj_v)) ≈ conj.(collect(nonzeros(dv)))

                @test eltype(real_v) == real(T)
                @test collect(nonzeros(real_v)) ≈ real.(collect(nonzeros(dv)))

                @test eltype(imag_v) == real(T)
                @test collect(nonzeros(imag_v)) ≈ imag.(collect(nonzeros(dv)))
            else
                # For real types
                conj_v = conj(dv)
                real_v = real(dv)
                imag_v = imag(dv)

                @test conj_v === dv  # Should return same object for real types
                @test real_v === dv  # Should return same object for real types
                @test nnz(imag_v) == 0  # Imaginary part of real should be zero sparse
            end
        end
    end

    @testset "Norms and Normalization" begin
        for T in (float_types..., complex_types...)
            v = sprand(T, 50, 0.5)
            dv = adapt(op, DeviceSparseVector(v))

            # Test different norms
            norm2 = norm(dv)
            norm1 = norm(dv, 1)
            norm_inf = norm(dv, Inf)

            @test norm2 ≈ norm(v, 2)
            @test norm1 ≈ norm(v, 1)
            @test norm_inf ≈ norm(v, Inf)

            # Test normalization (skip if zero vector)
            if norm2 > 0
                v_normalized = normalize(dv)
                @test norm(v_normalized) ≈ 1.0

                # Test in-place normalization
                v_copy = copy(dv)
                normalize!(v_copy)
                @test norm(v_copy) ≈ 1.0
            end
        end
    end
end
