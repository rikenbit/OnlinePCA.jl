include("Utils.jl")

function csv2sl(;csvfile="", slfile="")
    open(slfile, "w") do file
        n_genes::Int64 = 0
        n_cells::Int64 = 0
        open(csvfile , "r") do f
            while !eof(f)
                n_genes += 1
                print("\r", n_genes)
                xx = readline(f)
                xx = split(xx, ",")
                x = zeros(Float32, length(xx))
                for i=1:length(x)
                    x[i] = parse(Float32, xx[i])
                end
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

function main()
    parsed_args = parse_commandline()
    println("Parsed args:")
    for (arg,val) in parsed_args
        println("  $arg  =>  $val")
    end

    csv2sl(csvfile=parsed_args["csvfile"],
        slfile=parsed_args["slfile"])
end

# オプション設定
function parse_commandline()
    s = ArgParseSettings()

    @add_arg_table s begin
        "--csvfile", "-c"
            help = "input file (csv)"
            required = true
        "--slfile", "-s"
            help = "output file (serialized)"
            required = true
    end

    return parse_args(s)
end

main()

# # test
# @time csv2sl(csvfile="test.csv", slfile="test.dat") # 0.13s
# @time csv2sl(csvfile="test2.csv", slfile="test2.dat") # 23s
# @time csv2sl(csvfile="/data/koki/TestData/single_cell/10XGenomics/1M_neurons/scale_log_1M_neurons_filtered_gene_bc_matrices_h5.csv", slfile="test3.dat") # 3.87h
