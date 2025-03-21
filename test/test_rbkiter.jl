#####################################
println("####### Randomized Block Krylov Iteration (Julia API) #######")
out_rbkiter1 = rbkiter(input=joinpath(tmp, "Data.zst"),
	dim=3, numepoch=3,
	rowmeanlist=joinpath(dense_path, "Feature_FTTMeans.csv"),
	logdir=dense_path)

@test size(out_rbkiter1[1]) == (99, 3)
@test size(out_rbkiter1[2]) == (3, )
@test size(out_rbkiter1[3]) == (300, 3)
@test size(out_rbkiter1[4]) == (99, 3)
@test size(out_rbkiter1[5]) == ()
@test size(out_rbkiter1[6]) == ()
#####################################

#####################################
println("####### Randomized Block Krylov Iteration (Command line) #######")
run(`$(julia) $(joinpath(bindir, "rbkiter")) --input $(joinpath(tmp, "Data.zst")) --outdir $(dense_path) --dim 3 --numepoch 3 --rowmeanlist $(joinpath(dense_path, "Feature_FTTMeans.csv")) --logdir $(dense_path)`)

testfilesize(true,
	joinpath(dense_path, "Eigen_vectors.csv"),
	joinpath(dense_path, "Eigen_values.csv"),
	joinpath(dense_path, "Loadings.csv"),
	joinpath(dense_path, "Scores.csv"))
#####################################