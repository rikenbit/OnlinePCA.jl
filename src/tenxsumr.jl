"""
    tenxsumr(;tenxfile::AbstractString="", outdir::AbstractString=".", group::AbstractString="", chunksize::Number=5000)

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

# Column-wise statistics
function tenxnocounts(tenxfile::AbstractString, group::AbstractString, chunksize::Number, N::Number, M::Number, idp::AbstractArray)
    nc = zeros(UInt32, M)
    # Each chunk
	for i in 1:fld(N, chunksize)+1
        startp = Int64((i-1)*chunksize+1)
        endp = Int64(i*chunksize)
        if N - endp + chunksize < chunksize
	        endp = N
        end
        X = loadchromium(tenxfile, group, idp, startp, endp, M, false)
        nc += sum(X, dims=1)[1,:]
	end
    return nc
end

# Row-wise statistics
function tenxstats(tenxfile::AbstractString, group::AbstractString, chunksize::Number, N::Number, M::Number, idp::AbstractArray)
    m = zeros(N)
    lm = zeros(N)
    sqrtm = zeros(N)
    v = zeros(N)
    lv = zeros(N)
    sqrtv = zeros(N)
    c = zeros(N)
    nz = zeros(N)
    # Each chunk
    if N > chunksize
        lasti = fld(N, chunksize)+1
    else
        lasti = 1
    end
	for i in 1:lasti
        startp = Int64((i-1)*chunksize+1)
        endp = Int64(i*chunksize)
        if N - endp + chunksize < chunksize
	        endp = N
        end
        X = loadchromium(tenxfile, group, idp, startp, endp, M, false)
        logX = sparseLog10(X)
        sqrtX = sqrt.(X)
        # Update
        m[startp:endp] = mean(X, dims=2)
        lm[startp:endp] = mean(logX, dims=2)
        sqrtm[startp:endp] = mean(sqrtX, dims=2)
        v[startp:endp] = var(X, dims=2)
        lv[startp:endp] = var(logX, dims=2)
        sqrtv[startp:endp] = var(sqrtX, dims=2)
        c[startp:endp] = v[startp:endp] ./ (m[startp:endp] .* m[startp:endp])
	end
    return m, lm, sqrtm, v, lv, sqrtv, c, nz
end

function tenxsumr(;tenxfile::AbstractString="", outdir::AbstractString=".", group::AbstractString="", chunksize::Number=5000)
	# Row / Column
	N, M = tenxnm(tenxfile, group)
	# Index Pointer
	idp = indptr(tenxfile, group)

    # 1 / 2 : Column-wise statistics
    println("1 / 2 : Column-wise statistics are calculated...")
    Sample_NoCounts = tenxnocounts(tenxfile, group, chunksize, N, M, idp)

    # 2 / 2 : Row-wise statistics
    println("2 / 2 : Row-wise statistics are calculated...")
    Feature_Means, Feature_LogMeans, Feature_SqrtMeans, Feature_Vars, Feature_LogVars, Feature_SqrtVars, Feature_CV2s = tenxstats(tenxfile, group, chunksize, N, M, idp)

    # Save
    writecsv(joinpath(outdir, "Sample_NoCounts.csv"), Sample_NoCounts)
    writecsv(joinpath(outdir, "Feature_Means.csv"), Feature_Means)
    writecsv(joinpath(outdir, "Feature_LogMeans.csv"), Feature_LogMeans)
    writecsv(joinpath(outdir, "Feature_SqrtMeans.csv"), Feature_SqrtMeans)
    writecsv(joinpath(outdir, "Feature_Vars.csv"), Feature_Vars)
    writecsv(joinpath(outdir, "Feature_LogVars.csv"), Feature_LogVars)
    writecsv(joinpath(outdir, "Feature_SqrtVars.csv"), Feature_SqrtVars)
    writecsv(joinpath(outdir, "Feature_CV2s.csv"), Feature_CV2s)
end