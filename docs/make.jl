using DeviceSparseArrays
using Documenter

DocMeta.setdocmeta!(
    DeviceSparseArrays,
    :DocTestSetup,
    :(using DeviceSparseArrays);
    recursive = true,
)

makedocs(;
    modules = [DeviceSparseArrays],
    authors = "Alberto Mercurio <alberto.mercurio96@gmail.com> and contributors",
    sitename = "DeviceSparseArrays.jl",
    format = Documenter.HTML(;
        canonical = "https://albertomercurio.github.io/DeviceSparseArrays.jl",
        edit_link = "main",
        assets = String[],
    ),
    pages = ["Home" => "index.md", "API Reference" => "api.md"],
)

deploydocs(; repo = "github.com/albertomercurio/DeviceSparseArrays.jl", devbranch = "main")
