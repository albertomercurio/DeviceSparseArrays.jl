using Test
using Aqua
using JET
using DeviceSparseArrays
using JLArrays
using Adapt

using LinearAlgebra
using SparseArrays
using SparseArrays: nonzeroinds, getcolptr
using DeviceSparseArrays: getrowptr, colvals

import Pkg

include(joinpath(@__DIR__, "shared", "vector.jl"))
include(joinpath(@__DIR__, "shared", "matrix_csc.jl"))
include(joinpath(@__DIR__, "shared", "matrix_csr.jl"))
include(joinpath(@__DIR__, "shared", "matrix_coo.jl"))
include(joinpath(@__DIR__, "shared", "conversions.jl"))
include(joinpath(@__DIR__, "shared", "kron.jl"))

const GROUP_LIST = ("All", "Code-Quality", "CPU", "CUDA", "Metal", "Reactant")
const GROUP = get(ENV, "GROUP", "All")
GROUP in GROUP_LIST ||
    error("Invalid GROUP: $GROUP. Valid options are: $(join(GROUP_LIST, ", "))")

const cpu_backend_names = ("Base Array", "JLArray")
const cpu_backend_funcs = (Array, JLArray)

if GROUP in ("All", "CPU")
    @testset "CPU" verbose=true begin
        for (name, func) in zip(cpu_backend_names, cpu_backend_funcs)
            @testset "$name Backend" verbose=true begin
                shared_test_vector(
                    func,
                    name,
                    (Int32, Int64),
                    (Float32, Float64),
                    (ComplexF32, ComplexF64),
                )
                shared_test_matrix_csc(
                    func,
                    name,
                    (Int32, Int64),
                    (Float32, Float64),
                    (ComplexF32, ComplexF64),
                )
                shared_test_matrix_csr(
                    func,
                    name,
                    (Int32, Int64),
                    (Float32, Float64),
                    (ComplexF32, ComplexF64),
                )
                shared_test_matrix_coo(
                    func,
                    name,
                    (Int32, Int64),
                    (Float32, Float64),
                    (ComplexF32, ComplexF64),
                )
                shared_test_conversions(
                    func,
                    name,
                    (Int32, Int64),
                    (Float32, Float64),
                    (ComplexF32, ComplexF64),
                )
                shared_test_kron(
                    func,
                    name,
                    (Int32, Int64),
                    (Float32, Float64),
                    (ComplexF32, ComplexF64),
                )
            end
        end
    end
end

if GROUP == "CUDA"
    Pkg.activate(joinpath(@__DIR__, "cuda"))
    Pkg.develop(path = joinpath(@__DIR__, ".."))
    Pkg.update()

    using CUDA
    CUDA.versioninfo()

    include(joinpath(@__DIR__, "cuda/cuda.jl"))
end

if GROUP == "Metal"
    Pkg.activate(joinpath(@__DIR__, "metal"))
    Pkg.develop(path = joinpath(@__DIR__, ".."))
    Pkg.update()

    using Metal
    include(joinpath(@__DIR__, "metal/metal.jl"))
end

if GROUP == "Reactant"
    Pkg.activate(joinpath(@__DIR__, "reactant"))
    Pkg.develop(path = joinpath(@__DIR__, ".."))
    Pkg.update()

    using Reactant
    include(joinpath(@__DIR__, "reactant/reactant.jl"))
end

if GROUP in ("All", "Code-Quality")
    include(joinpath(@__DIR__, "shared", "code_quality.jl"))
    @testset "Code quality (Aqua.jl)" begin
        ambiguities = true # VERSION > v"1.11"
        Aqua.test_all(DeviceSparseArrays; ambiguities = ambiguities)
    end

    @testset "Code linting (JET.jl)" verbose=true begin
        # JET.test_package(DeviceSparseArrays; target_defined_modules = true)

        for (name, func) in zip(cpu_backend_names, cpu_backend_funcs)
            @testset "$name Backend" verbose=true begin
                @test_opt target_modules=(@__MODULE__, DeviceSparseArrays) shared_test_vector_quality(
                    func,
                    Float64;
                )
                @test_opt target_modules=(@__MODULE__, DeviceSparseArrays) shared_test_matrix_csc_quality(
                    func,
                    Float64;
                    op_A = adjoint,
                    op_B = identity,
                )
                @test_opt target_modules=(@__MODULE__, DeviceSparseArrays) shared_test_matrix_csc_quality(
                    func,
                    Float64;
                    op_A = adjoint,
                    op_B = adjoint,
                )
                @test_opt target_modules=(@__MODULE__, DeviceSparseArrays) shared_test_matrix_csr_quality(
                    func,
                    Float64;
                    op_A = identity,
                    op_B = identity,
                )
                @test_opt target_modules=(@__MODULE__, DeviceSparseArrays) shared_test_matrix_csr_quality(
                    func,
                    Float64;
                    op_A = identity,
                    op_B = adjoint,
                )
                @test_opt target_modules=(@__MODULE__, DeviceSparseArrays) shared_test_matrix_coo_quality(
                    func,
                    Float64;
                    op_A = identity,
                    op_B = identity,
                )
                @test_opt target_modules=(@__MODULE__, DeviceSparseArrays) shared_test_matrix_coo_quality(
                    func,
                    Float64;
                    op_A = transpose,
                    op_B = adjoint,
                )

                @test_call target_modules=(@__MODULE__, DeviceSparseArrays) shared_test_vector_quality(
                    func,
                    Float64;
                )
                @test_call target_modules=(@__MODULE__, DeviceSparseArrays) shared_test_matrix_csc_quality(
                    func,
                    Float64;
                    op_A = adjoint,
                    op_B = identity,
                )
                @test_call target_modules=(@__MODULE__, DeviceSparseArrays) shared_test_matrix_csc_quality(
                    func,
                    Float64;
                    op_A = adjoint,
                    op_B = adjoint,
                )
                @test_call target_modules=(@__MODULE__, DeviceSparseArrays) shared_test_matrix_csr_quality(
                    func,
                    Float64;
                    op_A = identity,
                    op_B = identity,
                )
                @test_call target_modules=(@__MODULE__, DeviceSparseArrays) shared_test_matrix_csr_quality(
                    func,
                    Float64;
                    op_A = identity,
                    op_B = adjoint,
                )
                @test_call target_modules=(@__MODULE__, DeviceSparseArrays) shared_test_matrix_coo_quality(
                    func,
                    Float64;
                    op_A = identity,
                    op_B = identity,
                )
                @test_call target_modules=(@__MODULE__, DeviceSparseArrays) shared_test_matrix_coo_quality(
                    func,
                    Float64;
                    op_A = transpose,
                    op_B = adjoint,
                )
                
                @test_opt target_modules=(@__MODULE__, DeviceSparseArrays) shared_test_kron_quality(
                    func,
                    Float64,
                )
                @test_call target_modules=(@__MODULE__, DeviceSparseArrays) shared_test_kron_quality(
                    func,
                    Float64,
                )
            end
        end
    end
end
