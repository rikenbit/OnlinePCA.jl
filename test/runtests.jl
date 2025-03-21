using OnlinePCA
using OnlinePCA: read_csv, write_csv
using Test
using ArgParse
using DelimitedFiles
using Statistics
using Distributions
using SparseArrays
using MatrixMarket

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

data = Int64.(ceil.(rand(NegativeBinomial(1, 0.5), 300, 99)))
data[1:50, 1:33] .= 100*data[1:50, 1:33]
data[51:100, 34:66] .= 100*data[51:100, 34:66]
data[101:150, 67:99] .= 100*data[101:150, 67:99]

# CSV
write_csv(joinpath(tmp, "Data.csv"), data)

# Matrix Market (MM)
mmwrite(joinpath(tmp, "Data.mtx"), sparse(data))

# Output Directories
dense_path = mktempdir()
sparse_path = mktempdir()

# Tests
println("Running all tests...")

include("test_csv2bin.jl")
include("test_mm2bin.jl")
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
include("test_exact_ooc_pca_dense.jl")
include("test_exact_ooc_pca_sparse.jl")

println("All tests completed.")
