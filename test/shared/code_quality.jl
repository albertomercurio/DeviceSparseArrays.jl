function shared_test_vector_quality(op, array_type::String) end

function shared_test_matrix_csc_quality(op, array_type::String)
    shared_test_matrix_csc_quality_basic_linearalgebra(op, array_type)
    shared_test_matrix_csc_quality_spmv_spmm(op, array_type)
end

function shared_test_matrix_csc_quality_basic_linearalgebra(op, array_type::String)
    for T in (Int32, Int64, Float32, Float64, ComplexF32, ComplexF64)
        A = sprand(T, 1000, 1000, 0.01)
        dA = DeviceSparseMatrixCSC(
            A.m,
            A.n,
            op(getcolptr(A)),
            op(rowvals(A)),
            op(nonzeros(A)),
        )

        sum(dA)

        if T in (ComplexF32, ComplexF64)
            # The kernel functions may use @atomic for CSC matrices, which does not support Complex types in JLArray
            continue
        end

        tr(dA)
    end
end

function shared_test_matrix_csc_quality_spmv_spmm(op, array_type::String)
    for T in (Int32, Int64, Float64, ComplexF32, ComplexF64)
        if T in (ComplexF32, ComplexF64) && array_type != "Base Array"
            # The mul! function uses @atomic for CSC matrices, which does not support Complex types in JLArray
            continue
        end

        A = sprand(T, 100, 80, 0.1)
        B = rand(T, 80, 50)
        b = rand(T, 80)

        dA = DeviceSparseMatrixCSC(
            size(A, 1),
            size(A, 2),
            op(getcolptr(A)),
            op(rowvals(A)),
            op(nonzeros(A)),
        )
        dB = op(B)
        db = op(b)

        # Matrix-Vector multiplication
        dA * db
        dA * dB
    end
end
