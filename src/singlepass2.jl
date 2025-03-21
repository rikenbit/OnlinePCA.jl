"""
    singlepass2(;input::AbstractString="", outdir::Union{Nothing,AbstractString}=nothing, scale::AbstractString="ftt", pseudocount::Number=1f0, rowmeanlist::AbstractString="", rowvarlist::AbstractString="", colsumlist::AbstractString="", dim::Number=3, noversamples::Number=5, niter::Number=3, initW::Union{Nothing,AbstractString}=nothing, initV::Union{Nothing,AbstractString}=nothing, logdir::Union{Nothing,AbstractString}=nothing, perm::Bool=false, cper::Number=1f0)

Single-pass PCA type II, which is one of randomized SVD algorithm.

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
- `noversamples` : The number of over-sampling.
- `niter` : The number of power interation.
- `initW` : The CSV file saving the initial values of eigenvectors.
- `initV` : The CSV file saving the initial values of loadings.
- `logdir` : The directory where intermediate files are saved, in every evalfreq (e.g. 5000) iteration.
- `perm` : Whether the data matrix is shuffled at random.
- `cper` : Count per X (e.g. CPM: Count per million <1e+6>)

Output Arguments
---------
- `V` : Eigen vectors of covariance matrix (No. columns of the data matrix × dim)
- `λ` : Eigen values (dim × dim)
- `U` : Loading vectors of covariance matrix (No. rows of the data matrix × dim)
- `Scores` : Principal component scores
- `ExpVar` : Explained variance by the eigenvectors
- `TotalVar` : Total variance of the data matrix
"""
function singlepass2(; input::AbstractString="", outdir::Union{Nothing,AbstractString}=nothing, scale::AbstractString="ftt", pseudocount::Number=1.0f0, rowmeanlist::AbstractString="", rowvarlist::AbstractString="", colsumlist::AbstractString="", dim::Number=3, noversamples::Number=5, niter::Number=3, initW::Union{Nothing,AbstractString}=nothing, initV::Union{Nothing,AbstractString}=nothing, logdir::Union{Nothing,AbstractString}=nothing, perm::Bool=false, cper::Number=1.0f0)
    # Initial Setting
    pca = SINGLEPASS2()
    pseudocount, W, D, rowmeanvec, rowvarvec, colsumvec, N, M, TotalVar = init(input, pseudocount, dim, rowmeanlist, rowvarlist, colsumlist, initW, initV, logdir, pca, cper, scale)
    # Perform PCA
    out = singlepass2(input, outdir, scale, pseudocount, rowmeanlist, rowvarlist, colsumlist, dim, noversamples, niter, logdir, pca, W, D, rowmeanvec, rowvarvec, colsumvec, N, M, TotalVar, perm, cper)
    # Output
    if outdir isa String
        write_csv(joinpath(outdir, "Eigen_vectors.csv"), out[1])
        write_csv(joinpath(outdir, "Eigen_values.csv"), out[2])
        write_csv(joinpath(outdir, "Loadings.csv"), out[3])
        write_csv(joinpath(outdir, "Scores.csv"), out[4])
        write_csv(joinpath(outdir, "ExpVar.csv"), out[5])
        write_csv(joinpath(outdir, "TotalVar.csv"), out[6])
    end
    return out
end

function singlepass2(input, outdir, scale, pseudocount, rowmeanlist, rowvarlist, colsumlist, dim, noversamples, niter, logdir, pca, W, D, rowmeanvec, rowvarvec, colsumvec, N, M, TotalVar, perm, cper)
    N, M = nm(input)
    tmpN = zeros(UInt32, 1)
    tmpM = zeros(UInt32, 1)
    x = zeros(UInt32, M)
    normx = zeros(Float32, M)
    b = round(Int64, dim ./ niter) + noversamples
    l = niter * b
    Ω = rand(Float32, M, l)
    G = zeros(Float32, N, l)
    H = zeros(Float32, M, l)
    Q = zeros(Float32, N, 0)
    B = zeros(Float32, 0, M)
    n = 1
    println("Random Projection : G = A Ω, H = A' A Ω")
    progress = Progress(N)
    open(input) do file
        stream = ZstdDecompressorStream(file)
        read!(stream, tmpN)
        read!(stream, tmpM)
        # Each step n
        while (n <= N)
            next!(progress)
            # Row vector of data matrix
            read!(stream, x)
            normx = normalizex(x, n, stream, scale, pseudocount, rowmeanlist, rowmeanvec, rowvarlist, rowvarvec, colsumlist, colsumvec, cper)
            if perm
                normx .= normx[randperm(length(normx))]
            end
            # Random Projection
            tmpG = normx' * Ω
            @inbounds for i in 1:size(tmpG)[2]
                G[n, i] = tmpG[1, i]
            end
            H .+= normx * tmpG
            n += 1
        end
        close(stream)
    end

    for i in 1:niter
        block = (i-1)*b+1:i*b
        Ωi = Ω[:, block]
        Yi = G[:, block] - Q * (B * Ωi)
        println("Subspace iterations (1/2) : Q = qr(Yi)")
        F1 = qr!(Yi)
        Qi = Array(F1.Q)
        println("Subspace iterations (2/2) : Q = qr(Qi - Q(Q' Qi))")
        F2 = qr!(Qi - Q * (Q' * Qi))
        Qi = Array(F2.Q)

        Ri = F2.R * F1.R
        Bi = inv(Ri)' * (H[:, block]' - Yi' * Q * B - Ωi' * B'B)
        if i == 1
            Q = Qi
            B = Bi
        else
            Q = hcat(Q, Qi)
            B = vcat(B, Bi)
        end
    end

    # SVD with small matrix
    println("SVD with small matrix : svd(B)")
    W, λ, V = svd(B)
    U = Q * W
    # PC scores, Explained Variance
    Scores = zeros(Float32, M, dim)
    for n = 1:dim
        Scores[:, n] .= λ[n] .* V[:, n]
    end
    ExpVar = sum(λ) / TotalVar
    # Return
    return (V[:, 1:dim], λ[1:dim], U[:, 1:dim], Scores[:, 1:dim], ExpVar, TotalVar)
end
