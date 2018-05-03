"""
    svrg(;input="", outdir=".", logscale=true, pseudocount=1, rowmeanlist="", colsumlist="", masklist="", dim=3, stepsize=0.1, numepoch=5, scheduling="robbins-monro", g=0.9, epsilon=1.0e-8, logdir=nothing)

Online PCA solved by variance-reduced stochastic gradient descent method, also known as VR-PCA.

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
- SVRG-PCA : [Ohad Shamir, 2015](http://proceedings.mlr.press/v37/shamir15.pdf)
"""
function svrg(;input="", outdir=".", logscale=true, pseudocount=1, rowmeanlist="", colsumlist="", masklist="", dim=3, stepsize=0.1, numepoch=5, scheduling="robbins-monro", g=0.9, epsilon=1.0e-8, logdir=nothing)
    # Initialization
    N, M = init(input) # No.gene, No.cell
    W = zeros(Float32, M, dim) # Eigen vectors
    Ws = zeros(Float32, M, dim) # Eigen vectors
    v = zeros(Float32, M, dim) # Temporal Vector (Same length as x)
    D = Diagonal(reverse(1:dim)) # Diagonaml Matrix
    for i=1:dim
        W[i,i] = 1
    end

    # mean (gene), library size (cell), cell mask list
    rowmeanvec = zeros(Float32, N, 1)
    colsumvec = zeros(Float32, M, 1)
    cellmaskvec = zeros(Float32, M, 1)
    if rowmeanlist != ""
        rowmeanvec = readcsv(rowmeanlist, Float32)
    end
    if colsumlist != ""
        colsumvec = readcsv(colsumlist, Float32)
    end
    if masklist != ""
        cellmaskvec = readcsv(masklist, Float32)
    end

    # directory for log file
    if typeof(logdir) == String
        if(!isdir(logdir))
            mkdir(logdir)
        end
    end

    # progress
    progress = Progress(numepoch)
    for s = 1:numepoch
        u = ∇f(W, input, D * Float32(stepsize)/s, N, M, logscale, pseudocount, masklist, rowmeanlist, colsumlist, rowmeanvec, colsumvec)
        Ws = W
        open(input) do file
            N = read(file, Int64)
            M = read(file, Int64)
            for n = 1:N
                # Data Import
                x = deserialize(file)
                if logscale
                    x = log10.(x + pseudocount)
                end
                if masklist != ""
                    x = x[cellmaskvec]
                end
                if (rowmeanlist != "") && (colsumlist != "")
                    x = (x - rowmeanvec[n, 1]) ./ colsumvec
                end
                if (rowmeanlist != "") && (colsumlist == "")
                    x = x - rowmeanvec[n, 1]
                end
                if (rowmeanlist == "") && (colsumlist != "")
                    x = x ./ colsumvec
                end
                # SVRG × Robbins-Monro
                if scheduling == "robbins-monro"
                    W .= W .+ Pw(∇fn(W, x, D * Float32(stepsize)/(N*(s-1)+n), M), W) .- Pw(∇fn(Ws, x, D * Float32(stepsize)/(N*(s-1)+n), M), Ws) .+ u
                # SVRG × Momentum
                elseif scheduling == "momentum"
                    v .= g .* v .+ ∇fn(W, x, D * Float32(stepsize), M) .- ∇fn(Ws, x, D * Float32(stepsize), M) .+ u
                    W .= W .+ v
                # SVRG × NAG
                elseif scheduling == "nag"
                    v = g .* v + ∇fn(W - g .* v, x, D * Float32(stepsize), M) .- ∇fn(Ws, x, D * Float32(stepsize), M) .+ u
                    W .= W .+ v
                # SVRG × Adagrad
                elseif scheduling == "adagrad"
                    grad = ∇fn(W, x, D * Float32(stepsize), M) .- ∇fn(Ws, x, D * Float32(stepsize), M) .+ u
                    grad = grad / Float32(stepsize)
                    v .= v .+ grad .* grad
                    W .= W .+ Float32(stepsize) ./ (sqrt.(v) + epsilon) .* grad
                else
                    error("Specify the scheduling as robbins-monro, momentum, nag or adagrad")
                end
                # NaN
                if any(isnan, W)
                    error("NaN values are generated. Select other stepsize")
                end

                # Retraction
                W .= full(qrfact!(W)[:Q], thin=true)
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
    WλV(W, input, dim)
end