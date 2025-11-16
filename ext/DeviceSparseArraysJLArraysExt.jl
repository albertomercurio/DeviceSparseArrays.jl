module DeviceSparseArraysJLArraysExt

using JLArrays: JLArray
import DeviceSparseArrays

DeviceSparseArrays._sortperm_AK(x::JLArray) = JLArray(sortperm(collect(x)))
DeviceSparseArrays._cumsum_AK(x::JLArray) = JLArray(cumsum(collect(x)))

end
