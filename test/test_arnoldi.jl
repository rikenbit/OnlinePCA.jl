#####################################
println("####### ARNOLDI (Julia API) #######")
out_arnoldi1 = arnoldi(input=joinpath(tmp, "Data.zst"),
	dim=3,
	rowmeanlist=joinpath(dense_path, "Feature_FTTMeans.csv"))

@test size(out_arnoldi1[1]) == (99, 3)
@test size(out_arnoldi1[2]) == (3, )
@test size(out_arnoldi1[3]) == (300, 3)
@test size(out_arnoldi1[4]) == (99, 3)
@test size(out_arnoldi1[5]) == ()
@test size(out_arnoldi1[6]) == ()
#####################################

#####################################
println("####### ARNOLDI (Command line) #######")
run(`$(julia) $(joinpath(bindir, "arnoldi")) --input $(joinpath(tmp, "Data.zst")) --outdir $(dense_path) --dim 3 --numepoch 3 --rowmeanlist $(joinpath(dense_path, "Feature_FTTMeans.csv"))`)

testfilesize(true,
	joinpath(dense_path, "Eigen_vectors.csv"),
	joinpath(dense_path, "Eigen_values.csv"),
	joinpath(dense_path, "Loadings.csv"),
	joinpath(dense_path, "Scores.csv"))
#####################################