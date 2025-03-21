"""
    tenxsumr(; tenxfile::AbstractString="", outdir::AbstractString=".", group::AbstractString="", chunksize::Number=5000)

Extract the summary information of 10X-HDF5.

Input Arguments
---------
- `tenxfile` is the HDF5 file formatted by 10X Genomics.
- `outdir` is specified the directory you want to save the result.
- `group` is the group name of HDF5 (e.g. mm10).
- `chunksize` is the number of rows reading at once (e.g. 5000).

Output Files
---------
- `Sample_NoCounts.csv` : Sum of counts in each column.
- `Feature_Means.csv` : Mean in each row.
- `Feature_LogMeans.csv` : Log10(Mean+1) in each row.
- `Feature_SqrtMeans.csv` : sqrt(Mean+1) in each row.
- `Feature_Vars.csv` : Sample variance in each row.
- `Feature_LogVars.csv` : Log10(Var+1) in each row.
- `Feature_SqrtVars.csv` : sqrt(Var+1) in each row.
- `Feature_CV2s.csv` : Coefficient of Variation in each row.
"""
function tenxsumr(; tenxfile::AbstractString="", outdir::AbstractString=".", group::AbstractString="", chunksize::Number=5000)
    # Row / Column
    N, M = tenxnm(tenxfile, group)
    # Index Pointer
    idp = indptr(tenxfile, group)

    # 1 / 2 : Column-wise statistics
    println("1 / 2 : Column-wise statistics are calculated...")
    Sample_NoCounts = tenxnocounts(tenxfile, group, chunksize, N, M, idp)

    # 2 / 2 : Row-wise statistics
    println("2 / 2 : Row-wise statistics are calculated...")
    Feature_Means, Feature_LogMeans, Feature_SqrtMeans, Feature_Vars, Feature_LogVars, Feature_SqrtVars, Feature_CPMMeans, Feature_LogCPMMeans, Feature_SqrtCPMMeans, Feature_CPMVars, Feature_LogCPMVars, Feature_SqrtCPMVars, Feature_CPTMeans, Feature_LogCPTMeans, Feature_SqrtCPTMeans, Feature_CPTVars, Feature_LogCPTVars, Feature_SqrtCPTVars, Feature_CPMEDMeans, Feature_LogCPMEDMeans, Feature_SqrtCPMEDMeans, Feature_CPMEDVars, Feature_LogCPMEDVars, Feature_SqrtCPMEDVars, Feature_CV2s = tenxstats(tenxfile, group, chunksize, N, M, idp, Sample_NoCounts)

    # Save
    write_csv(joinpath(outdir, "Sample_NoCounts.csv"), Sample_NoCounts)

    write_csv(joinpath(outdir, "Feature_Means.csv"), Feature_Means)
    write_csv(joinpath(outdir, "Feature_LogMeans.csv"), Feature_LogMeans)
    write_csv(joinpath(outdir, "Feature_SqrtMeans.csv"), Feature_SqrtMeans)

    write_csv(joinpath(outdir, "Feature_CPMMeans.csv"), Feature_CPMMeans)
    write_csv(joinpath(outdir, "Feature_LogCPMMeans.csv"), Feature_LogCPMMeans)
    write_csv(joinpath(outdir, "Feature_SqrtCPMMeans.csv"), Feature_SqrtCPMMeans)

    write_csv(joinpath(outdir, "Feature_CPTMeans.csv"), Feature_CPTMeans)
    write_csv(joinpath(outdir, "Feature_LogCPTMeans.csv"), Feature_LogCPTMeans)
    write_csv(joinpath(outdir, "Feature_SqrtCPTMeans.csv"), Feature_SqrtCPTMeans)

    write_csv(joinpath(outdir, "Feature_CPMEDMeans.csv"), Feature_CPMEDMeans)
    write_csv(joinpath(outdir, "Feature_LogCPMEDMeans.csv"), Feature_LogCPMEDMeans)
    write_csv(joinpath(outdir, "Feature_SqrtCPMEDMeans.csv"), Feature_SqrtCPMEDMeans)

    write_csv(joinpath(outdir, "Feature_Vars.csv"), Feature_Vars)
    write_csv(joinpath(outdir, "Feature_LogVars.csv"), Feature_LogVars)
    write_csv(joinpath(outdir, "Feature_SqrtVars.csv"), Feature_SqrtVars)

    write_csv(joinpath(outdir, "Feature_CPMVars.csv"), Feature_CPMVars)
    write_csv(joinpath(outdir, "Feature_LogCPMVars.csv"), Feature_LogCPMVars)
    write_csv(joinpath(outdir, "Feature_SqrtCPMVars.csv"), Feature_SqrtCPMVars)

    write_csv(joinpath(outdir, "Feature_CPTVars.csv"), Feature_CPTVars)
    write_csv(joinpath(outdir, "Feature_LogCPTVars.csv"), Feature_LogCPTVars)
    write_csv(joinpath(outdir, "Feature_SqrtCPTVars.csv"), Feature_SqrtCPTVars)

    write_csv(joinpath(outdir, "Feature_CPMEDVars.csv"), Feature_CPMEDVars)
    write_csv(joinpath(outdir, "Feature_LogCPMEDVars.csv"), Feature_LogCPMEDVars)
    write_csv(joinpath(outdir, "Feature_SqrtCPMEDVars.csv"), Feature_SqrtCPMEDVars)

    write_csv(joinpath(outdir, "Feature_CV2s.csv"), Feature_CV2s)
end

# Column-wise statistics
function tenxnocounts(tenxfile::AbstractString, group::AbstractString, chunksize::Number, N::Number, M::Number, idp::AbstractArray)
    nc = zeros(UInt32, M)
    # Each chunk
    for i in 1:fld(N, chunksize)+1
        startp = Int64((i - 1) * chunksize + 1)
        endp = Int64(i * chunksize)
        if N - endp + chunksize < chunksize
            endp = N
        end
        X = loadchromium(tenxfile, group, idp, startp, endp, M, false)
        nc += sum(X, dims=1)[1, :]
    end
    return nc
end

# Row-wise statistics
function tenxstats(tenxfile::AbstractString, group::AbstractString, chunksize::Number, N::Number, M::Number, idp::AbstractArray, nc::AbstractArray)

    m = zeros(N)
    lm = zeros(N)
    sqrtm = zeros(N)

    v = zeros(N)
    lv = zeros(N)
    sqrtv = zeros(N)

    cpmm = zeros(N)
    lcpmm = zeros(N)
    sqrtcpmm = zeros(N)

    cpmv = zeros(N)
    lcpmv = zeros(N)
    sqrtcpmv = zeros(N)

    cptm = zeros(N)
    lcptm = zeros(N)
    sqrtcptm = zeros(N)

    cptv = zeros(N)
    lcptv = zeros(N)
    sqrtcptv = zeros(N)

    cpmedm = zeros(N)
    lcpmedm = zeros(N)
    sqrtcpmedm = zeros(N)

    cpmedv = zeros(N)
    lcpmedv = zeros(N)
    sqrtcpmedv = zeros(N)

    c = zeros(N)

    # Each chunk
    if N > chunksize
        lasti = fld(N, chunksize) + 1
    else
        lasti = 1
    end

    for i in 1:lasti
        startp = Int64((i - 1) * chunksize + 1)
        endp = Int64(i * chunksize)
        if N - endp + chunksize < chunksize
            endp = N
        end
        X = loadchromium(tenxfile, group, idp, startp, endp, M, false)
        logX = sparseLog10(X)
        sqrtX = sqrt.(X)

        cpmX = 1e6 .* X ./ nc'
        logcpmX = 1e6 .* logX ./ nc'
        sqrtcpmX = 1e6 .* sqrtX ./ nc'

        cptX = 1e4 .* X ./ nc'
        logcptX = 1e4 .* logX ./ nc'
        sqrtcptX = 1e4 .* sqrtX ./ nc'

        cpmedX = median(nc) .* X ./ nc'
        logcpmedX = median(nc) .* logX ./ nc'
        sqrtcpmedX = median(nc) .* sqrtX ./ nc'

        # Update
        m[startp:endp] = mean(X, dims=2)
        lm[startp:endp] = mean(logX, dims=2)
        sqrtm[startp:endp] = mean(sqrtX, dims=2)

        v[startp:endp] = var(X, dims=2)
        lv[startp:endp] = var(logX, dims=2)
        sqrtv[startp:endp] = var(sqrtX, dims=2)

        cpmm[startp:endp] = mean(cpmX, dims=2)
        lcpmm[startp:endp] = mean(logcpmX, dims=2)
        sqrtcpmm[startp:endp] = mean(sqrtcpmX, dims=2)

        cpmv[startp:endp] = var(cpmX, dims=2)
        lcpmv[startp:endp] = var(logcpmX, dims=2)
        sqrtcpmv[startp:endp] = var(sqrtcpmX, dims=2)

        cptm[startp:endp] = mean(cptX, dims=2)
        lcptm[startp:endp] = mean(logcptX, dims=2)
        sqrtcptm[startp:endp] = mean(sqrtcptX, dims=2)

        cptv[startp:endp] = var(cptX, dims=2)
        lcptv[startp:endp] = var(logcptX, dims=2)
        sqrtcptv[startp:endp] = var(sqrtcptX, dims=2)

        cpmedm[startp:endp] = mean(cpmedX, dims=2)
        lcpmedm[startp:endp] = mean(logcpmedX, dims=2)
        sqrtcpmedm[startp:endp] = mean(sqrtcpmedX, dims=2)

        cpmedv[startp:endp] = var(cpmedX, dims=2)
        lcpmedv[startp:endp] = var(logcpmedX, dims=2)
        sqrtcpmedv[startp:endp] = var(sqrtcpmedX, dims=2)

        c[startp:endp] = v[startp:endp] ./ (m[startp:endp] .* m[startp:endp])
    end
    return m, lm, sqrtm, v, lv, sqrtv, cpmm, lcpmm, sqrtcpmm, cpmv, lcpmv, sqrtcpmv, cptm, lcptm, sqrtcptm, cptv, lcptv, sqrtcptv, cpmedm, lcpmedm, sqrtcpmedm, cpmedv, lcpmedv, sqrtcpmedv, c
end
