"""
    gd(;input::AbstractString="", outdir::Union{Nothing,AbstractString}=nothing, scale::AbstractString="ftt", pseudocount::Number=1.0, rowmeanlist::AbstractString="", rowvarlist::AbstractString="",colsumlist::AbstractString="", dim::Number=3, stepsize::Number=0.1, numepoch::Number=3, scheduling::AbstractString="robbins-monro", g::Number=0.9, epsilon::Number=1.0e-8, lower::Number=0, upper::Number=1.0f+38, expvar::Number=0.1f0, evalfreq::Number=5000, offsetFull::Number=1f-20, offsetStoch::Number=1f-6, initW::Union{Nothing,AbstractString}=nothing, initV::Union{Nothing,AbstractString}=nothing, logdir::Union{Nothing,AbstractString}=nothing, perm::Bool=false)


Online PCA solved by gradient descent method.

The convergence is relatively slower than the other online PCA methods.

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
- `lower` : Stopping Criteria (When the relative change of error is below this value, the calculation is terminated)
- `upper` : Stopping Criteria (When the relative change of error is above this value, the calculation is terminated)
- `evalfreq` : Evaluation Frequency of Reconstruction Error
- `offsetFull` : Off set value for avoding overflow when calculating full gradient
- `offsetStoch` : Off set value for avoding overflow when calculating stochastic gradient
- `initW` : The CSV file saving the initial values of eigenvectors.
- `initV` : The CSV file saving the initial values of loadings.
- `logdir` : The directory where intermediate files are saved, in every 1000 iteration.
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
function gd(;input::AbstractString="", outdir::Union{Nothing,AbstractString}=nothing, scale::AbstractString="ftt", pseudocount::Number=1.0, rowmeanlist::AbstractString="", rowvarlist::AbstractString="",colsumlist::AbstractString="", dim::Number=3, stepsize::Number=0.1, numepoch::Number=3, scheduling::AbstractString="robbins-monro", g::Number=0.9, epsilon::Number=1.0e-8, lower::Number=0, upper::Number=1.0f+38, expvar::Number=0.1f0, evalfreq::Number=5000, offsetFull::Number=1f-20, offsetStoch::Number=1f-6, initW::Union{Nothing,AbstractString}=nothing, initV::Union{Nothing,AbstractString}=nothing, logdir::Union{Nothing,AbstractString}=nothing, perm::Bool=false)
    # Initial Setting
    pca = GD()
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
    pseudocount, stepsize, g, epsilon, W, v, D, rowmeanvec, rowvarvec, colsumvec, N, M, TotalVar, lower, upper, evalfreq, offsetFull, offsetStoch = init(input, pseudocount, stepsize, g, epsilon, dim, rowmeanlist, rowvarlist, colsumlist, initW, initV, logdir, pca, lower, upper, evalfreq, offsetFull, offsetStoch, scale)
    # Perform PCA
    out = gd(input, outdir, scale, pseudocount, rowmeanlist, rowvarlist, colsumlist, dim, stepsize, numepoch, scheduling, g, epsilon, logdir, pca, W, v, D, rowmeanvec, rowvarvec, colsumvec, N, M, TotalVar, lower, upper, evalfreq, offsetFull, offsetStoch, perm)
    if outdir isa String
        output(outdir, out, expvar)
    end
    return out
end

function gd(input, outdir, scale, pseudocount, rowmeanlist, rowvarlist, colsumlist, dim, stepsize, numepoch, scheduling, g, epsilon, logdir, pca, W, v, D, rowmeanvec, rowvarvec, colsumvec, N, M, TotalVar, lower, upper, evalfreq, offsetFull, offsetStoch, perm)
    # If not 0 the calculation is converged
    stop = 0
    s = 1
    n = 1
    # Each epoch s
    progress = Progress(numepoch)
    while(stop == 0 && s <= numepoch)
        next!(progress)
        # Update Eigen vector
        W, v = gdupdate(scheduling, stepsize, g, epsilon, D, N, M, W, v, s, input, scale, pseudocount, rowmeanlist, rowmeanvec, rowvarlist, rowvarvec, colsumlist, colsumvec, offsetFull, offsetStoch, perm)
        # NaN
        checkNaN(W, pca)
        # Retraction
        W .= Array(qr!(W).Q)
        # save log file
        if logdir isa String
            stop = outputlog(s, input, dim, logdir, W, pca, TotalVar, scale, pseudocount, rowmeanlist, rowmeanvec, rowvarlist, rowvarvec, colsumlist, colsumvec, lower, upper, stop)
        end
        s += 1
    end

    # Return, W, λ, V
    out = WλV(W, input, dim, scale, pseudocount, rowmeanlist, rowmeanvec, rowvarlist, rowvarvec, colsumlist, colsumvec, TotalVar)
    return (out[1], out[2], out[3], out[4], out[5], out[6], stop)
end

# GD × Robbins-Monro
function gdupdate(scheduling::ROBBINS_MONRO, stepsize, g, epsilon, D, N, M, W, v, s, input, scale, pseudocount, rowmeanlist, rowmeanvec, rowvarlist, rowvarvec, colsumlist, colsumvec, offsetFull, offsetStoch, perm)
    W .= W .+ ∇f(W, input, D, scale, pseudocount, rowmeanlist, rowmeanvec, rowvarlist, rowvarvec, colsumlist, colsumvec, stepsize/s, offsetFull, offsetStoch, perm)
    v = nothing
    return W, v
end

# GD × Momentum
function gdupdate(scheduling::MOMENTUM, stepsize, g, epsilon, D, N, M, W, v, s, input, scale, pseudocount, rowmeanlist, rowmeanvec, rowvarlist, rowvarvec, colsumlist, colsumvec, offsetFull, offsetStoch, perm)
    v .= g .* v .+ ∇f(W, input, D, scale, pseudocount, rowmeanlist, rowmeanvec, rowvarlist, rowvarvec, colsumlist, colsumvec, stepsize/s, offsetFull, offsetStoch, perm)
    W .= W .+ v
    return W, v
end

# GD × NAG
function gdupdate(scheduling::NAG, stepsize, g, epsilon, D, N, M, W, v, s, input, scale, pseudocount, rowmeanlist, rowmeanvec, rowvarlist, rowvarvec, colsumlist, colsumvec, offsetFull, offsetStoch, perm)
    v = g .* v + ∇f(W - g .* v, input, D, scale, pseudocount, rowmeanlist, rowmeanvec, rowvarlist, rowvarvec, colsumlist, colsumvec, stepsize/s, offsetFull, offsetStoch, perm)
    W .= W .+ v
    return W, v
end

# GD × Adagrad
function gdupdate(scheduling::ADAGRAD, stepsize, g, epsilon, D, N, M, W, v, s, input, scale, pseudocount, rowmeanlist, rowmeanvec, rowvarlist, rowvarvec, colsumlist, colsumvec, offsetFull, offsetStoch, perm)
    grad = ∇f(W, input, D, scale, pseudocount, rowmeanlist, rowmeanvec, rowvarlist, rowvarvec, colsumlist, colsumvec, stepsize/s, offsetFull, offsetStoch, perm)
    grad = grad / stepsize
    v .= v .+ grad .* grad
    W .= W .+ stepsize ./ (sqrt.(v) .+ epsilon) .* grad
    return W, v
end
