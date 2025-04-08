"""
bincoo2bin(;bincoofile::AbstractString="", binfile::AbstractString="")

Convert a Binary COO (BinCOO) file to Julia Binary file.

Input Arguments
---------
- `bincoofile` : Binary COO file (e.g., Data.bincoo).
- `binfile` : Julia Binary file (e.g., Data.bincoo.zst).
"""
function bincoo2bin(; bincoofile::AbstractString="", binfile::AbstractString="")
    # Temporary uncompressed file
    temp_uncompressed = tempname()
    max_row = UInt32(0)
    max_col = UInt32(0)
    # Step 1: Read the BinCOO file and write to a temporary uncompressed file
    open(bincoofile, "r") do infile
        open(temp_uncompressed, "w") do out
            for line in eachline(infile)
                row, col = parse.(UInt32, split(line))
                max_row = max(max_row, row)
                max_col = max(max_col, col)
                write(out, row)
                write(out, col)
            end
        end
    end
    # Step 2: Compress the temporary uncompressed file and write to the final binary file
    open(binfile, "w") do final_out
        stream = ZstdCompressorStream(final_out)
        write(stream, max_row)
        write(stream, max_col)
        open(temp_uncompressed, "r") do temp_in
            record = Vector{UInt8}(undef, 8)
            while !eof(temp_in)
                nread = readbytes!(temp_in, record)
                if nread < 8
                    error("Corrupted input: partial record of $nread bytes")
                end
                write(stream, record)
            end
        end
        close(stream)
    end
    # Remove the temporary uncompressed file
    rm(temp_uncompressed, force=true)
end
