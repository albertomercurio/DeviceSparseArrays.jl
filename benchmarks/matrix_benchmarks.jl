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

    # Level 3: Format (CSC, CSR, COO - will be plotted together)
    SUITE["Matrix-Vector Multiplication"][array_type_name]["CSC"] = @benchmarkable begin
        mul!($vec, $dsm_csc, $x_vec)
        _synchronize_backend($dsm_csc)
    end

    SUITE["Matrix-Vector Multiplication"][array_type_name]["CSR"] = @benchmarkable begin
        mul!($vec, $dsm_csr, $x_vec)
        _synchronize_backend($dsm_csr)
    end

    SUITE["Matrix-Vector Multiplication"][array_type_name]["COO"] = @benchmarkable begin
        mul!($vec, $dsm_coo, $x_vec)
        _synchronize_backend($dsm_coo)
    end

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

    # Level 3: Format (CSC, CSR, COO - will be plotted together)
    SUITE["Matrix-Matrix Multiplication"][array_type_name]["CSC"] = @benchmarkable begin
        mul!($result_mat, $dsm_csc, $mat)
        _synchronize_backend($dsm_csc)
    end

    SUITE["Matrix-Matrix Multiplication"][array_type_name]["CSR"] = @benchmarkable begin
        mul!($result_mat, $dsm_csr, $mat)
        _synchronize_backend($dsm_csr)
    end

    SUITE["Matrix-Matrix Multiplication"][array_type_name]["COO"] = @benchmarkable begin
        mul!($result_mat, $dsm_coo, $mat)
        _synchronize_backend($dsm_coo)
    end

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

    # Level 3: Format (CSC, CSR, COO - will be plotted together)
    SUITE["Three-argument dot"][array_type_name]["CSC"] = @benchmarkable begin
        dot($x_vec, $dsm_csc, $y_vec)
        _synchronize_backend($dsm_csc)
    end

    SUITE["Three-argument dot"][array_type_name]["CSR"] = @benchmarkable begin
        dot($x_vec, $dsm_csr, $y_vec)
        _synchronize_backend($dsm_csr)
    end

    SUITE["Three-argument dot"][array_type_name]["COO"] = @benchmarkable begin
        dot($x_vec, $dsm_coo, $y_vec)
        _synchronize_backend($dsm_coo)
    end

    return nothing
end

"""
    benchmark_sparse_dense_add!(SUITE, array_constructor, array_type_name; N=10000, T=Float64)

Benchmark sparse + dense matrix addition for CSC, CSR, and COO formats.

# Arguments
- `SUITE`: The BenchmarkGroup to add benchmarks to
- `array_constructor`: Function to construct arrays (e.g., `Array`, `JLArray`)
- `array_type_name`: String name for the array type (for display)

# Keyword Arguments
- `N`: Size of the matrix (default: 10000)
- `T`: Element type (default: Float64)
"""
function benchmark_sparse_dense_add!(
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

    # Create dense matrix
    dense_mat = adapt(array_constructor, randn(T, N, N))

    # Level 3: Format (CSC, CSR, COO - will be plotted together)
    SUITE["Sparse + Dense Addition"][array_type_name]["CSC"] = @benchmarkable begin
        $dsm_csc + $dense_mat
        _synchronize_backend($dsm_csc)
    end

    SUITE["Sparse + Dense Addition"][array_type_name]["CSR"] = @benchmarkable begin
        $dsm_csr + $dense_mat
        _synchronize_backend($dsm_csr)
    end

    SUITE["Sparse + Dense Addition"][array_type_name]["COO"] = @benchmarkable begin
        $dsm_coo + $dense_mat
        _synchronize_backend($dsm_coo)
    end

    return nothing
end

"""
    benchmark_kron!(SUITE, array_constructor, array_type_name; N=100, T=Float64)

Benchmark Kronecker product (kron) for CSC, CSR, and COO formats.

# Arguments
- `SUITE`: The BenchmarkGroup to add benchmarks to
- `array_constructor`: Function to construct arrays (e.g., `Array`, `JLArray`)
- `array_type_name`: String name for the array type (for display)

# Keyword Arguments
- `N`: Size of the matrices (default: 100)
- `T`: Element type (default: Float64)
"""
function benchmark_kron!(
    SUITE,
    array_constructor,
    array_type_name;
    N = 100,
    T = Float64,
)
    # Create sparse matrices with 1% density (smaller matrices since kron grows quadratically)
    sm_a_std = sprand(T, N, N, 0.01)
    sm_b_std = sprand(T, N, N, 0.01)

    # Convert to different formats
    sm_a_csc = DeviceSparseMatrixCSC(sm_a_std)
    sm_b_csc = DeviceSparseMatrixCSC(sm_b_std)
    
    sm_a_csr = DeviceSparseMatrixCSR(sm_a_std)
    sm_b_csr = DeviceSparseMatrixCSR(sm_b_std)
    
    sm_a_coo = DeviceSparseMatrixCOO(sm_a_std)
    sm_b_coo = DeviceSparseMatrixCOO(sm_b_std)

    # Adapt to device
    dsm_a_csc = adapt(array_constructor, sm_a_csc)
    dsm_b_csc = adapt(array_constructor, sm_b_csc)
    
    dsm_a_csr = adapt(array_constructor, sm_a_csr)
    dsm_b_csr = adapt(array_constructor, sm_b_csr)
    
    dsm_a_coo = adapt(array_constructor, sm_a_coo)
    dsm_b_coo = adapt(array_constructor, sm_b_coo)

    # Level 3: Format (CSC, CSR, COO - will be plotted together)
    SUITE["Kronecker Product"][array_type_name]["CSC"] = @benchmarkable begin
        kron($dsm_a_csc, $dsm_b_csc)
        _synchronize_backend($dsm_a_csc)
    end

    SUITE["Kronecker Product"][array_type_name]["CSR"] = @benchmarkable begin
        kron($dsm_a_csr, $dsm_b_csr)
        _synchronize_backend($dsm_a_csr)
    end

    SUITE["Kronecker Product"][array_type_name]["COO"] = @benchmarkable begin
        kron($dsm_a_coo, $dsm_b_coo)
        _synchronize_backend($dsm_a_coo)
    end

    return nothing
end

