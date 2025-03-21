#####################################
println("####### Summarization (Julia API) #######")
sumr(binfile=joinpath(tmp, "Data.zst"), outdir=dense_path)

testfilesize(true,
	joinpath(dense_path, "Sample_NoCounts.csv"),
	joinpath(dense_path, "Feature_Means.csv"),
	joinpath(dense_path, "Feature_LogMeans.csv"),
	joinpath(dense_path, "Feature_FTTMeans.csv"),
	joinpath(dense_path, "Feature_CPMMeans.csv"),
	joinpath(dense_path, "Feature_LogCPMMeans.csv"),
	joinpath(dense_path, "Feature_FTTCPMMeans.csv"),
	joinpath(dense_path, "Feature_CPTMeans.csv"),
	joinpath(dense_path, "Feature_LogCPTMeans.csv"),
	joinpath(dense_path, "Feature_FTTCPTMeans.csv"),
	joinpath(dense_path, "Feature_CPMEDMeans.csv"),
	joinpath(dense_path, "Feature_LogCPMEDMeans.csv"),
	joinpath(dense_path, "Feature_FTTCPMEDMeans.csv"),
	joinpath(dense_path, "Feature_Vars.csv"),
	joinpath(dense_path, "Feature_LogVars.csv"),
	joinpath(dense_path, "Feature_FTTVars.csv"),
	joinpath(dense_path, "Feature_CPMVars.csv"),
	joinpath(dense_path, "Feature_LogCPMVars.csv"),
	joinpath(dense_path, "Feature_FTTCPMVars.csv"),
	joinpath(dense_path, "Feature_CPTVars.csv"),
	joinpath(dense_path, "Feature_LogCPTVars.csv"),
	joinpath(dense_path, "Feature_FTTCPTVars.csv"),
	joinpath(dense_path, "Feature_CPMEDVars.csv"),
	joinpath(dense_path, "Feature_LogCPMEDVars.csv"),
	joinpath(dense_path, "Feature_FTTCPMEDVars.csv"),
	joinpath(dense_path, "Feature_CV2s.csv"),
	joinpath(dense_path, "Feature_NoZeros.csv"))
#####################################

#####################################
println("####### Summarization (Command line) #######")
run(`$(julia) $(joinpath(bindir, "sumr")) --binfile $(joinpath(tmp, "Data.zst")) --outdir $(dense_path)`)

testfilesize(false,
	joinpath(dense_path, "Sample_NoCounts.csv"),
	joinpath(dense_path, "Feature_Means.csv"),
	joinpath(dense_path, "Feature_LogMeans.csv"),
	joinpath(dense_path, "Feature_FTTMeans.csv"),
	joinpath(dense_path, "Feature_CPMMeans.csv"),
	joinpath(dense_path, "Feature_LogCPMMeans.csv"),
	joinpath(dense_path, "Feature_FTTCPMMeans.csv"),
	joinpath(dense_path, "Feature_CPTMeans.csv"),
	joinpath(dense_path, "Feature_LogCPTMeans.csv"),
	joinpath(dense_path, "Feature_FTTCPTMeans.csv"),
	joinpath(dense_path, "Feature_CPMEDMeans.csv"),
	joinpath(dense_path, "Feature_LogCPMEDMeans.csv"),
	joinpath(dense_path, "Feature_FTTCPMEDMeans.csv"),
	joinpath(dense_path, "Feature_Vars.csv"),
	joinpath(dense_path, "Feature_LogVars.csv"),
	joinpath(dense_path, "Feature_FTTVars.csv"),
	joinpath(dense_path, "Feature_CPMVars.csv"),
	joinpath(dense_path, "Feature_LogCPMVars.csv"),
	joinpath(dense_path, "Feature_FTTCPMVars.csv"),
	joinpath(dense_path, "Feature_CPTVars.csv"),
	joinpath(dense_path, "Feature_LogCPTVars.csv"),
	joinpath(dense_path, "Feature_FTTCPTVars.csv"),
	joinpath(dense_path, "Feature_CPMEDVars.csv"),
	joinpath(dense_path, "Feature_LogCPMEDVars.csv"),
	joinpath(dense_path, "Feature_FTTCPMEDVars.csv"),
	joinpath(dense_path, "Feature_CV2s.csv"),
	joinpath(dense_path, "Feature_NoZeros.csv"))
#####################################
