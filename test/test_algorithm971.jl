#####################################
println("####### ALGORITHM971 (Julia API) #######")
out_algorithm971 = algorithm971(input=joinpath(tmp, "Data.zst"),
	dim=3,
	rowmeanlist=joinpath(dense_path, "Feature_FTTMeans.csv"),
	logdir=dense_path)

@test size(out_algorithm971[1]) == (99, 3)
@test size(out_algorithm971[2]) == (3, )
@test size(out_algorithm971[3]) == (300, 3)
@test size(out_algorithm971[4]) == (99, 3)
@test size(out_algorithm971[5]) == ()
#####################################

#####################################
println("####### ALGORITHM971 (Command line) #######")
run(`$(julia) $(joinpath(bindir, "algorithm971")) --input $(joinpath(tmp, "Data.zst")) --outdir $(dense_path) --dim 3 --rowmeanlist $(joinpath(dense_path, "Feature_FTTMeans.csv")) --logdir $(dense_path)`)

testfilesize(true,
	joinpath(dense_path, "Eigen_vectors.csv"),
	joinpath(dense_path, "Eigen_values.csv"),
	joinpath(dense_path, "Loadings.csv"),
	joinpath(dense_path, "Scores.csv"))
#####################################