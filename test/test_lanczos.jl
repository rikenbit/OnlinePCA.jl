#####################################
println("####### LANCZOS (Julia API) #######")
out_lanczos1 = lanczos(input=joinpath(tmp, "Data.zst"),
	dim=3,
	rowmeanlist=joinpath(dense_path, "Feature_FTTMeans.csv"))

@test size(out_lanczos1[1]) == (99, 3)
@test size(out_lanczos1[2]) == (3, )
@test size(out_lanczos1[3]) == (300, 3)
@test size(out_lanczos1[4]) == (99, 3)
@test size(out_lanczos1[5]) == ()
@test size(out_lanczos1[6]) == ()
#####################################

#####################################
println("####### LANCZOS (Command line) #######")
run(`$(julia) $(joinpath(bindir, "lanczos")) --input $(joinpath(tmp, "Data.zst")) --outdir $(dense_path) --dim 3 --numepoch 3 --rowmeanlist $(joinpath(dense_path, "Feature_FTTMeans.csv"))`)

testfilesize(true,
	joinpath(dense_path, "Eigen_vectors.csv"),
	joinpath(dense_path, "Eigen_values.csv"),
	joinpath(dense_path, "Loadings.csv"),
	joinpath(dense_path, "Scores.csv"))
#####################################