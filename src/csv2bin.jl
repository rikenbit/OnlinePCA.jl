"""
    csv2bin(;csvfile::AbstractString="", binfile::AbstractString="")

Convert a CSV file to Julia Binary file.

`csvfile` and `binfile` are specified such as Data.csv and Data.dat, respectively.
"""
function csv2bin(;csvfile::AbstractString="", binfile::AbstractString="")
    N = zeros(UInt32, 1)
    M = zeros(UInt32, 1)
    N[] = UInt32(nrow(csvfile=csvfile))
    M[] = UInt32(ncol(csvfile=csvfile))
    counter = 0
    open(binfile, "w") do file
        stream = LZ4CompressorStream(file)
        write(stream, N)
        write(stream, M)
        open(csvfile , "r") do f
            while !eof(f)
                counter += 1
                print("\r", counter)
                xx = readline(f)
                xx = split(xx, ",") # Imported as Character
                # Assume input data is Integer
                x = zeros(UInt32, length(xx))
                for i=1:length(x)
                    x[i] = floor(UInt32, parse(Float64, xx[i]))
                end
                write(stream, x)
            end
        end
        close(stream)
    end
    print("\n")
end

# no.of row of csv
function nrow(;csvfile::AbstractString="")
    nrow = 0
    open(csvfile, "r") do f
        while !eof(f)
            nrow += 1
            readline(f)
        end
    end
    nrow
end

# no. of columns of csv
function ncol(;csvfile::AbstractString="")
    counter = 0
    open(csvfile, "r") do f
        xx = readline(f)
        xx = split(xx, ",")
        length(xx)
    end
end
