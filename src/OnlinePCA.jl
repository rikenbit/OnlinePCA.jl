__precompile__()

module OnlinePCA

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

	export output, common_parse_commandline, csv2sl, sumr, filtering, hvg, oja, ccipca, gd, rsgd, svrg, rsvrg

	include("Utils.jl")
	include("csv2sl.jl")
	include("sumr.jl")
	include("filtering.jl")
	include("hvg.jl")
	include("oja.jl")
	include("ccipca.jl")
	include("gd.jl")
	include("rsgd.jl")
	include("svrg.jl")
	include("rsvrg.jl")
end
