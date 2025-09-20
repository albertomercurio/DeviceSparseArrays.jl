
function shared_test_vector(op, array_type::String)
    @testset "DeviceSparseVector $array_type" verbose=true begin
        @testset "Conversion" begin
            sv = SparseVector(10, Int[], Float64[])
            sv2 = sparsevec([3], [2.5], 8)

            # test only conversion SparseVector <-> DeviceSparseVector
            if op === identity
                dsv = DeviceSparseVector(sv)
                @test size(dsv) == (10,)
                @test length(dsv) == 10
                @test SparseVector(dsv) == sv
            end

            dsv = DeviceSparseVector(10, op(sv.nzind), op(sv.nzval))
            @test size(dsv) == (10,)
            @test length(dsv) == 10
            @test nnz(dsv) == 0
            @test collect(nonzeros(dsv)) == Float64[]
            @test collect(nonzeroinds(dsv)) == Int[]

            dsv2 = DeviceSparseVector(8, op(sv2.nzind), op(sv2.nzval))
            @test size(dsv2) == (8,)
            @test length(dsv2) == 8
            @test nnz(dsv2) == 1
            @test collect(nonzeros(dsv2)) == nonzeros(sv2)
            @test collect(nonzeroinds(dsv2)) == [3]
            @test SparseVector(dsv2) == sv2
        end
    end
end

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
    end
end
