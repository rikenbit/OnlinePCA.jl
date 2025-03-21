#####################################
println("####### RSGD (Julia API) #######")
out_rsgd1 = rsgd(input=joinpath(tmp, "Data.zst"),
	dim=3, scheduling="robbins-monro",
	stepsize=1.0e-15, numepoch=1,
	rowmeanlist=joinpath(dense_path, "Feature_FTTMeans.csv"),
	logdir=dense_path)

out_rsgd2 = rsgd(input=joinpath(tmp, "Data.zst"),
	dim=3, scheduling="momentum",
	stepsize=1.0e-15, numepoch=1,
	rowmeanlist=joinpath(dense_path, "Feature_FTTMeans.csv"),
	logdir=dense_path)

out_rsgd3 = rsgd(input=joinpath(tmp, "Data.zst"),
	dim=3, scheduling="nag",
	stepsize=1.0e-15, numepoch=1,
	rowmeanlist=joinpath(dense_path, "Feature_FTTMeans.csv"),
	logdir=dense_path)

out_rsgd4 = rsgd(input=joinpath(tmp, "Data.zst"),
	dim=3, scheduling="adagrad",
	stepsize=1.0e-15, numepoch=1,
	rowmeanlist=joinpath(dense_path, "Feature_FTTMeans.csv"),
	logdir=dense_path)

@test size(out_rsgd1[1]) == (99, 3)
@test size(out_rsgd1[2]) == (3, )
@test size(out_rsgd1[3]) == (300, 3)
@test size(out_rsgd1[4]) == (99, 3)
@test size(out_rsgd1[5]) == ()
@test size(out_rsgd1[6]) == ()

@test size(out_rsgd2[1]) == (99, 3)
@test size(out_rsgd2[2]) == (3, )
@test size(out_rsgd2[3]) == (300, 3)
@test size(out_rsgd2[4]) == (99, 3)
@test size(out_rsgd2[5]) == ()
@test size(out_rsgd2[6]) == ()

@test size(out_rsgd3[1]) == (99, 3)
@test size(out_rsgd3[2]) == (3, )
@test size(out_rsgd3[3]) == (300, 3)
@test size(out_rsgd3[4]) == (99, 3)
@test size(out_rsgd3[5]) == ()
@test size(out_rsgd3[6]) == ()

@test size(out_rsgd4[1]) == (99, 3)
@test size(out_rsgd4[2]) == (3, )
@test size(out_rsgd4[3]) == (300, 3)
@test size(out_rsgd4[4]) == (99, 3)
@test size(out_rsgd4[5]) == ()
@test size(out_rsgd4[6]) == ()
#####################################


#####################################
println("####### RSGD (Command line) #######")
run(`$(julia) $(joinpath(bindir, "rsgd")) --input $(joinpath(tmp, "Data.zst")) --outdir $(dense_path) --dim 3 --scheduling robbins-monro --stepsize 1.0e-15 --numepoch 1 --rowmeanlist $(joinpath(dense_path, "Feature_FTTMeans.csv")) --logdir $(dense_path)`)

testfilesize(true,
	joinpath(dense_path, "Eigen_vectors.csv"),
	joinpath(dense_path, "Eigen_values.csv"),
	joinpath(dense_path, "Loadings.csv"),
	joinpath(dense_path, "Scores.csv"))

run(`$(julia) $(joinpath(bindir, "rsgd")) --input $(joinpath(tmp, "Data.zst"))  --outdir $(dense_path) --dim 3 --scheduling momentum --stepsize 1.0e-15 --numepoch 1 --rowmeanlist $(joinpath(dense_path, "Feature_FTTMeans.csv")) --logdir $(dense_path)`)

testfilesize(true,
	joinpath(dense_path, "Eigen_vectors.csv"),
	joinpath(dense_path, "Eigen_values.csv"),
	joinpath(dense_path, "Loadings.csv"),
	joinpath(dense_path, "Scores.csv"))

run(`$(julia) $(joinpath(bindir, "rsgd")) --input $(joinpath(tmp, "Data.zst"))  --outdir $(dense_path) --dim 3 --scheduling nag --stepsize 1.0e-15 --numepoch 1 --rowmeanlist $(joinpath(dense_path, "Feature_FTTMeans.csv")) --logdir $(dense_path)`)

testfilesize(true,
	joinpath(dense_path, "Eigen_vectors.csv"),
	joinpath(dense_path, "Eigen_values.csv"),
	joinpath(dense_path, "Loadings.csv"),
	joinpath(dense_path, "Scores.csv"))

run(`$(julia) $(joinpath(bindir, "rsgd")) --input $(joinpath(tmp, "Data.zst"))  --outdir $(dense_path) --dim 3 --scheduling adagrad --stepsize 1.0e-15 --numepoch 1 --rowmeanlist $(joinpath(dense_path, "Feature_FTTMeans.csv")) --logdir $(dense_path)`)

testfilesize(true,
	joinpath(dense_path, "Eigen_vectors.csv"),
	joinpath(dense_path, "Eigen_values.csv"),
	joinpath(dense_path, "Loadings.csv"),
	joinpath(dense_path, "Scores.csv"))
#####################################
