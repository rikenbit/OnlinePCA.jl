"""
    ccipca(;input::AbstractString="", outdir::Union{Void,AbstractString}=nothing, logscale::Bool=true, pseudocount::Number=1.0, rowmeanlist::AbstractString="", colsumlist::AbstractString="", masklist::AbstractString="", dim::Number=3, stepsize::Number=0.1, numepoch::Number=5, logdir::Union{Void,AbstractString}=nothing)

Online PCA solved by candid covariance-free incremental PCA.

Input Arguments
---------
- `input` : Julia Binary file generated by `OnlinePCA.csv2sl` function.
- `outdir` : The directory specified the directory you want to save the result.
- `logscale`  : Whether the count value is converted to log10(x + pseudocount).
- `pseudocount` : The number specified to avoid NaN by log10(0) and used when `Feature_LogMeans.csv` <log10(mean+pseudocount) value of each feature> is generated.
- `rowmeanlist` : The mean of each row of matrix. The CSV file is generated by `OnlinePCA.sumr` functions.
- `colsumlist` : The sum of counts of each columns of matrix. The CSV file is generated by `OnlinePCA.sumr` functions.
- `masklist` : The column list that user actually analyze.
- `dim` : The number of dimension of PCA.
- `stepsize` : The parameter used in every iteration.
- `numepoch` : The number of epoch.
- `logdir` : The directory where intermediate files are saved, in every 1000 iteration.

Output Arguments
---------
- `W` : Eigen vectors of covariance matrix (No. columns of the data matrix × dim)
- `λ` : Eigen values (dim × dim)
- `V` : Loading vectors of covariance matrix (No. rows of the data matrix × dim)

Reference
---------
- CCIPCA : [Juyang Weng et. al., 2003](http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.7.5665&rep=rep1&type=pdf)
"""
function ccipca(;input::AbstractString="", outdir::Union{Void,AbstractString}=nothing, logscale::Bool=true, pseudocount::Number=1.0, rowmeanlist::AbstractString="", colsumlist::AbstractString="", masklist::AbstractString="", dim::Number=3, stepsize::Number=0.1, numepoch::Number=5, logdir::Union{Void,AbstractString}=nothing)
    # Initial Setting
    pca = CCIPCA()
    pseudocount, stepsize, W, X, D, rowmeanvec, colsumvec, maskvec, N, M = init(input, pseudocount, stepsize, dim, rowmeanlist, colsumlist, masklist, logdir, pca)

    # Each epoch s
    progress = Progress(numepoch)
    for s = 1:numepoch
        open(input) do file
            N = read(file, Int64)
            M = read(file, Int64)
            # Each step n
            for n = 1:N
                # Data Import
                X[:, 1] = deserializex(n, file, logscale, pseudocount, masklist, maskvec, rowmeanlist, rowmeanvec, colsumlist, colsumvec)
                # CCIPCA
                k = N * (s - 1) + n
                for i = 1:min(dim, k)
                    if i == k
                        W[:, i] = X[:, i]
                    else
                        w1 = (k - 1 - stepsize) / k
                        w2 = (1 + stepsize) / k
                        Wi = W[:, i]
                        Xi = X[:, i]
                        # Eigen vector update
                        W[:, i] = w1 * Wi + w2 * Xi * dot(Xi, Wi/norm(Wi))
                        # Data for calculating i+1 th Eigen vector
                        Wi = W[:, i]
                        Wnorm = Wi / norm(Wi)
                        X[:, i+1] = Xi - dot(Xi, Wnorm) * Wnorm
                    end
                end
                # NaN
                checkNaN(N, s, n, W, pca)
                # save log file
                if typeof(logdir) == String
                    outputlog(N, s, n, input, logdir, W, pca)
                end
            end
        end
        next!(progress)
    end

    # Return, W, λ, V
    out = WλV(W, input, dim)
    if typeof(outdir) == String
        output(outdir, out)
    end
    return out
end