using OnlinePCA
using Base.Test
using Distributions

#####################################
println("####### CSV #######")
tmp = mktempdir()
input = Int64.(ceil.(rand(NegativeBinomial(1, 0.5), 300, 99)))
input[1:50, 1:33] .= 100*input[1:50, 1:33]
input[51:100, 34:66] .= 100*input[51:100, 34:66]
input[101:150, 67:99] .= 100*input[101:150, 67:99]
writecsv(tmp*"/Data.csv", input)
#####################################


#####################################
println("####### Binarization (Julia API) #######")
csv2sl(csvfile=tmp*"/Data.csv", slfile=tmp*"/Data.dat")

@test eval(parse("filesize(\""*tmp*"/Data.dat"*"\")")) != 0
rm(tmp*"/Data.dat")
#####################################


#####################################
println("####### Binarization (Command line) #######")
csv2slpath = Pkg.dir() * "/OnlinePCA/bin/csv2sl"
csv2slcom = "run(`julia " * csv2slpath * " --csvfile " * tmp * "/Data.csv --slfile " * tmp * "/Data.dat`)"
eval(parse(csv2slcom))
@test eval(parse("filesize(\""*tmp*"/Data.dat"*"\")")) != 0
#####################################


#####################################
println("####### Summarization (Julia API) #######")
sumr(slfile=tmp*"/Data.dat", outdir=tmp)

@test eval(parse("filesize(\""*tmp*"/Sample_NoCounts.csv"*"\")")) != 0
@test eval(parse("filesize(\""*tmp*"/Feature_CV2s.csv"*"\")")) != 0
@test eval(parse("filesize(\""*tmp*"/Feature_LogMeans.csv"*"\")")) != 0
@test eval(parse("filesize(\""*tmp*"/Feature_Means.csv"*"\")")) != 0
@test eval(parse("filesize(\""*tmp*"/Feature_NoZeros.csv"*"\")")) != 0
@test eval(parse("filesize(\""*tmp*"/Feature_Vars.csv"*"\")")) != 0

rm(tmp*"/Sample_NoCounts.csv")
rm(tmp*"/Feature_CV2s.csv")
rm(tmp*"/Feature_LogMeans.csv")
rm(tmp*"/Feature_Means.csv")
rm(tmp*"/Feature_NoZeros.csv")
rm(tmp*"/Feature_Vars.csv")
#####################################


#####################################
println("####### Summarization (Command line) #######")
sumrpath = Pkg.dir() * "/OnlinePCA/bin/sumr"
sumrcom = "run(`julia " * sumrpath * " --slfile " * tmp * "/Data.dat --outdir " * tmp * "`)"
eval(parse(sumrcom))

@test eval(parse("filesize(\""*tmp*"/Sample_NoCounts.csv"*"\")")) != 0
@test eval(parse("filesize(\""*tmp*"/Feature_CV2s.csv"*"\")")) != 0
@test eval(parse("filesize(\""*tmp*"/Feature_LogMeans.csv"*"\")")) != 0
@test eval(parse("filesize(\""*tmp*"/Feature_Means.csv"*"\")")) != 0
@test eval(parse("filesize(\""*tmp*"/Feature_NoZeros.csv"*"\")")) != 0
@test eval(parse("filesize(\""*tmp*"/Feature_Vars.csv"*"\")")) != 0
#####################################


#####################################
println("####### Filtering (Julia API) #######")
filtering(slfile=tmp*"/Data.dat", featurelist=tmp*"/Feature_Means.csv", thr=10, outdir=tmp)

@test eval(parse("filesize(\""*tmp*"/filtered.dat"*"\")")) != 0

rm(tmp*"/filtered.dat")
#####################################


#####################################
println("####### Filtering (Command line) #######")
filteringpath = Pkg.dir() * "/OnlinePCA/bin/filtering"
filteringcom = "run(`julia " * filteringpath * " --slfile " * tmp * "/Data.dat --featurelist " * tmp*"/Feature_Means.csv --thr 10" * " --outdir " * tmp * "`)"
eval(parse(filteringcom))

@test eval(parse("filesize(\""*tmp*"/Sample_NoCounts.csv"*"\")")) != 0
#####################################


#####################################
println("####### HVG (Julia API) #######")
hvg(slfile=tmp*"/Data.dat", rowmeanlist=tmp*"/Feature_Means.csv", rowvarlist=tmp*"/Feature_Vars.csv", rowcv2list=tmp*"/Feature_CV2s.csv", outdir=tmp)

@test eval(parse("filesize(\""*tmp*"/HVG_pval.csv"*"\")")) != 0
@test eval(parse("filesize(\""*tmp*"/HVG_a0.csv"*"\")")) != 0
@test eval(parse("filesize(\""*tmp*"/HVG_a1.csv"*"\")")) != 0
@test eval(parse("filesize(\""*tmp*"/HVG_afit.csv"*"\")")) != 0
@test eval(parse("filesize(\""*tmp*"/HVG_useForFit.csv"*"\")")) != 0
@test eval(parse("filesize(\""*tmp*"/HVG_varFitRatio.csv"*"\")")) != 0
@test eval(parse("filesize(\""*tmp*"/HVG_df.csv"*"\")")) != 0

rm(tmp*"/HVG_pval.csv")
rm(tmp*"/HVG_a0.csv")
rm(tmp*"/HVG_a1.csv")
rm(tmp*"/HVG_afit.csv")
rm(tmp*"/HVG_useForFit.csv")
rm(tmp*"/HVG_varFitRatio.csv")
rm(tmp*"/HVG_df.csv")
#####################################


#####################################
println("####### HVG (Command line) #######")
hvgpath = Pkg.dir() * "/OnlinePCA/bin/hvg"
hvgcom = "run(`julia " * hvgpath * " --slfile " * tmp * "/Data.dat --rowmeanlist " * tmp*"/Feature_Means.csv --rowvarlist " * tmp * "/Feature_Vars.csv --rowcv2list " * tmp * "/Feature_CV2s.csv --outdir " * tmp * "`)"
eval(parse(hvgcom))

@test eval(parse("filesize(\""*tmp*"/HVG_pval.csv"*"\")")) != 0
@test eval(parse("filesize(\""*tmp*"/HVG_a0.csv"*"\")")) != 0
@test eval(parse("filesize(\""*tmp*"/HVG_a1.csv"*"\")")) != 0
@test eval(parse("filesize(\""*tmp*"/HVG_afit.csv"*"\")")) != 0
@test eval(parse("filesize(\""*tmp*"/HVG_useForFit.csv"*"\")")) != 0
@test eval(parse("filesize(\""*tmp*"/HVG_varFitRatio.csv"*"\")")) != 0
@test eval(parse("filesize(\""*tmp*"/HVG_df.csv"*"\")")) != 0
#####################################


#####################################
println("####### Oja (Julia API) #######")
out_oja1 = oja(input=tmp*"/Data.dat", dim=3, scheduling="robbins-monro", stepsize=1.0e-15, numepoch=1, rowmeanlist=tmp*"/Feature_LogMeans.csv")
out_oja2 = oja(input=tmp*"/Data.dat", dim=3, scheduling="momentum", stepsize=1.0e-15, numepoch=1, rowmeanlist=tmp*"/Feature_LogMeans.csv")
out_oja3 = oja(input=tmp*"/Data.dat", dim=3, scheduling="nag", stepsize=1.0e-15, numepoch=1, rowmeanlist=tmp*"/Feature_LogMeans.csv")
out_oja4 = oja(input=tmp*"/Data.dat", dim=3, scheduling="adagrad", stepsize=1.0e-15, numepoch=1, rowmeanlist=tmp*"/Feature_LogMeans.csv")

@test size(out_oja1[1]) == (99, 3)
@test size(out_oja1[2]) == (3, )
@test size(out_oja1[3]) == (300, 3)
@test size(out_oja2[1]) == (99, 3)
@test size(out_oja2[2]) == (3, )
@test size(out_oja2[3]) == (300, 3)
@test size(out_oja3[1]) == (99, 3)
@test size(out_oja3[2]) == (3, )
@test size(out_oja3[3]) == (300, 3)
@test size(out_oja4[1]) == (99, 3)
@test size(out_oja4[2]) == (3, )
@test size(out_oja4[3]) == (300, 3)
#####################################


#####################################
println("####### Oja (Command line) #######")
ojapath = Pkg.dir() * "/OnlinePCA/bin/oja"
ojacom1 = "run(`julia " * ojapath * " --input " * tmp * "/Data.dat " * " --outdir " * tmp * " --dim 3 --scheduling robbins-monro --stepsize 1.0e-15 --numepoch 1 --rowmeanlist " * tmp * "/Feature_LogMeans.csv`)"
ojacom2 = "run(`julia " * ojapath * " --input " * tmp * "/Data.dat " * " --outdir " * tmp * " --dim 3 --scheduling robbins-monro --stepsize 1.0e-15 --numepoch 1 --rowmeanlist " * tmp * "/Feature_LogMeans.csv`)"
ojacom3 = "run(`julia " * ojapath * " --input " * tmp * "/Data.dat " * " --outdir " * tmp * " --dim 3 --scheduling robbins-monro --stepsize 1.0e-15 --numepoch 1 --rowmeanlist " * tmp * "/Feature_LogMeans.csv`)"
ojacom4 = "run(`julia " * ojapath * " --input " * tmp * "/Data.dat " * " --outdir " * tmp * " --dim 3 --scheduling robbins-monro --stepsize 1.0e-15 --numepoch 1 --rowmeanlist " * tmp * "/Feature_LogMeans.csv`)"

eval(parse(ojacom1))
@test eval(parse("filesize(\""*tmp*"/Eigen_vectors.csv"*"\")")) != 0
@test eval(parse("filesize(\""*tmp*"/Eigen_values.csv"*"\")")) != 0
@test eval(parse("filesize(\""*tmp*"/Scores.csv"*"\")")) != 0
rm(tmp*"/Eigen_vectors.csv")
rm(tmp*"/Eigen_values.csv")
rm(tmp*"/Scores.csv")

eval(parse(ojacom2))
@test eval(parse("filesize(\""*tmp*"/Eigen_vectors.csv"*"\")")) != 0
@test eval(parse("filesize(\""*tmp*"/Eigen_values.csv"*"\")")) != 0
@test eval(parse("filesize(\""*tmp*"/Scores.csv"*"\")")) != 0
rm(tmp*"/Eigen_vectors.csv")
rm(tmp*"/Eigen_values.csv")
rm(tmp*"/Scores.csv")

eval(parse(ojacom3))
@test eval(parse("filesize(\""*tmp*"/Eigen_vectors.csv"*"\")")) != 0
@test eval(parse("filesize(\""*tmp*"/Eigen_values.csv"*"\")")) != 0
@test eval(parse("filesize(\""*tmp*"/Scores.csv"*"\")")) != 0
rm(tmp*"/Eigen_vectors.csv")
rm(tmp*"/Eigen_values.csv")
rm(tmp*"/Scores.csv")

eval(parse(ojacom4))
@test eval(parse("filesize(\""*tmp*"/Eigen_vectors.csv"*"\")")) != 0
@test eval(parse("filesize(\""*tmp*"/Eigen_values.csv"*"\")")) != 0
@test eval(parse("filesize(\""*tmp*"/Scores.csv"*"\")")) != 0
rm(tmp*"/Eigen_vectors.csv")
rm(tmp*"/Eigen_values.csv")
rm(tmp*"/Scores.csv")
#####################################


#####################################
println("####### CCIPCA (Julia API) #######")
out_ccipca1 = ccipca(input=tmp*"/Data.dat", dim=3, stepsize=1.0e-15, numepoch=1, rowmeanlist=tmp*"/Feature_LogMeans.csv")

@test size(out_ccipca1[1]) == (99, 3)
@test size(out_ccipca1[2]) == (3, )
@test size(out_ccipca1[3]) == (300, 3)
#####################################


#####################################
println("####### CCIPCA (Command line) #######")
ccipcapath = Pkg.dir() * "/OnlinePCA/bin/ccipca"
ccipcacom1 = "run(`julia " * ccipcapath * " --input " * tmp * "/Data.dat " * " --outdir " * tmp * " --dim 3 --stepsize 1.0e-15 --numepoch 1 --rowmeanlist " * tmp * "/Feature_LogMeans.csv`)"

eval(parse(ccipcacom1))
@test eval(parse("filesize(\""*tmp*"/Eigen_vectors.csv"*"\")")) != 0
@test eval(parse("filesize(\""*tmp*"/Eigen_values.csv"*"\")")) != 0
@test eval(parse("filesize(\""*tmp*"/Scores.csv"*"\")")) != 0
rm(tmp*"/Eigen_vectors.csv")
rm(tmp*"/Eigen_values.csv")
rm(tmp*"/Scores.csv")
#####################################


#####################################
println("####### GD (Julia API) #######")
out_gd1 = gd(input=tmp*"/Data.dat", dim=3, scheduling="robbins-monro", stepsize=1.0e-15, numepoch=1, rowmeanlist=tmp*"/Feature_LogMeans.csv")
out_gd2 = gd(input=tmp*"/Data.dat", dim=3, scheduling="momentum", stepsize=1.0e-15, numepoch=1, rowmeanlist=tmp*"/Feature_LogMeans.csv")
out_gd3 = gd(input=tmp*"/Data.dat", dim=3, scheduling="nag", stepsize=1.0e-15, numepoch=1, rowmeanlist=tmp*"/Feature_LogMeans.csv")
out_gd4 = gd(input=tmp*"/Data.dat", dim=3, scheduling="adagrad", stepsize=1.0e-15, numepoch=1, rowmeanlist=tmp*"/Feature_LogMeans.csv")

@test size(out_gd1[1]) == (99, 3)
@test size(out_gd1[2]) == (3, )
@test size(out_gd1[3]) == (300, 3)
@test size(out_gd2[1]) == (99, 3)
@test size(out_gd2[2]) == (3, )
@test size(out_gd2[3]) == (300, 3)
@test size(out_gd3[1]) == (99, 3)
@test size(out_gd3[2]) == (3, )
@test size(out_gd3[3]) == (300, 3)
@test size(out_gd4[1]) == (99, 3)
@test size(out_gd4[2]) == (3, )
@test size(out_gd4[3]) == (300, 3)
#####################################


#####################################
println("####### GD (Command line) #######")
gdpath = Pkg.dir() * "/OnlinePCA/bin/gd"
gdcom1 = "run(`julia " * gdpath * " --input " * tmp * "/Data.dat " * " --outdir " * tmp * " --dim 3 --scheduling robbins-monro --stepsize 1.0e-15 --numepoch 1 --rowmeanlist " * tmp * "/Feature_LogMeans.csv`)"
gdcom2 = "run(`julia " * gdpath * " --input " * tmp * "/Data.dat " * " --outdir " * tmp * " --dim 3 --scheduling robbins-monro --stepsize 1.0e-15 --numepoch 1 --rowmeanlist " * tmp * "/Feature_LogMeans.csv`)"
gdcom3 = "run(`julia " * gdpath * " --input " * tmp * "/Data.dat " * " --outdir " * tmp * " --dim 3 --scheduling robbins-monro --stepsize 1.0e-15 --numepoch 1 --rowmeanlist " * tmp * "/Feature_LogMeans.csv`)"
gdcom4 = "run(`julia " * gdpath * " --input " * tmp * "/Data.dat " * " --outdir " * tmp * " --dim 3 --scheduling robbins-monro --stepsize 1.0e-15 --numepoch 1 --rowmeanlist " * tmp * "/Feature_LogMeans.csv`)"

eval(parse(gdcom1))
@test eval(parse("filesize(\""*tmp*"/Eigen_vectors.csv"*"\")")) != 0
@test eval(parse("filesize(\""*tmp*"/Eigen_values.csv"*"\")")) != 0
@test eval(parse("filesize(\""*tmp*"/Scores.csv"*"\")")) != 0
rm(tmp*"/Eigen_vectors.csv")
rm(tmp*"/Eigen_values.csv")
rm(tmp*"/Scores.csv")

eval(parse(gdcom2))
@test eval(parse("filesize(\""*tmp*"/Eigen_vectors.csv"*"\")")) != 0
@test eval(parse("filesize(\""*tmp*"/Eigen_values.csv"*"\")")) != 0
@test eval(parse("filesize(\""*tmp*"/Scores.csv"*"\")")) != 0
rm(tmp*"/Eigen_vectors.csv")
rm(tmp*"/Eigen_values.csv")
rm(tmp*"/Scores.csv")

eval(parse(gdcom3))
@test eval(parse("filesize(\""*tmp*"/Eigen_vectors.csv"*"\")")) != 0
@test eval(parse("filesize(\""*tmp*"/Eigen_values.csv"*"\")")) != 0
@test eval(parse("filesize(\""*tmp*"/Scores.csv"*"\")")) != 0
rm(tmp*"/Eigen_vectors.csv")
rm(tmp*"/Eigen_values.csv")
rm(tmp*"/Scores.csv")

eval(parse(gdcom4))
@test eval(parse("filesize(\""*tmp*"/Eigen_vectors.csv"*"\")")) != 0
@test eval(parse("filesize(\""*tmp*"/Eigen_values.csv"*"\")")) != 0
@test eval(parse("filesize(\""*tmp*"/Scores.csv"*"\")")) != 0
rm(tmp*"/Eigen_vectors.csv")
rm(tmp*"/Eigen_values.csv")
rm(tmp*"/Scores.csv")
#####################################


#####################################
println("####### RSGD (Julia API) #######")
out_rsgd1 = rsgd(input=tmp*"/Data.dat", dim=3, scheduling="robbins-monro", stepsize=1.0e-15, numepoch=1, rowmeanlist=tmp*"/Feature_LogMeans.csv")
out_rsgd2 = rsgd(input=tmp*"/Data.dat", dim=3, scheduling="momentum", stepsize=1.0e-15, numepoch=1, rowmeanlist=tmp*"/Feature_LogMeans.csv")
out_rsgd3 = rsgd(input=tmp*"/Data.dat", dim=3, scheduling="nag", stepsize=1.0e-15, numepoch=1, rowmeanlist=tmp*"/Feature_LogMeans.csv")
out_rsgd4 = rsgd(input=tmp*"/Data.dat", dim=3, scheduling="adagrad", stepsize=1.0e-15, numepoch=1, rowmeanlist=tmp*"/Feature_LogMeans.csv")

@test size(out_rsgd1[1]) == (99, 3)
@test size(out_rsgd1[2]) == (3, )
@test size(out_rsgd1[3]) == (300, 3)
@test size(out_rsgd2[1]) == (99, 3)
@test size(out_rsgd2[2]) == (3, )
@test size(out_rsgd2[3]) == (300, 3)
@test size(out_rsgd3[1]) == (99, 3)
@test size(out_rsgd3[2]) == (3, )
@test size(out_rsgd3[3]) == (300, 3)
@test size(out_rsgd4[1]) == (99, 3)
@test size(out_rsgd4[2]) == (3, )
@test size(out_rsgd4[3]) == (300, 3)
#####################################


#####################################
println("####### RSGD (Command line) #######")
rsgdpath = Pkg.dir() * "/OnlinePCA/bin/rsgd"
rsgdcom1 = "run(`julia " * rsgdpath * " --input " * tmp * "/Data.dat " * " --outdir " * tmp * " --dim 3 --scheduling robbins-monro --stepsize 1.0e-15 --numepoch 1 --rowmeanlist " * tmp * "/Feature_LogMeans.csv`)"
rsgdcom2 = "run(`julia " * rsgdpath * " --input " * tmp * "/Data.dat " * " --outdir " * tmp * " --dim 3 --scheduling robbins-monro --stepsize 1.0e-15 --numepoch 1 --rowmeanlist " * tmp * "/Feature_LogMeans.csv`)"
rsgdcom3 = "run(`julia " * rsgdpath * " --input " * tmp * "/Data.dat " * " --outdir " * tmp * " --dim 3 --scheduling robbins-monro --stepsize 1.0e-15 --numepoch 1 --rowmeanlist " * tmp * "/Feature_LogMeans.csv`)"
rsgdcom4 = "run(`julia " * rsgdpath * " --input " * tmp * "/Data.dat " * " --outdir " * tmp * " --dim 3 --scheduling robbins-monro --stepsize 1.0e-15 --numepoch 1 --rowmeanlist " * tmp * "/Feature_LogMeans.csv`)"

eval(parse(rsgdcom1))
@test eval(parse("filesize(\""*tmp*"/Eigen_vectors.csv"*"\")")) != 0
@test eval(parse("filesize(\""*tmp*"/Eigen_values.csv"*"\")")) != 0
@test eval(parse("filesize(\""*tmp*"/Scores.csv"*"\")")) != 0
rm(tmp*"/Eigen_vectors.csv")
rm(tmp*"/Eigen_values.csv")
rm(tmp*"/Scores.csv")

eval(parse(rsgdcom2))
@test eval(parse("filesize(\""*tmp*"/Eigen_vectors.csv"*"\")")) != 0
@test eval(parse("filesize(\""*tmp*"/Eigen_values.csv"*"\")")) != 0
@test eval(parse("filesize(\""*tmp*"/Scores.csv"*"\")")) != 0
rm(tmp*"/Eigen_vectors.csv")
rm(tmp*"/Eigen_values.csv")
rm(tmp*"/Scores.csv")

eval(parse(rsgdcom3))
@test eval(parse("filesize(\""*tmp*"/Eigen_vectors.csv"*"\")")) != 0
@test eval(parse("filesize(\""*tmp*"/Eigen_values.csv"*"\")")) != 0
@test eval(parse("filesize(\""*tmp*"/Scores.csv"*"\")")) != 0
rm(tmp*"/Eigen_vectors.csv")
rm(tmp*"/Eigen_values.csv")
rm(tmp*"/Scores.csv")

eval(parse(rsgdcom4))
@test eval(parse("filesize(\""*tmp*"/Eigen_vectors.csv"*"\")")) != 0
@test eval(parse("filesize(\""*tmp*"/Eigen_values.csv"*"\")")) != 0
@test eval(parse("filesize(\""*tmp*"/Scores.csv"*"\")")) != 0
rm(tmp*"/Eigen_vectors.csv")
rm(tmp*"/Eigen_values.csv")
rm(tmp*"/Scores.csv")
#####################################


#####################################
println("####### SVRG (Julia API) #######")
out_svrg1 = svrg(input=tmp*"/Data.dat", dim=3, scheduling="robbins-monro", stepsize=1.0e-15, numepoch=1, rowmeanlist=tmp*"/Feature_LogMeans.csv")
out_svrg2 = svrg(input=tmp*"/Data.dat", dim=3, scheduling="momentum", stepsize=1.0e-15, numepoch=1, rowmeanlist=tmp*"/Feature_LogMeans.csv")
out_svrg3 = svrg(input=tmp*"/Data.dat", dim=3, scheduling="nag", stepsize=1.0e-15, numepoch=1, rowmeanlist=tmp*"/Feature_LogMeans.csv")
out_svrg4 = svrg(input=tmp*"/Data.dat", dim=3, scheduling="adagrad", stepsize=1.0e-15, numepoch=1, rowmeanlist=tmp*"/Feature_LogMeans.csv")

@test size(out_svrg1[1]) == (99, 3)
@test size(out_svrg1[2]) == (3, )
@test size(out_svrg1[3]) == (300, 3)
@test size(out_svrg2[1]) == (99, 3)
@test size(out_svrg2[2]) == (3, )
@test size(out_svrg2[3]) == (300, 3)
@test size(out_svrg3[1]) == (99, 3)
@test size(out_svrg3[2]) == (3, )
@test size(out_svrg3[3]) == (300, 3)
@test size(out_svrg4[1]) == (99, 3)
@test size(out_svrg4[2]) == (3, )
@test size(out_svrg4[3]) == (300, 3)
#####################################


#####################################
println("####### SVRG (Command line) #######")
svrgpath = Pkg.dir() * "/OnlinePCA/bin/svrg"
svrgcom1 = "run(`julia " * svrgpath * " --input " * tmp * "/Data.dat " * " --outdir " * tmp * " --dim 3 --scheduling robbins-monro --stepsize 1.0e-15 --numepoch 1 --rowmeanlist " * tmp * "/Feature_LogMeans.csv`)"
svrgcom2 = "run(`julia " * svrgpath * " --input " * tmp * "/Data.dat " * " --outdir " * tmp * " --dim 3 --scheduling robbins-monro --stepsize 1.0e-15 --numepoch 1 --rowmeanlist " * tmp * "/Feature_LogMeans.csv`)"
svrgcom3 = "run(`julia " * svrgpath * " --input " * tmp * "/Data.dat " * " --outdir " * tmp * " --dim 3 --scheduling robbins-monro --stepsize 1.0e-15 --numepoch 1 --rowmeanlist " * tmp * "/Feature_LogMeans.csv`)"
svrgcom4 = "run(`julia " * svrgpath * " --input " * tmp * "/Data.dat " * " --outdir " * tmp * " --dim 3 --scheduling robbins-monro --stepsize 1.0e-15 --numepoch 1 --rowmeanlist " * tmp * "/Feature_LogMeans.csv`)"

eval(parse(svrgcom1))
@test eval(parse("filesize(\""*tmp*"/Eigen_vectors.csv"*"\")")) != 0
@test eval(parse("filesize(\""*tmp*"/Eigen_values.csv"*"\")")) != 0
@test eval(parse("filesize(\""*tmp*"/Scores.csv"*"\")")) != 0
rm(tmp*"/Eigen_vectors.csv")
rm(tmp*"/Eigen_values.csv")
rm(tmp*"/Scores.csv")

eval(parse(svrgcom2))
@test eval(parse("filesize(\""*tmp*"/Eigen_vectors.csv"*"\")")) != 0
@test eval(parse("filesize(\""*tmp*"/Eigen_values.csv"*"\")")) != 0
@test eval(parse("filesize(\""*tmp*"/Scores.csv"*"\")")) != 0
rm(tmp*"/Eigen_vectors.csv")
rm(tmp*"/Eigen_values.csv")
rm(tmp*"/Scores.csv")

eval(parse(svrgcom3))
@test eval(parse("filesize(\""*tmp*"/Eigen_vectors.csv"*"\")")) != 0
@test eval(parse("filesize(\""*tmp*"/Eigen_values.csv"*"\")")) != 0
@test eval(parse("filesize(\""*tmp*"/Scores.csv"*"\")")) != 0
rm(tmp*"/Eigen_vectors.csv")
rm(tmp*"/Eigen_values.csv")
rm(tmp*"/Scores.csv")

eval(parse(svrgcom4))
@test eval(parse("filesize(\""*tmp*"/Eigen_vectors.csv"*"\")")) != 0
@test eval(parse("filesize(\""*tmp*"/Eigen_values.csv"*"\")")) != 0
@test eval(parse("filesize(\""*tmp*"/Scores.csv"*"\")")) != 0
rm(tmp*"/Eigen_vectors.csv")
rm(tmp*"/Eigen_values.csv")
rm(tmp*"/Scores.csv")
#####################################


#####################################
println("####### RSVRG (Julia API) #######")
out_rsvrg1 = rsvrg(input=tmp*"/Data.dat", dim=3, scheduling="robbins-monro", stepsize=1.0e-15, numepoch=1, rowmeanlist=tmp*"/Feature_LogMeans.csv")
out_rsvrg2 = rsvrg(input=tmp*"/Data.dat", dim=3, scheduling="momentum", stepsize=1.0e-15, numepoch=1, rowmeanlist=tmp*"/Feature_LogMeans.csv")
out_rsvrg3 = rsvrg(input=tmp*"/Data.dat", dim=3, scheduling="nag", stepsize=1.0e-15, numepoch=1, rowmeanlist=tmp*"/Feature_LogMeans.csv")
out_rsvrg4 = rsvrg(input=tmp*"/Data.dat", dim=3, scheduling="adagrad", stepsize=1.0e-15, numepoch=1, rowmeanlist=tmp*"/Feature_LogMeans.csv")

@test size(out_rsvrg1[1]) == (99, 3)
@test size(out_rsvrg1[2]) == (3, )
@test size(out_rsvrg1[3]) == (300, 3)
@test size(out_rsvrg2[1]) == (99, 3)
@test size(out_rsvrg2[2]) == (3, )
@test size(out_rsvrg2[3]) == (300, 3)
@test size(out_rsvrg3[1]) == (99, 3)
@test size(out_rsvrg3[2]) == (3, )
@test size(out_rsvrg3[3]) == (300, 3)
@test size(out_rsvrg4[1]) == (99, 3)
@test size(out_rsvrg4[2]) == (3, )
@test size(out_rsvrg4[3]) == (300, 3)
#####################################


#####################################
println("####### RSVRG (Command line) #######")
rsvrgpath = Pkg.dir() * "/OnlinePCA/bin/rsvrg"
rsvrgcom1 = "run(`julia " * rsvrgpath * " --input " * tmp * "/Data.dat " * " --outdir " * tmp * " --dim 3 --scheduling robbins-monro --stepsize 1.0e-15 --numepoch 1 --rowmeanlist " * tmp * "/Feature_LogMeans.csv`)"
rsvrgcom2 = "run(`julia " * rsvrgpath * " --input " * tmp * "/Data.dat " * " --outdir " * tmp * " --dim 3 --scheduling robbins-monro --stepsize 1.0e-15 --numepoch 1 --rowmeanlist " * tmp * "/Feature_LogMeans.csv`)"
rsvrgcom3 = "run(`julia " * rsvrgpath * " --input " * tmp * "/Data.dat " * " --outdir " * tmp * " --dim 3 --scheduling robbins-monro --stepsize 1.0e-15 --numepoch 1 --rowmeanlist " * tmp * "/Feature_LogMeans.csv`)"
rsvrgcom4 = "run(`julia " * rsvrgpath * " --input " * tmp * "/Data.dat " * " --outdir " * tmp * " --dim 3 --scheduling robbins-monro --stepsize 1.0e-15 --numepoch 1 --rowmeanlist " * tmp * "/Feature_LogMeans.csv`)"

eval(parse(rsvrgcom1))
@test eval(parse("filesize(\""*tmp*"/Eigen_vectors.csv"*"\")")) != 0
@test eval(parse("filesize(\""*tmp*"/Eigen_values.csv"*"\")")) != 0
@test eval(parse("filesize(\""*tmp*"/Scores.csv"*"\")")) != 0
rm(tmp*"/Eigen_vectors.csv")
rm(tmp*"/Eigen_values.csv")
rm(tmp*"/Scores.csv")

eval(parse(rsvrgcom2))
@test eval(parse("filesize(\""*tmp*"/Eigen_vectors.csv"*"\")")) != 0
@test eval(parse("filesize(\""*tmp*"/Eigen_values.csv"*"\")")) != 0
@test eval(parse("filesize(\""*tmp*"/Scores.csv"*"\")")) != 0
rm(tmp*"/Eigen_vectors.csv")
rm(tmp*"/Eigen_values.csv")
rm(tmp*"/Scores.csv")

eval(parse(rsvrgcom3))
@test eval(parse("filesize(\""*tmp*"/Eigen_vectors.csv"*"\")")) != 0
@test eval(parse("filesize(\""*tmp*"/Eigen_values.csv"*"\")")) != 0
@test eval(parse("filesize(\""*tmp*"/Scores.csv"*"\")")) != 0
rm(tmp*"/Eigen_vectors.csv")
rm(tmp*"/Eigen_values.csv")
rm(tmp*"/Scores.csv")

eval(parse(rsvrgcom4))
@test eval(parse("filesize(\""*tmp*"/Eigen_vectors.csv"*"\")")) != 0
@test eval(parse("filesize(\""*tmp*"/Eigen_values.csv"*"\")")) != 0
@test eval(parse("filesize(\""*tmp*"/Scores.csv"*"\")")) != 0
#####################################