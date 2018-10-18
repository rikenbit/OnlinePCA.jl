using Documenter
using OnlinePCA

makedocs()

makedocs(
    format = :html,
    sitename = "OnlinePCA.jl",
    modules = [OnlinePCA],
    pages = [
        "Home" => "index.md",
        "Julia API" => "juliaapi.md",
        "Command line Tool" => "commandline.md"
    ])

deploydocs(
    repo = "github.com/rikenbit/OnlinePCA.jl.git",
    julia = "1.0",
    target = "build",
    deps = nothing,
    make = nothing)
