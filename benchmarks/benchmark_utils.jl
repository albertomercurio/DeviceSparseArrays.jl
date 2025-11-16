"""
    _synchronize_backend(arr)

Synchronize the backend associated with array `arr` to ensure all operations
have completed before benchmarking continues. This is essential for accurate
GPU timing.

# Implementation
This function uses multiple dispatch to handle different array types:
- For arrays with KernelAbstractions backends, it calls `synchronize` on the backend
- For other array types, it is a no-op (fallback method)
- New array types can extend this function by adding methods for specific types

# Examples
```julia
# GPU array with KernelAbstractions - will synchronize
gpu_arr = adapt(CuArray, DeviceSparseVector(...))
_synchronize_backend(gpu_arr)

# CPU array or arrays without KernelAbstractions - no-op
cpu_arr = DeviceSparseVector(...)
_synchronize_backend(cpu_arr)

# Extend for custom array types:
# _synchronize_backend(arr::MyCustomArray) = my_custom_sync(arr)
```
"""
_synchronize_backend(arr) = nothing  # Fallback: no-op for arrays without KernelAbstractions

"""
    _synchronize_backend(arr::AbstractDeviceSparseArray)

Synchronize KernelAbstractions backend for DeviceSparseArray types.
"""
_synchronize_backend(arr::AbstractDeviceSparseArray) = _synchronize_backend(nonzeros(arr))

function _synchronize_backend(x::AbstractArray)
    backend = KernelAbstractions.get_backend(arr)
    KernelAbstractions.synchronize(backend)
    return nothing
end
_synchronize_backend(x::JLArray) = nothing  # No-op for Julia Arrays
