#####################################
println("####### Exact Out-of-Core PCA (Dense, Julia API) #######")
out_exact_ooc_pca_dense = exact_ooc_pca(input=joinpath(tmp, "Data.zst"),
	dim=3, chunksize=51)

@test size(out_exact_ooc_pca_dense[1]) == (99, 3)
@test size(out_exact_ooc_pca_dense[2]) == (3, )
@test size(out_exact_ooc_pca_dense[3]) == (300, 3)
@test size(out_exact_ooc_pca_dense[4]) == (300, 3)
@test size(out_exact_ooc_pca_dense[5]) == ()
@test size(out_exact_ooc_pca_dense[6]) == ()
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

#####################################
println("####### Exact Out-of-Core PCA (MM-Sparse, Julia API) #######")
out_exact_ooc_pca_sparse_mm = exact_ooc_pca(input=joinpath(tmp, "Data.mtx.zst"),
	dim=3, chunksize=51, mode="sparse_mm")

@test size(out_exact_ooc_pca_sparse_mm[1]) == (99, 3)
@test size(out_exact_ooc_pca_sparse_mm[2]) == (3, )
@test size(out_exact_ooc_pca_sparse_mm[3]) == (300, 3)
@test size(out_exact_ooc_pca_sparse_mm[4]) == (300, 3)
@test size(out_exact_ooc_pca_sparse_mm[5]) == ()
@test size(out_exact_ooc_pca_sparse_mm[6]) == ()
#####################################

#####################################
println("####### Exact Out-of-Core PCA (MM-Sparse, Command line) #######")
run(`$(julia) $(joinpath(bindir, "exact_ooc_pca")) --input $(joinpath(tmp, "Data.mtx.zst")) --outdir $(sparse_path) --dim 3 --chunksize 51 --mode "sparse_mm"`)

testfilesize(true,
	joinpath(sparse_path, "Eigen_vectors.csv"),
	joinpath(sparse_path, "Eigen_values.csv"),
	joinpath(sparse_path, "Loadings.csv"),
	joinpath(sparse_path, "Scores.csv"))
#####################################

#####################################
println("####### Exact Out-of-Core PCA (BinCOO-Sparse, Julia API) #######")
out_exact_ooc_pca_sparse_bincoo = exact_ooc_pca(input=joinpath(tmp, "Data.bincoo.zst"),
	dim=3, chunksize=51, mode="sparse_bincoo")

@test size(out_exact_ooc_pca_sparse_bincoo[1]) == (99, 3)
@test size(out_exact_ooc_pca_sparse_bincoo[2]) == (3, )
@test size(out_exact_ooc_pca_sparse_bincoo[3]) == (300, 3)
@test size(out_exact_ooc_pca_sparse_bincoo[4]) == (300, 3)
@test size(out_exact_ooc_pca_sparse_bincoo[5]) == ()
@test size(out_exact_ooc_pca_sparse_bincoo[6]) == ()
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

#####################################
@test all(abs.(abs.(diag(out_exact_ooc_pca_dense[1]' * out_exact_ooc_pca_sparse_mm[1])) .- 1) .< 1e-5)
@test all(abs.(abs.(diag(out_exact_ooc_pca_dense[1]' * out_exact_ooc_pca_sparse_bincoo[1])) .- 1) .< 1e-5)
@test all(abs.(abs.(diag(out_exact_ooc_pca_dense[3]' * out_exact_ooc_pca_sparse_mm[3])) .- 1) .< 1e-5)
@test all(abs.(abs.(diag(out_exact_ooc_pca_dense[3]' * out_exact_ooc_pca_sparse_bincoo[3])) .- 1) .< 1e-5)
######################################
