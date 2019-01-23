"""
    lanczos(;input::AbstractString="", outdir::Union{Nothing,AbstractString}=nothing, scale::AbstractString="ftt", pseudocount::Number=1.0, rowmeanlist::AbstractString="", rowvarlist::AbstractString="",colsumlist::AbstractString="", dim::Number=3, numepoch::Number=10, perm::Bool=false)

Online PCA solved by candid covariance-free incremental PCA.

Input Arguments
---------
- `input` : Julia Binary file generated by `OnlinePCA.csv2bin` function.
- `outdir` : The directory specified the directory you want to save the result.
- `scale` : {log,ftt,raw}-scaling of the value.
- `pseudocount` : The number specified to avoid NaN by log10(0) and used when `Feature_LogMeans.csv` <log10(mean+pseudocount) value of each feature> is generated.
- `rowmeanlist` : The mean of each row of matrix. The CSV file is generated by `OnlinePCA.sumr` functions.
- `rowvarlist` : The variance of each row of matrix. The CSV file is generated by `OnlinePCA.sumr` functions.
- `colsumlist` : The sum of counts of each columns of matrix. The CSV file is generated by `OnlinePCA.sumr` functions.
- `dim` : The number of dimension of PCA.
- `perm` : Whether the data matrix is shuffled at random.

Output Arguments
---------
- `W` : Eigen vectors of covariance matrix (No. columns of the data matrix × dim)
- `λ` : Eigen values (dim × dim)
- `V` : Loading vectors of covariance matrix (No. rows of the data matrix × dim)
- `Scores` : Principal component scores
- `ExpVar` : Explained variance by the eigenvectors
- `TotalVar` : Total variance of the data matrix
- stop : Whether the calculation is converged
"""
function lanczos(;input::AbstractString="", outdir::Union{Nothing,AbstractString}=nothing, scale::AbstractString="ftt", pseudocount::Number=1.0, rowmeanlist::AbstractString="", rowvarlist::AbstractString="",colsumlist::AbstractString="", dim::Number=3, numepoch::Number=10, perm::Bool=false)
    # Initial Setting
    pca = LANCZOS()
    N, M = nm(input)
    pseudocount, W, X, D, rowmeanvec, rowvarvec, colsumvec, N, M, TotalVar = init(input, pseudocount, dim, rowmeanlist, rowvarlist, colsumlist, pca, numepoch, scale)
    T = zeros(Float32, numepoch, numepoch)
    tmpN = zeros(UInt32, 1)
    tmpM = zeros(UInt32, 1)
    x = zeros(UInt32, M)
    normx = zeros(Float32, M)
    # If not 0 the calculation is converged
    stop = 0
    k = 1
    n = 1
    s = 0
    # Each epoch s
    progress = Progress(numepoch)
    while(stop == 0 && k <= numepoch)
        v = zeros(Float32, M)
        open(input) do file
            stream = ZstdDecompressorStream(file)
            read!(stream, tmpN)
            read!(stream, tmpM)
            # Each step n
            while(stop == 0 && n <= N)
                next!(progress)
                # Row vector of data matrix
                read!(stream, x)
                normx = normalizex(x, n, stream, scale, pseudocount, rowmeanlist, rowmeanvec, rowvarlist, rowvarvec, colsumlist, colsumvec)
                if perm
                    normx .= normx[randperm(length(normx))]
                end
                # Power iteration
                v .+= normx * (normx' * W[:,k])
                n += 1
            end
            close(stream)
        end
        # NaN
        checkNaN(W, GD())
        # Check Float32
        @assert W[1,1] isa Float32
        # Ortho-normalization in Lanczos process
        T[k,k] = W[:,k]' * v
        if k == 1
            v = v .- T[k,k] * W[:,k]
        else
            v = v .- s * W[:,k-1] .- T[k,k] * W[:,k]
        end
        s = norm(v)
        if k != numepoch
            T[k+1,k] = s
            T[k,k+1] = s
        end
        W[:,k+1] = v / s
        k += 1
        if n == N + 1
            n = 1
        end
    end

    # Return, W, λ, V
    Y = eigvecs(T[1:numepoch, :])
    X = (W[:,1:numepoch] * Y[:,1:dim])
    out = WλV(X, input, dim, scale, pseudocount, rowmeanlist, rowmeanvec, rowvarlist, rowvarvec, colsumlist, colsumvec, TotalVar)
    out = (out[1], out[2], out[3], out[4], out[5], out[6], stop)
    if outdir isa String
        output(outdir, out, expvar)
    end
    return out
end
