#####################################
println("####### HVG (Julia API) #######")
hvg(binfile=joinpath(tmp, "Data.zst"),
	rowmeanlist=joinpath(dense_path, "Feature_Means.csv"),
	rowvarlist=joinpath(dense_path, "Feature_Vars.csv"),
	rowcv2list=joinpath(dense_path, "Feature_CV2s.csv"), outdir=dense_path)

testfilesize(true,
	joinpath(dense_path, "HVG_pval.csv"),
	joinpath(dense_path, "HVG_a0.csv"),
	joinpath(dense_path, "HVG_a1.csv"),
	joinpath(dense_path, "HVG_afit.csv"),
	joinpath(dense_path, "HVG_useForFit.csv"),
	joinpath(dense_path, "HVG_varFitRatio.csv"),
	joinpath(dense_path, "HVG_df.csv"))
#####################################

#####################################
println("####### HVG (Command line) #######")
run(`$(julia) $(joinpath(bindir, "hvg")) --binfile $(joinpath(tmp, "Data.zst")) --rowmeanlist $(joinpath(dense_path, "Feature_Means.csv")) --rowvarlist $(joinpath(dense_path, "Feature_Vars.csv")) --rowcv2list $(joinpath(dense_path, "Feature_CV2s.csv")) --outdir $(dense_path)`)

testfilesize(false,
	joinpath(dense_path, "HVG_pval.csv"),
	joinpath(dense_path, "HVG_a0.csv"),
	joinpath(dense_path, "HVG_a1.csv"),
	joinpath(dense_path, "HVG_afit.csv"),
	joinpath(dense_path, "HVG_useForFit.csv"),
	joinpath(dense_path, "HVG_varFitRatio.csv"),
	joinpath(dense_path, "HVG_df.csv"))
#####################################
