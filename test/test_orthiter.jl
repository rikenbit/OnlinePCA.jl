#####################################
println("####### Orthogonal Iteration (Julia API) #######")
out_orthiter1 = orthiter(input=joinpath(tmp, "Data.zst"),
	dim=3, numepoch=3,
	rowmeanlist=joinpath(dense_path, "Feature_FTTMeans.csv"),
	logdir=dense_path)

@test size(out_orthiter1[1]) == (99, 3)
@test size(out_orthiter1[2]) == (3, )
@test size(out_orthiter1[3]) == (300, 3)
@test size(out_orthiter1[4]) == (99, 3)
@test size(out_orthiter1[5]) == ()
@test size(out_orthiter1[6]) == ()
#####################################


#####################################
println("####### Orthogonal Iteration (Command line) #######")
run(`$(julia) $(joinpath(bindir, "orthiter")) --input $(joinpath(tmp, "Data.zst")) --outdir $(dense_path) --dim 3 --numepoch 3 --rowmeanlist $(joinpath(dense_path, "Feature_FTTMeans.csv")) --logdir $(dense_path)`)

testfilesize(true,
	joinpath(dense_path, "Eigen_vectors.csv"),
	joinpath(dense_path, "Eigen_values.csv"),
	joinpath(dense_path, "Loadings.csv"),
	joinpath(dense_path, "Scores.csv"))
#####################################
