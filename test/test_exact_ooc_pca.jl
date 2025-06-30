#####################################
println("####### Exact Out-of-Core PCA (Dense, Julia API) #######")
out_exact_ooc_pca_dense = exact_ooc_pca(input=joinpath(tmp, "Data.zst"),
	dim=3, scale="raw", chunksize=51)

@test size(out_exact_ooc_pca_dense[1]) == (99, 3)
@test size(out_exact_ooc_pca_dense[2]) == (3, )
@test size(out_exact_ooc_pca_dense[3]) == (300, 3)
@test size(out_exact_ooc_pca_dense[4]) == (300, 3)
@test size(out_exact_ooc_pca_dense[5]) == ()
@test size(out_exact_ooc_pca_dense[6]) == ()
#####################################

#####################################
println("####### Exact Out-of-Core PCA (Dense, Command line) #######")
run(`$(julia) $(joinpath(bindir, "exact_ooc_pca")) --input $(joinpath(tmp, "Data.zst")) --outdir $(dense_path) --dim 3 --scale "raw" --chunksize 51`)

testfilesize(true,
	joinpath(dense_path, "Eigen_vectors.csv"),
	joinpath(dense_path, "Eigen_values.csv"),
	joinpath(dense_path, "Loadings.csv"),
	joinpath(dense_path, "Scores.csv"))
#####################################

#####################################
println("####### Exact Out-of-Core PCA (MM-Sparse, Julia API) #######")
out_exact_ooc_pca_sparse_mm = exact_ooc_pca(input=joinpath(tmp, "Data.mtx.zst"),
	dim=3, scale="raw", chunksize=51, mode="sparse_mm")

@test size(out_exact_ooc_pca_sparse_mm[1]) == (99, 3)
@test size(out_exact_ooc_pca_sparse_mm[2]) == (3, )
@test size(out_exact_ooc_pca_sparse_mm[3]) == (300, 3)
@test size(out_exact_ooc_pca_sparse_mm[4]) == (300, 3)
@test size(out_exact_ooc_pca_sparse_mm[5]) == ()
@test size(out_exact_ooc_pca_sparse_mm[6]) == ()
#####################################

#####################################
println("####### Exact Out-of-Core PCA (MM-Sparse, Command line) #######")
run(`$(julia) $(joinpath(bindir, "exact_ooc_pca")) --input $(joinpath(tmp, "Data.mtx.zst")) --outdir $(sparse_path) --dim 3 --scale "raw" --chunksize 51 --mode "sparse_mm"`)

testfilesize(true,
	joinpath(sparse_path, "Eigen_vectors.csv"),
	joinpath(sparse_path, "Eigen_values.csv"),
	joinpath(sparse_path, "Loadings.csv"),
	joinpath(sparse_path, "Scores.csv"))
#####################################

#####################################
println("####### Exact Out-of-Core PCA (BinCOO-Sparse, Julia API) #######")
out_exact_ooc_pca_sparse_bincoo = exact_ooc_pca(input=joinpath(tmp, "Data.bincoo.zst"),
	dim=3, scale="raw", chunksize=51, mode="sparse_bincoo")

@test size(out_exact_ooc_pca_sparse_bincoo[1]) == (99, 3)
@test size(out_exact_ooc_pca_sparse_bincoo[2]) == (3, )
@test size(out_exact_ooc_pca_sparse_bincoo[3]) == (300, 3)
@test size(out_exact_ooc_pca_sparse_bincoo[4]) == (300, 3)
@test size(out_exact_ooc_pca_sparse_bincoo[5]) == ()
@test size(out_exact_ooc_pca_sparse_bincoo[6]) == ()
#####################################

#####################################
println("####### Exact Out-of-Core PCA (BinCOO-Sparse, Command line) #######")
run(`$(julia) $(joinpath(bindir, "exact_ooc_pca")) --input $(joinpath(tmp, "Data.bincoo.zst")) --outdir $(sparse_path) --dim 3 --scale "raw" --chunksize 51 --mode "sparse_bincoo"`)

testfilesize(true,
	joinpath(sparse_path, "Eigen_vectors.csv"),
	joinpath(sparse_path, "Eigen_values.csv"),
	joinpath(sparse_path, "Loadings.csv"),
	joinpath(sparse_path, "Scores.csv"))
#####################################

# centered_data = log10.(centered_data .+ 1)
cov_mat = centered_data' * centered_data
out_svd = svd(cov_mat)
V = out_svd.Vt[1:3, :]

inner_prod1 = maximum(abs.(diag(V * out_exact_ooc_pca_dense[1])))
inner_prod2 = maximum(abs.(diag(V * out_exact_ooc_pca_sparse_mm[1])))
inner_prod3 = maximum(abs.(diag(V * out_exact_ooc_pca_sparse_bincoo[1])))
println("Inner product (Dense): ", inner_prod1)
println("Inner product (Sparse MM): ", inner_prod2)
println("Inner product (Sparse BinCOO): ", inner_prod3)
@test inner_prod1 > 0.7
@test inner_prod2 > 0.7
@test inner_prod3 > 0.7
