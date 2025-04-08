#####################################
println("####### Summarization (Julia API) #######")
sumr(binfile=joinpath(tmp, "Data.mtx.zst"), outdir=sparse_path, mode="sparse_mm")

testfilesize(true,
	joinpath(sparse_path, "Sample_NoCounts.csv"),
	joinpath(sparse_path, "Feature_Means.csv"),
	joinpath(sparse_path, "Feature_LogMeans.csv"),
	joinpath(sparse_path, "Feature_FTTMeans.csv"),
	joinpath(sparse_path, "Feature_CPMMeans.csv"),
	joinpath(sparse_path, "Feature_LogCPMMeans.csv"),
	joinpath(sparse_path, "Feature_FTTCPMMeans.csv"),
	joinpath(sparse_path, "Feature_CPTMeans.csv"),
	joinpath(sparse_path, "Feature_LogCPTMeans.csv"),
	joinpath(sparse_path, "Feature_FTTCPTMeans.csv"),
	joinpath(sparse_path, "Feature_CPMEDMeans.csv"),
	joinpath(sparse_path, "Feature_LogCPMEDMeans.csv"),
	joinpath(sparse_path, "Feature_FTTCPMEDMeans.csv"),
	joinpath(sparse_path, "Feature_Vars.csv"),
	joinpath(sparse_path, "Feature_LogVars.csv"),
	joinpath(sparse_path, "Feature_FTTVars.csv"),
	joinpath(sparse_path, "Feature_CPMVars.csv"),
	joinpath(sparse_path, "Feature_LogCPMVars.csv"),
	joinpath(sparse_path, "Feature_FTTCPMVars.csv"),
	joinpath(sparse_path, "Feature_CPTVars.csv"),
	joinpath(sparse_path, "Feature_LogCPTVars.csv"),
	joinpath(sparse_path, "Feature_FTTCPTVars.csv"),
	joinpath(sparse_path, "Feature_CPMEDVars.csv"),
	joinpath(sparse_path, "Feature_LogCPMEDVars.csv"),
	joinpath(sparse_path, "Feature_FTTCPMEDVars.csv"),
	joinpath(sparse_path, "Feature_CV2s.csv"),
	joinpath(sparse_path, "Feature_NoZeros.csv"))
#####################################

#####################################
println("####### Summarization (Command line) #######")
run(`$(julia) $(joinpath(bindir, "sumr")) --binfile $(joinpath(tmp, "Data.mtx.zst")) --outdir $(sparse_path) --mode "sparse_mm"`)

testfilesize(false,
	joinpath(sparse_path, "Sample_NoCounts.csv"),
	joinpath(sparse_path, "Feature_Means.csv"),
	joinpath(sparse_path, "Feature_LogMeans.csv"),
	joinpath(sparse_path, "Feature_FTTMeans.csv"),
	joinpath(sparse_path, "Feature_CPMMeans.csv"),
	joinpath(sparse_path, "Feature_LogCPMMeans.csv"),
	joinpath(sparse_path, "Feature_FTTCPMMeans.csv"),
	joinpath(sparse_path, "Feature_CPTMeans.csv"),
	joinpath(sparse_path, "Feature_LogCPTMeans.csv"),
	joinpath(sparse_path, "Feature_FTTCPTMeans.csv"),
	joinpath(sparse_path, "Feature_CPMEDMeans.csv"),
	joinpath(sparse_path, "Feature_LogCPMEDMeans.csv"),
	joinpath(sparse_path, "Feature_FTTCPMEDMeans.csv"),
	joinpath(sparse_path, "Feature_Vars.csv"),
	joinpath(sparse_path, "Feature_LogVars.csv"),
	joinpath(sparse_path, "Feature_FTTVars.csv"),
	joinpath(sparse_path, "Feature_CPMVars.csv"),
	joinpath(sparse_path, "Feature_LogCPMVars.csv"),
	joinpath(sparse_path, "Feature_FTTCPMVars.csv"),
	joinpath(sparse_path, "Feature_CPTVars.csv"),
	joinpath(sparse_path, "Feature_LogCPTVars.csv"),
	joinpath(sparse_path, "Feature_FTTCPTVars.csv"),
	joinpath(sparse_path, "Feature_CPMEDVars.csv"),
	joinpath(sparse_path, "Feature_LogCPMEDVars.csv"),
	joinpath(sparse_path, "Feature_FTTCPMEDVars.csv"),
	joinpath(sparse_path, "Feature_CV2s.csv"),
	joinpath(sparse_path, "Feature_NoZeros.csv"))
#####################################
