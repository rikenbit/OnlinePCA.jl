"""
    hvg(slfile, rowmeanlist, rowvarlist, rowcv2list, outdir)

This function perform highly variable genes, which is an feature selection method in scRNA-seq studies.

Input Arguments
---------
- `slfile` : A Julia Binary file generated by `csv2sl` function.
- `featurelist` : A row-wise summary data such as. The CSV files are generated by `csv2sl` function.
- `thr` : The threshold to reject low-signal feature.
- `outdir` : The directory specified the directory you want to save the result.

Output files
---------
- `filtered.dat` : Filtered binary file.
"""
function filtering(;slfile="", featurelist="", thr=0, outdir=".")
    # File
    outfile = outdir*"/filtered.dat"

    # Feature selection
    featurelist = readcsv(featurelist)

    # thr
    if typeof(thr) == String
        thr = parse(Float64, thr)
    end

    open(outfile, "w") do file1
        nrow::Int64 = 0
        ncol::Int64 = 0
        open(slfile , "r") do file2
            N = read(file2, Int64)
            M = read(file2, Int64)
            progress = Progress(N)
            for n = 1:N
                x = deserialize(file2)
                if n == 1
                    seek(file1, sizeof(Int64) * 2)
                    ncol = length(x)
                end
                if featurelist[n, 1] > thr
                    nrow += 1
                    serialize(file1, x)
                end
                next!(progress)
            end
            seekstart(file1)
            write(file1, nrow)
            write(file1, ncol)
            close(file2)
        end
        close(file1)
    end
    print("\n")
end