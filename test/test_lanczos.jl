#####################################
println("####### LANCZOS (Julia API) #######")
out_lanczos1 = lanczos(input=joinpath(tmp, "Data.zst"),
	dim=3,
	rowmeanlist=joinpath(dense_path, "Feature_FTTMeans.csv"))

# Size tests
@test size(out_lanczos1[1]) == (99, 3)
@test size(out_lanczos1[2]) == (3, )
@test size(out_lanczos1[3]) == (300, 3)
@test size(out_lanczos1[4]) == (99, 3)
@test size(out_lanczos1[5]) == ()
@test size(out_lanczos1[6]) == ()

# Accuracy tests:
# eigenvalues should be non-negative and sorted in descending order
## Non-negative eigenvalues
@test all(out_lanczos1[2] .>= 0)

## Descending order (PC1 > PC2 > PC3)
@test issorted(out_lanczos1[2], rev=true)

## Loadings should have unit norm (columns are orthonormal)
for j in 1:3
    @test isapprox(norm(out_lanczos1[3][:, j]), 1.0, atol=0.1)
end

## Total variance explained should be positive
@test sum(out_lanczos1[2]) > 0
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