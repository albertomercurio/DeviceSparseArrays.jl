function shared_test_vector(op, array_type::String)
    @testset "DeviceSparseVector $array_type" verbose=true begin
        @testset "Conversion" begin
            sv = SparseVector(10, Int[], Float64[])
            sv2 = sparsevec([3], [2.5], 8)

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
            @test collect(nonzeros(dsv)) == Float64[]
            @test collect(nonzeroinds(dsv)) == Int[]

            dsv2 = adapt(op, DeviceSparseVector(sv2))
            @test size(dsv2) == (8,)
            @test length(dsv2) == 8
            @test nnz(dsv2) == 1
            @test collect(nonzeros(dsv2)) == nonzeros(sv2)
            @test collect(nonzeroinds(dsv2)) == [3]
            @test SparseVector(dsv2) == sv2
        end

        @testset "Basic LinearAlgebra" begin
            for T in (Int32, Int64, Float32, Float64, ComplexF32, ComplexF64)
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
    end
end
