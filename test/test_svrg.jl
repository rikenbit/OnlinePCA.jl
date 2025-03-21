#####################################
println("####### SVRG (Julia API) #######")
out_svrg1 = svrg(input=joinpath(tmp, "Data.zst"),
	dim=3, scheduling="robbins-monro",
	stepsize=1.0e-15, numepoch=1,
	rowmeanlist=joinpath(dense_path, "Feature_FTTMeans.csv"),
	logdir=dense_path)

out_svrg2 = svrg(input=joinpath(tmp, "Data.zst"),
	dim=3, scheduling="momentum",
	stepsize=1.0e-15, numepoch=1,
	rowmeanlist=joinpath(dense_path, "Feature_FTTMeans.csv"),
	logdir=dense_path)

out_svrg3 = svrg(input=joinpath(tmp, "Data.zst"),
	dim=3, scheduling="nag",
	stepsize=1.0e-15, numepoch=1,
	rowmeanlist=joinpath(dense_path, "Feature_FTTMeans.csv"),
	logdir=dense_path)

out_svrg4 = svrg(input=joinpath(tmp, "Data.zst"),
	dim=3, scheduling="adagrad",
	stepsize=1.0e-15, numepoch=1,
	rowmeanlist=joinpath(dense_path, "Feature_FTTMeans.csv"),
	logdir=dense_path)

@test size(out_svrg1[1]) == (99, 3)
@test size(out_svrg1[2]) == (3, )
@test size(out_svrg1[3]) == (300, 3)
@test size(out_svrg1[4]) == (99, 3)
@test size(out_svrg1[5]) == ()
@test size(out_svrg1[6]) == ()

@test size(out_svrg2[1]) == (99, 3)
@test size(out_svrg2[2]) == (3, )
@test size(out_svrg2[3]) == (300, 3)
@test size(out_svrg2[4]) == (99, 3)
@test size(out_svrg2[5]) == ()
@test size(out_svrg2[6]) == ()

@test size(out_svrg3[1]) == (99, 3)
@test size(out_svrg3[2]) == (3, )
@test size(out_svrg3[3]) == (300, 3)
@test size(out_svrg3[4]) == (99, 3)
@test size(out_svrg3[5]) == ()
@test size(out_svrg3[6]) == ()

@test size(out_svrg4[1]) == (99, 3)
@test size(out_svrg4[2]) == (3, )
@test size(out_svrg4[3]) == (300, 3)
@test size(out_svrg4[4]) == (99, 3)
@test size(out_svrg4[5]) == ()
@test size(out_svrg4[6]) == ()
#####################################

#####################################
println("####### SVRG (Command line) #######")
run(`$(julia) $(joinpath(bindir, "svrg")) --input $(joinpath(tmp, "Data.zst")) --outdir $(dense_path) --dim 3 --scheduling robbins-monro --stepsize 1.0e-15 --numepoch 1 --rowmeanlist $(joinpath(dense_path, "Feature_FTTMeans.csv")) --logdir $(dense_path)`)

testfilesize(true,
	joinpath(dense_path, "Eigen_vectors.csv"),
	joinpath(dense_path, "Eigen_values.csv"),
	joinpath(dense_path, "Loadings.csv"),
	joinpath(dense_path, "Scores.csv"))

run(`$(julia) $(joinpath(bindir, "svrg")) --input $(joinpath(tmp, "Data.zst"))  --outdir $(dense_path) --dim 3 --scheduling momentum --stepsize 1.0e-15 --numepoch 1 --rowmeanlist $(joinpath(dense_path, "Feature_FTTMeans.csv")) --logdir $(dense_path)`)

testfilesize(true,
	joinpath(dense_path, "Eigen_vectors.csv"),
	joinpath(dense_path, "Eigen_values.csv"),
	joinpath(dense_path, "Loadings.csv"),
	joinpath(dense_path, "Scores.csv"))

run(`$(julia) $(joinpath(bindir, "svrg")) --input $(joinpath(tmp, "Data.zst"))  --outdir $(dense_path) --dim 3 --scheduling nag --stepsize 1.0e-15 --numepoch 1 --rowmeanlist $(joinpath(dense_path, "Feature_FTTMeans.csv")) --logdir $(dense_path)`)

testfilesize(true,
	joinpath(dense_path, "Eigen_vectors.csv"),
	joinpath(dense_path, "Eigen_values.csv"),
	joinpath(dense_path, "Loadings.csv"),
	joinpath(dense_path, "Scores.csv"))

run(`$(julia) $(joinpath(bindir, "svrg")) --input $(joinpath(tmp, "Data.zst"))  --outdir $(dense_path) --dim 3 --scheduling adagrad --stepsize 1.0e-15 --numepoch 1 --rowmeanlist $(joinpath(dense_path, "Feature_FTTMeans.csv")) --logdir $(dense_path)`)

testfilesize(true,
	joinpath(dense_path, "Eigen_vectors.csv"),
	joinpath(dense_path, "Eigen_values.csv"),
	joinpath(dense_path, "Loadings.csv"),
	joinpath(dense_path, "Scores.csv"))
#####################################

