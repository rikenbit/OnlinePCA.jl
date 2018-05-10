"""
    csv2sl(;csvfile::AbstractString="", slfile::AbstractString="")

Convert a CSV file to Julia Binary file.

`csvfile` and `slfile` are specified such as Data.csv and Data.dat, respectively.

Reference
---------
- [Serialization・The Julia Language](https://docs.julialang.org/en/latest/stdlib/Serialization/)
"""
function csv2sl(;csvfile::AbstractString="", slfile::AbstractString="")
    open(slfile, "w") do file
        global nrow = 0
        global ncol = 0
        open(csvfile , "r") do f
            while !eof(f)
                nrow += 1
                print("\r", nrow)
                xx = readline(f)
                xx = split(xx, ",")
                # Assume input data is Integer
                x = spzeros(Int64, length(xx))
                for i=1:length(x)
                    x[i] = Int64(floor(parse(Float32, xx[i])))
                end
                x = dropzeros(x)
                if nrow == 1
                    seek(file, sizeof(Int64) * 2)
                    ncol = length(x)
                end
                serialize(file, x)
            end
            seekstart(file)
            write(file, nrow)
            write(file, ncol)
        end
        close(file)
    end
    print("\n")
end
