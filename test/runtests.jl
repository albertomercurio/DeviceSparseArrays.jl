using Test
using Aqua
using JET
using DeviceSparseArrays

"""
Multi-backend test runner.

Layout:
  test/
    cpu/Project.toml            # CPU backend environment
    cpu/*.jl                    # CPU-specific tests
    (future) cuda/Project.toml  # CUDA backend environment
    (future) metal/Project.toml # Metal backend environment

Root `runtests.jl` executes quality gates in the package environment, then
activates each backend sub-environment to run functional tests for that backend.
"""

@testset "Code quality (Aqua.jl)" begin
    Aqua.test_all(DeviceSparseArrays; stale_deps = false)
end
@testset "Code linting (JET.jl)" begin
    JET.test_package(DeviceSparseArrays; target_defined_modules = true)
end

# CPU backend tests
@testset "CPU backend" begin
    import Pkg
    cpu_dir = joinpath(@__DIR__, "cpu")

    Pkg.activate(cpu_dir)
    Pkg.develop(Pkg.PackageSpec(path = dirname(@__DIR__)))
    Pkg.update()

    include(joinpath(cpu_dir, "sparse_csc.jl"))
end
