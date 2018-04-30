include("Utils.jl")

function csv2sl(;csvfile="", slfile="")
    open(slfile, "w") do file
        global n_genes = 0
        global n_cells = 0
        open(csvfile , "r") do f
            while !eof(f)
                n_genes += 1
                print("\r", n_genes)
                xx = readline(f)
                xx = split(xx, ",")
                # Assume input data is Integer
                x = spzeros(Int64, length(xx))
                for i=1:length(x)
                    x[i] = Int64(floor(parse(Float32, xx[i])))
                end
                x = dropzeros(x)
                if n_genes == 1
                    seek(file, sizeof(Int64) * 2)
                    n_cells = length(x)
                end
                serialize(file, x)
            end
            # write n_cells and n_cells at the top of the file
            seekstart(file)
            write(file, n_genes)
            write(file, n_cells)
        end
        close(file)
    end
    print("\n")
end
