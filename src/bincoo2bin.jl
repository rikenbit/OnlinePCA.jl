"""
bincoo2bin(;bincoofile::AbstractString="", binfile::AbstractString="")

Convert a Binary COO (BinCOO) file to Julia Binary file.

Input Arguments
---------
- `bincoofile` : Binary COO file (e.g., Data.bincoo).
- `binfile` : Julia Binary file (e.g., Data.bincoo.zst).
"""
function bincoo2bin(; bincoofile::AbstractString="", binfile::AbstractString="")
    # Read data and find dimensions
    data = Vector{Tuple{UInt32, UInt32}}()
    max_row = UInt32(0)
    max_col = UInt32(0)
    # Step 1: Read the BinCOO file and get max_row and max_col
    open(bincoofile, "r") do infile
        for line in eachline(infile)
            row, col = parse.(UInt32, split(line))
            push!(data, (row, col))
            max_row = max(max_row, row)
            max_col = max(max_col, col)
        end
    end
    # Step 2: Column-wise Sorting
    sorted_data = sort(data, by = x -> (x[1], x[2]))

    # Step 3: Write to compressed binary file
    open(binfile, "w") do outfile
        stream = ZstdCompressorStream(outfile)
        write(stream, max_row)
        write(stream, max_col)
        for (row, col) in sorted_data
            write(stream, row)
            write(stream, col)
        end
        close(stream)
    end
end
