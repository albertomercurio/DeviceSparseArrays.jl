@testset "Reactant Backend" verbose=true begin
    shared_test_vector(
        Reactant.ConcreteRArray,
        "Reactant",
        (Int32, Int64),
        (Float32, Float64),
        (ComplexF32, ComplexF64),
    )
    shared_test_matrix_csc(
        Reactant.ConcreteRArray,
        "Reactant",
        (Int32, Int64),
        (Float32, Float64),
        (ComplexF32, ComplexF64),
    )
    shared_test_matrix_csr(
        Reactant.ConcreteRArray,
        "Reactant",
        (Int32, Int64),
        (Float32, Float64),
        (ComplexF32, ComplexF64),
    )
    shared_test_matrix_coo(
        Reactant.ConcreteRArray,
        "Reactant",
        (Int32, Int64),
        (Float32, Float64),
        (ComplexF32, ComplexF64),
    )
    shared_test_matrix_sell(
        Reactant.ConcreteRArray,
        "Reactant",
        (Int32, Int64),
        (Float32, Float64),
        (ComplexF32, ComplexF64),
    )
end
