@testset "CUDA Backend" verbose=true begin
    shared_test_vector(
        CuArray,
        "CUDA",
        (Int32, Int64),
        (Float32, Float64),
        (ComplexF32, ComplexF64),
    )
    shared_test_matrix_csc(
        CuArray,
        "CUDA",
        (Int32, Int64),
        (Float32, Float64),
        (ComplexF32, ComplexF64),
    )
    shared_test_matrix_csr(
        CuArray,
        "CUDA",
        (Int32, Int64),
        (Float32, Float64),
        (ComplexF32, ComplexF64),
    )
    shared_test_matrix_coo(
        CuArray,
        "CUDA",
        (Int32, Int64),
        (Float32, Float64),
        (ComplexF32, ComplexF64),
    )
end
