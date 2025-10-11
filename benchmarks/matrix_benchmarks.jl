"""
    benchmark_matrix_vector_mul!(SUITE, array_constructor, array_type_name; N=10000, T=Float64)

Benchmark matrix-vector multiplication for CSC, CSR, and COO formats.

# Arguments
- `SUITE`: The BenchmarkGroup to add benchmarks to
- `array_constructor`: Function to construct arrays (e.g., `Array`, `JLArray`, `CuArray`)
- `array_type_name`: String name for the array type (for display)

# Keyword Arguments
- `N`: Size of the matrix (default: 10000)
- `T`: Element type (default: Float64)
"""
function benchmark_matrix_vector_mul!(
    SUITE,
    array_constructor,
    array_type_name;
    N = 10000,
    T = Float64,
)
    # Create sparse matrix with 1% density
    sm_csc_std = sprand(T, N, N, 0.01)

    # Convert to different formats
    sm_csc = DeviceSparseMatrixCSC(sm_csc_std)
    sm_csr = DeviceSparseMatrixCSR(sm_csc_std)
    sm_coo = DeviceSparseMatrixCOO(sm_csc_std)

    # Adapt to device
    dsm_csc = adapt(array_constructor, sm_csc)
    dsm_csr = adapt(array_constructor, sm_csr)
    dsm_coo = adapt(array_constructor, sm_coo)

    # Create dense vectors
    vec = adapt(array_constructor, randn(T, N))
    x_vec = adapt(array_constructor, randn(T, N))

    group_name = "Matrix-Vector Multiplication"
    if !haskey(SUITE, group_name)
        SUITE[group_name] = BenchmarkGroup()
    end

    SUITE[group_name]["CSC [$array_type_name]"] =
        @benchmarkable mul!($vec, $dsm_csc, $x_vec)

    SUITE[group_name]["CSR [$array_type_name]"] =
        @benchmarkable mul!($vec, $dsm_csr, $x_vec)

    SUITE[group_name]["COO [$array_type_name]"] =
        @benchmarkable mul!($vec, $dsm_coo, $x_vec)

    return nothing
end

"""
    benchmark_matrix_matrix_mul!(SUITE, array_constructor, array_type_name; N=10000, T=Float64, M=100)

Benchmark matrix-matrix multiplication for CSC, CSR, and COO formats.
Multiplies a sparse N×N matrix with a dense N×M matrix.

# Arguments
- `SUITE`: The BenchmarkGroup to add benchmarks to
- `array_constructor`: Function to construct arrays (e.g., `Array`, `jl`)
- `array_type_name`: String name for the array type (for display)

# Keyword Arguments
- `N`: Size of the sparse matrix (default: 10000)
- `T`: Element type (default: Float64)
- `M`: Number of columns in the dense matrix (default: 100)
"""
function benchmark_matrix_matrix_mul!(
    SUITE,
    array_constructor,
    array_type_name;
    N = 10000,
    T = Float64,
    M = 100,
)
    # Create sparse matrix with 1% density
    sm_csc_std = sprand(T, N, N, 0.01)

    # Convert to different formats
    sm_csc = DeviceSparseMatrixCSC(sm_csc_std)
    sm_csr = DeviceSparseMatrixCSR(sm_csc_std)
    sm_coo = DeviceSparseMatrixCOO(sm_csc_std)

    # Adapt to device
    dsm_csc = adapt(array_constructor, sm_csc)
    dsm_csr = adapt(array_constructor, sm_csr)
    dsm_coo = adapt(array_constructor, sm_coo)

    # Create dense matrix N×M (much smaller than N×N)
    mat = adapt(array_constructor, randn(T, N, M))
    result_mat = adapt(array_constructor, zeros(T, N, M))

    group_name = "Matrix-Matrix Multiplication"
    if !haskey(SUITE, group_name)
        SUITE[group_name] = BenchmarkGroup()
    end

    SUITE[group_name]["CSC [$array_type_name]"] =
        @benchmarkable mul!($result_mat, $dsm_csc, $mat)

    SUITE[group_name]["CSR [$array_type_name]"] =
        @benchmarkable mul!($result_mat, $dsm_csr, $mat)

    SUITE[group_name]["COO [$array_type_name]"] =
        @benchmarkable mul!($result_mat, $dsm_coo, $mat)

    return nothing
end

"""
    benchmark_three_arg_dot!(SUITE, array_constructor, array_type_name; N=10000, T=Float64)

Benchmark three-argument dot product dot(x, A, y) for CSC, CSR, and COO formats.

# Arguments
- `SUITE`: The BenchmarkGroup to add benchmarks to
- `array_constructor`: Function to construct arrays (e.g., `Array`, `jl`)
- `array_type_name`: String name for the array type (for display)

# Keyword Arguments
- `N`: Size of the matrix (default: 10000)
- `T`: Element type (default: Float64)
"""
function benchmark_three_arg_dot!(
    SUITE,
    array_constructor,
    array_type_name;
    N = 10000,
    T = Float64,
)
    # Create sparse matrix with 1% density
    sm_csc_std = sprand(T, N, N, 0.01)

    # Convert to different formats
    sm_csc = DeviceSparseMatrixCSC(sm_csc_std)
    sm_csr = DeviceSparseMatrixCSR(sm_csc_std)
    sm_coo = DeviceSparseMatrixCOO(sm_csc_std)

    # Adapt to device
    dsm_csc = adapt(array_constructor, sm_csc)
    dsm_csr = adapt(array_constructor, sm_csr)
    dsm_coo = adapt(array_constructor, sm_coo)

    # Create dense vectors
    x_vec = adapt(array_constructor, randn(T, N))
    y_vec = adapt(array_constructor, randn(T, N))

    group_name = "Three-argument dot"
    if !haskey(SUITE, group_name)
        SUITE[group_name] = BenchmarkGroup()
    end

    SUITE[group_name]["CSC [$array_type_name]"] =
        @benchmarkable dot($x_vec, $dsm_csc, $y_vec)

    SUITE[group_name]["CSR [$array_type_name]"] =
        @benchmarkable dot($x_vec, $dsm_csr, $y_vec)

    SUITE[group_name]["COO [$array_type_name]"] =
        @benchmarkable dot($x_vec, $dsm_coo, $y_vec)

    return nothing
end
