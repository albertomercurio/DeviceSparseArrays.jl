using DeviceSparseArrays
using Test
using Aqua
using JET

@testset "DeviceSparseArrays.jl" begin
    @testset "Code quality (Aqua.jl)" begin
        Aqua.test_all(DeviceSparseArrays)
    end
    @testset "Code linting (JET.jl)" begin
        JET.test_package(DeviceSparseArrays; target_defined_modules = true)
    end
    # Write your tests here.
end
