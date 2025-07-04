"""
    exact_ooc_pca(; input::AbstractString="", outdir::Union{Nothing,AbstractString}=nothing, scale::AbstractString="raw", pseudocount::Number=1.0f0, dim::Number=3, chunksize::Number=1, mode::AbstractString="dense")

Exact Out-of-Core PCA, which is based on normal full-rank SVD and does not assume the low-rank approximation.

Input Arguments
---------
- `input` : Julia Binary file generated by `OnlinePCA.csv2bin` or `OnlinPCA.mm2bin` function.
- `outdir` : The directory specified the directory you want to save the result.
- `scale` : {raw,log,ftt}-scaling of the value.
- `pseudocount` : The number specified to avoid NaN by log10(0) and used when `Feature_LogMeans.csv` <log10(mean+pseudocount) value of each feature> is generated.
- `dim` : The number of dimension of PCA.
- `chunksize` : The number of rows to be read at once.
- `mode` : "dense", "sparse_mm", or "sparse_bincoo" can be specified.

Output Arguments
---------
- `V` : Eigen vectors of covariance matrix (No. columns of the data matrix × dim)
- `λ` : Eigen values (dim × dim)
- `U` : Loading vectors of covariance matrix (No. rows of the data matrix × dim)
- `Scores` : Principal component scores
- `ExpVar` : Explained variance by the eigenvectors
- `TotalVar` : Total variance of the data matrix
"""
function exact_ooc_pca(; input::AbstractString="", outdir::Union{Nothing,AbstractString}=nothing, scale::AbstractString="raw", pseudocount::Number=1.0f0, dim::Number=3, chunksize::Number=1, mode::AbstractString="dense")
    # Argument Check
    N, M = nm(input)
    if dim > min(N, M)
        error("dim must be less than or equal to the minimum of N and M.")
    end
    @assert mode in ("dense", "sparse_mm", "sparse_bincoo")
    # Covariance Matrix
    cov_mat, colmeanvec = ooc_cov(input, scale, pseudocount, chunksize, mode)

    # Singular Value Decomposition
    out_svd = svd(cov_mat)
    V = out_svd.Vt[1:dim, :]'
    S = out_svd.S
    TotalVar = Float32(sum(S .^ 2))
    ExpVar = Float32(sum(S[1:dim] .^ 2) / TotalVar)

    # V, λ, W, Scores
    println("# 3. PC Score (Z = XV) is being calculated.")
    out = VλW(V, input, dim, scale, pseudocount, chunksize, colmeanvec, mode)

    # Output
    if outdir isa String
        write_csv(joinpath(outdir, "Eigen_vectors.csv"), out[1])
        write_csv(joinpath(outdir, "Eigen_values.csv"), out[2])
        write_csv(joinpath(outdir, "Loadings.csv"), out[3])
        write_csv(joinpath(outdir, "Scores.csv"), out[4])
        write_csv(joinpath(outdir, "ExpVar.csv"), ExpVar)
        write_csv(joinpath(outdir, "TotalVar.csv"), TotalVar)
    end
    return (out[1], out[2], out[3], out[4], ExpVar, TotalVar)
end

# Out-of-Core Covariance Matrix Calculator
function ooc_cov(input::AbstractString="", scale::AbstractString="raw", pseudocount::Number=1.0f0, chunksize::Number=1, mode::AbstractString=false)
    # Arugment Check
    if !(scale in ["raw", "log", "ftt"])
        error("scale must be specified as log, ftt, or raw")
    end
    println("# 1. Column-wise Mean")
    N, M = nm(input)
    nc = nocounts(input, mode, chunksize)
    colmeanvec = Float32.(nc ./ N)
    cov_mat = zeros(Float32, M, M)
    println("# 2. Out-of-Core Covariance Matrix Calculation")
    progress = ProgressUnknown()
    open(input, "r") do file
        stream = ZstdDecompressorStream(file)
        tmpN = zeros(UInt32, 1)
        tmpM = zeros(UInt32, 1)
        read!(stream, tmpN)
        read!(stream, tmpM)
        n = 1
        ########################################
        # CSV / Dense Matrix
        ########################################
        if mode == "dense"
            X_chunk = zeros(UInt32, chunksize, M)
            buffer = zeros(UInt32, chunksize * M)
            while n <= N
                batch_size = min(chunksize, N - n + 1)
                read!(stream, view(buffer, 1:batch_size * M))
                X_chunk[1:batch_size, :] .= permutedims(reshape(Float32.(buffer[1:batch_size * M]), Int(M), batch_size))
                if scale == "raw"
                    cov_mat .+= X_chunk' * X_chunk
                else
                    normX_chunk = normalize_X_chunk(X_chunk[1:batch_size, :], scale, pseudocount)
                    cov_mat .+= normX_chunk' * normX_chunk
                end
                next!(progress)
                n += batch_size
            end
        end
        ########################################
        # MM / Sparse Matrix
        ########################################
        if mode == "sparse_mm"
            overflow_buf = UInt32[]
            while n <= N
                batch_size = min(chunksize, N - n + 1)
                max_size = (batch_size + 1) * M # For overflow
                rows = zeros(UInt32, max_size)
                cols = zeros(UInt32, max_size)
                vals = zeros(UInt32, max_size)
                count = 0
                ############### Overflow buffer ###############
                if !isempty(overflow_buf)
                    count += 1
                    rows[count] = overflow_buf[1] - n + 1
                    cols[count] = overflow_buf[2]
                    vals[count] = overflow_buf[3]
                    empty!(overflow_buf)
                end
               ###############################################
                while !eof(stream)
                    buf = zeros(UInt32, 3)
                    read!(stream, buf)
                    row, col, val = buf[1], buf[2], buf[3]
                    if n ≤ row < n + batch_size
                        count += 1
                        # Re-mapping row index
                        rows[count] = row - n + 1
                        cols[count] = col
                        vals[count] = val
                    else
                        overflow_buf = buf
                        break
                    end
                end
                # Remove 0s from the end
                resize!(rows, count)
                resize!(cols, count)
                resize!(vals, count)
                # Construct sparse matrix
                if count > 0
                    X_chunk = sparse(rows, cols, vals, batch_size, M)
                else
                    X_chunk = spzeros(batch_size, M)
                end
                if scale == "raw"
                    cov_mat .+= X_chunk' * X_chunk
                else
                    # Normalize the chunk
                    normX_chunk = normalize_X_chunk(X_chunk, scale, pseudocount)
                    cov_mat .+= normX_chunk' * normX_chunk
                end
                next!(progress)
                n += batch_size
            end
        end
        ########################################
        # Bin COO / Sparse Matrix
        ########################################
        if mode == "sparse_bincoo"
            overflow_buf = UInt32[]
            while n <= N
                batch_size = min(chunksize, N - n + 1)
                max_size = (batch_size + 1) * M
                rows = zeros(UInt32, max_size)
                cols = zeros(UInt32, max_size)
                vals = ones(UInt32, max_size)
                count = 0
                ############### Overflow buffer ###############
                if !isempty(overflow_buf)
                    row, col = overflow_buf
                    if n ≤ row < n + batch_size
                        count += 1
                        rows[count] = row - n + 1
                        cols[count] = col
                        empty!(overflow_buf)
                    end
                end
                ###############################################
                buf = zeros(UInt32, 2)
                while !eof(stream)
                    read!(stream, buf)
                    row, col = buf
                    if n ≤ row < n + batch_size
                        count += 1
                        rows[count] = row - n + 1
                        cols[count] = col
                    else
                        overflow_buf = [row, col]
                        break
                    end
                end
                resize!(rows, count)
                resize!(cols, count)
                resize!(vals, count)
                if count > 0
                    X_chunk = sparse(rows, cols, vals, batch_size, M)
                else
                    X_chunk = spzeros(batch_size, M)
                end
                if scale == "raw"
                    cov_mat .+= X_chunk' * X_chunk
                else
                    # Normalize the chunk
                    normX_chunk = normalize_X_chunk(X_chunk, scale, pseudocount)
                    cov_mat .+= normX_chunk' * normX_chunk
                end
                next!(progress)
                n += batch_size
            end
        end
    end
    finish!(progress)
    if scale == "raw"
        cov_mat -= N .* (colmeanvec * colmeanvec')
    end
    cov_mat = cov_mat ./ (N - 1)
    return cov_mat, colmeanvec
end

# normalize X w/o rowmeanlist, rowmeanvec, rowvarlist, rowvarvec, colsumlist, colsumvec
function normalize_X_chunk(X_chunk, scale::AbstractString, pseudocount::Number)
    if scale == "log"
        X_chunk = log10.(X_chunk .+ pseudocount)
    elseif scale == "ftt"
        X_chunk = sqrt.(X_chunk) .+ sqrt.(X_chunk .+ 1.0f0)
    end
    colmeanvec = vec(mean(X_chunk, dims=1))
    return X_chunk .- reshape(colmeanvec, 1, :)
end

function VλW(V::AbstractArray, input::AbstractString, dim::Number, scale::AbstractString, pseudocount::Number, chunksize::Number, colmeanvec::Vector{Float32}, mode::AbstractString)
    println("# 4. Out-of-Core PC Score Calculation")
    N, M = nm(input)
    W = zeros(Float32, N, dim)
    progress = ProgressUnknown()
    open(input, "r") do file
        stream = ZstdDecompressorStream(file)
        tmpN = zeros(UInt32, 1)
        tmpM = zeros(UInt32, 1)
        read!(stream, tmpN)
        read!(stream, tmpM)
        n = 1
        ########################################
        # CSV / Dense Matrix
        ########################################
        if mode == "dense"
            X_chunk = zeros(UInt32, chunksize, M)
            buffer = zeros(UInt32, chunksize * M)
            while n <= N
                batch_size = min(chunksize, N - n + 1)
                read!(stream, view(buffer, 1:batch_size * M))
                X_chunk[1:batch_size, :] .= permutedims(reshape(Float32.(buffer[1:batch_size * M]), Int(M), batch_size))
                if scale == "raw"
                    W[n:n+batch_size-1, :] .= X_chunk[1:batch_size, :] * V
                else
                    normX_chunk = normalize_X_chunk(X_chunk[1:batch_size, :], scale, pseudocount)
                    W[n:n+batch_size-1, :] .= normX_chunk * V
                end
                next!(progress)
                n += batch_size
            end
        end
        ########################################
        # MM / Sparse Matrix
        ########################################
        if mode == "sparse_mm"
            overflow_buf = UInt32[]
            while n <= N
                batch_size = min(chunksize, N - n + 1)
                max_size = (batch_size + 1) * M
                rows = zeros(UInt32, max_size)
                cols = zeros(UInt32, max_size)
                vals = zeros(UInt32, max_size)
                count = 0
                ############### Overflow buffer ###############
                if !isempty(overflow_buf)
                    count += 1
                    rows[count] = overflow_buf[1] - n + 1
                    cols[count] = overflow_buf[2]
                    vals[count] = overflow_buf[3]
                    empty!(overflow_buf)
                end
                ###############################################
                while !eof(stream)
                    buf = zeros(UInt32, 3)
                    read!(stream, buf)
                    row, col, val = buf[1], buf[2], buf[3]
                    if n ≤ row < n + batch_size
                        count += 1
                        rows[count] = row - n + 1
                        cols[count] = col
                        vals[count] = val
                    else
                        overflow_buf = buf
                        break
                    end
                end
                resize!(rows, count)
                resize!(cols, count)
                resize!(vals, count)
                if count > 0
                    X_chunk = sparse(rows, cols, vals, batch_size, M)
                else
                    X_chunk = spzeros(batch_size, M)
                end
                if scale == "raw"
                    W[n:n+batch_size-1, :] .= X_chunk * V
                else
                    normX_chunk = normalize_X_chunk(X_chunk, scale, pseudocount)
                    W[n:n+batch_size-1, :] .= normX_chunk * V
                end
                next!(progress)
                n += batch_size
            end
        end
        ########################################
        # Bin COO / Sparse Matrix
        ########################################
        if mode == "sparse_bincoo"
            overflow_buf = UInt32[]
            while n <= N
                batch_size = min(chunksize, N - n + 1)
                max_size = (batch_size + 1) * M
                rows = zeros(UInt32, max_size)
                cols = zeros(UInt32, max_size)
                count = 0
                ############### Overflow buffer ###############
                if !isempty(overflow_buf)
                    count += 1
                    rows[count] = overflow_buf[1] - n + 1
                    cols[count] = overflow_buf[2]
                    empty!(overflow_buf)
                end
                ###############################################
                while !eof(stream)
                    buf = zeros(UInt32, 2)
                    read!(stream, buf)
                    row, col = buf[1], buf[2]
                    if n ≤ row < n + batch_size
                        count += 1
                        rows[count] = row - n + 1
                        cols[count] = col
                    else
                        overflow_buf = buf
                        break
                    end
                end
                resize!(rows, count)
                resize!(cols, count)
                if count > 0
                    X_chunk = sparse(rows, cols, 1, batch_size, M)
                else
                    X_chunk = spzeros(batch_size, M)
                end
                if scale == "raw"
                    W[n:n+batch_size-1, :] .= X_chunk * V
                else
                    normX_chunk = normalize_X_chunk(X_chunk, scale, pseudocount)
                    W[n:n+batch_size-1, :] .= normX_chunk * V
                end
                next!(progress)
                n += batch_size
            end
        end
    end
    finish!(progress)

    # Delayed Centering Correction
    println("# 5. Delayed Centering Correction")
    correction = (colmeanvec' * V)
    W .-= repeat(correction, N, 1)

    # Normalize
    println("# 6. Normalize W and Calculate Eigenvalues")
    σ = Float32[norm(W[:, x]) for x = 1:dim]
    for n = 1:dim
        if σ[n] > 0f0
            W[:, n] ./= σ[n]
        else
            W[:, n] .= 0f0
        end
    end

    λ = σ .* σ ./ N

    # Sort by descending eigenvalue
    idx = sortperm(λ, rev=true)
    W .= W[:, idx]
    λ .= λ[idx]
    V .= V[:, idx]

    # Score Calculation
    Scores = zeros(Float32, N, dim)
    for n = 1:dim
        Scores[:, n] .= λ[n] .* W[:, n]
    end

    return V, λ, W, Scores
end
