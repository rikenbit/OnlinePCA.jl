module OnlinePCA

	using ProgressMeter:
		Progress, next!
	using ArgParse:
		@add_arg_table
	using StatsBase:
		percentile
	using DataFrames:
		DataFrame
	using GLM:
		glm, coef, IdentityLink, @formula
	using Distributions:
		Gamma, ccdf, Chisq

	export csv2sl, sumr, oja, ccipca, gd, rsgd, svrg, rsvrg

	include("oja.jl")
	include("ccipca.jl")
	include("gd.jl")
	include("rsgd.jl")
	include("svrg.jl")
	include("rsvrg.jl")

end
