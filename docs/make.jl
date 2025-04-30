using Documenter
using OnlinePCA

makedocs(
    sitename = "OnlinePCA.jl",
    modules = [OnlinePCA],
    format = Documenter.HTML(prettyurls = true),
    pages = [
        "Home" => "index.md",
        "Julia API" => "juliaapi.md",
        "Command line Tool" => "commandline.md"
    ])

deploydocs(
    repo = "github.com/rikenbit/OnlinePCA.jl.git",
    devbranch = "docs-only",
    versions = ["latest" => "master"],
    target = "build",
    deps = nothing,
    make = nothing)
