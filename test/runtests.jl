using OnlinePCA
using Test
using Pkg
using DelimitedFiles
using Statistics
using Distributions

using OnlinePCA: readcsv, writecsv

tmp = mktempdir()
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

#####################################
input = Int64.(ceil.(rand(NegativeBinomial(1, 0.5), 300, 99)))
input[1:50, 1:33] .= 100*input[1:50, 1:33]
input[51:100, 34:66] .= 100*input[51:100, 34:66]
input[101:150, 67:99] .= 100*input[101:150, 67:99]
writecsv(joinpath(tmp, "Data.csv"), input)
#####################################


#####################################
println("####### Binarization (Julia API) #######")
csv2bin(csvfile=joinpath(tmp, "Data.csv"),
	binfile=joinpath(tmp, "Data.zst"))

testfilesize(true, joinpath(tmp, "Data.zst"))
#####################################


#####################################
println("####### Binarization (Command line) #######")
run(`$(julia) $(joinpath(bindir, "csv2bin")) --csvfile $(joinpath(tmp, "Data.csv")) --binfile $(joinpath(tmp, "Data.zst"))`)

testfilesize(false, joinpath(tmp, "Data.zst"))
#####################################


#####################################
println("####### Summarization (Julia API) #######")
sumr(binfile=joinpath(tmp, "Data.zst"), outdir=tmp)

testfilesize(true,
	joinpath(tmp, "Sample_NoCounts.csv"),
	joinpath(tmp, "Feature_CV2s.csv"),
	joinpath(tmp, "Feature_LogMeans.csv"),
	joinpath(tmp, "Feature_Means.csv"),
	joinpath(tmp, "Feature_NoZeros.csv"),
	joinpath(tmp, "Feature_Vars.csv"))
#####################################


#####################################
println("####### Summarization (Command line) #######")
run(`$(julia) $(joinpath(bindir, "sumr")) --binfile $(joinpath(tmp, "Data.zst")) --outdir $(tmp)`)

testfilesize(false,
	joinpath(tmp, "Sample_NoCounts.csv"),
	joinpath(tmp, "Feature_CV2s.csv"),
	joinpath(tmp, "Feature_LogMeans.csv"),
	joinpath(tmp, "Feature_Means.csv"),
	joinpath(tmp, "Feature_NoZeros.csv"),
	joinpath(tmp, "Feature_Vars.csv"))
#####################################


#####################################
println("####### HVG (Julia API) #######")
hvg(binfile=joinpath(tmp, "Data.zst"),
	rowmeanlist=joinpath(tmp, "Feature_Means.csv"),
	rowvarlist=joinpath(tmp, "Feature_Vars.csv"),
	rowcv2list=joinpath(tmp, "Feature_CV2s.csv"), outdir=tmp)

testfilesize(true,
	joinpath(tmp, "HVG_pval.csv"),
	joinpath(tmp, "HVG_a0.csv"),
	joinpath(tmp, "HVG_a1.csv"),
	joinpath(tmp, "HVG_afit.csv"),
	joinpath(tmp, "HVG_useForFit.csv"),
	joinpath(tmp, "HVG_varFitRatio.csv"),
	joinpath(tmp, "HVG_df.csv"))
#####################################


#####################################
println("####### HVG (Command line) #######")
run(`$(julia) $(joinpath(bindir, "hvg")) --binfile $(joinpath(tmp, "Data.zst")) --rowmeanlist $(joinpath(tmp, "Feature_Means.csv")) --rowvarlist $(joinpath(tmp, "Feature_Vars.csv")) --rowcv2list $(joinpath(tmp, "Feature_CV2s.csv")) --outdir $(tmp)`)

testfilesize(false,
	joinpath(tmp, "HVG_pval.csv"),
	joinpath(tmp, "HVG_a0.csv"),
	joinpath(tmp, "HVG_a1.csv"),
	joinpath(tmp, "HVG_afit.csv"),
	joinpath(tmp, "HVG_useForFit.csv"),
	joinpath(tmp, "HVG_varFitRatio.csv"),
	joinpath(tmp, "HVG_df.csv"))
#####################################


#####################################
println("####### Filtering (Julia API) #######")
filtering(input=joinpath(tmp, "Data.zst"),
	featurelist=joinpath(tmp, "Feature_Means.csv"),
	samplelist=joinpath(tmp, "Sample_NoCounts.csv"),
	thr1=10, thr2=10,
	direct1="+", direct2="+",
	output=joinpath(tmp, "filtered.zst"))

testfilesize(true,
	joinpath(tmp, "filtered.zst"))
#####################################


#####################################
println("####### Filtering (Command line) #######")
run(`$(julia) $(joinpath(bindir, "filtering")) --input $(joinpath(tmp, "Data.zst")) --featurelist $(joinpath(tmp, "Feature_Means.csv")) --samplelist $(joinpath(tmp, "Sample_NoCounts.csv")) --thr1 10 --thr2 10 --output $(joinpath(tmp, "filtered.zst"))`)

testfilesize(false,
	joinpath(tmp, "filtered.zst"))
#####################################


#####################################
println("####### GD (Julia API) #######")
out_gd1 = gd(input=joinpath(tmp, "Data.zst"),
	dim=3, scheduling="robbins-monro",
	stepsize=1.0e-15, numepoch=1,
	rowmeanlist=joinpath(tmp, "Feature_FTTMeans.csv"),
	logdir=tmp)

out_gd2 = gd(input=joinpath(tmp, "Data.zst"),
	dim=3, scheduling="momentum",
	stepsize=1.0e-15, numepoch=1,
	rowmeanlist=joinpath(tmp, "Feature_FTTMeans.csv"),
	logdir=tmp)

out_gd3 = gd(input=joinpath(tmp, "Data.zst"),
	dim=3, scheduling="nag",
	stepsize=1.0e-15, numepoch=1,
	rowmeanlist=joinpath(tmp, "Feature_FTTMeans.csv"),
	logdir=tmp)

out_gd4 = gd(input=joinpath(tmp, "Data.zst"),
	dim=3, scheduling="adagrad",
	stepsize=1.0e-15, numepoch=1,
	rowmeanlist=joinpath(tmp, "Feature_FTTMeans.csv"),
	logdir=tmp)

@test size(out_gd1[1]) == (99, 3)
@test size(out_gd1[2]) == (3, )
@test size(out_gd1[3]) == (300, 3)
@test size(out_gd1[4]) == (99, 3)

@test size(out_gd2[1]) == (99, 3)
@test size(out_gd2[2]) == (3, )
@test size(out_gd2[3]) == (300, 3)
@test size(out_gd2[4]) == (99, 3)

@test size(out_gd3[1]) == (99, 3)
@test size(out_gd3[2]) == (3, )
@test size(out_gd3[3]) == (300, 3)
@test size(out_gd3[4]) == (99, 3)

@test size(out_gd4[1]) == (99, 3)
@test size(out_gd4[2]) == (3, )
@test size(out_gd4[3]) == (300, 3)
@test size(out_gd4[4]) == (99, 3)
#####################################


#####################################
println("####### GD (Command line) #######")
run(`$(julia) $(joinpath(bindir, "gd")) --input $(joinpath(tmp, "Data.zst")) --outdir $(tmp) --dim 3 --scheduling robbins-monro --stepsize 1.0e-15 --numepoch 1 --rowmeanlist $(joinpath(tmp, "Feature_FTTMeans.csv")) --logdir $(tmp)`)

testfilesize(true,
	joinpath(tmp, "Eigen_vectors.csv"),
	joinpath(tmp, "Eigen_values.csv"),
	joinpath(tmp, "Loadings.csv"),
	joinpath(tmp, "Scores.csv"))

run(`$(julia) $(joinpath(bindir, "gd")) --input $(joinpath(tmp, "Data.zst"))  --outdir $(tmp) --dim 3 --scheduling momentum --stepsize 1.0e-15 --numepoch 1 --rowmeanlist $(joinpath(tmp, "Feature_FTTMeans.csv")) --logdir $(tmp)`)

testfilesize(true,
	joinpath(tmp, "Eigen_vectors.csv"),
	joinpath(tmp, "Eigen_values.csv"),
	joinpath(tmp, "Loadings.csv"),
	joinpath(tmp, "Scores.csv"))

run(`$(julia) $(joinpath(bindir, "gd")) --input $(joinpath(tmp, "Data.zst"))  --outdir $(tmp) --dim 3 --scheduling nag --stepsize 1.0e-15 --numepoch 1 --rowmeanlist $(joinpath(tmp, "Feature_FTTMeans.csv")) --logdir $(tmp)`)

testfilesize(true,
	joinpath(tmp, "Eigen_vectors.csv"),
	joinpath(tmp, "Eigen_values.csv"),
	joinpath(tmp, "Loadings.csv"),
	joinpath(tmp, "Scores.csv"))

run(`$(julia) $(joinpath(bindir, "gd")) --input $(joinpath(tmp, "Data.zst"))  --outdir $(tmp) --dim 3 --scheduling adagrad --stepsize 1.0e-15 --numepoch 1 --rowmeanlist $(joinpath(tmp, "Feature_FTTMeans.csv")) --logdir $(tmp)`)

testfilesize(true,
	joinpath(tmp, "Eigen_vectors.csv"),
	joinpath(tmp, "Eigen_values.csv"),
	joinpath(tmp, "Loadings.csv"),
	joinpath(tmp, "Scores.csv"))
#####################################


#####################################
println("####### Oja (Julia API) #######")
out_oja1 = oja(input=joinpath(tmp, "Data.zst"),
	dim=3, scheduling="robbins-monro",
	stepsize=1.0e-15, numepoch=1,
	rowmeanlist=joinpath(tmp, "Feature_FTTMeans.csv"),
	logdir=tmp)

out_oja2 = oja(input=joinpath(tmp, "Data.zst"),
	dim=3, scheduling="momentum",
	stepsize=1.0e-15, numepoch=1,
	rowmeanlist=joinpath(tmp, "Feature_FTTMeans.csv"),
	logdir=tmp)

out_oja3 = oja(input=joinpath(tmp, "Data.zst"),
	dim=3, scheduling="nag",
	stepsize=1.0e-15, numepoch=1,
	rowmeanlist=joinpath(tmp, "Feature_FTTMeans.csv"),
	logdir=tmp)

out_oja4 = oja(input=joinpath(tmp, "Data.zst"),
	dim=3, scheduling="adagrad",
	stepsize=1.0e-15, numepoch=1,
	rowmeanlist=joinpath(tmp, "Feature_FTTMeans.csv"),
	logdir=tmp)

@test size(out_oja1[1]) == (99, 3)
@test size(out_oja1[2]) == (3, )
@test size(out_oja1[3]) == (300, 3)
@test size(out_oja1[4]) == (99, 3)

@test size(out_oja2[1]) == (99, 3)
@test size(out_oja2[2]) == (3, )
@test size(out_oja2[3]) == (300, 3)
@test size(out_oja2[4]) == (99, 3)

@test size(out_oja3[1]) == (99, 3)
@test size(out_oja3[2]) == (3, )
@test size(out_oja3[3]) == (300, 3)
@test size(out_oja3[4]) == (99, 3)

@test size(out_oja4[1]) == (99, 3)
@test size(out_oja4[2]) == (3, )
@test size(out_oja4[3]) == (300, 3)
@test size(out_oja4[4]) == (99, 3)
#####################################


#####################################
println("####### Oja (Command line) #######")
run(`$(julia) $(joinpath(bindir, "oja")) --input $(joinpath(tmp, "Data.zst")) --outdir $(tmp) --dim 3 --scheduling robbins-monro --stepsize 1.0e-15 --numepoch 1 --rowmeanlist $(joinpath(tmp, "Feature_FTTMeans.csv")) --logdir $(tmp)`)

testfilesize(true,
	joinpath(tmp, "Eigen_vectors.csv"),
	joinpath(tmp, "Eigen_values.csv"),
	joinpath(tmp, "Loadings.csv"),
	joinpath(tmp, "Scores.csv"))

run(`$(julia) $(joinpath(bindir, "oja")) --input $(joinpath(tmp, "Data.zst"))  --outdir $(tmp) --dim 3 --scheduling momentum --stepsize 1.0e-15 --numepoch 1 --rowmeanlist $(joinpath(tmp, "Feature_FTTMeans.csv")) --logdir $(tmp)`)

testfilesize(true,
	joinpath(tmp, "Eigen_vectors.csv"),
	joinpath(tmp, "Eigen_values.csv"),
	joinpath(tmp, "Loadings.csv"),
	joinpath(tmp, "Scores.csv"))

run(`$(julia) $(joinpath(bindir, "oja")) --input $(joinpath(tmp, "Data.zst"))  --outdir $(tmp) --dim 3 --scheduling nag --stepsize 1.0e-15 --numepoch 1 --rowmeanlist $(joinpath(tmp, "Feature_FTTMeans.csv")) --logdir $(tmp)`)

testfilesize(true,
	joinpath(tmp, "Eigen_vectors.csv"),
	joinpath(tmp, "Eigen_values.csv"),
	joinpath(tmp, "Loadings.csv"),
	joinpath(tmp, "Scores.csv"))

run(`$(julia) $(joinpath(bindir, "oja")) --input $(joinpath(tmp, "Data.zst"))  --outdir $(tmp) --dim 3 --scheduling adagrad --stepsize 1.0e-15 --numepoch 1 --rowmeanlist $(joinpath(tmp, "Feature_FTTMeans.csv")) --logdir $(tmp)`)

testfilesize(true,
	joinpath(tmp, "Eigen_vectors.csv"),
	joinpath(tmp, "Eigen_values.csv"),
	joinpath(tmp, "Loadings.csv"),
	joinpath(tmp, "Scores.csv"))
#####################################


#####################################
println("####### CCIPCA (Julia API) #######")
out_ccipca1 = ccipca(input=joinpath(tmp, "Data.zst"),
	dim=3, stepsize=1.0e-15, numepoch=1,
	rowmeanlist=joinpath(tmp, "Feature_FTTMeans.csv"),
	logdir=tmp)

@test size(out_ccipca1[1]) == (99, 3)
@test size(out_ccipca1[2]) == (3, )
@test size(out_ccipca1[3]) == (300, 3)
@test size(out_ccipca1[4]) == (99, 3)
#####################################


#####################################
println("####### CCIPCA (Command line) #######")
run(`$(julia) $(joinpath(bindir, "ccipca")) --input $(joinpath(tmp, "Data.zst")) --outdir $(tmp) --dim 3 --stepsize 1.0e-15 --numepoch 1 --rowmeanlist $(joinpath(tmp, "Feature_FTTMeans.csv")) --logdir $(tmp)`)

testfilesize(true,
	joinpath(tmp, "Eigen_vectors.csv"),
	joinpath(tmp, "Eigen_values.csv"),
	joinpath(tmp, "Loadings.csv"),
	joinpath(tmp, "Scores.csv"))
#####################################


#####################################
println("####### RSGD (Julia API) #######")
out_rsgd1 = rsgd(input=joinpath(tmp, "Data.zst"),
	dim=3, scheduling="robbins-monro",
	stepsize=1.0e-15, numepoch=1,
	rowmeanlist=joinpath(tmp, "Feature_FTTMeans.csv"),
	logdir=tmp)

out_rsgd2 = rsgd(input=joinpath(tmp, "Data.zst"),
	dim=3, scheduling="momentum",
	stepsize=1.0e-15, numepoch=1,
	rowmeanlist=joinpath(tmp, "Feature_FTTMeans.csv"),
	logdir=tmp)

out_rsgd3 = rsgd(input=joinpath(tmp, "Data.zst"),
	dim=3, scheduling="nag",
	stepsize=1.0e-15, numepoch=1,
	rowmeanlist=joinpath(tmp, "Feature_FTTMeans.csv"),
	logdir=tmp)

out_rsgd4 = rsgd(input=joinpath(tmp, "Data.zst"),
	dim=3, scheduling="adagrad",
	stepsize=1.0e-15, numepoch=1,
	rowmeanlist=joinpath(tmp, "Feature_FTTMeans.csv"),
	logdir=tmp)

@test size(out_rsgd1[1]) == (99, 3)
@test size(out_rsgd1[2]) == (3, )
@test size(out_rsgd1[3]) == (300, 3)
@test size(out_rsgd1[4]) == (99, 3)

@test size(out_rsgd2[1]) == (99, 3)
@test size(out_rsgd2[2]) == (3, )
@test size(out_rsgd2[3]) == (300, 3)
@test size(out_rsgd2[4]) == (99, 3)

@test size(out_rsgd3[1]) == (99, 3)
@test size(out_rsgd3[2]) == (3, )
@test size(out_rsgd3[3]) == (300, 3)
@test size(out_rsgd3[4]) == (99, 3)

@test size(out_rsgd4[1]) == (99, 3)
@test size(out_rsgd4[2]) == (3, )
@test size(out_rsgd4[3]) == (300, 3)
@test size(out_rsgd4[4]) == (99, 3)
#####################################


#####################################
println("####### RSGD (Command line) #######")
run(`$(julia) $(joinpath(bindir, "rsgd")) --input $(joinpath(tmp, "Data.zst")) --outdir $(tmp) --dim 3 --scheduling robbins-monro --stepsize 1.0e-15 --numepoch 1 --rowmeanlist $(joinpath(tmp, "Feature_FTTMeans.csv")) --logdir $(tmp)`)

testfilesize(true,
	joinpath(tmp, "Eigen_vectors.csv"),
	joinpath(tmp, "Eigen_values.csv"),
	joinpath(tmp, "Loadings.csv"),
	joinpath(tmp, "Scores.csv"))

run(`$(julia) $(joinpath(bindir, "rsgd")) --input $(joinpath(tmp, "Data.zst"))  --outdir $(tmp) --dim 3 --scheduling momentum --stepsize 1.0e-15 --numepoch 1 --rowmeanlist $(joinpath(tmp, "Feature_FTTMeans.csv")) --logdir $(tmp)`)

testfilesize(true,
	joinpath(tmp, "Eigen_vectors.csv"),
	joinpath(tmp, "Eigen_values.csv"),
	joinpath(tmp, "Loadings.csv"),
	joinpath(tmp, "Scores.csv"))

run(`$(julia) $(joinpath(bindir, "rsgd")) --input $(joinpath(tmp, "Data.zst"))  --outdir $(tmp) --dim 3 --scheduling nag --stepsize 1.0e-15 --numepoch 1 --rowmeanlist $(joinpath(tmp, "Feature_FTTMeans.csv")) --logdir $(tmp)`)

testfilesize(true,
	joinpath(tmp, "Eigen_vectors.csv"),
	joinpath(tmp, "Eigen_values.csv"),
	joinpath(tmp, "Loadings.csv"),
	joinpath(tmp, "Scores.csv"))

run(`$(julia) $(joinpath(bindir, "rsgd")) --input $(joinpath(tmp, "Data.zst"))  --outdir $(tmp) --dim 3 --scheduling adagrad --stepsize 1.0e-15 --numepoch 1 --rowmeanlist $(joinpath(tmp, "Feature_FTTMeans.csv")) --logdir $(tmp)`)

testfilesize(true,
	joinpath(tmp, "Eigen_vectors.csv"),
	joinpath(tmp, "Eigen_values.csv"),
	joinpath(tmp, "Loadings.csv"),
	joinpath(tmp, "Scores.csv"))
#####################################


#####################################
println("####### SVRG (Julia API) #######")
out_svrg1 = svrg(input=joinpath(tmp, "Data.zst"),
	dim=3, scheduling="robbins-monro",
	stepsize=1.0e-15, numepoch=1,
	rowmeanlist=joinpath(tmp, "Feature_FTTMeans.csv"),
	logdir=tmp)

out_svrg2 = svrg(input=joinpath(tmp, "Data.zst"),
	dim=3, scheduling="momentum",
	stepsize=1.0e-15, numepoch=1,
	rowmeanlist=joinpath(tmp, "Feature_FTTMeans.csv"),
	logdir=tmp)

out_svrg3 = svrg(input=joinpath(tmp, "Data.zst"),
	dim=3, scheduling="nag",
	stepsize=1.0e-15, numepoch=1,
	rowmeanlist=joinpath(tmp, "Feature_FTTMeans.csv"),
	logdir=tmp)

out_svrg4 = svrg(input=joinpath(tmp, "Data.zst"),
	dim=3, scheduling="adagrad",
	stepsize=1.0e-15, numepoch=1,
	rowmeanlist=joinpath(tmp, "Feature_FTTMeans.csv"),
	logdir=tmp)

@test size(out_svrg1[1]) == (99, 3)
@test size(out_svrg1[2]) == (3, )
@test size(out_svrg1[3]) == (300, 3)
@test size(out_svrg1[4]) == (99, 3)

@test size(out_svrg2[1]) == (99, 3)
@test size(out_svrg2[2]) == (3, )
@test size(out_svrg2[3]) == (300, 3)
@test size(out_svrg2[4]) == (99, 3)

@test size(out_svrg3[1]) == (99, 3)
@test size(out_svrg3[2]) == (3, )
@test size(out_svrg3[3]) == (300, 3)
@test size(out_svrg3[4]) == (99, 3)

@test size(out_svrg4[1]) == (99, 3)
@test size(out_svrg4[2]) == (3, )
@test size(out_svrg4[3]) == (300, 3)
@test size(out_svrg4[4]) == (99, 3)
#####################################


#####################################
println("####### SVRG (Command line) #######")
run(`$(julia) $(joinpath(bindir, "svrg")) --input $(joinpath(tmp, "Data.zst")) --outdir $(tmp) --dim 3 --scheduling robbins-monro --stepsize 1.0e-15 --numepoch 1 --rowmeanlist $(joinpath(tmp, "Feature_FTTMeans.csv")) --logdir $(tmp)`)

testfilesize(true,
	joinpath(tmp, "Eigen_vectors.csv"),
	joinpath(tmp, "Eigen_values.csv"),
	joinpath(tmp, "Loadings.csv"),
	joinpath(tmp, "Scores.csv"))

run(`$(julia) $(joinpath(bindir, "svrg")) --input $(joinpath(tmp, "Data.zst"))  --outdir $(tmp) --dim 3 --scheduling momentum --stepsize 1.0e-15 --numepoch 1 --rowmeanlist $(joinpath(tmp, "Feature_FTTMeans.csv")) --logdir $(tmp)`)

testfilesize(true,
	joinpath(tmp, "Eigen_vectors.csv"),
	joinpath(tmp, "Eigen_values.csv"),
	joinpath(tmp, "Loadings.csv"),
	joinpath(tmp, "Scores.csv"))

run(`$(julia) $(joinpath(bindir, "svrg")) --input $(joinpath(tmp, "Data.zst"))  --outdir $(tmp) --dim 3 --scheduling nag --stepsize 1.0e-15 --numepoch 1 --rowmeanlist $(joinpath(tmp, "Feature_FTTMeans.csv")) --logdir $(tmp)`)

testfilesize(true,
	joinpath(tmp, "Eigen_vectors.csv"),
	joinpath(tmp, "Eigen_values.csv"),
	joinpath(tmp, "Loadings.csv"),
	joinpath(tmp, "Scores.csv"))

run(`$(julia) $(joinpath(bindir, "svrg")) --input $(joinpath(tmp, "Data.zst"))  --outdir $(tmp) --dim 3 --scheduling adagrad --stepsize 1.0e-15 --numepoch 1 --rowmeanlist $(joinpath(tmp, "Feature_FTTMeans.csv")) --logdir $(tmp)`)

testfilesize(true,
	joinpath(tmp, "Eigen_vectors.csv"),
	joinpath(tmp, "Eigen_values.csv"),
	joinpath(tmp, "Loadings.csv"),
	joinpath(tmp, "Scores.csv"))
#####################################


#####################################
println("####### RSVRG (Julia API) #######")
out_rsvrg1 = rsvrg(input=joinpath(tmp, "Data.zst"),
	dim=3, scheduling="robbins-monro",
	stepsize=1.0e-15, numepoch=1,
	rowmeanlist=joinpath(tmp, "Feature_FTTMeans.csv"),
	logdir=tmp)

out_rsvrg2 = rsvrg(input=joinpath(tmp, "Data.zst"),
	dim=3, scheduling="momentum",
	stepsize=1.0e-15, numepoch=1,
	rowmeanlist=joinpath(tmp, "Feature_FTTMeans.csv"),
	logdir=tmp)

out_rsvrg3 = rsvrg(input=joinpath(tmp, "Data.zst"),
	dim=3, scheduling="nag",
	stepsize=1.0e-15, numepoch=1,
	rowmeanlist=joinpath(tmp, "Feature_FTTMeans.csv"),
	logdir=tmp)

out_rsvrg4 = rsvrg(input=joinpath(tmp, "Data.zst"),
	dim=3, scheduling="adagrad",
	stepsize=1.0e-15, numepoch=1,
	rowmeanlist=joinpath(tmp, "Feature_FTTMeans.csv"),
	logdir=tmp)

@test size(out_rsvrg1[1]) == (99, 3)
@test size(out_rsvrg1[2]) == (3, )
@test size(out_rsvrg1[3]) == (300, 3)
@test size(out_rsvrg1[4]) == (99, 3)

@test size(out_rsvrg2[1]) == (99, 3)
@test size(out_rsvrg2[2]) == (3, )
@test size(out_rsvrg2[3]) == (300, 3)
@test size(out_rsvrg2[4]) == (99, 3)

@test size(out_rsvrg3[1]) == (99, 3)
@test size(out_rsvrg3[2]) == (3, )
@test size(out_rsvrg3[3]) == (300, 3)
@test size(out_rsvrg3[4]) == (99, 3)

@test size(out_rsvrg4[1]) == (99, 3)
@test size(out_rsvrg4[2]) == (3, )
@test size(out_rsvrg4[3]) == (300, 3)
@test size(out_rsvrg4[4]) == (99, 3)
#####################################


#####################################
println("####### RSVRG (Command line) #######")
run(`$(julia) $(joinpath(bindir, "rsvrg")) --input $(joinpath(tmp, "Data.zst")) --outdir $(tmp) --dim 3 --scheduling robbins-monro --stepsize 1.0e-15 --numepoch 1 --rowmeanlist $(joinpath(tmp, "Feature_FTTMeans.csv")) --logdir $(tmp)`)

testfilesize(true,
	joinpath(tmp, "Eigen_vectors.csv"),
	joinpath(tmp, "Eigen_values.csv"),
	joinpath(tmp, "Loadings.csv"),
	joinpath(tmp, "Scores.csv"))

run(`$(julia) $(joinpath(bindir, "rsvrg")) --input $(joinpath(tmp, "Data.zst"))  --outdir $(tmp) --dim 3 --scheduling momentum --stepsize 1.0e-15 --numepoch 1 --rowmeanlist $(joinpath(tmp, "Feature_FTTMeans.csv")) --logdir $(tmp)`)

testfilesize(true,
	joinpath(tmp, "Eigen_vectors.csv"),
	joinpath(tmp, "Eigen_values.csv"),
	joinpath(tmp, "Loadings.csv"),
	joinpath(tmp, "Scores.csv"))

run(`$(julia) $(joinpath(bindir, "rsvrg")) --input $(joinpath(tmp, "Data.zst"))  --outdir $(tmp) --dim 3 --scheduling nag --stepsize 1.0e-15 --numepoch 1 --rowmeanlist $(joinpath(tmp, "Feature_FTTMeans.csv")) --logdir $(tmp)`)

testfilesize(true,
	joinpath(tmp, "Eigen_vectors.csv"),
	joinpath(tmp, "Eigen_values.csv"),
	joinpath(tmp, "Loadings.csv"),
	joinpath(tmp, "Scores.csv"))

run(`$(julia) $(joinpath(bindir, "rsvrg")) --input $(joinpath(tmp, "Data.zst"))  --outdir $(tmp) --dim 3 --scheduling adagrad --stepsize 1.0e-15 --numepoch 1 --rowmeanlist $(joinpath(tmp, "Feature_FTTMeans.csv")) --logdir $(tmp)`)

testfilesize(true,
	joinpath(tmp, "Eigen_vectors.csv"),
	joinpath(tmp, "Eigen_values.csv"),
	joinpath(tmp, "Loadings.csv"),
	joinpath(tmp, "Scores.csv"))
#####################################
