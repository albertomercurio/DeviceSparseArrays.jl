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

include(joinpath(@__DIR__, "shared", "vector.jl"))
include(joinpath(@__DIR__, "shared", "matrix_csc.jl"))
include(joinpath(@__DIR__, "shared", "matrix_csr.jl"))
include(joinpath(@__DIR__, "shared", "matrix_coo.jl"))

const cpu_backend_names = ("Base Array", "JLArray")
const cpu_backend_funcs = (Array, JLArray)

@testset "CPU" verbose=true begin
    for (name, func) in zip(cpu_backend_names, cpu_backend_funcs)
        @testset "$name Backend" verbose=true begin
            shared_test_vector(func, name)
            shared_test_matrix_csc(func, name)
            shared_test_matrix_csr(func, name)
            shared_test_matrix_coo(func, name)
        end
    end
end

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
        end
    end
end
