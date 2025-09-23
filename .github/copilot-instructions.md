# Copilot Instructions for DeviceSparseArrays.jl

These guidelines give AI coding agents the minimum project-specific context to be productive. They reflect the repository as it exists now and should NOT assume unimplemented features.

## 1. Purpose & Current State
- Package name: `DeviceSparseArrays` — intended focus: backend-agnostic sparse array types & operations for CPU/GPU/accelerators.
- Unlike traditional SparseArrays.jl, this package aims to provide a unified interface for sparse data structures that can seamlessly operate across different hardware backends.
- Any new functionality you add must be inside this module and accompanied by tests + docstrings.

## 2. Repository Layout
- `Project.toml` / `Manifest.toml`: Project environment. Add deps with compat bounds in alphabetical order; do not remove existing `[compat]` or test extras.
- `src/DeviceSparseArrays.jl`: Single entry point. Keep exports explicit (add an `export` block when you introduce public APIs). Keep imports explicit (use `import PackageName: symbol` or `using PackageName: symbol` as needed).
- `docs/` (Documenter): `make.jl` sets up docs + doctests. `docs/src/index.md` auto-docs the module; adding docstrings automatically surfaces them.

## 3. Development Workflows
- Run tests locally: `make test` from the repo root folder.
- Add a dependency: `julia --project -e 'using Pkg; Pkg.add("PackageName")'` from the repo root folder, then update `[compat]` manually with a bounded version.
- Build docs locally: `make docs`.
- Doctests: Any code block in docstrings marked for execution must pass CI doctest phase.
- Format code: `make format`.
- Always check in which directory you are running commands. Change directory to the repo root if needed.

## 4. Coding Conventions
- Public API: add docstrings starting with a concise one-line summary, then details (Documenter picks them up).
- Keep internal helpers non-exported; prefix with an underscore only if truly private.
- Avoid type piracy: only extend Base / external methods for types you own OR clearly justify in comments.
- Prefer parametric methods that remain type-stable (JET will flag instability; address before committing).
- Write minimal, composable functions; avoid global state.
- Avoid scalar indexing. The arrays defined in this package could be on the GPU, so use KernelAbstractions.jl](https://github.com/JuliaGPU/KernelAbstractions.jl), [AcceleratedKernels.jl](https://github.com/JuliaGPU/AcceleratedKernels.jl), or similar abstractions to maintain backend-agnosticism.

## 5. Testing Patterns
- Always test the same functionality on all the supported backends (CPU, GPU, etc.) to ensure consistent behavior and avoid repetitions when generating the problem. Make tests reusable across backends when possible using shared functions in the `test/shared` folder.
- The test for different CPU/GPU architectures should be in a separate Julia environment, as each machine may not have all the backends available.
- When you run tests locally, only tests for the CPU and CUDA backends, as the others are not always available.
- All added code must pass Aqua + JET. If JET warns about type instability, refactor or add an inline comment explaining any intentional dynamic behavior.

## 6. Documentation Patterns

## 7. DO / DON'T for AI Agents
- DO keep changes minimal & incremental, with tests + docs in same PR.
- DO update docs & exports when adding public symbols.
- DO NOT introduce broad dependencies without justification (prefer lightweight, widely-used packages).
- DO NOT silence JET/Aqua warnings by removing the checks; fix root causes.

## 8. When Unsure
Add a TODO comment with a brief rationale instead of guessing hidden requirements; keep TODOs concise so maintainers can triage.
