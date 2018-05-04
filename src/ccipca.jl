"""
    ccipca(;input::String="", outdir=nothing, logscale::Bool=true, pseudocount::Float64=1.0, rowmeanlist::String="", colsumlist::String="", masklist::String="", dim::Int64=3, stepsize::Float64=0.1, numepoch::Int64=5, logdir=nothing)

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
function ccipca(;input::String="", outdir=nothing, logscale::Bool=true, pseudocount::Float64=1.0, rowmeanlist::String="", colsumlist::String="", masklist::String="", dim::Int64=3, stepsize::Float64=0.1, numepoch::Int64=5, logdir=nothing)
    # Initial Setting
    N, M, pseudocount, stepsize, W, X, D, rowmeanvec, colsumvec, cellmaskvec = ccipca_init(input, pseudocount, stepsize, dim, rowmeanlist, colsumlist, masklist, logdir)

    # progress
    progress = Progress(numepoch)
    for s = 1:numepoch
        open(input) do file
            N = read(file, Int64)
            M = read(file, Int64)
            for n = 1:N
                # Data Import
                X[:, 1] = deserialize(file)
                if logscale
                    X[:, 1] = log10.(X[:, 1] + pseudocount)
                end
                if masklist != ""
                    X[:, 1] = X[:, 1][cellmaskvec]
                end
                if (rowmeanlist != "") && (colsumlist != "")
                    X[:, 1] = (X[:, 1] - rowmeanvec[n, 1]) ./ colsumvec
                end
                if (rowmeanlist != "") && (colsumlist == "")
                    X[:, 1] = X[:, 1] - rowmeanvec[n, 1]
                end
                if (rowmeanlist == "") && (colsumlist != "")
                    X[:, 1] = X[:, 1] ./ colsumvec
                end

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
                if mod((N*(s-1)+n), 1000) == 0
                    if any(isnan, W)
                        error("NaN values are generated. Select other stepsize")
                    end
                end
                # save log file
                if typeof(logdir) == String
                     if(mod((N*(s-1)+n), 1000) == 0)
                        writecsv(logdir * "/W_" * string((N*(s-1)+n)) * ".csv", W)
                        writecsv(logdir * "/RecError_" * string((N*(s-1)+n)) * ".csv", RecError(W, input))
                        touch(logdir * "/W_" * string((N*(s-1)+n)) * ".csv")
                        touch(logdir * "/RecError_" * string((N*(s-1)+n)) * ".csv")
                    end
                end
            end
        end
        next!(progress)
    end

    # Return, W, λ, V
    out = WλV(W, input, dim)
    if typeof(outdir) == String
        writecsv(outdir * "/Eigen_vectors.csv", out[1])
        writecsv(outdir *"/Eigen_values.csv", out[2])
        writecsv(outdir *"/Loadings.csv", out[3])
        writecsv(outdir *"/Scores.csv", out[4])
        touch(outdir * "/Eigen_vectors.csv")
        touch(outdir *"/Eigen_values.csv")
        touch(outdir *"/Loadings.csv")
        touch(outdir *"/Scores.csv")
    end
    return out
end