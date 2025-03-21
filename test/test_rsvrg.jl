#####################################
println("####### RSVRG (Julia API) #######")
out_rsvrg1 = rsvrg(input=joinpath(tmp, "Data.zst"),
	dim=3, scheduling="robbins-monro",
	stepsize=1.0e-15, numepoch=1,
	rowmeanlist=joinpath(dense_path, "Feature_FTTMeans.csv"),
	logdir=dense_path)

out_rsvrg2 = rsvrg(input=joinpath(tmp, "Data.zst"),
	dim=3, scheduling="momentum",
	stepsize=1.0e-15, numepoch=1,
	rowmeanlist=joinpath(dense_path, "Feature_FTTMeans.csv"),
	logdir=dense_path)

out_rsvrg3 = rsvrg(input=joinpath(tmp, "Data.zst"),
	dim=3, scheduling="nag",
	stepsize=1.0e-15, numepoch=1,
	rowmeanlist=joinpath(dense_path, "Feature_FTTMeans.csv"),
	logdir=dense_path)

out_rsvrg4 = rsvrg(input=joinpath(tmp, "Data.zst"),
	dim=3, scheduling="adagrad",
	stepsize=1.0e-15, numepoch=1,
	rowmeanlist=joinpath(dense_path, "Feature_FTTMeans.csv"),
	logdir=dense_path)

@test size(out_rsvrg1[1]) == (99, 3)
@test size(out_rsvrg1[2]) == (3, )
@test size(out_rsvrg1[3]) == (300, 3)
@test size(out_rsvrg1[4]) == (99, 3)
@test size(out_rsvrg1[5]) == ()
@test size(out_rsvrg1[6]) == ()

@test size(out_rsvrg2[1]) == (99, 3)
@test size(out_rsvrg2[2]) == (3, )
@test size(out_rsvrg2[3]) == (300, 3)
@test size(out_rsvrg2[4]) == (99, 3)
@test size(out_rsvrg2[5]) == ()
@test size(out_rsvrg2[6]) == ()

@test size(out_rsvrg3[1]) == (99, 3)
@test size(out_rsvrg3[2]) == (3, )
@test size(out_rsvrg3[3]) == (300, 3)
@test size(out_rsvrg3[4]) == (99, 3)
@test size(out_rsvrg3[5]) == ()
@test size(out_rsvrg3[6]) == ()

@test size(out_rsvrg4[1]) == (99, 3)
@test size(out_rsvrg4[2]) == (3, )
@test size(out_rsvrg4[3]) == (300, 3)
@test size(out_rsvrg4[4]) == (99, 3)
@test size(out_rsvrg4[5]) == ()
@test size(out_rsvrg4[6]) == ()
#####################################

#####################################
println("####### RSVRG (Command line) #######")
run(`$(julia) $(joinpath(bindir, "rsvrg")) --input $(joinpath(tmp, "Data.zst")) --outdir $(dense_path) --dim 3 --scheduling robbins-monro --stepsize 1.0e-15 --numepoch 1 --rowmeanlist $(joinpath(dense_path, "Feature_FTTMeans.csv")) --logdir $(dense_path)`)

testfilesize(true,
	joinpath(dense_path, "Eigen_vectors.csv"),
	joinpath(dense_path, "Eigen_values.csv"),
	joinpath(dense_path, "Loadings.csv"),
	joinpath(dense_path, "Scores.csv"))

run(`$(julia) $(joinpath(bindir, "rsvrg")) --input $(joinpath(tmp, "Data.zst"))  --outdir $(dense_path) --dim 3 --scheduling momentum --stepsize 1.0e-15 --numepoch 1 --rowmeanlist $(joinpath(dense_path, "Feature_FTTMeans.csv")) --logdir $(dense_path)`)

testfilesize(true,
	joinpath(dense_path, "Eigen_vectors.csv"),
	joinpath(dense_path, "Eigen_values.csv"),
	joinpath(dense_path, "Loadings.csv"),
	joinpath(dense_path, "Scores.csv"))

run(`$(julia) $(joinpath(bindir, "rsvrg")) --input $(joinpath(tmp, "Data.zst"))  --outdir $(dense_path) --dim 3 --scheduling nag --stepsize 1.0e-15 --numepoch 1 --rowmeanlist $(joinpath(dense_path, "Feature_FTTMeans.csv")) --logdir $(dense_path)`)

testfilesize(true,
	joinpath(dense_path, "Eigen_vectors.csv"),
	joinpath(dense_path, "Eigen_values.csv"),
	joinpath(dense_path, "Loadings.csv"),
	joinpath(dense_path, "Scores.csv"))

run(`$(julia) $(joinpath(bindir, "rsvrg")) --input $(joinpath(tmp, "Data.zst"))  --outdir $(dense_path) --dim 3 --scheduling adagrad --stepsize 1.0e-15 --numepoch 1 --rowmeanlist $(joinpath(dense_path, "Feature_FTTMeans.csv")) --logdir $(dense_path)`)

testfilesize(true,
	joinpath(dense_path, "Eigen_vectors.csv"),
	joinpath(dense_path, "Eigen_values.csv"),
	joinpath(dense_path, "Loadings.csv"),
	joinpath(dense_path, "Scores.csv"))
#####################################

