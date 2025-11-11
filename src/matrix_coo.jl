# DeviceSparseMatrixCOO implementation

"""
    DeviceSparseMatrixCOO{Tv,Ti,RowIndT<:AbstractVector,ColIndT<:AbstractVector,NzValT<:AbstractVector} <: AbstractDeviceSparseMatrix{Tv,Ti}

Coordinate (COO) sparse matrix with generic storage vectors for row indices,
column indices, and nonzero values. Buffer types (e.g. `Vector`, GPU array
types) enable dispatch on device characteristics.

# Fields
- `m::Int`               - number of rows
- `n::Int`               - number of columns
- `rowind::RowIndT`      - row indices of stored entries
- `colind::ColIndT`      - column indices of stored entries
- `nzval::NzValT`        - stored values
"""
struct DeviceSparseMatrixCOO{
    Tv,
    Ti<:Integer,
    RowIndT<:AbstractVector,
    ColIndT<:AbstractVector,
    NzValT<:AbstractVector,
} <: AbstractDeviceSparseMatrix{Tv,Ti}
    m::Int
    n::Int
    rowind::RowIndT
    colind::ColIndT
    nzval::NzValT
    function DeviceSparseMatrixCOO{Tv,Ti,RowIndT,ColIndT,NzValT}(
        m::Integer,
        n::Integer,
        rowind::RowIndT,
        colind::ColIndT,
        nzval::NzValT,
    ) where {
        Tv,
        Ti<:Integer,
        RowIndT<:AbstractVector,
        ColIndT<:AbstractVector,
        NzValT<:AbstractVector,
    }
        get_backend(rowind) == get_backend(colind) == get_backend(nzval) ||
            throw(ArgumentError("All storage vectors must be on the same device/backend."))

        m >= 0 || throw(ArgumentError("m must be non-negative"))
        n >= 0 || throw(ArgumentError("n must be non-negative"))
        SparseArrays.sparse_check_Ti(m, n, Ti)

        _check_type(Ti, rowind) || throw(ArgumentError("rowind must be of type $Ti"))
        _check_type(Ti, colind) || throw(ArgumentError("colind must be of type $Ti"))
        _check_type(Tv, nzval) || throw(ArgumentError("nzval must be of type $Tv"))

        length(rowind) == length(colind) == length(nzval) ||
            throw(ArgumentError("rowind, colind, and nzval must have same length"))

        return new(Int(m), Int(n), rowind, colind, nzval)
    end
end

function DeviceSparseMatrixCOO(
    m::Integer,
    n::Integer,
    rowind::RowIndT,
    colind::ColIndT,
    nzval::NzValT,
) where {
    RowIndT<:AbstractVector{Ti},
    ColIndT<:AbstractVector{Ti},
    NzValT<:AbstractVector{Tv},
} where {Ti<:Integer,Tv}
    Ti2 = _get_eltype(rowind)
    Tv2 = _get_eltype(nzval)
    DeviceSparseMatrixCOO{Tv2,Ti2,RowIndT,ColIndT,NzValT}(m, n, rowind, colind, nzval)
end

# Conversion from SparseMatrixCSC to COO
function DeviceSparseMatrixCOO(A::SparseMatrixCSC{Tv,Ti}) where {Tv,Ti}
    m, n = size(A)
    nnz_count = nnz(A)

    rowind = Vector{Ti}(undef, nnz_count)
    colind = Vector{Ti}(undef, nnz_count)
    nzval = Vector{Tv}(undef, nnz_count)

    idx = 1
    for col = 1:n
        for j in nzrange(A, col)
            rowind[idx] = rowvals(A)[j]
            colind[idx] = col
            nzval[idx] = nonzeros(A)[j]
            idx += 1
        end
    end

    return DeviceSparseMatrixCOO(m, n, rowind, colind, nzval)
end

# Conversion from COO to SparseMatrixCSC
function SparseMatrixCSC(A::DeviceSparseMatrixCOO)
    m, n = size(A)
    rowind = collect(A.rowind)
    colind = collect(A.colind)
    nzval = collect(A.nzval)

    return sparse(rowind, colind, nzval, m, n)
end

Adapt.adapt_structure(to, A::DeviceSparseMatrixCOO) = DeviceSparseMatrixCOO(
    A.m,
    A.n,
    Adapt.adapt_structure(to, A.rowind),
    Adapt.adapt_structure(to, A.colind),
    Adapt.adapt_structure(to, A.nzval),
)

Base.size(A::DeviceSparseMatrixCOO) = (A.m, A.n)
Base.length(A::DeviceSparseMatrixCOO) = A.m * A.n
Base.copy(A::DeviceSparseMatrixCOO) =
    DeviceSparseMatrixCOO(A.m, A.n, copy(A.rowind), copy(A.colind), copy(A.nzval))

Base.collect(A::DeviceSparseMatrixCOO) = collect(SparseMatrixCSC(A))

function Base.zero(A::DeviceSparseMatrixCOO)
    rowind = similar(A.rowind, 0)
    colind = similar(A.colind, 0)
    nzval = similar(A.nzval, 0)
    return DeviceSparseMatrixCOO(A.m, A.n, rowind, colind, nzval)
end

function Base.:(*)(α::Number, A::DeviceSparseMatrixCOO)
    return DeviceSparseMatrixCOO(
        A.m,
        A.n,
        copy(getrowind(A)),
        copy(getcolind(A)),
        α .* nonzeros(A),
    )
end
Base.:(*)(A::DeviceSparseMatrixCOO, α::Number) = α * A
Base.:(/)(A::DeviceSparseMatrixCOO, α::Number) = (1 / α) * A

function Base.:-(A::DeviceSparseMatrixCOO)
    return DeviceSparseMatrixCOO(A.m, A.n, copy(A.rowind), copy(A.colind), -A.nzval)
end

Base.conj(A::DeviceSparseMatrixCOO{<:Real}) = A
function Base.conj(A::DeviceSparseMatrixCOO{<:Complex})
    return DeviceSparseMatrixCOO(A.m, A.n, copy(A.rowind), copy(A.colind), conj.(A.nzval))
end

Base.real(A::DeviceSparseMatrixCOO{<:Real}) = A
function Base.real(A::DeviceSparseMatrixCOO{<:Complex})
    return DeviceSparseMatrixCOO(A.m, A.n, copy(A.rowind), copy(A.colind), real.(A.nzval))
end

Base.imag(A::DeviceSparseMatrixCOO{<:Real}) = zero(A)
function Base.imag(A::DeviceSparseMatrixCOO{<:Complex})
    return DeviceSparseMatrixCOO(A.m, A.n, copy(A.rowind), copy(A.colind), imag.(A.nzval))
end

SparseArrays.nonzeros(A::DeviceSparseMatrixCOO) = A.nzval
getrowind(A::DeviceSparseMatrixCOO) = A.rowind
getcolind(A::DeviceSparseMatrixCOO) = A.colind
SparseArrays.getnzval(A::DeviceSparseMatrixCOO) = nonzeros(A)

function LinearAlgebra.tr(A::DeviceSparseMatrixCOO)
    m, n = size(A)
    m == n || throw(DimensionMismatch("Matrix must be square to compute the trace."))

    backend = get_backend(A)

    @kernel function kernel_tr(res, @Const(rowind), @Const(colind), @Const(nzval))
        i = @index(Global)

        @inbounds if rowind[i] == colind[i]
            @atomic res[1] += nzval[i]
        end
    end

    res = similar(nonzeros(A), 1)
    fill!(res, zero(eltype(A)))

    kernel = kernel_tr(backend)
    kernel(res, getrowind(A), getcolind(A), nonzeros(A); ndrange = (length(nonzeros(A)),))

    return allowed_getindex(res, 1)
end

# Matrix-Vector and Matrix-Matrix multiplication
for (wrapa, transa, opa, unwrapa, whereT1) in trans_adj_wrappers_old(:DeviceSparseMatrixCOO)
    for (wrapb, transb, opb, unwrapb, whereT2) in trans_adj_wrappers_old(:DenseVecOrMat)
        TypeA = wrapa(:(T1))
        TypeB = wrapb(:(T2))
        TypeC = :(DenseVecOrMat{T3})

        kernel_spmatmul! = transa ? :kernel_spmatmul_T! : :kernel_spmatmul_N!

        indB = transb ? (i, j) -> :(($j, $i)) : (i, j) -> :(($i, $j)) # transpose indices

        @eval function LinearAlgebra.mul!(
            C::$TypeC,
            A::$TypeA,
            B::$TypeB,
            α::Number,
            β::Number,
        ) where {$(whereT1(:T1)),$(whereT2(:T2)),T3}
            size(A, 2) == size(B, 1) || throw(
                DimensionMismatch(
                    "second dimension of A, $(size(A,2)), does not match the first dimension of B, $(size(B,1))",
                ),
            )
            size(A, 1) == size(C, 1) || throw(
                DimensionMismatch(
                    "first dimension of A, $(size(A,1)), does not match the first dimension of C, $(size(C,1))",
                ),
            )
            size(B, 2) == size(C, 2) || throw(
                DimensionMismatch(
                    "second dimension of B, $(size(B,2)), does not match the second dimension of C, $(size(C,2))",
                ),
            )

            promote_type(T1, T2, eltype(α), eltype(β)) <: T3 || throw(
                ArgumentError(
                    "element types of A, B, α, and β must be promotable to the element type of C",
                ),
            )

            _A = $(unwrapa(:A))
            _B = $(unwrapb(:B))

            backend_C = get_backend(C)
            backend_A = get_backend(_A)
            backend_B = get_backend(_B)

            backend_A == backend_B == backend_C ||
                throw(ArgumentError("All arrays must have the same backend"))

            @kernel function kernel_spmatmul_N!(
                C,
                @Const(rowind),
                @Const(colind),
                @Const(nzval),
                @Const(B)
            )
                k, i = @index(Global, NTuple)

                @inbounds begin
                    row = rowind[i]
                    col = colind[i]
                    Bi, Bj = $(indB(:col, :k))
                    axj = $(opb(:(B[Bi, Bj]))) * α
                    @atomic C[row, k] += $(opa(:(nzval[i]))) * axj
                end
            end

            @kernel function kernel_spmatmul_T!(
                C,
                @Const(rowind),
                @Const(colind),
                @Const(nzval),
                @Const(B)
            )
                k, i = @index(Global, NTuple)

                @inbounds begin
                    row = rowind[i]
                    col = colind[i]
                    Bi, Bj = $(indB(:row, :k))
                    axj = $(opb(:(B[Bi, Bj]))) * α
                    @atomic C[col, k] += $(opa(:(nzval[i]))) * axj
                end
            end

            β != one(β) && LinearAlgebra._rmul_or_fill!(C, β)

            kernel! = $kernel_spmatmul!(backend_A)
            kernel!(
                C,
                getrowind(_A),
                getcolind(_A),
                getnzval(_A),
                _B;
                ndrange = (size(C, 2), length(nonzeros(_A))),
            )

            return C
        end
    end
end

# Three-argument dot product: dot(x, A, y) = x' * A * y
for (wrapa, transa, opa, unwrapa, whereT1) in trans_adj_wrappers_old(:DeviceSparseMatrixCOO)
    TypeA = wrapa(:(T1))
    kernel_dot! = transa ? :kernel_dot_T! : :kernel_dot_N!

    @eval function LinearAlgebra.dot(
        x::AbstractVector{T2},
        A::$TypeA,
        y::AbstractVector{T3},
    ) where {$(whereT1(:T1)),T2,T3}
        size(A, 1) == length(x) || throw(
            DimensionMismatch(
                "first dimension of A, $(size(A,1)), does not match the length of x, $(length(x))",
            ),
        )
        size(A, 2) == length(y) || throw(
            DimensionMismatch(
                "second dimension of A, $(size(A,2)), does not match the length of y, $(length(y))",
            ),
        )

        _A = $(unwrapa(:A))

        backend_x = get_backend(x)
        backend_A = get_backend(_A)
        backend_y = get_backend(y)

        backend_x == backend_A == backend_y ||
            throw(ArgumentError("All arrays must have the same backend"))

        T = promote_type(T1, T2, T3)

        nnz_val = nnz(_A)
        rowind = getrowind(_A)
        colind = getcolind(_A)
        nzval = getnzval(_A)

        backend = backend_A

        # Use a workgroup-based reduction kernel
        # Each work-item processes multiple nonzero entries with a stride, then reduces within workgroup
        @kernel inbounds=true unsafe_indices=true function kernel_workgroup_dot!(
            block_results,
            @Const(x),
            @Const(rowind),
            @Const(colind),
            @Const(nzval),
            @Const(y),
            @Const(nnz_val)
        )
            # Get work-item and workgroup indices
            local_id = @index(Local, Linear)
            group_id = @index(Group, Linear)
            global_id = @index(Global, Linear)

            workgroup_size = @uniform @groupsize()[1]
            stride = @uniform @ndrange()[1]

            # Allocate shared memory for workgroup reduction
            shared = @localmem(eltype(block_results), workgroup_size)

            # Each work-item accumulates its contribution from nonzero entries with stride
            local_sum = zero(eltype(block_results))
            for i = global_id:stride:nnz_val
                row = rowind[i]
                col = colind[i]
                local_sum += $(
                    transa ? :(dot(x[col], $(opa(:(nzval[i]))), y[row])) :
                    :(dot(x[row], $(opa(:(nzval[i]))), y[col]))
                )
            end

            # Store local sum in shared memory
            shared[local_id] = local_sum
            @synchronize()

            # Perform tree reduction within workgroup
            # @private offset = workgroup_size >>> 1
            # while offset > 0
            #     if local_id <= offset
            #         shared[local_id] += shared[local_id+offset]
            #     end
            #     @synchronize()
            #     offset >>>= 1
            # end

            # if local_id == 1
            #     block_results[group_id] = shared[1]
            # end

            if local_id == 1
                sum = zero(eltype(block_results))
                for i = 1:workgroup_size
                    sum += shared[i]
                end
                block_results[group_id] = sum
            end
        end

        group_size = 256
        n_groups = min(cld(nnz_val, group_size), 256)
        total_workitems = group_size * n_groups

        # Allocate array for block results (one per workgroup)
        block_results = similar(nzval, T, n_groups)

        # Launch kernel with workgroup configuration
        kernel! = kernel_workgroup_dot!(backend, group_size)
        kernel!(
            block_results,
            x,
            rowind,
            colind,
            nzval,
            y,
            nnz_val;
            ndrange = (total_workitems,),
        )

        # Final reduction: sum all block results
        return sum(block_results)
    end
end
