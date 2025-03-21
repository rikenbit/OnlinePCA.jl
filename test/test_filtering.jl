#####################################
println("####### Filtering (Julia API) #######")
filtering(input=joinpath(tmp, "Data.zst"),
	featurelist=joinpath(dense_path, "Feature_Means.csv"),
	samplelist=joinpath(dense_path, "Sample_NoCounts.csv"),
	thr1=10, thr2=10,
	direct1="+", direct2="+",
	outdir=dense_path)

filtering(input=joinpath(tmp, "Data.zst"),
	featurelist=joinpath(dense_path, "Feature_Means.csv"),
	thr1=10, thr2=10,
	direct1="+", direct2="+",
	outdir=dense_path)

filtering(input=joinpath(tmp, "Data.zst"),
	samplelist=joinpath(dense_path, "Sample_NoCounts.csv"),
	thr1=10, thr2=10,
	direct1="+", direct2="+",
	outdir=dense_path)

testfilesize(true,
	joinpath(dense_path, "filtered.zst"))
testfilesize(true,
	joinpath(dense_path, "filteredFeature.csv"))
testfilesize(true,
	joinpath(dense_path, "filteredSample.csv"))
####################################

#####################################
println("####### Filtering (Command line) #######")
run(`$(julia) $(joinpath(bindir, "filtering")) --input $(joinpath(tmp, "Data.zst")) --featurelist $(joinpath(dense_path, "Feature_Means.csv")) --samplelist $(joinpath(dense_path, "Sample_NoCounts.csv")) --thr1 10 --thr2 10 --outdir $(dense_path)`)

run(`$(julia) $(joinpath(bindir, "filtering")) --input $(joinpath(tmp, "Data.zst")) --featurelist $(joinpath(dense_path, "Feature_Means.csv")) --thr1 10 --thr2 10 --outdir $(dense_path)`)

run(`$(julia) $(joinpath(bindir, "filtering")) --input $(joinpath(tmp, "Data.zst")) --samplelist $(joinpath(dense_path, "Sample_NoCounts.csv")) --thr1 10 --thr2 10 --outdir $(dense_path)`)

testfilesize(false,
	joinpath(dense_path, "filtered.zst"))
testfilesize(false,
	joinpath(dense_path, "filteredFeature.csv"))
testfilesize(false,
	joinpath(dense_path, "filteredSample.csv"))
#####################################
