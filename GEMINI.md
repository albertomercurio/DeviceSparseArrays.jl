# Gemini Project Context: DeviceSparseArrays.jl

## Project Overview

`DeviceSparseArrays.jl` is a Julia package that provides backend-agnostic sparse array types and operations for CPUs, GPUs, and other accelerators. It aims to offer a unified interface for sparse data structures that can seamlessly operate across different hardware backends.

The package supports various sparse formats like CSC, CSR, and COO, and can be used with backends such as:
- CPU (standard Julia arrays)
- GPUs (CUDA, Metal)
- XLA (via Reactant.jl)

It uses `KernelAbstractions.jl` and `AcceleratedKernels.jl` to provide a consistent interface for kernel execution across different hardware backends.

## Building and Running

### Dependencies

The project's Julia dependencies are listed in `Project.toml`. Key dependencies include:
- `AcceleratedKernels`
- `Adapt`
- `ArrayInterface`
- `KernelAbstractions`
- `LinearAlgebra`
- `SparseArrays`

### Key Commands

The `Makefile` provides several useful commands for development:

- **Run tests:**
  ```bash
  make test
  ```
  This command runs the test suite. The tests are structured to run against different backends (CPU, CUDA, etc.) based on the `GROUP` environment variable. For example, to run only the CUDA tests, you would use `GROUP=CUDA make test`.

- **Format code:**
  ```bash
  make format
  ```
  This formats the code using `JuliaFormatter.jl`, based on the configuration in `.JuliaFormatter.toml`.

- **Build documentation:**
  ```bash
  make docs
  ```
  This builds the project documentation using `Documenter.jl`.

- **Run benchmarks:**
  ```bash
  make benchmark
  ```
  This runs the benchmark suite located in the `benchmarks/` directory.

You **must be in the project root directory** to run these commands.

## Development Conventions

### Code Style

The project uses `JuliaFormatter.jl` to enforce a consistent code style. The configuration is in `.JuliaFormatter.toml`. Before committing, run `make format` to format your changes.

### Testing

- Tests are located in the `test/` directory.
- `test/runtests.jl` is the main entry point for running tests.
- Tests are organized by backend and data structure. Shared tests are in the `test/shared/` directory.
- The test suite uses environment variables (`GROUP`) to select which tests to run. This is useful for CI and for testing specific backends.
- The project uses `Aqua.jl` for code quality checks (e.g., ambiguities, unbound type parameters) and `JET.jl` for static analysis.

### Guidelines for Adding New Features

When adding new features or resolving issues:
- Follow the existing code style and structure.
- Don't implement all the changes at once, but rather in small, reviewable increments that are tested step-by-step.
- Ensure that new features are covered by tests, ideally in the appropriate backend-specific test files.

### Contribution

The `README.md` indicates that contributions are welcome. Given the structure of the project, contributions would likely involve adding support for new sparse formats, new backends, or new operations on the existing data structures.
