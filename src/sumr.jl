"""
    sumr(; binfile::AbstractString="", outdir::AbstractString=".", pseudocount::Number=1.0, mode::AbstractString="dense", chunksize::Int=1)

Extract the summary information of data matrix.

Input Arguments
---------
- `binfile` is a Julia Binary file generated by `csv2bin` function.
- `outdir` is specified the directory you want to save the result.
- `pseudocount` is specified to avoid NaN by log10(0) and used when `Feature_LogMeans.csv` <log10(mean+pseudocount) value of each feature> is generated.
- `mode` : "dense" or "sparse_mm" can be specified.
- `chunksize` : The number of rows to be read at once.

Output Files
---------
- `Sample_NoCounts.csv` : Sum of counts in each column.
- `Feature_Means.csv` : Mean in each row.
- `Feature_LogMeans.csv` : Log10(Mean+pseudocount) in each row.
- `Feature_FTTMeans.csv` : FTT(Mean+pseudocount) in each row.
- `Feature_Vars.csv` : Sample variance in each row.
- `Feature_LogVars.csv` : Log10(Var+pseudocount) in each row.
- `Feature_FTTVars.csv` : FTT(Var+pseudocount) in each row.
- `Feature_CV2s.csv` : Coefficient of Variation in each row.
- `Feature_NoZeros.csv` : Number of zero-elements in each row.
"""
function sumr(; binfile::AbstractString="", outdir::AbstractString=".", pseudocount::Number=1.0, mode::AbstractString="dense", chunksize::Int=1)
    # Argument Check
    @assert mode in ("dense", "sparse_mm")
    # 1 / 2 : Column-wise statistics
    println("1 / 2 : Column-wise statistics are calculated...")
    Sample_NoCounts = nocounts(binfile, mode, chunksize)

    # 2 / 2 : Row-wise statistics
    println("2 / 2 : Row-wise statistics are calculated...")
    Feature_Means, Feature_LogMeans, Feature_FTTMeans, Feature_Vars, Feature_LogVars, Feature_FTTVars, Feature_CPMMeans, Feature_LogCPMMeans, Feature_FTTCPMMeans, Feature_CPMVars, Feature_LogCPMVars, Feature_FTTCPMVars, Feature_CPTMeans, Feature_LogCPTMeans, Feature_FTTCPTMeans, Feature_CPTVars, Feature_LogCPTVars, Feature_FTTCPTVars, Feature_CPMEDMeans, Feature_LogCPMEDMeans, Feature_FTTCPMEDMeans, Feature_CPMEDVars, Feature_LogCPMEDVars, Feature_FTTCPMEDVars, Feature_CV2s, Feature_NoZeros = stats(binfile, pseudocount, Sample_NoCounts, mode)

    # Save
    write_csv(joinpath(outdir, "Sample_NoCounts.csv"), Sample_NoCounts)

    write_csv(joinpath(outdir, "Feature_Means.csv"), Feature_Means)
    write_csv(joinpath(outdir, "Feature_LogMeans.csv"), Feature_LogMeans)
    write_csv(joinpath(outdir, "Feature_FTTMeans.csv"), Feature_FTTMeans)

    write_csv(joinpath(outdir, "Feature_CPMMeans.csv"), Feature_CPMMeans)
    write_csv(joinpath(outdir, "Feature_LogCPMMeans.csv"), Feature_LogCPMMeans)
    write_csv(joinpath(outdir, "Feature_FTTCPMMeans.csv"), Feature_FTTCPMMeans)

    write_csv(joinpath(outdir, "Feature_CPTMeans.csv"), Feature_CPTMeans)
    write_csv(joinpath(outdir, "Feature_LogCPTMeans.csv"), Feature_LogCPTMeans)
    write_csv(joinpath(outdir, "Feature_FTTCPTMeans.csv"), Feature_FTTCPTMeans)

    write_csv(joinpath(outdir, "Feature_CPMEDMeans.csv"), Feature_CPMEDMeans)
    write_csv(joinpath(outdir, "Feature_LogCPMEDMeans.csv"), Feature_LogCPMEDMeans)
    write_csv(joinpath(outdir, "Feature_FTTCPMEDMeans.csv"), Feature_FTTCPMEDMeans)

    write_csv(joinpath(outdir, "Feature_Vars.csv"), Feature_Vars)
    write_csv(joinpath(outdir, "Feature_LogVars.csv"), Feature_LogVars)
    write_csv(joinpath(outdir, "Feature_FTTVars.csv"), Feature_FTTVars)

    write_csv(joinpath(outdir, "Feature_CPMVars.csv"), Feature_CPMVars)
    write_csv(joinpath(outdir, "Feature_LogCPMVars.csv"), Feature_LogCPMVars)
    write_csv(joinpath(outdir, "Feature_FTTCPMVars.csv"), Feature_FTTCPMVars)

    write_csv(joinpath(outdir, "Feature_CPTVars.csv"), Feature_CPTVars)
    write_csv(joinpath(outdir, "Feature_LogCPTVars.csv"), Feature_LogCPTVars)
    write_csv(joinpath(outdir, "Feature_FTTCPTVars.csv"), Feature_FTTCPTVars)

    write_csv(joinpath(outdir, "Feature_CPMEDVars.csv"), Feature_CPMEDVars)
    write_csv(joinpath(outdir, "Feature_LogCPMEDVars.csv"), Feature_LogCPMEDVars)
    write_csv(joinpath(outdir, "Feature_FTTCPMEDVars.csv"), Feature_FTTCPMEDVars)

    write_csv(joinpath(outdir, "Feature_CV2s.csv"), Feature_CV2s)
    write_csv(joinpath(outdir, "Feature_NoZeros.csv"), Feature_NoZeros)
end

# Row-wise statistics
function stats(binfile::AbstractString, pseudocount::Number, nc::AbstractArray, mode::AbstractString)
    N, M = nm(binfile)
    tmpN = zeros(UInt32, 1)
    tmpM = zeros(UInt32, 1)
    # Buffer for each stats
    m = zeros(N)
    lm = zeros(N)
    fttm = zeros(N)
    v = zeros(N)
    lv = zeros(N)
    fttv = zeros(N)
    cpmm = zeros(N)
    lcpmm = zeros(N)
    fttcpmm = zeros(N)
    cpmv = zeros(N)
    lcpmv = zeros(N)
    fttcpmv = zeros(N)
    cptm = zeros(N)
    lcptm = zeros(N)
    fttcptm = zeros(N)
    cptv = zeros(N)
    lcptv = zeros(N)
    fttcptv = zeros(N)
    cpmedm = zeros(N)
    lcpmedm = zeros(N)
    fttcpmedm = zeros(N)
    cpmedv = zeros(N)
    lcpmedv = zeros(N)
    fttcpmedv = zeros(N)
    c = zeros(N)
    nz = zeros(N)
    progress = Progress(N)
    open(binfile) do file
        stream = ZstdDecompressorStream(file)
        read!(stream, tmpN)
        read!(stream, tmpM)
        ########################################
        # CSV / Dense Matrix
        ########################################
        if mode == "dense"
            x = zeros(UInt32, M)
            for n = 1:N
                read!(stream, x)
                update_stats!(n, x, nothing, nc, pseudocount,
                    m, lm, fttm, v, lv, fttv,
                    cpmm, lcpmm, fttcpmm, cpmv, lcpmv, fttcpmv,
                    cptm, lcptm, fttcptm, cptv, lcptv, fttcptv,
                    cpmedm, lcpmedm, fttcpmedm, cpmedv, lcpmedv, fttcpmedv,
                    c, nz)
                next!(progress)
            end
        end
        ########################################
        # MM / Sparse Matrix
        ########################################
        if mode == "sparse_mm"
            row_buffer = []
            col_buffer = []
            val_buffer = []
            current_row = 1
            while !eof(stream)
                buf = zeros(UInt32, 3)  # (row, col, val)
                read!(stream, buf)
                row, col, val = buf[1], buf[2], buf[3]
                if row != current_row
                    update_stats!(current_row, row_buffer, val_buffer, nc, pseudocount,
                        m, lm, fttm, v, lv, fttv,
                        cpmm, lcpmm, fttcpmm, cpmv, lcpmv, fttcpmv,
                        cptm, lcptm, fttcptm, cptv, lcptv, fttcptv,
                        cpmedm, lcpmedm, fttcpmedm, cpmedv, lcpmedv, fttcpmedv,
                        c, nz)
                    # Next row
                    current_row = row
                    empty!(row_buffer)
                    empty!(col_buffer)
                    empty!(val_buffer)
                end
                push!(row_buffer, row)
                push!(col_buffer, col)
                push!(val_buffer, val)
            end
            # Last row
            update_stats!(current_row, row_buffer, val_buffer, nc, pseudocount,
                m, lm, fttm, v, lv, fttv,
                cpmm, lcpmm, fttcpmm, cpmv, lcpmv, fttcpmv,
                cptm, lcptm, fttcptm, cptv, lcptv, fttcptv,
                cpmedm, lcpmedm, fttcpmedm, cpmedv, lcpmedv, fttcpmedv,
                c, nz)
        end
        close(stream)
    end
    return m, lm, fttm, v, lv, fttv, cpmm, lcpmm, fttcpmm, cpmv, lcpmv, fttcpmv, cptm, lcptm, fttcptm, cptv, lcptv, fttcptv, cpmedm, lcpmedm, fttcpmedm, cpmedv, lcpmedv, fttcpmedv, c, nz
end

function update_stats!(n, x, val_buffer, nc, pseudocount,
    m, lm, fttm, v, lv, fttv,
    cpmm, lcpmm, fttcpmm, cpmv, lcpmv, fttcpmv,
    cptm, lcptm, fttcptm, cptv, lcptv, fttcptv,
    cpmedm, lcpmedm, fttcpmedm, cpmedv, lcpmedv, fttcpmedv,
    c, nz)
    if val_buffer !== nothing
        x = zeros(UInt32, length(nc))
        for i in eachindex(val_buffer)
            x[i] = val_buffer[i]
        end
    end

    # Each stats
    m[n] = mean(x)
    lm[n] = mean(log10.(x .+ pseudocount))
    fttm[n] = mean(sqrt.(x) .+ sqrt.(x .+ 1))
    v[n] = var(x)
    lv[n] = var(log10.(x .+ pseudocount))
    fttv[n] = var(sqrt.(x) .+ sqrt.(x .+ 1))

    x_div = x ./ nc

    x_cpm = 1e6 .* x_div
    cpmm[n] = mean(x_cpm)
    lcpmm[n] = mean(log10.(x_cpm .+ pseudocount))
    fttcpmm[n] = mean(sqrt.(x_cpm) .+ sqrt.(x_cpm .+ 1))

    cpmv[n] = var(x_cpm)
    lcpmv[n] = var(log10.(x_cpm .+ pseudocount))
    fttcpmv[n] = var(sqrt.(x_cpm) .+ sqrt.(x_cpm .+ 1))

    x_cpt = 1e4 .* x_div
    cptm[n] = mean(x_cpt)
    lcptm[n] = mean(log10.(x_cpt .+ pseudocount))
    fttcptm[n] = mean(sqrt.(x_cpt) .+ sqrt.(x_cpt .+ 1))

    cptv[n] = var(x_cpt)
    lcptv[n] = var(log10.(x_cpt .+ pseudocount))
    fttcptv[n] = var(sqrt.(x_cpt) .+ sqrt.(x_cpt .+ 1))

    x_cpmed = median(nc) .* x_div
    cpmedm[n] = mean(x_cpmed)
    lcpmedm[n] = mean(log10.(x_cpmed .+ pseudocount))
    fttcpmedm[n] = mean(sqrt.(x_cpmed) .+ sqrt.(x_cpmed .+ 1))

    cpmedv[n] = var(x_cpmed)
    lcpmedv[n] = var(log10.(x_cpmed .+ pseudocount))
    fttcpmedv[n] = var(sqrt.(x_cpmed) .+ sqrt.(x_cpmed .+ 1))

    c[n] = v[n] / (m[n]^2 + eps(Float64))

    nz[n] = sum(x .!= 0)
end
