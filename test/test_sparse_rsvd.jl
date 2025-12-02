#####################################
println("####### Sparse Randomized SVD (Julia API) #######")
out_sparse_rsvd = sparse_rsvd(input=joinpath(tmp, "Data.mtx.zst"),
	dim=3,
	rowmeanlist=joinpath(sparse_path, "Feature_FTTMeans.csv"),
	logdir=sparse_path, chunksize=51)

# Size tests
@test size(out_sparse_rsvd[1]) == (99, 3)
@test size(out_sparse_rsvd[2]) == (3, )
@test size(out_sparse_rsvd[3]) == (300, 3)
@test size(out_sparse_rsvd[4]) == (99, 3)
@test size(out_sparse_rsvd[5]) == ()

# Accuracy tests:
# eigenvalues should be non-negative and sorted in descending order
## Non-negative eigenvalues
@test all(out_sparse_rsvd[2] .>= 0)

## Descending order (PC1 > PC2 > PC3)
@test issorted(out_sparse_rsvd[2], rev=true)

## Loadings should have unit norm (columns are orthonormal)
for j in 1:3
    @test isapprox(norm(out_sparse_rsvd[3][:, j]), 1.0, atol=0.1)
end

## Total variance explained should be positive
@test sum(out_sparse_rsvd[2]) > 0
#####################################

#####################################
println("####### Sparse Randomized SVD (Command line) #######")
run(`$(julia) $(joinpath(bindir, "sparse_rsvd")) --input $(joinpath(tmp, "Data.mtx.zst")) --outdir $(sparse_path) --dim 3 --rowmeanlist $(joinpath(sparse_path, "Feature_FTTMeans.csv")) --logdir $(sparse_path) --chunksize 51`)

testfilesize(true,
	joinpath(sparse_path, "Eigen_vectors.csv"),
	joinpath(sparse_path, "Eigen_values.csv"),
	joinpath(sparse_path, "Loadings.csv"),
	joinpath(sparse_path, "Scores.csv"))
#####################################