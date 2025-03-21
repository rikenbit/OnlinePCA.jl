#####################################
println("####### CCIPCA (Julia API) #######")
out_ccipca1 = ccipca(input=joinpath(tmp, "Data.zst"),
	dim=3, stepsize=1.0e-15, numepoch=1,
	rowmeanlist=joinpath(dense_path, "Feature_FTTMeans.csv"),
	logdir=dense_path)

@test size(out_ccipca1[1]) == (99, 3)
@test size(out_ccipca1[2]) == (3, )
@test size(out_ccipca1[3]) == (300, 3)
@test size(out_ccipca1[4]) == (99, 3)
@test size(out_ccipca1[5]) == ()
@test size(out_ccipca1[6]) == ()
#####################################

#####################################
println("####### CCIPCA (Command line) #######")
run(`$(julia) $(joinpath(bindir, "ccipca")) --input $(joinpath(tmp, "Data.zst")) --outdir $(dense_path) --dim 3 --stepsize 1.0e-15 --numepoch 1 --rowmeanlist $(joinpath(dense_path, "Feature_FTTMeans.csv")) --logdir $(dense_path)`)

testfilesize(true,
	joinpath(dense_path, "Eigen_vectors.csv"),
	joinpath(dense_path, "Eigen_values.csv"),
	joinpath(dense_path, "Loadings.csv"),
	joinpath(dense_path, "Scores.csv"))
#####################################
