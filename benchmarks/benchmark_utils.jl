"""
    _synchronize_backend(arr)

Synchronize the backend associated with array `arr` to ensure all operations
have completed before benchmarking continues. This is essential for accurate
GPU timing.

# Details
- For arrays that support `KernelAbstractions.get_backend`, synchronizes the backend
- For CPU arrays and arrays without KernelAbstractions support, this is a no-op
- Safe to use with any array type; handles cases where `get_backend` is not defined

# Examples
```julia
# GPU array - will synchronize
gpu_arr = adapt(CuArray, DeviceSparseVector(...))
_synchronize_backend(gpu_arr)

# CPU array - no-op
cpu_arr = DeviceSparseVector(...)
_synchronize_backend(cpu_arr)
```
"""
function _synchronize_backend(arr)
    # Try to get the backend and synchronize it
    # This is a no-op for CPU backends and safe for all array types
    try
        backend = KernelAbstractions.get_backend(arr)
        KernelAbstractions.synchronize(backend)
    catch
        # If get_backend is not defined or synchronize fails,
        # just continue (e.g., for CPU arrays or non-KA arrays)
        nothing
    end
    return nothing
end
