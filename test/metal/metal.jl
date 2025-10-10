@testset "Metal Backend" verbose=true begin
    shared_test_vector(MtlArray, "Reactant")
    shared_test_matrix_csc(MtlArray, "Reactant")
    shared_test_matrix_csr(MtlArray, "Reactant")
    shared_test_matrix_coo(MtlArray, "Reactant")
end
