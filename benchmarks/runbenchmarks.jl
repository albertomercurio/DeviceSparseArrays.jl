using BenchmarkTools
using LinearAlgebra
using SparseArrays
using DeviceSparseArrays
using Adapt
using JLArrays
using KernelAbstractions

BLAS.set_num_threads(2)

const SUITE = BenchmarkGroup()

# Include utility functions
include("benchmark_utils.jl")

# Include benchmark files
include("vector_benchmarks.jl")
include("matrix_benchmarks.jl")
include("conversion_benchmarks.jl")

# Run benchmarks for CPU (Array)
println("Running benchmarks for CPU (Array)...")
benchmark_vector_sum!(SUITE, Array, "Array")
benchmark_vector_sparse_dense_dot!(SUITE, Array, "Array")
benchmark_matrix_vector_mul!(SUITE, Array, "Array")
benchmark_matrix_matrix_mul!(SUITE, Array, "Array")
benchmark_three_arg_dot!(SUITE, Array, "Array")
benchmark_sparse_dense_add!(SUITE, Array, "Array")
benchmark_kron!(SUITE, Array, "Array")
benchmark_conversions!(SUITE, Array, "Array")

# Run benchmarks for JLArrays
println("Running benchmarks for JLArrays...")
benchmark_vector_sum!(SUITE, JLArray, "JLArray")
benchmark_vector_sparse_dense_dot!(SUITE, JLArray, "JLArray")
benchmark_matrix_vector_mul!(SUITE, JLArray, "JLArray")
benchmark_matrix_matrix_mul!(SUITE, JLArray, "JLArray")
benchmark_three_arg_dot!(SUITE, JLArray, "JLArray")
benchmark_sparse_dense_add!(SUITE, JLArray, "JLArray")
benchmark_kron!(SUITE, JLArray, "JLArray")
# benchmark_conversions!(SUITE, JLArray, "JLArray")

# Tune and run benchmarks
println("\nTuning benchmarks...")
BenchmarkTools.tune!(SUITE)

println("\nRunning benchmarks...")
results = BenchmarkTools.run(SUITE, verbose = true)

println("\n" * "="^80)
println("Benchmark Results Summary")
println("="^80)
display(median(results))

# Save results in JSON format for github-action-benchmark
println("\n\nSaving results to benchmarks_output.json...")
BenchmarkTools.save("benchmarks_output.json", median(results))

println("\nBenchmarks completed successfully!")
