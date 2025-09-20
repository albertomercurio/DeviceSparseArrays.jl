using Test
using Aqua
using JET
using DeviceSparseArrays
using SparseArrays
using SparseArrays: nonzeroinds, getcolptr

include(joinpath(@__DIR__, "shared", "shared.jl"))

@testset "Base Array backend" verbose=true begin
    import Pkg
    cpu_dir = joinpath(@__DIR__, "base_array")

    Pkg.activate(cpu_dir)
    Pkg.develop(Pkg.PackageSpec(path = dirname(@__DIR__)))
    Pkg.update()

    shared_test_vector(identity, "Base Array")
    shared_test_matrix_csc(identity, "Base Array")
end

@testset "JLArray backend" verbose=true begin
    import Pkg
    cpu_dir = joinpath(@__DIR__, "jlarrays")

    Pkg.activate(cpu_dir)
    Pkg.develop(Pkg.PackageSpec(path = dirname(@__DIR__)))
    Pkg.update()

    using JLArrays

    shared_test_vector(JLArray, "JLArray")
    shared_test_matrix_csc(JLArray, "JLArray")
end

@testset "Code quality (Aqua.jl)" begin
    Aqua.test_all(DeviceSparseArrays; stale_deps = false)
end
@testset "Code linting (JET.jl)" begin
    JET.test_package(DeviceSparseArrays; target_defined_modules = true)
end
