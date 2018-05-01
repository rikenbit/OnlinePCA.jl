function nocounts(slfile, N, M)
    nc = zeros(Int64, M)
    progress = Progress(N)
    open(slfile) do file
        N = read(file, Int64)
        M = read(file, Int64)
        for n = 1:N
            # Data Import
            x = deserialize(file)
            # Update
            nc = nc .+ x
            # Progress Bar
            next!(progress)
        end
    end
    return nc
end

function genestats(slfile, N, M, pseudocount)
    m = zeros(N)
    lm = zeros(N)
    v = zeros(N)
    c = zeros(N)
    nz = zeros(N)
    progress = Progress(N)
    open(slfile) do file
        N = read(file, Int64)
        M = read(file, Int64)
        for n = 1:N
            # Data Import
            x = deserialize(file)
            # Update
            m[n] = mean(x)
            lm[n] = log10(mean(x .+ pseudocount))
            v[n] = var(x)
            c[n] = v[n] / m[n]^2
            nz[n] = M - length(x.nzind)
            # Progress Bar
            next!(progress)
        end
    end
    return m, lm, v, c, nz
end

function hvg(slfile, N, M, m, v, cv2)
    # Select genes for fitting
    useForFit = []
    pm = []
    counter = 0
    pval = ones(N)
    for n = 1:N
        if cv2[n] > 0.3
            counter = counter + 1
            push!(pm, n)
        end
    end
    thr = percentile(m[pm], 50)
    for n = 1:N
        if m[n] >= thr
            push!(useForFit, n)
        end
    end
    # Fitting
    data = DataFrame(Y=cv2[useForFit], X=1./m[useForFit])
    fit = glm(@formula(Y ~ X), data, Gamma(), IdentityLink())
    a0, a1 = coef(fit)
    afit = a1 ./ m .+ a0
    varFitRatio = v ./ (afit .* m .* m)
    df = M - 1
    # P-value
    for n = 1:N
        pval[n] = ccdf(Chisq(df), varFitRatio[n]*df)
    end

    # Return
    return useForFit, a0, a1, afit, varFitRatio, df, pval
end

function sumr(;slfile="", outdir=".", pseudocount=1.0)
    # Initialization
    N, M = init(slfile)

    # 1 / 3 : Sum of counts in each cell
    println("1 / 3 : Sum of counts in each cell are calculated...")
    Sample_NoCounts = nocounts(slfile, N, M)

    # 2 / 3 : Gene-wise statistics
    println("2 / 3 : Gene-wise statistics are calculated...")
    Feature_Means, Feature_LogMeans, Feature_Vars, Feature_CV2s, Feature_NoZeros = genestats(slfile, N, M, pseudocount)

    # 3 / 3 : Highly Variable Genes
    println("3 / 3 : Highly Variable Genes are calculated...")
    HVG_useForFit, HVG_a0, HVG_a1, HVG_afits, HVG_varFitRatios, HVG_DF, HVG_Pvals = hvg(slfile, N, M, Feature_Means, Feature_Vars, Feature_CV2s)

    # Save
    writecsv(outdir*"/Sample_NoCounts.csv", Sample_NoCounts)

    writecsv(outdir*"/Feature_Means.csv", Feature_Means)
    writecsv(outdir*"/Feature_LogMeans.csv", Feature_LogMeans)
    writecsv(outdir*"/Feature_Vars.csv", Feature_Vars)
    writecsv(outdir*"/Feature_CV2s.csv", Feature_CV2s)
    writecsv(outdir*"/Feature_NoZeros.csv", Feature_NoZeros)

    writecsv(outdir*"/HVG_useForFit.csv", HVG_useForFit)
    writecsv(outdir*"/HVG_a0.csv", HVG_a0)
    writecsv(outdir*"/HVG_a1.csv", HVG_a1)
    writecsv(outdir*"/HVG_afits.csv", HVG_afits)
    writecsv(outdir*"/HVG_varFitRatios.csv", HVG_varFitRatios)
    writecsv(outdir*"/HVG_DF.csv", HVG_DF)
    writecsv(outdir*"/HVG_Pvals.csv", HVG_Pvals)
end