# DeviceSparseArrays.jl Benchmarks

This directory contains benchmark tracking for the DeviceSparseArrays.jl package using [BenchmarkTools.jl](https://github.com/JuliaCI/BenchmarkTools.jl) and [github-action-benchmark](https://github.com/benchmark-action/github-action-benchmark).

## Structure

- `Project.toml`: Dependencies for running benchmarks
- `runbenchmarks.jl`: Main script that runs all benchmarks
- `vector_benchmarks.jl`: Benchmarks for sparse vector operations
- `matrix_benchmarks.jl`: Benchmarks for sparse matrix operations

## Benchmarks Tracked

All benchmarks use matrices/vectors of size 10000 with 5% sparsity and Float64 element type by default. These can be customized via keyword arguments.

### Sparse Vector Operations
- **Sum**: Sum of all elements in a sparse vector
- **Sparse-Dense dot**: Dot product between a sparse vector and a dense vector

### Sparse Matrix Operations
All matrix operations are benchmarked for CSC, CSR, and COO formats to compare their performance:

- **Matrix-Vector Multiplication**: `mul!(y, A, x)` for sparse matrix A and dense vectors x, y
- **Matrix-Matrix Multiplication**: `mul!(C, A, B)` for sparse matrix A and dense matrix B
- **Three-argument dot**: `dot(x, A, y)` for sparse matrix A and dense vectors x, y

## Array Types

Each benchmark is run on multiple array types to ensure backend-agnostic performance:

- **CPU (Array)**: Standard Julia arrays on CPU
- **JLArray**: JLArrays.jl backend (CPU/GPU agnostic for testing)

Future backends (Metal, AMDGPU, etc.) can be easily added following the same pattern once GitHub Actions supports them.

## Running Benchmarks Locally

To run the benchmarks locally:

```bash
make benchmark
```

Or manually:

```bash
cd benchmarks
julia --project --threads=2 -e '
    using Pkg;
    Pkg.develop(PackageSpec(path=joinpath(pwd(), "..")));
    Pkg.instantiate();
    include("runbenchmarks.jl")'
```

## Automatic Benchmark Tracking

Benchmarks are automatically run on:
- Every push to the `main` branch
- Every pull request to `main` (excluding drafts)

The workflow:
1. Runs all benchmarks
2. Compares results with previous runs
3. Posts a comment on PRs if performance degrades by >30%
4. Fails the CI if performance degrades by >70%
5. Updates the benchmark history on the `gh-pages` branch

## Viewing Benchmark Results

Benchmark results are tracked over time and can be viewed at:
https://albertomercurio.github.io/DeviceSparseArrays.jl/benchmarks/

## Adding New Benchmarks

To add new benchmarks:

1. Create a new benchmark function in the appropriate file (or create a new file)
2. Follow the pattern:
   ```julia
   function benchmark_new_feature!(SUITE, array_constructor, array_type_name; N=10000, T=Float64)
       # Create test data using sprand
       data = sprand(T, N, N, 0.05)
       adapted_data = adapt(array_constructor, DeviceSparseMatrix...(data))
       
       # Add to suite
       group_name = "Feature Name"
       if !haskey(SUITE, group_name)
           SUITE[group_name] = BenchmarkGroup()
       end
       
       SUITE[group_name]["Test Case [$array_type_name]"] = 
           @benchmarkable operation($adapted_data)
       
       return nothing
   end
   ```
3. Call your function in `runbenchmarks.jl` for each array type
4. Test locally with `make benchmark`

## Notes

- Benchmarks use `BLAS.set_num_threads(1)` to ensure consistent results
- Default parameters: N=10000, T=Float64, 5% sparsity
- Parameters can be customized via keyword arguments
- Array types are detected automatically (JLArrays is optional)
- Results are saved in JSON format compatible with github-action-benchmark
- CUDA benchmarks are not included as GitHub Actions runners don't have GPU support
