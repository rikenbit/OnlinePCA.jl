using OnlinePCA
using Base.Test
using Distributions

tmp = mktempdir()
julia = joinpath(JULIA_HOME, "julia")

function testfilesize(remove::Bool, x...)
	for n = 1:length(x)
		@test filesize(x[n]) != 0
		if remove
			rm(x[n])
		end
	end
end

#####################################
println("####### CSV #######")
input = Int64.(ceil.(rand(NegativeBinomial(1, 0.5), 300, 99)))
input[1:50, 1:33] .= 100*input[1:50, 1:33]
input[51:100, 34:66] .= 100*input[51:100, 34:66]
input[101:150, 67:99] .= 100*input[101:150, 67:99]
writecsv("$(tmp)/Data.csv", input)
#####################################


#####################################
println("####### Binarization (Julia API) #######")
csv2sl(csvfile="$(tmp)/Data.csv", slfile="$(tmp)/Data.dat")
testfilesize(true, "$(tmp)/Data.dat")
#####################################


#####################################
println("####### Binarization (Command line) #######")
run(`$(julia) $(Pkg.dir())/OnlinePCA/bin/csv2sl --csvfile $(tmp)/Data.csv --slfile $(tmp)/Data.dat`)
testfilesize(false, "$(tmp)/Data.dat")
#####################################


#####################################
println("####### Summarization (Julia API) #######")
sumr(slfile="$(tmp)/Data.dat", outdir=tmp)
testfilesize(true, "$(tmp)/Sample_NoCounts.csv", "$(tmp)/Feature_CV2s.csv", "$(tmp)/Feature_LogMeans.csv", "$(tmp)/Feature_Means.csv", "$(tmp)/Feature_NoZeros.csv", "$(tmp)/Feature_Vars.csv")
#####################################


#####################################
println("####### Summarization (Command line) #######")
run(`$(julia) $(Pkg.dir())/OnlinePCA/bin/sumr --slfile $(tmp)/Data.dat --outdir $(tmp)`)
testfilesize(false, "$(tmp)/Sample_NoCounts.csv", "$(tmp)/Feature_CV2s.csv", "$(tmp)/Feature_LogMeans.csv", "$(tmp)/Feature_Means.csv", "$(tmp)/Feature_NoZeros.csv", "$(tmp)/Feature_Vars.csv")
#####################################


#####################################
println("####### Filtering (Julia API) #######")
filtering(slfile="$(tmp)/Data.dat", featurelist="$(tmp)/Feature_Means.csv", thr=10, outdir=tmp)
testfilesize(true, "$(tmp)/filtered.dat")
#####################################


#####################################
println("####### Filtering (Command line) #######")
run(`$(julia) $(Pkg.dir())/OnlinePCA/bin/filtering --slfile $(tmp)/Data.dat --featurelist $(tmp)/Feature_Means.csv --thr 10 --outdir $(tmp)`)
testfilesize(false, "$(tmp)/filtered.dat")
#####################################


#####################################
println("####### HVG (Julia API) #######")
hvg(slfile="$(tmp)/Data.dat", rowmeanlist="$(tmp)/Feature_Means.csv", rowvarlist="$(tmp)/Feature_Vars.csv", rowcv2list="$(tmp)/Feature_CV2s.csv", outdir=tmp)
testfilesize(true, "$(tmp)/HVG_pval.csv", "$(tmp)/HVG_a0.csv", "$(tmp)/HVG_a1.csv", "$(tmp)/HVG_afit.csv", "$(tmp)/HVG_useForFit.csv", "$(tmp)/HVG_varFitRatio.csv", "$(tmp)/HVG_df.csv")
#####################################


#####################################
println("####### HVG (Command line) #######")
run(`$(julia) $(Pkg.dir())/OnlinePCA/bin/hvg --slfile $(tmp)/Data.dat --rowmeanlist $(tmp)/Feature_Means.csv --rowvarlist $(tmp)/Feature_Vars.csv --rowcv2list $(tmp)/Feature_CV2s.csv --outdir $(tmp)`)
testfilesize(false, "$(tmp)/HVG_pval.csv", "$(tmp)/HVG_a0.csv", "$(tmp)/HVG_a1.csv", "$(tmp)/HVG_afit.csv", "$(tmp)/HVG_useForFit.csv", "$(tmp)/HVG_varFitRatio.csv", "$(tmp)/HVG_df.csv")
#####################################


#####################################
println("####### Oja (Julia API) #######")
out_oja1 = oja(input="$(tmp)/Data.dat", dim=3, scheduling="robbins-monro", stepsize=1.0e-15, numepoch=1, rowmeanlist="$(tmp)/Feature_LogMeans.csv")
out_oja2 = oja(input="$(tmp)/Data.dat", dim=3, scheduling="momentum", stepsize=1.0e-15, numepoch=1, rowmeanlist="$(tmp)/Feature_LogMeans.csv")
out_oja3 = oja(input="$(tmp)/Data.dat", dim=3, scheduling="nag", stepsize=1.0e-15, numepoch=1, rowmeanlist="$(tmp)/Feature_LogMeans.csv")
out_oja4 = oja(input="$(tmp)/Data.dat", dim=3, scheduling="adagrad", stepsize=1.0e-15, numepoch=1, rowmeanlist="$(tmp)/Feature_LogMeans.csv")
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
run(`$(julia) $(Pkg.dir())/OnlinePCA/bin/oja --input $(tmp)/Data.dat --outdir $(tmp) --dim 3 --scheduling robbins-monro --stepsize 1.0e-15 --numepoch 1 --rowmeanlist $(tmp)/Feature_LogMeans.csv`)
testfilesize(true, "$(tmp)/Eigen_vectors.csv", "$(tmp)/Eigen_values.csv", "$(tmp)/Loadings.csv", "$(tmp)/Scores.csv")

run(`$(julia) $(Pkg.dir())/OnlinePCA/bin/oja --input $(tmp)/Data.dat  --outdir $(tmp) --dim 3 --scheduling robbins-monro --stepsize 1.0e-15 --numepoch 1 --rowmeanlist $(tmp)/Feature_LogMeans.csv`)
testfilesize(true, "$(tmp)/Eigen_vectors.csv", "$(tmp)/Eigen_values.csv", "$(tmp)/Loadings.csv", "$(tmp)/Scores.csv")

run(`$(julia) $(Pkg.dir())/OnlinePCA/bin/oja --input $(tmp)/Data.dat  --outdir $(tmp) --dim 3 --scheduling robbins-monro --stepsize 1.0e-15 --numepoch 1 --rowmeanlist $(tmp)/Feature_LogMeans.csv`)
testfilesize(true, "$(tmp)/Eigen_vectors.csv", "$(tmp)/Eigen_values.csv", "$(tmp)/Loadings.csv", "$(tmp)/Scores.csv")

run(`$(julia) $(Pkg.dir())/OnlinePCA/bin/oja --input $(tmp)/Data.dat  --outdir $(tmp) --dim 3 --scheduling robbins-monro --stepsize 1.0e-15 --numepoch 1 --rowmeanlist $(tmp)/Feature_LogMeans.csv`)
testfilesize(true, "$(tmp)/Eigen_vectors.csv", "$(tmp)/Eigen_values.csv", "$(tmp)/Loadings.csv", "$(tmp)/Scores.csv")
#####################################


#####################################
println("####### CCIPCA (Julia API) #######")
out_ccipca1 = ccipca(input="$(tmp)/Data.dat", dim=3, stepsize=1.0e-15, numepoch=1, rowmeanlist="$(tmp)/Feature_LogMeans.csv")
@test size(out_ccipca1[1]) == (99, 3)
@test size(out_ccipca1[2]) == (3, )
@test size(out_ccipca1[3]) == (300, 3)
@test size(out_ccipca1[4]) == (99, 3)
#####################################


#####################################
println("####### CCIPCA (Command line) #######")
run(`$(julia) $(Pkg.dir())/OnlinePCA/bin/ccipca --input $(tmp)/Data.dat --outdir $(tmp) --dim 3 --stepsize 1.0e-15 --numepoch 1 --rowmeanlist $(tmp)/Feature_LogMeans.csv`)
testfilesize(true, "$(tmp)/Eigen_vectors.csv", "$(tmp)/Eigen_values.csv", "$(tmp)/Loadings.csv", "$(tmp)/Scores.csv")
#####################################


#####################################
println("####### GD (Julia API) #######")
out_gd1 = gd(input="$(tmp)/Data.dat", dim=3, scheduling="robbins-monro", stepsize=1.0e-15, numepoch=1, rowmeanlist="$(tmp)/Feature_LogMeans.csv")
out_gd2 = gd(input="$(tmp)/Data.dat", dim=3, scheduling="momentum", stepsize=1.0e-15, numepoch=1, rowmeanlist="$(tmp)/Feature_LogMeans.csv")
out_gd3 = gd(input="$(tmp)/Data.dat", dim=3, scheduling="nag", stepsize=1.0e-15, numepoch=1, rowmeanlist="$(tmp)/Feature_LogMeans.csv")
out_gd4 = gd(input="$(tmp)/Data.dat", dim=3, scheduling="adagrad", stepsize=1.0e-15, numepoch=1, rowmeanlist="$(tmp)/Feature_LogMeans.csv")
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
run(`$(julia) $(Pkg.dir())/OnlinePCA/bin/gd --input $(tmp)/Data.dat --outdir $(tmp) --dim 3 --scheduling robbins-monro --stepsize 1.0e-15 --numepoch 1 --rowmeanlist $(tmp)/Feature_LogMeans.csv`)
testfilesize(true, "$(tmp)/Eigen_vectors.csv", "$(tmp)/Eigen_values.csv", "$(tmp)/Loadings.csv", "$(tmp)/Scores.csv")

run(`$(julia) $(Pkg.dir())/OnlinePCA/bin/gd --input $(tmp)/Data.dat  --outdir $(tmp) --dim 3 --scheduling robbins-monro --stepsize 1.0e-15 --numepoch 1 --rowmeanlist $(tmp)/Feature_LogMeans.csv`)
testfilesize(true, "$(tmp)/Eigen_vectors.csv", "$(tmp)/Eigen_values.csv", "$(tmp)/Loadings.csv", "$(tmp)/Scores.csv")

run(`$(julia) $(Pkg.dir())/OnlinePCA/bin/gd --input $(tmp)/Data.dat  --outdir $(tmp) --dim 3 --scheduling robbins-monro --stepsize 1.0e-15 --numepoch 1 --rowmeanlist $(tmp)/Feature_LogMeans.csv`)
testfilesize(true, "$(tmp)/Eigen_vectors.csv", "$(tmp)/Eigen_values.csv", "$(tmp)/Loadings.csv", "$(tmp)/Scores.csv")

run(`$(julia) $(Pkg.dir())/OnlinePCA/bin/gd --input $(tmp)/Data.dat  --outdir $(tmp) --dim 3 --scheduling robbins-monro --stepsize 1.0e-15 --numepoch 1 --rowmeanlist $(tmp)/Feature_LogMeans.csv`)
testfilesize(true, "$(tmp)/Eigen_vectors.csv", "$(tmp)/Eigen_values.csv", "$(tmp)/Loadings.csv", "$(tmp)/Scores.csv")
#####################################


#####################################
println("####### RSGD (Julia API) #######")
out_rsgd1 = rsgd(input="$(tmp)/Data.dat", dim=3, scheduling="robbins-monro", stepsize=1.0e-15, numepoch=1, rowmeanlist="$(tmp)/Feature_LogMeans.csv")
out_rsgd2 = rsgd(input="$(tmp)/Data.dat", dim=3, scheduling="momentum", stepsize=1.0e-15, numepoch=1, rowmeanlist="$(tmp)/Feature_LogMeans.csv")
out_rsgd3 = rsgd(input="$(tmp)/Data.dat", dim=3, scheduling="nag", stepsize=1.0e-15, numepoch=1, rowmeanlist="$(tmp)/Feature_LogMeans.csv")
out_rsgd4 = rsgd(input="$(tmp)/Data.dat", dim=3, scheduling="adagrad", stepsize=1.0e-15, numepoch=1, rowmeanlist="$(tmp)/Feature_LogMeans.csv")

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
run(`$(julia) $(Pkg.dir())/OnlinePCA/bin/rsgd --input $(tmp)/Data.dat --outdir $(tmp) --dim 3 --scheduling robbins-monro --stepsize 1.0e-15 --numepoch 1 --rowmeanlist $(tmp)/Feature_LogMeans.csv`)
testfilesize(true, "$(tmp)/Eigen_vectors.csv", "$(tmp)/Eigen_values.csv", "$(tmp)/Loadings.csv", "$(tmp)/Scores.csv")

run(`$(julia) $(Pkg.dir())/OnlinePCA/bin/rsgd --input $(tmp)/Data.dat  --outdir $(tmp) --dim 3 --scheduling robbins-monro --stepsize 1.0e-15 --numepoch 1 --rowmeanlist $(tmp)/Feature_LogMeans.csv`)
testfilesize(true, "$(tmp)/Eigen_vectors.csv", "$(tmp)/Eigen_values.csv", "$(tmp)/Loadings.csv", "$(tmp)/Scores.csv")

run(`$(julia) $(Pkg.dir())/OnlinePCA/bin/rsgd --input $(tmp)/Data.dat  --outdir $(tmp) --dim 3 --scheduling robbins-monro --stepsize 1.0e-15 --numepoch 1 --rowmeanlist $(tmp)/Feature_LogMeans.csv`)
testfilesize(true, "$(tmp)/Eigen_vectors.csv", "$(tmp)/Eigen_values.csv", "$(tmp)/Loadings.csv", "$(tmp)/Scores.csv")

run(`$(julia) $(Pkg.dir())/OnlinePCA/bin/rsgd --input $(tmp)/Data.dat  --outdir $(tmp) --dim 3 --scheduling robbins-monro --stepsize 1.0e-15 --numepoch 1 --rowmeanlist $(tmp)/Feature_LogMeans.csv`)
testfilesize(true, "$(tmp)/Eigen_vectors.csv", "$(tmp)/Eigen_values.csv", "$(tmp)/Loadings.csv", "$(tmp)/Scores.csv")
#####################################


#####################################
println("####### SVRG (Julia API) #######")
out_svrg1 = svrg(input="$(tmp)/Data.dat", dim=3, scheduling="robbins-monro", stepsize=1.0e-15, numepoch=1, rowmeanlist="$(tmp)/Feature_LogMeans.csv")
out_svrg2 = svrg(input="$(tmp)/Data.dat", dim=3, scheduling="momentum", stepsize=1.0e-15, numepoch=1, rowmeanlist="$(tmp)/Feature_LogMeans.csv")
out_svrg3 = svrg(input="$(tmp)/Data.dat", dim=3, scheduling="nag", stepsize=1.0e-15, numepoch=1, rowmeanlist="$(tmp)/Feature_LogMeans.csv")
out_svrg4 = svrg(input="$(tmp)/Data.dat", dim=3, scheduling="adagrad", stepsize=1.0e-15, numepoch=1, rowmeanlist="$(tmp)/Feature_LogMeans.csv")
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
run(`$(julia) $(Pkg.dir())/OnlinePCA/bin/svrg --input $(tmp)/Data.dat --outdir $(tmp) --dim 3 --scheduling robbins-monro --stepsize 1.0e-15 --numepoch 1 --rowmeanlist $(tmp)/Feature_LogMeans.csv`)
testfilesize(true, "$(tmp)/Eigen_vectors.csv", "$(tmp)/Eigen_values.csv", "$(tmp)/Loadings.csv", "$(tmp)/Scores.csv")

run(`$(julia) $(Pkg.dir())/OnlinePCA/bin/svrg --input $(tmp)/Data.dat  --outdir $(tmp) --dim 3 --scheduling robbins-monro --stepsize 1.0e-15 --numepoch 1 --rowmeanlist $(tmp)/Feature_LogMeans.csv`)
testfilesize(true, "$(tmp)/Eigen_vectors.csv", "$(tmp)/Eigen_values.csv", "$(tmp)/Loadings.csv", "$(tmp)/Scores.csv")

run(`$(julia) $(Pkg.dir())/OnlinePCA/bin/svrg --input $(tmp)/Data.dat  --outdir $(tmp) --dim 3 --scheduling robbins-monro --stepsize 1.0e-15 --numepoch 1 --rowmeanlist $(tmp)/Feature_LogMeans.csv`)
testfilesize(true, "$(tmp)/Eigen_vectors.csv", "$(tmp)/Eigen_values.csv", "$(tmp)/Loadings.csv", "$(tmp)/Scores.csv")

run(`$(julia) $(Pkg.dir())/OnlinePCA/bin/svrg --input $(tmp)/Data.dat  --outdir $(tmp) --dim 3 --scheduling robbins-monro --stepsize 1.0e-15 --numepoch 1 --rowmeanlist $(tmp)/Feature_LogMeans.csv`)
testfilesize(true, "$(tmp)/Eigen_vectors.csv", "$(tmp)/Eigen_values.csv", "$(tmp)/Loadings.csv", "$(tmp)/Scores.csv")
#####################################


#####################################
println("####### RSVRG (Julia API) #######")
out_rsvrg1 = rsvrg(input="$(tmp)/Data.dat", dim=3, scheduling="robbins-monro", stepsize=1.0e-15, numepoch=1, rowmeanlist="$(tmp)/Feature_LogMeans.csv")
out_rsvrg2 = rsvrg(input="$(tmp)/Data.dat", dim=3, scheduling="momentum", stepsize=1.0e-15, numepoch=1, rowmeanlist="$(tmp)/Feature_LogMeans.csv")
out_rsvrg3 = rsvrg(input="$(tmp)/Data.dat", dim=3, scheduling="nag", stepsize=1.0e-15, numepoch=1, rowmeanlist="$(tmp)/Feature_LogMeans.csv")
out_rsvrg4 = rsvrg(input="$(tmp)/Data.dat", dim=3, scheduling="adagrad", stepsize=1.0e-15, numepoch=1, rowmeanlist="$(tmp)/Feature_LogMeans.csv")
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
run(`$(julia) $(Pkg.dir())/OnlinePCA/bin/rsvrg --input $(tmp)/Data.dat --outdir $(tmp) --dim 3 --scheduling robbins-monro --stepsize 1.0e-15 --numepoch 1 --rowmeanlist $(tmp)/Feature_LogMeans.csv`)
testfilesize(true, "$(tmp)/Eigen_vectors.csv", "$(tmp)/Eigen_values.csv", "$(tmp)/Loadings.csv", "$(tmp)/Scores.csv")

run(`$(julia) $(Pkg.dir())/OnlinePCA/bin/rsvrg --input $(tmp)/Data.dat  --outdir $(tmp) --dim 3 --scheduling robbins-monro --stepsize 1.0e-15 --numepoch 1 --rowmeanlist $(tmp)/Feature_LogMeans.csv`)
testfilesize(true, "$(tmp)/Eigen_vectors.csv", "$(tmp)/Eigen_values.csv", "$(tmp)/Loadings.csv", "$(tmp)/Scores.csv")

run(`$(julia) $(Pkg.dir())/OnlinePCA/bin/rsvrg --input $(tmp)/Data.dat  --outdir $(tmp) --dim 3 --scheduling robbins-monro --stepsize 1.0e-15 --numepoch 1 --rowmeanlist $(tmp)/Feature_LogMeans.csv`)
testfilesize(true, "$(tmp)/Eigen_vectors.csv", "$(tmp)/Eigen_values.csv", "$(tmp)/Loadings.csv", "$(tmp)/Scores.csv")

run(`$(julia) $(Pkg.dir())/OnlinePCA/bin/rsvrg --input $(tmp)/Data.dat  --outdir $(tmp) --dim 3 --scheduling robbins-monro --stepsize 1.0e-15 --numepoch 1 --rowmeanlist $(tmp)/Feature_LogMeans.csv`)
testfilesize(true, "$(tmp)/Eigen_vectors.csv", "$(tmp)/Eigen_values.csv", "$(tmp)/Loadings.csv", "$(tmp)/Scores.csv")
#####################################