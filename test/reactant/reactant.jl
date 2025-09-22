@testset "Reactant Backend" verbose=true begin
    shared_test_vector(Reactant.ConcreteRArray, "Reactant")
    shared_test_matrix_csc(Reactant.ConcreteRArray, "Reactant")
    shared_test_matrix_csr(Reactant.ConcreteRArray, "Reactant")
end
