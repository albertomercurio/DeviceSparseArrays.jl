# Copilot Instructions for DeviceSparseArrays.jl

These guidelines give AI coding agents the minimum project-specific context to be productive. They reflect the repository as it exists now (skeleton state) and should NOT assume unimplemented features.

## 1. Purpose & Current State
- Package name: `DeviceSparseArrays` — intended focus: backend-agnostic sparse array types & operations for CPU/GPU/accelerators.
- Unlike traditional SparseArrays.jl, this package aims to provide a unified interface for sparse data structures that can seamlessly operate across different hardware backends. For example, a `DeviceSparseMatrixCSC` type could represent a sparse matrix stored in Compressed Sparse Column format, where the underlying data could reside in CPU memory or GPU memory, dispatching specific implementations based on the target device.
- Any new functionality you add must be inside this module and accompanied by tests + docstrings.

## 2. Repository Layout
- `Project.toml` / `Manifest.toml`: Project environment. Add deps with compat bounds; do not remove existing `[compat]` or test extras.
- `src/DeviceSparseArrays.jl`: Single entry point. Keep exports explicit (add an `export` block when you introduce public APIs). Keep imports explicit (use `import PackageName: symbol` or `using PackageName: symbol` as needed).
- `test/runtests.jl`: Runs three layers: (1) Aqua quality checks `Aqua.test_all` (enforces no method ambiguities, undefined exports, piracy) (2) JET static analysis `JET.test_package` (type stability & inference warnings) (3) Placeholder for functional tests — extend with focused `@testset` blocks.
- `docs/` (Documenter): `make.jl` sets up docs + doctests. `docs/src/index.md` auto-docs the module; adding docstrings automatically surfaces them.
- `.github/workflows/CI.yml`: Defines matrix test (Julia 1.10, 1.11, pre-release) plus docs build & doctests, plus coverage upload.

## 3. Development Workflows
- Run tests locally: `julia --project -e 'using Pkg; Pkg.test()'` from the repo root folder.
- Add a dependency: `julia --project -e 'using Pkg; Pkg.add("PackageName")'` from the repo root folder, then update `[compat]` manually with a bounded version.
- Build docs locally: `julia --project=docs docs/make.jl` (first: `Pkg.develop(PackageSpec(path=pwd())); Pkg.instantiate()` inside docs environment if needed).
- Doctests: Any code block in docs marked for execution must pass CI doctest phase. Prefer using `jldoctest` fenced code examples.

## 4. Coding Conventions
- Public API: add docstrings starting with a concise one-line summary, then details (Documenter picks them up).
- Keep internal helpers non-exported; prefix with an underscore only if truly private.
- Avoid type piracy: only extend Base / external methods for types you own OR clearly justify in comments.
- Prefer parametric methods that remain type-stable (JET will flag instability; address before committing).
- Write minimal, composable functions; avoid global state.
- Avoid using backend-specific packages (e.g. CUDA.jl) directly in this package; instead, use [KernelAbstractions.jl](https://github.com/JuliaGPU/KernelAbstractions.jl), [AcceleratedKernels.jl](https://github.com/JuliaGPU/AcceleratedKernels.jl), or similar abstractions to maintain backend-agnosticism.

## 5. Testing Patterns
- Each new feature: add a focused `@testset "FeatureName" begin ... end` after the quality test sets in `runtests.jl`.
- Include at least one edge case (empty sparse structure, zero-sized dimensions, etc.).
- If you add performance-oriented code, still provide a correctness test; benchmarks should NOT live in `test/` (place future benchmarks elsewhere, e.g. `bench/`).

## 6. Documentation Patterns

## 7. CI Expectations
- All added code must pass Aqua + JET. If JET warns about type instability, refactor or add an inline comment explaining any intentional dynamic behavior.
- Maintain compatibility with all matrix Julia versions unless a deliberate bump (then update `[compat]` and CI matrix).

## 8. DO / DON'T for AI Agents
- DO keep changes minimal & incremental, with tests + docs in same PR.
- DO update docs & exports when adding public symbols.
- DO NOT introduce broad dependencies without justification (prefer lightweight, widely-used packages).
- DO NOT silence JET/Aqua warnings by removing the checks; fix root causes.

## 9. When Unsure
Add a TODO comment with a brief rationale instead of guessing hidden requirements; keep TODOs concise so maintainers can triage.
