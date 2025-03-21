#####################################
println("####### Binarization of MM (Julia API) #######")
mm2bin(mmfile=joinpath(tmp, "Data.mtx"),
	binfile=joinpath(tmp, "Data.mtx.zst"))

testfilesize(true, joinpath(tmp, "Data.mtx.zst"))
###################################

#####################################
println("####### Binarization of MM (Command line) #######")
run(`$(julia) $(joinpath(bindir, "mm2bin")) --mmfile $(joinpath(tmp, "Data.mtx")) --binfile $(joinpath(tmp, "Data.mtx.zst"))`)

testfilesize(false, joinpath(tmp, "Data.mtx.zst"))
#####################################
