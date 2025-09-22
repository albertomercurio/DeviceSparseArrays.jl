module DeviceSparseArraysReactantExt

import DeviceSparseArrays
import Reactant

DeviceSparseArrays._check_type(
    ::Type{T},
    ::Reactant.RArray{Reactant.TracedRNumber{T}},
) where {T} = true
DeviceSparseArrays._get_eltype(::Reactant.RArray{Reactant.TracedRNumber{T}}) where {T} = T

end
