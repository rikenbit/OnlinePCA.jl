#####################################
println("####### SINGLEPASS2 (Julia API) #######")
out_singlepass2 = singlepass2(input=joinpath(tmp, "Data.zst"),
	dim=3,
	rowmeanlist=joinpath(dense_path, "Feature_FTTMeans.csv"),
	logdir=dense_path)

@test size(out_singlepass2[1]) == (99, 3)
@test size(out_singlepass2[2]) == (3, )
@test size(out_singlepass2[3]) == (300, 3)
@test size(out_singlepass2[4]) == (99, 3)
@test size(out_singlepass2[5]) == ()
####################################

#####################################
println("####### SINGLEPASS2 (Command line) #######")
run(`$(julia) $(joinpath(bindir, "singlepass2")) --input $(joinpath(tmp, "Data.zst")) --outdir $(dense_path) --dim 3 --rowmeanlist $(joinpath(dense_path, "Feature_FTTMeans.csv")) --logdir $(dense_path)`)

testfilesize(true,
	joinpath(dense_path, "Eigen_vectors.csv"),
	joinpath(dense_path, "Eigen_values.csv"),
	joinpath(dense_path, "Loadings.csv"),
	joinpath(dense_path, "Scores.csv"))
#####################################
