"""
    svrg(;input::AbstractString="", outdir::Union{Nothing,AbstractString}=nothing, scale::AbstractString="ftt", pseudocount::Number=1f0, rowmeanlist::AbstractString="", rowvarlist::AbstractString="", colsumlist::AbstractString="", dim::Number=3, stepsize::Number=0.1, numbatch::Number=100, numepoch::Number=3, scheduling::AbstractString="robbins-monro", g::Number=0.9, epsilon::Number=1.0e-8, lower::Number=0, upper::Number=1.0f+38, expvar::Number=0.1f0, evalfreq::Number=5000, offsetFull::Number=1f-20, offsetStoch::Number=1f-6, initW::Union{Nothing,AbstractString}=nothing, initV::Union{Nothing,AbstractString}=nothing, logdir::Union{Nothing,AbstractString}=nothing, perm::Bool=false, cper::Number=1f0)

Variance-reduced stochastic gradient descent method, also known as VR-PCA.

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
- `numbatch` : The number of batch size.
- `numepoch` : The number of epoch.
- `scheduling` : Learning parameter scheduling. `robbins-monro`, `momentum`, `nag`, and `adagrad` are available.
- `g` : The parameter that is used when scheduling is specified as nag.
- `epsilon` : The parameter that is used when scheduling is specified as adagrad.
- `lower` : Stopping Criteria (When the relative change of error is below this value, the calculation is terminated)
- `upper` : Stopping Criteria (When the relative change of error is above this value, the calculation is terminated)
- `evalfreq` : Evaluation Frequency of Reconstruction Error
- `offsetFull` : Off set value for avoding overflow when calculating full gradient
- `offsetStoch` : Off set value for avoding overflow when calculating stochastic gradient
- `initW` : The CSV file saving the initial values of eigenvectors.
- `initV` : The CSV file saving the initial values of loadings.
- `logdir` : The directory where intermediate files are saved, in every evalfreq (e.g. 5000) iteration.
- `perm` : Whether the data matrix is shuffled at random.
- `cper` : Count per X (e.g. CPM: Count per million <1e+6>)

Output Arguments
---------
- `W` : Eigen vectors of covariance matrix (No. columns of the data matrix × dim)
- `λ` : Eigen values (dim × dim)
- `V` : Loading vectors of covariance matrix (No. rows of the data matrix × dim)
- `Scores` : Principal component scores
- `ExpVar` : Explained variance by the eigenvectors
- `TotalVar` : Total variance of the data matrix
- stop : Whether the calculation is converged

Reference
---------
- SVRG-PCA : [Ohad Shamir, 2015](http://proceedings.mlr.press/v37/shamir15.pdf)
"""
function svrg(;input::AbstractString="", outdir::Union{Nothing,AbstractString}=nothing, scale::AbstractString="ftt", pseudocount::Number=1f0, rowmeanlist::AbstractString="", rowvarlist::AbstractString="", colsumlist::AbstractString="", dim::Number=3, stepsize::Number=0.1, numbatch::Number=100, numepoch::Number=3, scheduling::AbstractString="robbins-monro", g::Number=0.9, epsilon::Number=1.0e-8, lower::Number=0, upper::Number=1.0f+38, expvar::Number=0.1f0, evalfreq::Number=5000, offsetFull::Number=1f-20, offsetStoch::Number=1f-6, initW::Union{Nothing,AbstractString}=nothing, initV::Union{Nothing,AbstractString}=nothing, logdir::Union{Nothing,AbstractString}=nothing, perm::Bool=false, cper::Number=1f0)
    # Initial Setting
    pca = SVRG()
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
    pseudocount, stepsize, g, epsilon, W, v, D, rowmeanvec, rowvarvec, colsumvec, N, M, TotalVar, lower, upper, evalfreq, offsetFull, offsetStoch = init(input, pseudocount, stepsize, g, epsilon, dim, rowmeanlist, rowvarlist, colsumlist, initW, initV, logdir, pca, lower, upper, evalfreq, offsetFull, offsetStoch, cper, scale)
    # Perform PCA
    out = svrg(input, outdir, scale, pseudocount, rowmeanlist, rowvarlist, colsumlist, dim, stepsize, numbatch, numepoch, scheduling, g, epsilon, logdir, pca, W, v, D, rowmeanvec, rowvarvec, colsumvec, N, M, TotalVar, lower, upper, evalfreq, offsetFull, offsetStoch, perm, cper)
    if outdir isa String
        output(outdir, out, expvar)
    end
    return out
end

function svrg(input, outdir, scale, pseudocount, rowmeanlist, rowvarlist, colsumlist, dim, stepsize, numbatch, numepoch, scheduling, g, epsilon, logdir, pca, W, v, D, rowmeanvec, rowvarvec, colsumvec, N, M, TotalVar, lower, upper, evalfreq, offsetFull, offsetStoch, perm, cper)
    N, M = nm(input)
    tmpN = zeros(UInt32, 1)
    tmpM = zeros(UInt32, 1)
    x = zeros(UInt32, M)
    normx = zeros(Float32, M)
    batchgrad1 = zeros(Float32, M, dim)
    batchgrad2 = zeros(Float32, M, dim)
    # If not 0 the calculation is converged
    stop = 0
    s = 1
    n = 1
    batchidx = 1
    batchcount = 1
    # Each epoch s
    progress = Progress(numepoch*N)
    while(stop == 0 && s <= numepoch)
        u = ∇f(W, input, D, scale, pseudocount, rowmeanlist, rowmeanvec, rowvarlist, rowvarvec, colsumlist, colsumvec, stepsize/s, offsetFull, offsetStoch, perm, cper)
        Ws = W
        open(input) do file
            stream = ZstdDecompressorStream(file)
            read!(stream, tmpN)
            read!(stream, tmpM)
            # Each step n
            while(stop == 0 && n <= N)
                next!(progress)
                # Row vector of data matrix
                read!(stream, x)
                normx = normalizex(x, n, stream, scale, pseudocount, rowmeanlist, rowmeanvec, rowvarlist, rowvarvec, colsumlist, colsumvec, cper)
                if perm
                    normx .= normx[randperm(length(normx))]
                end
                # Update Eigen vector
                W, v, batchgrad1, batchgrad2, batchidx, batchcount = svrgupdate(scheduling, stepsize, g, epsilon, D, N, M, dim, W, v, batchgrad1, batchgrad2, batchidx, batchcount, numbatch, normx, s, n, u, Ws, offsetStoch)
                # NaN
                checkNaN(N, s, n, W, evalfreq, pca)
                # Retraction
                W .= Array(qr!(W).Q)
                # save log file
                if logdir isa String
                    stop = outputlog(N, s, n, input, dim, logdir, W, pca, TotalVar, scale, pseudocount, rowmeanlist, rowmeanvec, rowvarlist, rowvarvec, colsumlist, colsumvec, lower, upper, stop, evalfreq, cper)
                end
                n += 1
            end
            close(stream)
        end
        # save log file
        if logdir isa String
            stop = outputlog(s, input, dim, logdir, W, GD(), TotalVar, scale, pseudocount, rowmeanlist, rowmeanvec, rowvarlist, rowvarvec, colsumlist, colsumvec, lower, upper, stop, cper)
        end
        s += 1
        if n == N + 1
            n = 1
        end
    end

    # Return, W, λ, V
    out = WλV(W, input, dim, scale, pseudocount, rowmeanlist, rowmeanvec, rowvarlist, rowvarvec, colsumlist, colsumvec, TotalVar, cper)
    return (out[1], out[2], out[3], out[4], out[5], out[6], stop)
end

# SVRG × Robbins-Monro
function svrgupdate(scheduling::ROBBINS_MONRO, stepsize, g, epsilon, D, N, M, dim, W, v, batchgrad1, batchgrad2, batchidx, batchcount, numbatch, normx, s, n, u, Ws, offsetStoch)
    if mod(batchidx, numbatch) == 0 && n != 1
        W .= W .+ batchgrad1 .- batchgrad2 .+ u
        batchgrad1 = zeros(Float32, M, dim)
        batchgrad2 = zeros(Float32, M, dim)
        batchidx = 1
        batchcount += 1
    else
        batchgrad1 .+= ∇fn(W, normx, D, M, stepsize/batchcount, offsetStoch)
        batchgrad2 .+= ∇fn(Ws, normx, D, M, stepsize/batchcount, offsetStoch)
        batchidx += 1
    end
    v = nothing
    return W, v, batchgrad1, batchgrad2, batchidx, batchcount
end

# SVRG × Momentum
function svrgupdate(scheduling::MOMENTUM, stepsize, g, epsilon, D, N, M, dim, W, v, batchgrad1, batchgrad2, batchidx, batchcount, numbatch, normx, s, n, u, Ws, offsetStoch)
    if mod(batchidx, numbatch) == 0 && n != 1
        v .= g .* v .+ batchgrad1 .- batchgrad2 .+ u
        W .= W .+ v
        batchgrad1 = zeros(Float32, M, dim)
        batchgrad2 = zeros(Float32, M, dim)
        batchidx = 1
        batchcount += 1
    else
        batchgrad1 .+= ∇fn(W, normx, D, M, stepsize, offsetStoch)
        batchgrad2 .+= ∇fn(Ws, normx, D, M, stepsize, offsetStoch)
        batchidx += 1
    end
    return W, v, batchgrad1, batchgrad2, batchidx, batchcount
end

# SVRG × NAG
function svrgupdate(scheduling::NAG, stepsize, g, epsilon, D, N, M, dim, W, v, batchgrad1, batchgrad2, batchidx, batchcount, numbatch, normx, s, n, u, Ws, offsetStoch)
    if mod(batchidx, numbatch) == 0 && n != 1
        v = g .* v + batchgrad1 .- batchgrad2 .+ u
        W .= W .+ v
        batchgrad1 = zeros(Float32, M, dim)
        batchgrad2 = zeros(Float32, M, dim)
        batchidx = 1
        batchcount += 1
    else
        batchgrad1 .+= ∇fn(W - g .* v, normx, D, M, stepsize, offsetStoch)
        batchgrad2 .+= ∇fn(Ws, normx, D, M, stepsize, offsetStoch)
        batchidx += 1
    end
    return W, v, batchgrad1, batchgrad2, batchidx, batchcount
end

# SVRG × Adagrad
function svrgupdate(scheduling::ADAGRAD, stepsize, g, epsilon, D, N, M, dim, W, v, batchgrad1, batchgrad2, batchidx, batchcount, numbatch, normx, s, n, u, Ws, offsetStoch)
    if mod(batchidx, numbatch) == 0 && n != 1
        grad = batchgrad1 .- batchgrad2 .+ u
        grad = grad / stepsize
        v .= v .+ grad .* grad
        W .= W .+ stepsize ./ (sqrt.(v) .+ epsilon) .* grad
        batchgrad1 = zeros(Float32, M, dim)
        batchgrad2 = zeros(Float32, M, dim)
        batchidx = 1
        batchcount += 1
    else
        batchgrad1 .+= ∇fn(W, normx, D, M, stepsize, offsetStoch)
        batchgrad2 .+= ∇fn(Ws, normx, D, M, stepsize, offsetStoch)
        batchidx += 1
    end
    return W, v, batchgrad1, batchgrad2, batchidx, batchcount
end
