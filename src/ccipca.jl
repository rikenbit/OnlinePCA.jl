function ccipca(;input="", output=".", logscale=true, pseudocount=1, meanlist="", liblist="", cellmasklist="", dim=3, stepsize=0.1, numepoch=5, logfile=false)
    # Initialization
    N, M = init(input) # No.gene, No.cell
    W = zeros(Float32, M, dim) # Eigen vectors
    X = zeros(Float32, M, dim+1) # Temporal Vector (Same length as x)
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
                X[:, 1] = deserialize(file)
                if logscale
                    X[:, 1] = log10.(X[:, 1] + pseudocount)
                end
                if cellmasklist != ""
                    X[:, 1] = X[:, 1][cellmaskvec]
                end
                if (meanlist != "") && (liblist != "")
                    X[:, 1] = (X[:, 1] - meanvec[n, 1]) ./ libvec
                end
                if (meanlist != "") && (liblist == "")
                    X[:, 1] = X[:, 1] - meanvec[n, 1]
                end
                if (meanlist == "") && (liblist != "")
                    X[:, 1] = X[:, 1] ./ libvec
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
                if any(isnan, W)
                    error("NaN values are generated. Select other stepsize")
                end

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