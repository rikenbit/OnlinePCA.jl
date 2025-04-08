#####################################
println("####### Binarization of Binary COO (Julia API) #######")
bincoo2bin(bincoofile=joinpath(tmp, "Data.bincoo"),
	binfile=joinpath(tmp, "Data.bincoo.zst"))

testfilesize(true, joinpath(tmp, "Data.bincoo.zst"))
###################################

#####################################
println("####### Binarization of Binary COO (Command line) #######")
run(`$(julia) $(joinpath(bindir, "bincoo2bin")) --bincoofile $(joinpath(tmp, "Data.bincoo")) --binfile $(joinpath(tmp, "Data.bincoo.zst"))`)

testfilesize(false, joinpath(tmp, "Data.bincoo.zst"))
#####################################
