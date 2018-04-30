include("Utils.jl")

function oja(;input="", output=".", logscale=true, pseudocount=1, meanlist="", liblist="", cellmasklist="", dim=3, stepsize=0.1, numepoch=5, scheduling="robbins-monro", g=0.9, epsilon=0.00000001, logfile=false)
    # Initialization
    N, M = init(input) # No.gene, No.cell
    W = zeros(Float32, M, dim) # Eigen vectors
    v = zeros(Float32, M, dim) # Temporal Vector (Same length as x)
    D = Diagonal(reverse(1:dim)) # Diagonaml Matrix
    for i=1:dim
        W[i,i] = 1
    end

    # mean (gene), library size (cell), cell mask list
    meanvec = zeros(Float32, N, 1)
    libvec = zeros(Float32, M, 1)
    cellmaskvec = zeros(Float32, M, 1)
    if meanlist != ""
        meanvec = readcsv(meanlist, Float32)
    end
    if liblist != ""
        libvec = readcsv(liblist, Float32)
    end
    if cellmasklist != ""
        cellmaskvec = readcsv(cellmasklist, Float32)
    end

    # directory for log file
    if typeof(logfile) == String
        if(!isdir(logfile))
            mkdir(logfile)
        end
    end

    # progress
    progress = Progress(numepoch)
    for s = 1:numepoch
        open(input) do file
            N = read(file, Int64)
            M = read(file, Int64)
            for n = 1:N
                # Data Import
                x = deserialize(file)
                if logscale
                    x = log10.(x + pseudocount)
                end
                if cellmasklist != ""
                    x = x[cellmaskvec]
                end
                if (meanlist != "") && (liblist != "")
                    x = (x - meanvec[n, 1]) ./ libvec
                end
                if (meanlist != "") && (liblist == "")
                    x = x - meanvec[n, 1]
                end
                if (meanlist == "") && (liblist != "")
                    x = x ./ libvec
                end
                # SGD × Robbins-Monro
                if scheduling == "robbins-monro"
                    W .= W .+ ∇fn(W, x, D * Float32(stepsize)/(N*(s-1)+n), M)
                # SGD × Momentum
                elseif scheduling == "momentum"
                    v .= g .* v .+ ∇fn(W, x, D * Float32(stepsize), M)
                    W .= W .+ v
                # SGD × NAG
                elseif scheduling == "nag"
                    v = g .* v + ∇fn(W - g .* v, x, D * Float32(stepsize), M)
                    W .= W .+ v
                # SGD × Adagrad
                elseif scheduling == "adagrad"
                    grad = ∇fn(W, x, D, M)
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
                if typeof(logfile) == String
                     if(mod((N*(s-1)+n), 1000) == 0)
                        writecsv(logfile * "/W_" * string((N*(s-1)+n)) * ".csv", W)
                        writecsv(logfile * "/RecError_" * string((N*(s-1)+n)) * ".csv", RecError(W, input))
                        touch(logfile * "/W_" * string((N*(s-1)+n)) * ".csv")
                        touch(logfile * "/RecError_" * string((N*(s-1)+n)) * ".csv")
                    end
                end
            end
        end
        next!(progress)
    end
    # Return, W, λ, V
    WλV(W, input, dim)
end