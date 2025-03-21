"""
mm2bin(;mmfile::AbstractString="", binfile::AbstractString="")

Convert a Matrix Market (MM) file to Julia Binary file.

Input Arguments
---------
- `mmfile` : Matrix Market file (e.g., Data.mtx).
- `binfile` : Julia Binary file (e.g., Data.mtx.zst).
"""
function mm2bin(; mmfile::AbstractString="", binfile::AbstractString="")
    open(mmfile, "r") do infile
        open(binfile, "w") do outfile
            # N, M in Header
            stream = ZstdCompressorStream(outfile)
            lines = readlines(infile)
            N, M = parse.(UInt32, split(lines[2]))
            write(stream, N)
            write(stream, M)
            # Column-wise Sorting
            data_lines = lines[3:end]
            sorted_data = sort(data_lines, by=x -> let parts = split(x)
                (parse(UInt32, parts[1]), parse(UInt32, parts[2]))
            end)
            for line in sorted_data
                parts = parse.(UInt32, split(line))
                write(stream, parts)
            end
            close(stream)
        end
    end
end