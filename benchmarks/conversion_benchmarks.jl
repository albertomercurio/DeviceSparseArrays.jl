"""
    benchmark_conversions!(SUITE, array_constructor, array_type_name; N=10000, T=Float64)

Benchmark sparse matrix format conversions (CSC, CSR, COO).

# Arguments
- `SUITE`: The BenchmarkGroup to add benchmarks to
- `array_constructor`: Function to construct arrays (e.g., `Array`, `JLArray`, `CuArray`)
- `array_type_name`: String name for the array type (for display)

# Keyword Arguments
- `N`: Size of the matrix (default: 10000)
- `T`: Element type (default: Float64)
"""
function benchmark_conversions!(
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

    # CSC → COO conversion
    SUITE["Format Conversions"][array_type_name]["CSC → COO"] = @benchmarkable begin
        DeviceSparseMatrixCOO($dsm_csc)
        _synchronize_backend($dsm_csc)
    end

    # COO → CSC conversion
    SUITE["Format Conversions"][array_type_name]["COO → CSC"] = @benchmarkable begin
        DeviceSparseMatrixCSC($dsm_coo)
        _synchronize_backend($dsm_coo)
    end

    # CSR → COO conversion
    SUITE["Format Conversions"][array_type_name]["CSR → COO"] = @benchmarkable begin
        DeviceSparseMatrixCOO($dsm_csr)
        _synchronize_backend($dsm_csr)
    end

    # COO → CSR conversion
    SUITE["Format Conversions"][array_type_name]["COO → CSR"] = @benchmarkable begin
        DeviceSparseMatrixCSR($dsm_coo)
        _synchronize_backend($dsm_coo)
    end

    return nothing
end
