module OnlinePCA

using HDF5:
    HDF5File, HDF5Group, h5open
using SparseArrays:
    SparseArrays, SparseMatrixCSC, sortSparseMatrixCSC!
using DelimitedFiles:
    writedlm, readdlm
using Statistics:
    mean, var, median
using LinearAlgebra:
    Diagonal, lu!, qr!, svd, svd!, dot, norm, eigvecs, tr
using Random:
    randperm
using ProgressMeter:
	Progress, next!
using ArgParse:
    ArgParseSettings, parse_args, @add_arg_table
using StatsBase:
	percentile
using DataFrames:
	DataFrame
using GLM:
	glm, coef, IdentityLink, @formula
using Distributions:
	Gamma, ccdf, Chisq
using CodecZstd:
	ZstdCompressorStream, ZstdDecompressorStream

export output, common_parse_commandline, csv2bin, sumr, tenxsumr, filtering, hvg, sgd, oja, ccipca, gd, rsgd, svrg, rsvrg, orthiter, arnoldi, lanczos, halko, algorithm971, rbkiter, singlepass, singlepass2, tenxpca

include("Utils.jl")
include("csv2bin.jl")
include("sumr.jl")
include("tenxsumr.jl")
include("filtering.jl")
include("hvg.jl")
include("sgd.jl")
include("oja.jl")
include("ccipca.jl")
include("gd.jl")
include("rsgd.jl")
include("svrg.jl")
include("rsvrg.jl")
include("orthiter.jl")
include("arnoldi.jl")
include("lanczos.jl")
include("halko.jl")
include("algorithm971.jl")
include("rbkiter.jl")
include("singlepass.jl")
include("singlepass2.jl")
include("tenxpca.jl")

end
