"""
    benchmark_vector_sum!(SUITE, array_constructor, array_type_name; N=10000, T=Float64)

Benchmark sparse vector sum operation.

# Arguments
- `SUITE`: The BenchmarkGroup to add benchmarks to
- `array_constructor`: Function to construct arrays (e.g., `Array`, `jl`)
- `array_type_name`: String name for the array type (for display)

# Keyword Arguments
- `N`: Size of the vector (default: 10000)
- `T`: Element type (default: Float64)
"""
function benchmark_vector_sum!(
    SUITE,
    array_constructor,
    array_type_name;
    N = 10000,
    T = Float64,
)
    # Create sparse vector with 1% density
    sv = sprand(T, N, 0.01)
    dsv = adapt(array_constructor, DeviceSparseVector(sv))

    group_name = "Sparse Vector"
    if !haskey(SUITE, group_name)
        SUITE[group_name] = BenchmarkGroup()
    end

    SUITE[group_name]["Sum [$array_type_name]"] = @benchmarkable sum($dsv)

    return nothing
end

"""
    benchmark_vector_sparse_dense_dot!(SUITE, array_constructor, array_type_name; N=10000, T=Float64)

Benchmark sparse-dense dot product.

# Arguments
- `SUITE`: The BenchmarkGroup to add benchmarks to
- `array_constructor`: Function to construct arrays (e.g., `Array`, `jl`)
- `array_type_name`: String name for the array type (for display)

# Keyword Arguments
- `N`: Size of the vector (default: 10000)
- `T`: Element type (default: Float64)
"""
function benchmark_vector_sparse_dense_dot!(
    SUITE,
    array_constructor,
    array_type_name;
    N = 10000,
    T = Float64,
)
    # Create sparse vector with 1% density
    sv = sprand(T, N, 0.01)
    dsv = adapt(array_constructor, DeviceSparseVector(sv))

    # Create dense vector
    dense_vec = adapt(array_constructor, randn(T, N))

    group_name = "Sparse Vector"
    if !haskey(SUITE, group_name)
        SUITE[group_name] = BenchmarkGroup()
    end

    SUITE[group_name]["Sparse-Dense dot [$array_type_name]"] =
        @benchmarkable dot($dsv, $dense_vec)

    return nothing
end
