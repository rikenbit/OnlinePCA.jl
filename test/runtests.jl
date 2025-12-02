using OnlinePCA
using OnlinePCA: read_csv, write_csv
using Test
using ArgParse
using DelimitedFiles
using Statistics
using Distributions
using SparseArrays
using MatrixMarket
using LinearAlgebra
using Random

# Setting
## Input Directory
tmp = mktempdir()
println(tmp)

julia = joinpath(Sys.BINDIR, "julia")
bindir = joinpath(dirname(pathof(OnlinePCA)), "..", "bin")

function testfilesize(remove::Bool, x...)
	for n = 1:length(x)
		@test filesize(x[n]) != 0
		if remove
			rm(x[n])
		end
	end
end

Random.seed!(1111)
data = Int64.(ceil.(rand(Binomial(1, 0.5), 300, 99)))
data[1:100, 1:33] .= Int64.(ceil.(rand(Binomial(1, 0.8), 100, 33)))
data[101:200, 34:66] .= Int64.(ceil.(rand(Binomial(1, 0.8), 100, 33)))
data[201:300, 67:99] .= Int64.(ceil.(rand(Binomial(1, 0.8), 100, 33)))
centered_data = data .- mean(data, dims=1) # for test_exact_ooc_pca.jl

# CSV
write_csv(joinpath(tmp, "Data.csv"), data)

# Matrix Market (MM)
mmwrite(joinpath(tmp, "Data.mtx"), sparse(data))

# Binary COO (BinCOO)
bincoofile = joinpath(tmp, "Data.bincoo")
open(bincoofile, "w") do io
    for i in 1:size(data, 1)
        for j in 1:size(data, 2)
            if data[i, j] != 0
                println(io, "$i $j")
            end
        end
    end
end

# Output Directories
dense_path = mktempdir()
sparse_path = mktempdir()

# Tests
println("Running all tests...")

include("test_csv2bin.jl")
include("test_mm2bin.jl")
include("test_bincoo2bin.jl")
include("test_sumr_dense.jl")
include("test_sumr_sparse.jl")
include("test_hvg.jl")
include("test_filtering.jl")
include("test_gd.jl")
include("test_oja.jl")
include("test_sgd.jl")
include("test_ccipca.jl")
include("test_rsgd.jl")
include("test_svrg.jl")
include("test_rsvrg.jl")
include("test_orthiter.jl")
include("test_rbkiter.jl")
include("test_arnoldi.jl")
include("test_lanczos.jl")
include("test_halko.jl")
include("test_algorithm971.jl")
include("test_singlepass.jl")
include("test_singlepass2.jl")
include("test_sparse_rsvd.jl")
include("test_exact_ooc_pca.jl")

println("All tests completed.")
