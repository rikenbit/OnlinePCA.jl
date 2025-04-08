#####################################
println("####### Exact Out-of-Core PCA (BinCOO-Sparse, Julia API) #######")
out_exact_ooc_pca = exact_ooc_pca(input=joinpath(tmp, "Data.bincoo.zst"),
	dim=3, chunksize=51, mode="sparse_bincoo")

@test size(out_exact_ooc_pca[1]) == (99, 3)
@test size(out_exact_ooc_pca[2]) == (3, )
@test size(out_exact_ooc_pca[3]) == (300, 3)
@test size(out_exact_ooc_pca[4]) == (300, 3)
@test size(out_exact_ooc_pca[5]) == ()
@test size(out_exact_ooc_pca[6]) == ()
#####################################

#####################################
println("####### Exact Out-of-Core PCA (BinCOO-Sparse, Command line) #######")
run(`$(julia) $(joinpath(bindir, "exact_ooc_pca")) --input $(joinpath(tmp, "Data.bincoo.zst")) --outdir $(sparse_path) --dim 3 --chunksize 51 --mode "sparse_bincoo"`)

testfilesize(true,
	joinpath(sparse_path, "Eigen_vectors.csv"),
	joinpath(sparse_path, "Eigen_values.csv"),
	joinpath(sparse_path, "Loadings.csv"),
	joinpath(sparse_path, "Scores.csv"))
#####################################