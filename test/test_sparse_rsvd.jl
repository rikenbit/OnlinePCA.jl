#####################################
println("####### Sparse Randomized SVD (Julia API) #######")
out_sparse_rsvd = sparse_rsvd(input=joinpath(tmp, "Data.mtx.zst"),
	dim=3,
	rowmeanlist=joinpath(sparse_path, "Feature_FTTMeans.csv"),
	logdir=sparse_path, chunksize=100)

@test size(out_sparse_rsvd[1]) == (99, 3)
@test size(out_sparse_rsvd[2]) == (3, )
@test size(out_sparse_rsvd[3]) == (300, 3)
@test size(out_sparse_rsvd[4]) == (99, 3)
@test size(out_sparse_rsvd[5]) == ()
#####################################

#####################################
println("####### Sparse Randomized SVD (Command line) #######")
run(`$(julia) $(joinpath(bindir, "sparse_rsvd")) --input $(joinpath(tmp, "Data.mtx.zst")) --outdir $(sparse_path) --dim 3 --rowmeanlist $(joinpath(sparse_path, "Feature_FTTMeans.csv")) --logdir $(sparse_path) --chunksize 100`)

testfilesize(true,
	joinpath(sparse_path, "Eigen_vectors.csv"),
	joinpath(sparse_path, "Eigen_values.csv"),
	joinpath(sparse_path, "Loadings.csv"),
	joinpath(sparse_path, "Scores.csv"))
#####################################