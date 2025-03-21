#####################################
println("####### SINGLEPASS (Julia API) #######")
out_singlepass = singlepass(input=joinpath(tmp, "Data.zst"),
	dim=3,
	rowmeanlist=joinpath(dense_path, "Feature_FTTMeans.csv"),
	logdir=dense_path)

@test size(out_singlepass[1]) == (99, 3)
@test size(out_singlepass[2]) == (3, )
@test size(out_singlepass[3]) == (300, 3)
@test size(out_singlepass[4]) == (99, 3)
@test size(out_singlepass[5]) == ()
####################################

#####################################
println("####### SINGLEPASS (Command line) #######")
run(`$(julia) $(joinpath(bindir, "singlepass")) --input $(joinpath(tmp, "Data.zst")) --outdir $(dense_path) --dim 3 --rowmeanlist $(joinpath(dense_path, "Feature_FTTMeans.csv")) --logdir $(dense_path)`)

testfilesize(true,
	joinpath(dense_path, "Eigen_vectors.csv"),
	joinpath(dense_path, "Eigen_values.csv"),
	joinpath(dense_path, "Loadings.csv"),
	joinpath(dense_path, "Scores.csv"))
#####################################