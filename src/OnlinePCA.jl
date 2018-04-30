module OnlinePCA

	export csv2sl, sumr, oja, ccipca, gd, rsgd, svrg, rsvrg
	import ProgressMeter, ArgParse, StatsBase, DataFrames, GLM, Distributions

	include("oja.jl")
	include("ccipca.jl")
	include("gd.jl")
	include("rsgd.jl")
	include("svrg.jl")
	include("rsvrg.jl")

end
