using Test
using SparseArrays
using SparseArrays: nonzeroinds, getcolptr, rowvals
using DeviceSparseArrays

@testset "DeviceSparseVector basic" begin
    sv = SparseVector(10, Int[], Float64[])
    dsv = DeviceSparseVector(sv)
    @test size(dsv) == (10,)
    @test length(dsv) == 10
    @test SparseVector(dsv) == sv

    sv2 = sparsevec([3], [2.5], 8)
    dsv2 = DeviceSparseVector(sv2)
    @test size(dsv2) == (8,)
    @test collect(nonzeros(dsv2)) == [2.5]
    @test collect(nonzeroinds(dsv2)) == [3]
    @test SparseVector(dsv2) == sv2

    cp = copy(dsv2)
    @test cp !== dsv2
    @test SparseVector(cp) == sv2
end

@testset "DeviceSparseMatrixCSC basic" begin
    A = spzeros(Float32, 0, 0)
    dA = DeviceSparseMatrixCSC(A)
    @test size(dA) == (0,0)
    @test length(dA) == 0
    @test collect(nonzeros(dA)) == Float32[]
    @test SparseMatrixCSC(dA) == A

    rows = [1,2,1]
    cols = [1,1,2]
    vals = [1.0, 2.0, 3.0]
    B = sparse(rows, cols, vals, 2, 2)
    dB = DeviceSparseMatrixCSC(B)
    @test size(dB) == (2,2)
    @test length(dB) == 4
    @test collect(nonzeros(dB)) == collect(nonzeros(B))
    @test collect(rowvals(dB)) == collect(rowvals(B))
    @test collect(getcolptr(dB)) == collect(getcolptr(B))
    @test SparseMatrixCSC(dB) == B

    cp = copy(dB)
    @test cp !== dB
    @test SparseMatrixCSC(cp) == B

    @test_throws ArgumentError DeviceSparseMatrixCSC(2,2,[1,3], [1], [1.0])
end
