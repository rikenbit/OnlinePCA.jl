"""
    sparse_rsvd(; input::AbstractString="", outdir::Union{Nothing,AbstractString}=nothing, scale::AbstractString="ftt", rowmeanlist::AbstractString="", rowvarlist::AbstractString="", colsumlist::AbstractString="", dim::Number=3, noversamples::Number=5, niter::Number=3, chunksize::Number=1, initW::Union{Nothing,AbstractString}=nothing, initV::Union{Nothing,AbstractString}=nothing, logdir::Union{Nothing,AbstractString}=nothing, perm::Bool=false, cper::Number=1.0f0)

A randomized SVD.

Input Arguments
---------
- `input` : Julia Binary file generated by `OnlinePCA.mm2bin` function.
- `outdir` : The directory specified the directory you want to save the result.
- `scale` : {ftt,log,raw}-scaling of the value.
- `rowmeanlist` : The mean of each row of matrix. The CSV file is generated by `OnlinePCA.sumr` functions.
- `rowvarlist` : The variance of each row of matrix. The CSV file is generated by `OnlinePCA.sumr` functions.
- `colsumlist` : The sum of counts of each columns of matrix. The CSV file is generated by `OnlinePCA.sumr` functions.
- `dim` : The number of dimension of PCA.
- `noversamples` : The number of over-sampling.
- `niter` : The number of power interation.
- `chunksize` is the number of rows reading at once (e.g. 1).
- `initW` : The CSV file saving the initial values of eigenvectors.
- `initV` : The CSV file saving the initial values of loadings.
- `logdir` : The directory where intermediate files are saved, in every evalfreq (e.g. 1) iteration.
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
function sparse_rsvd(; input::AbstractString="", outdir::Union{Nothing,AbstractString}=nothing,
    scale::AbstractString="ftt", rowmeanlist::AbstractString="", rowvarlist::AbstractString="",
    colsumlist::AbstractString="", dim::Number=3, noversamples::Number=5, niter::Number=3,
    chunksize::Number=1, initW::Union{Nothing,AbstractString}=nothing, initV::Union{Nothing,AbstractString}=nothing,
    logdir::Union{Nothing,AbstractString}=nothing, perm::Bool=false, cper::Number=1.0f0)
    # Argument Check
    if !(scale in ["ftt", "log", "raw"])
        error("scale must be specified as 'ftt', 'log', or 'raw'")
    end

    println("Initial Setting...")
    W, D, rowmeanvec, rowvarvec, colsumvec, N, M, TotalVar = sparseinit(
        input, dim, chunksize, rowmeanlist, rowvarlist, colsumlist,
        initW, initV, logdir, cper, scale, perm
    )

    # PCA実行
    out = sparse_rsvd_core(input, outdir, scale, rowmeanvec, rowvarvec, rowvarlist, colsumvec, dim, noversamples, niter, chunksize, logdir, W, D, N, M, TotalVar, perm, cper)

    # 結果の保存
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

function sparse_rsvd_core(input, outdir, scale, rowmeanvec, rowvarvec, rowvarlist, colsumvec,
    dim, noversamples, niter, chunksize, logdir, W, D, N, M, TotalVar, perm, cper)
    # Argument Check
    l = dim + noversamples
    @assert 0 < dim ≤ l ≤ min(N, M)
    # Initialization
    Ω = rand(Float32, M, l)
    XΩ = zeros(Float32, N, l)
    Y = zeros(Float32, N, l)
    L = zeros(Float32, N, l)
    Q = zeros(Float32, N, l)
    B = zeros(Float32, l, M)
    QtX = zeros(Float32, l, M)
    Scores = zeros(Float32, M, dim)

    lasti = 0
    if N > chunksize
        lasti = fld(N, chunksize)
    else
        lasti = 1
    end

    println("Random Projection : Y = A Ω")
    progress = Progress(lasti)
    open(input, "r") do file
        stream = ZstdDecompressorStream(file)
        read!(stream, Ref(N))
        read!(stream, Ref(M))

        for i in 1:lasti
            next!(progress)
            startp = Int64((i - 1) * chunksize + 1)
            endp = min(Int64(i * chunksize), Int(N))
            X = load_bin_chunk(stream, startp, endp, Int(M), perm)
            X = normalize_sparse_bin(X, scale, cper, colsumvec)
            if rowvarlist != ""
                XΩ[startp:endp, :] .= (X ./ rowvarvec[startp:endp]) * Ω
            else
                XΩ[startp:endp, :] .= X * Ω
            end
        end
    end

    if rowvarlist != ""
        Y .= XΩ .- (rowmeanvec ./ rowvarvec) .* sum(Ω, dims=1)
    else
        Y .= XΩ .- rowmeanvec .* sum(Ω, dims=1)
    end
    println("LU factorization : L = lu(Y)")
    L .= lu!(Y).L

    for i in 1:niter
        println("##### Iteration ", i, " / ", niter, " #####")
        XL = zeros(Float32, M, l)
        AtL = zeros(Float32, M, l)
        XAtL = zeros(Float32, N, l)

        println("Normalized power iterations (1/3) : A' L")
        progress = Progress(lasti)
        open(input, "r") do file
            stream = ZstdDecompressorStream(file)
            read!(stream, Ref(N))
            read!(stream, Ref(M))

            for j in 1:lasti
                next!(progress)
                startp = Int64((j - 1) * chunksize + 1)
                endp = min(Int64(j * chunksize), N)

                X = load_bin_chunk(stream, startp, endp, Int(M), perm)
                X = normalize_sparse_bin(X, scale, cper, colsumvec)

                if rowvarlist != ""
                    XL .+= (X ./ rowvarvec[startp:endp])' * L[startp:endp, :]
                else
                    XL .+= X' * L[startp:endp, :]
                end
            end
        end

        if rowvarlist != ""
            AtL .= XL .- (rowmeanvec ./ rowvarvec)' * L
        else
            AtL .= XL .- rowmeanvec' * L
        end

        println("Normalized power iterations (2/3) : A A' L")
        progress = Progress(lasti)
        open(input, "r") do file
            stream = ZstdDecompressorStream(file)
            read!(stream, Ref(N))
            read!(stream, Ref(M))

            for j in 1:lasti
                next!(progress)
                startp = Int64((j - 1) * chunksize + 1)
                endp = min(Int64(j * chunksize), N)

                X = load_bin_chunk(stream, startp, endp, Int(M), perm)
                X = normalize_sparse_bin(X, scale, cper, colsumvec)

                if rowvarlist != ""
                    XAtL[startp:endp, :] .= (X ./ rowvarvec[startp:endp]) * AtL
                else
                    XAtL[startp:endp, :] .= X * AtL
                end
            end
        end

        if rowvarlist != ""
            Y .= XAtL .- (rowmeanvec ./ rowvarvec) .* sum(AtL, dims=1)
        else
            Y .= XAtL .- rowmeanvec .* sum(AtL, dims=1)
        end

        if i < niter
            println("LU decomposition (3/3) : L = lu(A A' L)")
            L .= lu!(Y).L
        else
            println("QR decomposition  (3/3) : Q = qr(A A' L)")
            Q .= Array(qr!(Y).Q)
        end
    end

    println("Small matrix computation : B = Q' A")
    progress = Progress(lasti)
    open(input, "r") do file
        stream = ZstdDecompressorStream(file)
        read!(stream, Ref(N))
        read!(stream, Ref(M))

        for j in 1:lasti
            next!(progress)
            startp = Int64((j - 1) * chunksize + 1)
            endp = min(Int64(j * chunksize), N)

            X = load_bin_chunk(stream, startp, endp, Int(M), perm)
            X = normalize_sparse_bin(X, scale, cper, colsumvec)

            if rowvarlist != ""
                QtX .+= ((X ./ rowvarvec[startp:endp])' * Q[startp:endp, :])'
            else
                QtX .+= (X' * Q[startp:endp, :])'
            end
        end
    end

    println("SVD : B = U Σ V'")
    if rowvarlist != ""
        B = QtX .- Q' * (rowmeanvec ./ rowvarvec)
    else
        B = QtX .- Q' * rowmeanvec
    end
    W, σ, V = svd(B)
    U = Q * W
    λ = σ .* σ ./ M
    # PC scores, Explained Variance
    for n = 1:dim
        Scores[:, n] .= λ[n] .* V[:, n]
    end
    ExpVar = sum(λ) / TotalVar
    return (V[:, 1:dim], λ[1:dim], U[:, 1:dim], Scores[:, 1:dim], ExpVar, TotalVar)
end

# Loading a chunk from binary MM file
function load_bin_chunk(stream, startp::Int, endp::Int, M::Int, perm::Bool=false)
    row_buffer = UInt32[]
    col_buffer = UInt32[]
    val_buffer = Float32[]
    while !eof(stream)
        buf = zeros(UInt32, 3)  # (row, col, val)
        read!(stream, buf)
        row, col, val = buf[1], buf[2], buf[3]
        if startp <= row <= endp
            push!(row_buffer, row - startp + 1)
            push!(col_buffer, col)
            push!(val_buffer, val)
        elseif row > endp
            break  # Next chunk
        end
    end
    X_chunk = sparse(row_buffer, col_buffer, val_buffer, endp - startp + 1, M)
    if perm
        permuted_indices = randperm(size(X_chunk, 1))
        X_chunk = X_chunk[permuted_indices, :]
    end
    return X_chunk
end

# Normalization of X
function normalize_sparse_bin(X, scale, cper, colsumvec)
    colsumvec = reshape(colsumvec, 1, :)
    X_new = cper .* X ./ colsumvec
    if scale == "ftt"
        return sqrt.(X_new) + sqrt.(X_new .+ 1.0f0)
    elseif scale == "log"
        return log10.(X_new .+ 1)
    end
    return X_new
end

# Initialization of W, D, rowmeanvec, rowvarvec, colsumvec, N, M, TotalVar
function sparseinit(input::AbstractString, dim::Number, chunksize::Number,
    rowmeanlist::AbstractString, rowvarlist::AbstractString,
    colsumlist::AbstractString, initW::Union{Nothing,AbstractString},
    initV::Union{Nothing,AbstractString}, logdir::Union{Nothing,AbstractString},
    cper::Number, scale::AbstractString="ftt", perm::Bool=false)
    N, M = nm(input)
    if dim > min(N, M)
        error("dim must be less than or equal to the minimum of N and M.")
    end
    if chunksize > N
        error("chunksize must be less than or equal to N.")
    end
    if initW == nothing
        W = zeros(Float32, M, dim)
        for i in 1:dim
            W[i, i] = 1
        end
    elseif typeof(initW) == String
        if initV == nothing
            W = read_csv(initW, Float32)
        else
            error("initW and initV are not specified at once. You only have one choice.")
        end
    end
    if typeof(initV) == String
        V = read_csv(initV, Float32)
        V = V[:, 1:dim]
    end
    D = Diagonal(reverse(1:dim)) # Diagonal Matrix
    rowmeanvec = zeros(Float32, N, 1)
    rowvarvec = zeros(Float32, N, 1)
    colsumvec = ones(Float32, M, 1)
    if rowmeanlist != ""
        rowmeanvec = read_csv(rowmeanlist, Float32)
    end
    if rowvarlist != ""
        rowvarvec = read_csv(rowvarlist, Float32)
    end
    if colsumlist != ""
        colsumvec = read_csv(colsumlist, Float32)
    end
    # All Variance
    TotalVar = 0.0
    # No. of chunks
    lasti = 0
    if N > chunksize
        lasti = fld(N, chunksize)
    else
        lasti = 1
    end
    progress = Progress(lasti)
    open(input, "r") do file
        stream = ZstdDecompressorStream(file)
        read!(stream, Ref(N))
        read!(stream, Ref(M))
        for i in 1:lasti
            next!(progress)
            startp = Int64((i - 1) * chunksize + 1)
            endp = min(Int64(i * chunksize), Int(N))
            X_chunk = load_bin_chunk(stream, startp, endp, Int(M), perm)
            X_chunk = normalize_sparse_bin(X_chunk, scale, cper, colsumvec)
            TotalVar = tv(TotalVar, X_chunk)
            if typeof(initV) == String
                W = W .+ (V * X_chunk')'
            end
        end
    end
    TotalVar = TotalVar / M
    if logdir isa String
        if !isdir(logdir)
            mkdir(logdir)
        end
    end
    return W, D, rowmeanvec, rowvarvec, colsumvec, N, M, TotalVar
end
