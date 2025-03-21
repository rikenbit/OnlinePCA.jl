module OnlinePCA
import HDF5
using HDF5: h5open
HDF5File = HDF5.File
using SparseArrays:
    SparseArrays, SparseMatrixCSC, sparse
using DelimitedFiles:
    writedlm, readdlm
using Statistics:
    mean, var, median
using LinearAlgebra:
    Diagonal, lu!, qr!, svd, svd!, dot, norm, eigvecs, tr, eigen
using Random:
    randperm
using ProgressMeter:
    Progress, ProgressUnknown, next!, finish!
using ArgParse:
    ArgParseSettings, parse_args, @add_arg_table!
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

export output, parse_commandline, csv2bin, sumr, tenxsumr, filtering, hvg, sgd, oja, ccipca, gd, rsgd, svrg, rsvrg, orthiter, arnoldi, lanczos, halko, algorithm971, rbkiter, singlepass, singlepass2, tenxpca, mm2bin, sparse_rsvd, exact_ooc_pca

include("Utils.jl")
include("csv2bin.jl")
include("mm2bin.jl")
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
include("sparse_rsvd.jl")
include("exact_ooc_pca.jl")

end
