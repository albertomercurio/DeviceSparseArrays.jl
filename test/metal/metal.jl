@testset "Metal Backend" verbose=true begin
    shared_test_vector(MtlArray, "Metal", (Int32,), (Float32,), (ComplexF32,))
    shared_test_matrix_csc(MtlArray, "Metal", (Int32,), (Float32,), (ComplexF32,))
    # shared_test_matrix_csr(MtlArray, "Metal")
    # shared_test_matrix_coo(MtlArray, "Metal")
end
