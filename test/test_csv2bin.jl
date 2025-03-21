#####################################
println("####### Binarization of CSV (Julia API) #######")
csv2bin(csvfile=joinpath(tmp, "Data.csv"),
	binfile=joinpath(tmp, "Data.zst"))

testfilesize(true, joinpath(tmp, "Data.zst"))
###################################

#####################################
println("####### Binarization of CSV (Command line) #######")
run(`$(julia) $(joinpath(bindir, "csv2bin")) --csvfile $(joinpath(tmp, "Data.csv")) --binfile $(joinpath(tmp, "Data.zst"))`)

testfilesize(false, joinpath(tmp, "Data.zst"))
#####################################
