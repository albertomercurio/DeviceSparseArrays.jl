# Kronecker product implementation for AbstractDeviceSparseMatrix

"""
    kron(A::DeviceSparseMatrixCOO, B::DeviceSparseMatrixCOO)

Compute the Kronecker product of two sparse matrices in COO format.

The Kronecker product of two matrices `A` (size m×n) and `B` (size p×q) 
is an (m*p)×(n*q) matrix formed by multiplying each element of `A` by the 
entire matrix `B`.

# Examples
```jldoctest
julia> using DeviceSparseArrays, SparseArrays

julia> A = DeviceSparseMatrixCOO(sparse([1, 2], [1, 2], [1.0, 2.0], 2, 2));

julia> B = DeviceSparseMatrixCOO(sparse([1, 2], [1, 2], [3.0, 4.0], 2, 2));

julia> C = kron(A, B);

julia> size(C)
(4, 4)

julia> nnz(C)
4
```
"""
function LinearAlgebra.kron(
    A::DeviceSparseMatrixCOO{Tv1,Ti1},
    B::DeviceSparseMatrixCOO{Tv2,Ti2},
) where {Tv1,Ti1,Tv2,Ti2}
    # Result dimensions
    m_C = size(A, 1) * size(B, 1)
    n_C = size(A, 2) * size(B, 2)
    nnz_C = nnz(A) * nnz(B)
    
    # Determine result types
    Tv = promote_type(Tv1, Tv2)
    Ti = promote_type(Ti1, Ti2)
    
    # Check backend compatibility
    backend_A = get_backend(A)
    backend_B = get_backend(B)
    backend_A == backend_B || throw(ArgumentError("Both arrays must have the same backend"))
    
    # Allocate output arrays
    rowind_C = similar(A.rowind, Ti, nnz_C)
    colind_C = similar(A.colind, Ti, nnz_C)
    nzval_C = similar(A.nzval, Tv, nnz_C)
    
    # Launch kernel
    kernel! = kron_coo_kernel!(backend_A)
    kernel!(
        A.rowind,
        A.colind,
        A.nzval,
        B.rowind,
        B.colind,
        B.nzval,
        rowind_C,
        colind_C,
        nzval_C,
        size(B, 1),
        size(B, 2);
        ndrange = nnz_C,
    )
    synchronize(backend_A)
    
    return DeviceSparseMatrixCOO(m_C, n_C, rowind_C, colind_C, nzval_C)
end

"""
    kron(A::AbstractDeviceSparseMatrix, B::AbstractDeviceSparseMatrix)

Compute the Kronecker product of two sparse matrices.

This method handles different sparse matrix formats by converting them to COO format,
computing the Kronecker product, and optionally converting back to the original format.

# Examples
```jldoctest
julia> using DeviceSparseArrays, SparseArrays

julia> A = DeviceSparseMatrixCSC(sparse([1, 2], [1, 2], [1.0, 2.0], 2, 2));

julia> B = DeviceSparseMatrixCSC(sparse([1, 2], [1, 2], [3.0, 4.0], 2, 2));

julia> C = kron(A, B);

julia> size(C)
(4, 4)

julia> nnz(C)
4
```
"""
function LinearAlgebra.kron(
    A::AbstractDeviceSparseMatrix,
    B::AbstractDeviceSparseMatrix,
)
    # Convert both matrices to COO format for efficient Kronecker product
    # Only convert if not already COO
    A_coo = A isa DeviceSparseMatrixCOO ? A : DeviceSparseMatrixCOO(A)
    B_coo = B isa DeviceSparseMatrixCOO ? B : DeviceSparseMatrixCOO(B)
    
    # Compute Kronecker product in COO format
    C_coo = kron(A_coo, B_coo)
    
    # Convert back to the same type as A
    # This preserves the format preference of the first argument
    if A isa DeviceSparseMatrixCOO
        return C_coo
    elseif A isa DeviceSparseMatrixCSC
        return DeviceSparseMatrixCSC(C_coo)
    elseif A isa DeviceSparseMatrixCSR
        return DeviceSparseMatrixCSR(C_coo)
    else
        # Fallback: return as COO
        return C_coo
    end
end
