"""
    rsgd(;input::AbstractString="", outdir::Union{Void,AbstractString}=nothing, scale::AbstractString="ftt", pseudocount::Number=1.0, rowmeanlist::AbstractString="", rowvarlist::AbstractString="",colsumlist::AbstractString="", dim::Number=3, stepsize::Number=0.1, numepoch::Number=3, scheduling::AbstractString="robbins-monro", g::Number=0.9, epsilon::Number=1.0e-8, stop::Number=1.0e-3, evalfreq::Number=5000, offsetFull::Number=1f-20, offsetStoch::Number=1f-6, logdir::Union{Void,AbstractString}=nothing)

Online PCA solved by Riemannian stochastic gradient descent method.

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
- `stepsize` : The parameter used in every iteration.
- `numepoch` : The number of epoch.
- `scheduling` : Learning parameter scheduling. `robbins-monro`, `momentum`, `nag`, and `adagrad` are available.
- `g` : The parameter that is used when scheduling is specified as nag.
- `epsilon` : The parameter that is used when scheduling is specified as adagrad.
- `logdir` : The directory where intermediate files are saved, in every 1000 iteration.

Output Arguments
---------
- `W` : Eigen vectors of covariance matrix (No. columns of the data matrix × dim)
- `λ` : Eigen values (dim × dim)
- `V` : Loading vectors of covariance matrix (No. rows of the data matrix × dim)

Reference
---------
- RSGD-PCA : [Silvere Bonnabel, 2013](https://arxiv.org/abs/1111.5280)
"""
function rsgd(;input::AbstractString="", outdir::Union{Void,AbstractString}=nothing, scale::AbstractString="ftt", pseudocount::Number=1.0, rowmeanlist::AbstractString="", rowvarlist::AbstractString="",colsumlist::AbstractString="", dim::Number=3, stepsize::Number=0.1, numepoch::Number=3, scheduling::AbstractString="robbins-monro", g::Number=0.9, epsilon::Number=1.0e-8, stop::Number=1.0e-3, evalfreq::Number=5000, offsetFull::Number=1f-20, offsetStoch::Number=1f-6, logdir::Union{Void,AbstractString}=nothing)
    # Initial Setting
    pca = RSGD()
    if scheduling == "robbins-monro"
        scheduling = ROBBINS_MONRO()
    elseif scheduling == "momentum"
        scheduling = MOMENTUM()
    elseif scheduling == "nag"
        scheduling = NAG()
    elseif scheduling == "adagrad"
        scheduling = ADAGRAD()
    else
        error("Specify the scheduling as robbins-monro, momentum, nag or adagrad")
    end
    pseudocount, stepsize, g, epsilon, W, v, D, rowmeanvec, rowvarvec, colsumvec, N, M, AllVar, stop, evalfreq, offsetFull, offsetStoch = init(input, pseudocount, stepsize, g, epsilon, dim, rowmeanlist, rowvarlist, colsumlist, logdir, pca, stop, evalfreq, offsetFull, offsetStoch, scale)
    # Perform PCA
    out = rsgd(input, outdir, scale, pseudocount, rowmeanlist, rowvarlist, colsumlist, dim, stepsize, numepoch, scheduling, g, epsilon, logdir, pca, W, v, D, rowmeanvec, rowvarvec, colsumvec, N, M, AllVar, stop, evalfreq, offsetStoch)
    if outdir isa String
        output(outdir, out)
    end
    return out
end

function rsgd(input, outdir, scale, pseudocount, rowmeanlist, rowvarlist, colsumlist, dim, stepsize, numepoch, scheduling, g, epsilon, logdir, pca, W, v, D, rowmeanvec, rowvarvec, colsumvec, N, M, AllVar, stop, evalfreq, offsetStoch)
    N, M = nm(input)
    tmpN = zeros(UInt32, 1)
    tmpM = zeros(UInt32, 1)
    x = zeros(UInt32, M)
    normx = zeros(Float32, M)
    # If true the calculation is converged
    conv = false
    s = 1
    n = 1
    # Each epoch s
    progress = Progress(numepoch*N)
    while(!conv && s <= numepoch)
        open(input) do file
            stream = ZstdDecompressorStream(file)
            read!(stream, tmpN)
            read!(stream, tmpM)
            # Each step n
            while(!conv && n <= N)
                next!(progress)
                # Row vector of data matrix
                read!(stream, x)
                normx = normalizex(x, n, stream, scale, pseudocount, rowmeanlist, rowmeanvec, rowvarlist, rowvarvec, colsumlist, colsumvec)
                # Update Eigen vector
                W, v = rsgdupdate(scheduling, stepsize, g, epsilon, D, N, M, W, v, normx, s, n, offsetStoch)
                # NaN
                checkNaN(N, s, n, W, evalfreq, pca)
                # Retraction
                W .= full(qrfact!(W)[:Q], thin=true)
                # save log file
                if logdir isa String
                    conv = outputlog(N, s, n, input, dim, logdir, W, pca, AllVar, scale, pseudocount, rowmeanlist, rowmeanvec, rowvarlist, rowvarvec, colsumlist, colsumvec, stop, conv, evalfreq)
                end
                n += 1
            end
            close(stream)
        end
        # save log file
        if logdir isa String
            conv = outputlog(s, input, dim, logdir, W, GD(), AllVar, scale, pseudocount, rowmeanlist, rowmeanvec, rowvarlist, rowvarvec, colsumlist, colsumvec, stop, conv)
        end
        s += 1
        if n == N + 1
            n = 1
        end
    end

    # Return, W, λ, V
    WλV(W, input, dim, scale, pseudocount, rowmeanlist, rowmeanvec, rowvarlist, rowvarvec, colsumlist, colsumvec)
end

# RSGD × Robbins-Monro
function rsgdupdate(scheduling::ROBBINS_MONRO, stepsize, g, epsilon, D, N, M, W, v, normx, s, n, offsetStoch)
    W .= W .+ Pw(∇fn(W, normx, D, M, stepsize/(N*(s-1)+n), offsetStoch), W)
    v = nothing
    return W, v
end

# RSGD × Momentum
function rsgdupdate(scheduling::MOMENTUM, stepsize, g, epsilon, D, N, M, W, v, normx, s, n, offsetStoch)
    v .= g .* v .+ Pw(∇fn(W, normx, D, M, stepsize, offsetStoch), W)
    W .= W .+ v
    return W, v
end

# RSGD × NAG
function rsgdupdate(scheduling::NAG, stepsize, g, epsilon, D, N, M, W, v, normx, s, n, offsetStoch)
    v = g .* v .+ Pw(∇fn(W - g .* v, normx, D, M, stepsize, offsetStoch), W)
    W .= W .+ v
    return W, v
end

# RSGD × Adagrad
function rsgdupdate(scheduling::ADAGRAD, stepsize, g, epsilon, D, N, M, W, v, normx, s, n, offsetStoch)
    grad = Pw(∇fn(W, normx, D, M, stepsize, offsetStoch), W)
    grad = grad / stepsize
    v .= v .+ grad .* grad
    W .= W .+ stepsize ./ (sqrt.(v) + epsilon) .* grad
    return W, v
end
