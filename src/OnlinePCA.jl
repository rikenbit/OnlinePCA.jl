module OnlinePCA

using DelimitedFiles:
    writedlm, readdlm
using Statistics:
    mean, var
using LinearAlgebra:
    Diagonal, lu!, qr!, svd, dot, norm
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

export output, common_parse_commandline, csv2bin, sumr, filtering, hvg, sgd, oja, ccipca, gd, rsgd, svrg, rsvrg, halko, oocpca

include("Utils.jl")
include("csv2bin.jl")
include("sumr.jl")
include("filtering.jl")
include("hvg.jl")
include("sgd.jl")
include("oja.jl")
include("ccipca.jl")
include("gd.jl")
include("rsgd.jl")
include("svrg.jl")
include("rsvrg.jl")
include("halko.jl")
include("oocpca.jl")

end
