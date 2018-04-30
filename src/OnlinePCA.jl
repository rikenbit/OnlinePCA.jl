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

	export init, WλV, RecError, ∇f, ∇fn, sym, Pw, parse_commandline, csv2sl, sumr, oja, ccipca, gd, rsgd, svrg, rsvrg

	include("Utils.jl")
	include("csv2sl.jl")
	include("sumr.jl")
	include("oja.jl")
	include("ccipca.jl")
	include("gd.jl")
	include("rsgd.jl")
	include("svrg.jl")
	include("rsvrg.jl")

end
