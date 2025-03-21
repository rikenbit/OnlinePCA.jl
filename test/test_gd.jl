#####################################
println("####### GD (Julia API) #######")
out_gd1 = gd(input=joinpath(tmp, "Data.zst"),
	dim=3, scheduling="robbins-monro",
	stepsize=1.0e-15, numepoch=1,
	rowmeanlist=joinpath(dense_path, "Feature_FTTMeans.csv"),
	logdir=dense_path)

out_gd2 = gd(input=joinpath(tmp, "Data.zst"),
	dim=3, scheduling="momentum",
	stepsize=1.0e-15, numepoch=1,
	rowmeanlist=joinpath(dense_path, "Feature_FTTMeans.csv"),
	logdir=dense_path)

out_gd3 = gd(input=joinpath(tmp, "Data.zst"),
	dim=3, scheduling="nag",
	stepsize=1.0e-15, numepoch=1,
	rowmeanlist=joinpath(dense_path, "Feature_FTTMeans.csv"),
	logdir=dense_path)

out_gd4 = gd(input=joinpath(tmp, "Data.zst"),
	dim=3, scheduling="adagrad",
	stepsize=1.0e-15, numepoch=1,
	rowmeanlist=joinpath(dense_path, "Feature_FTTMeans.csv"),
	logdir=dense_path)

@test size(out_gd1[1]) == (99, 3)
@test size(out_gd1[2]) == (3, )
@test size(out_gd1[3]) == (300, 3)
@test size(out_gd1[4]) == (99, 3)
@test size(out_gd1[5]) == ()
@test size(out_gd1[6]) == ()

@test size(out_gd2[1]) == (99, 3)
@test size(out_gd2[2]) == (3, )
@test size(out_gd2[3]) == (300, 3)
@test size(out_gd2[4]) == (99, 3)
@test size(out_gd2[5]) == ()
@test size(out_gd2[6]) == ()

@test size(out_gd3[1]) == (99, 3)
@test size(out_gd3[2]) == (3, )
@test size(out_gd3[3]) == (300, 3)
@test size(out_gd3[4]) == (99, 3)
@test size(out_gd3[5]) == ()
@test size(out_gd3[6]) == ()

@test size(out_gd4[1]) == (99, 3)
@test size(out_gd4[2]) == (3, )
@test size(out_gd4[3]) == (300, 3)
@test size(out_gd4[4]) == (99, 3)
@test size(out_gd4[5]) == ()
@test size(out_gd4[6]) == ()
#####################################

#####################################
println("####### GD (Command line) #######")
run(`$(julia) $(joinpath(bindir, "gd")) --input $(joinpath(tmp, "Data.zst")) --outdir $(dense_path) --dim 3 --scheduling robbins-monro --stepsize 1.0e-15 --numepoch 1 --rowmeanlist $(joinpath(dense_path, "Feature_FTTMeans.csv")) --logdir $(dense_path)`)

testfilesize(false,
	joinpath(dense_path, "Eigen_vectors.csv"),
	joinpath(dense_path, "Eigen_values.csv"),
	joinpath(dense_path, "Loadings.csv"),
	joinpath(dense_path, "Scores.csv"))

run(`$(julia) $(joinpath(bindir, "gd")) --initW $(joinpath(dense_path, "Eigen_vectors.csv")) --input $(joinpath(tmp, "Data.zst"))  --outdir $(dense_path) --dim 3 --scheduling momentum --stepsize 1.0e-15 --numepoch 1 --rowmeanlist $(joinpath(dense_path, "Feature_FTTMeans.csv")) --logdir $(dense_path)`)

testfilesize(false,
	joinpath(dense_path, "Eigen_vectors.csv"),
	joinpath(dense_path, "Eigen_values.csv"),
	joinpath(dense_path, "Loadings.csv"),
	joinpath(dense_path, "Scores.csv"))

run(`$(julia) $(joinpath(bindir, "gd")) --initV $(joinpath(dense_path, "Loadings.csv")) --input $(joinpath(tmp, "Data.zst"))  --outdir $(dense_path) --dim 3 --scheduling nag --stepsize 1.0e-15 --numepoch 1 --rowmeanlist $(joinpath(dense_path, "Feature_FTTMeans.csv")) --logdir $(dense_path)`)

testfilesize(true,
	joinpath(dense_path, "Eigen_vectors.csv"),
	joinpath(dense_path, "Eigen_values.csv"),
	joinpath(dense_path, "Loadings.csv"),
	joinpath(dense_path, "Scores.csv"))

run(`$(julia) $(joinpath(bindir, "gd")) --input $(joinpath(tmp, "Data.zst"))  --outdir $(dense_path) --dim 3 --scheduling adagrad --stepsize 1.0e-15 --numepoch 1 --rowmeanlist $(joinpath(dense_path, "Feature_FTTMeans.csv")) --logdir $(dense_path)`)

testfilesize(true,
	joinpath(dense_path, "Eigen_vectors.csv"),
	joinpath(dense_path, "Eigen_values.csv"),
	joinpath(dense_path, "Loadings.csv"),
	joinpath(dense_path, "Scores.csv"))
#####################################
