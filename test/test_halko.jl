#####################################
println("####### HALKO (Julia API) #######")
out_halko = halko(input=joinpath(tmp, "Data.zst"),
	dim=3,
	rowmeanlist=joinpath(dense_path, "Feature_FTTMeans.csv"),
	logdir=dense_path)

@test size(out_halko[1]) == (99, 3)
@test size(out_halko[2]) == (3, )
@test size(out_halko[3]) == (300, 3)
@test size(out_halko[4]) == (99, 3)
@test size(out_halko[5]) == ()
####################################

#####################################
println("####### HALKO (Command line) #######")
run(`$(julia) $(joinpath(bindir, "halko")) --input $(joinpath(tmp, "Data.zst")) --outdir $(dense_path) --dim 3 --rowmeanlist $(joinpath(dense_path, "Feature_FTTMeans.csv")) --logdir $(dense_path)`)

testfilesize(true,
	joinpath(dense_path, "Eigen_vectors.csv"),
	joinpath(dense_path, "Eigen_values.csv"),
	joinpath(dense_path, "Loadings.csv"),
	joinpath(dense_path, "Scores.csv"))
#####################################