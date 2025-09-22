@testset "CUDA Backend" verbose=true begin
    shared_test_vector(CuArray, "CUDA")
    shared_test_matrix_csc(CuArray, "CUDA")
    shared_test_matrix_csr(CuArray, "CUDA")
end
