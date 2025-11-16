#=
A method to check that an AbstractArray is of a given element type.
This is needed because we can implement new methods for different arrays (e.g., Reactant.jl)
=#
_check_type(::Type{T}, v::AbstractArray{T}) where {T} = true
_check_type(::Type{T}, v::AbstractArray) where {T} = false

_get_eltype(::AbstractArray{T}) where {T} = T

_sortperm_AK(x) = AcceleratedKernels.sortperm(x)
_cumsum_AK(x) = AcceleratedKernels.cumsum(x)
