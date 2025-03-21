#####################################
println("####### SGD (Julia API) #######")
out_sgd1 = sgd(input=joinpath(tmp, "Data.zst"),
	dim=3, scheduling="robbins-monro",
	stepsize=1.0e-15, numepoch=1,
	rowmeanlist=joinpath(dense_path, "Feature_FTTMeans.csv"),
	logdir=dense_path)

out_sgd2 = sgd(input=joinpath(tmp, "Data.zst"),
	dim=3, scheduling="momentum",
	stepsize=1.0e-15, numepoch=1,
	rowmeanlist=joinpath(dense_path, "Feature_FTTMeans.csv"),
	logdir=dense_path)

out_sgd3 = sgd(input=joinpath(tmp, "Data.zst"),
	dim=3, scheduling="nag",
	stepsize=1.0e-15, numepoch=1,
	rowmeanlist=joinpath(dense_path, "Feature_FTTMeans.csv"),
	logdir=dense_path)

out_sgd4 = sgd(input=joinpath(tmp, "Data.zst"),
	dim=3, scheduling="adagrad",
	stepsize=1.0e-15, numepoch=1,
	rowmeanlist=joinpath(dense_path, "Feature_FTTMeans.csv"),
	logdir=dense_path)

@test size(out_sgd1[1]) == (99, 3)
@test size(out_sgd1[2]) == (3, )
@test size(out_sgd1[3]) == (300, 3)
@test size(out_sgd1[4]) == (99, 3)
@test size(out_sgd1[5]) == ()
@test size(out_sgd1[6]) == ()

@test size(out_sgd2[1]) == (99, 3)
@test size(out_sgd2[2]) == (3, )
@test size(out_sgd2[3]) == (300, 3)
@test size(out_sgd2[4]) == (99, 3)
@test size(out_sgd2[5]) == ()
@test size(out_sgd2[6]) == ()

@test size(out_sgd3[1]) == (99, 3)
@test size(out_sgd3[2]) == (3, )
@test size(out_sgd3[3]) == (300, 3)
@test size(out_sgd3[4]) == (99, 3)
@test size(out_sgd3[5]) == ()
@test size(out_sgd3[6]) == ()

@test size(out_sgd4[1]) == (99, 3)
@test size(out_sgd4[2]) == (3, )
@test size(out_sgd4[3]) == (300, 3)
@test size(out_sgd4[4]) == (99, 3)
@test size(out_sgd4[5]) == ()
@test size(out_sgd4[6]) == ()
#####################################

#####################################
println("####### SGD (Command line) #######")
run(`$(julia) $(joinpath(bindir, "sgd")) --input $(joinpath(tmp, "Data.zst")) --outdir $(dense_path) --dim 3 --scheduling robbins-monro --stepsize 1.0e-15 --numepoch 1 --rowmeanlist $(joinpath(dense_path, "Feature_FTTMeans.csv")) --logdir $(dense_path)`)

testfilesize(true,
	joinpath(dense_path, "Eigen_vectors.csv"),
	joinpath(dense_path, "Eigen_values.csv"),
	joinpath(dense_path, "Loadings.csv"),
	joinpath(dense_path, "Scores.csv"))

run(`$(julia) $(joinpath(bindir, "sgd")) --input $(joinpath(tmp, "Data.zst"))  --outdir $(dense_path) --dim 3 --scheduling momentum --stepsize 1.0e-15 --numepoch 1 --rowmeanlist $(joinpath(dense_path, "Feature_FTTMeans.csv")) --logdir $(dense_path)`)

testfilesize(true,
	joinpath(dense_path, "Eigen_vectors.csv"),
	joinpath(dense_path, "Eigen_values.csv"),
	joinpath(dense_path, "Loadings.csv"),
	joinpath(dense_path, "Scores.csv"))

run(`$(julia) $(joinpath(bindir, "sgd")) --input $(joinpath(tmp, "Data.zst"))  --outdir $(dense_path) --dim 3 --scheduling nag --stepsize 1.0e-15 --numepoch 1 --rowmeanlist $(joinpath(dense_path, "Feature_FTTMeans.csv")) --logdir $(dense_path)`)

testfilesize(true,
	joinpath(dense_path, "Eigen_vectors.csv"),
	joinpath(dense_path, "Eigen_values.csv"),
	joinpath(dense_path, "Loadings.csv"),
	joinpath(dense_path, "Scores.csv"))

run(`$(julia) $(joinpath(bindir, "sgd")) --input $(joinpath(tmp, "Data.zst"))  --outdir $(dense_path) --dim 3 --scheduling adagrad --stepsize 1.0e-15 --numepoch 1 --rowmeanlist $(joinpath(dense_path, "Feature_FTTMeans.csv")) --logdir $(dense_path)`)

testfilesize(true,
	joinpath(dense_path, "Eigen_vectors.csv"),
	joinpath(dense_path, "Eigen_values.csv"),
	joinpath(dense_path, "Loadings.csv"),
	joinpath(dense_path, "Scores.csv"))
#####################################
