#####################################
println("####### Exact Out-of-Core PCA (Dense, Julia API) #######")
out_exact_ooc_pca = exact_ooc_pca(input=joinpath(tmp, "Data.zst"),
	dim=3, chunksize=51)

@test size(out_exact_ooc_pca[1]) == (99, 3)
@test size(out_exact_ooc_pca[2]) == (3, )
@test size(out_exact_ooc_pca[3]) == (300, 3)
@test size(out_exact_ooc_pca[4]) == (300, 3)
@test size(out_exact_ooc_pca[5]) == ()
@test size(out_exact_ooc_pca[6]) == ()
#####################################

#####################################
println("####### Exact Out-of-Core PCA (Dense, Command line) #######")
run(`$(julia) $(joinpath(bindir, "exact_ooc_pca")) --input $(joinpath(tmp, "Data.zst")) --outdir $(dense_path) --dim 3 --chunksize 51`)

testfilesize(true,
	joinpath(dense_path, "Eigen_vectors.csv"),
	joinpath(dense_path, "Eigen_values.csv"),
	joinpath(dense_path, "Loadings.csv"),
	joinpath(dense_path, "Scores.csv"))
#####################################