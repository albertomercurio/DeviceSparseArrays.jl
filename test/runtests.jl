using Test
using Aqua
using JET
using DeviceSparseArrays
using JLArrays

using LinearAlgebra
using SparseArrays
using SparseArrays: nonzeroinds, getcolptr

include(joinpath(@__DIR__, "shared", "shared.jl"))

const cpu_backend_names = ("Base Array", "JLArray")
const cpu_backend_funcs = (identity, JLArray)

@testset "CPU" verbose=true begin
    for (name, func) in zip(cpu_backend_names, cpu_backend_funcs)
        @testset "$name Backend" verbose=true begin
            shared_test_vector(func, name)
            shared_test_matrix_csc(func, name)
        end
    end
end

include(joinpath(@__DIR__, "shared", "code_quality.jl"))

@testset "Code quality (Aqua.jl)" begin
    Aqua.test_all(DeviceSparseArrays)
end
@testset "Code linting (JET.jl)" verbose=true begin
    # JET.test_package(DeviceSparseArrays; target_defined_modules = true)

    for (name, func) in zip(cpu_backend_names, cpu_backend_funcs)
        @testset "$name Backend" verbose=true begin
            @report_opt shared_test_vector_quality(func, name)
            @report_opt shared_test_matrix_csc_quality(func, name)

            @report_call shared_test_vector_quality(func, name)
            @report_call shared_test_matrix_csc_quality(func, name)
        end
    end
end
