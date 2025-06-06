# Types
struct SGD end
struct OJA end
struct CCIPCA end
struct GD end
struct RSGD end
struct SVRG end
struct RSVRG end
struct ALGORITHM971 end
struct HALKO end
struct ORTHITER end
struct RBKITER end
struct SINGLEPASS end
struct SINGLEPASS2 end
struct ARNOLDI end
struct LANCZOS end
struct TENXPCA end
struct SPARSE_RSVD end
struct EXACT_OOC_PCA end

struct ROBBINS_MONRO end
struct MOMENTUM end
struct NAG end
struct ADAGRAD end

# Total Variance for tenxpca and sparse_rsvd
function tv(TotalVar::Number, X::AbstractArray)
    l = size(X)[2]
    progress = Progress(l)
    for i in 1:l
        TotalVar = TotalVar + X[:, i]' * X[:, i]
        # Progress Bar
        next!(progress)
    end
    TotalVar
end

# Column-wise statistics for sumr and exact_ooc_pca
function nocounts(binfile::AbstractString, mode::AbstractString, chunksize::Int)
    N, M = nm(binfile)
    tmpN = zeros(UInt32, 1)
    tmpM = zeros(UInt32, 1)
    nc = zeros(UInt32, M)
    progress = Progress(N)
    open(binfile, "r") do file
        stream = ZstdDecompressorStream(file)
        read!(stream, tmpN)
        read!(stream, tmpM)
        ########################################
        # CSV / Dense Matrix
        ########################################
        if mode == "dense"
            # CSV / Dense Matrix
            x = zeros(UInt32, M)
            for n = 1:N
                read!(stream, x)
                nc .+= x
                next!(progress)
            end
        end
        ########################################
        # MM / Sparse Matrix
        ########################################
        if mode == "sparse_mm"
            # MM / Sparse Matrix
            while !eof(stream)
                buf = zeros(UInt32, 3)  # (row, col, val)
                read!(stream, buf)
                _, col, val = buf[1], buf[2], buf[3]
                if 1 ≤ col ≤ M
                    nc[col] += val
                else
                    println("Warning: Out-of-bounds column index ", col)
                end
            end
        end
        ########################################
        # Binary COO / Sparse Matrix
        ########################################
        if mode == "sparse_bincoo"
            buf = zeros(UInt32, 2)
            while !eof(stream)
                read!(stream, buf)
                _, col = buf
                if 1 ≤ col ≤ M
                    nc[col] += 1
                else
                    println("Warning: Out-of-bounds column index ", col)
                end
            end
        end
        close(stream)
    end
    return nc
end

# Row / Column
function tenxnm(tenxfile::AbstractString, group::AbstractString)
    N, M = h5open(tenxfile, "r") do file
        read(file[group*"/shape"])
    end
    return N[], M[]
end

# Index Pointer
function indptr(tenxfile::AbstractString, group::AbstractString)
    h5open(tenxfile, "r") do file
        read(file[group*"/indptr"]) .+ 1
    end
end

function loadchromium(tenxfile, group, idp, startp, endp, M, perm)
    # new objects
    newidp = ones(Int64, 1)
    newindices = zeros(Int64, 0)
    newdata = zeros(Int64, 0)
    file = h5open(tenxfile, "r")
    # Each column
    l = length(idp) - 1
    grp = file[group]
    progress = Progress(l)
    for i = 1:l
        lo = idp[i]
        hi = idp[i+1]
        # Extract
        extindices = grp["indices"][lo:hi-1] .+ 1
        extdata = grp["data"][lo:hi-1]
        orderIndices = sortperm(extindices)
        extindices = extindices[orderIndices]
        extdata = extdata[orderIndices]
        # e.g. 325
        lower = searchsortedfirst(extindices, startp)
        # e.g. 663
        upper = searchsortedlast(extindices, endp)
        # update
        append!(newindices, extindices[lower:upper])
        append!(newdata, extdata[lower:upper])
        append!(newidp, length(newdata) + 1)
        # Progress Bar
        next!(progress)
    end
    close(file)
    @assert minimum(newindices) >= startp
    @assert maximum(newindices) <= endp
    newindices = newindices .- (startp - 1)
    if perm
        counts = SparseMatrixCSC(endp - startp + 1, M, newidp, newindices, newdata[randperm(length(newdata))])
    else
        counts = SparseMatrixCSC(endp - startp + 1, M, newidp, newindices, newdata)
    end
    return counts
end

function sparseLog10(X::SparseMatrixCSC)
    m = X.m
    n = X.n
    colptr = X.colptr
    rowval = X.rowval
    nzval = log10.(X.nzval .+ 1)
    return SparseMatrixCSC(m, n, colptr, rowval, nzval)
end

# Check NaN value (only GD)
function checkNaN(W::AbstractArray, pca::GD)
    if any(isnan, W)
        error("NaN values are generated. Select other stepsize")
    end
end

# Check NaN value (other PCA)
function checkNaN(N::Number, s::Number, n::Number, W::AbstractArray, evalfreq::Number, pca::Union{OJA,SGD,CCIPCA,RSGD,SVRG,RSVRG})
    if mod((N * (s - 1) + n), evalfreq) == 0
        if any(isnan, W)
            error("NaN values are generated. Select other stepsize")
        end
    end
end

# Output the result of PCA
function output(outdir::AbstractString, out::Tuple, expvar::Number)
    write_csv(joinpath(outdir, "Eigen_vectors.csv"), out[1])
    write_csv(joinpath(outdir, "Eigen_values.csv"), out[2])
    write_csv(joinpath(outdir, "Loadings.csv"), out[3])
    write_csv(joinpath(outdir, "Scores.csv"), out[4])
    write_csv(joinpath(outdir, "ExpVar.csv"), out[5])
    if out[5] > expvar && out[6] == 1
        touch(joinpath(outdir, "Converged"))
    end
end

write_csv(filename::AbstractString, data) = writedlm(filename, data, ',')
read_csv(filename::AbstractString) = readdlm(filename, ',')
read_csv(filename::AbstractString, ::Type{T}) where {T} = readdlm(filename, ',', T)

# Parse command line options (EXACT_OOC_PCA)
function parse_commandline(pca::EXACT_OOC_PCA)
    s = ArgParseSettings()

    @add_arg_table! s begin
        "--input"
        help = "Julia Binary file generated by `OnlinePCA.csv2bin` or `OnlinPCA.mm2bin` function."
        arg_type = AbstractString
        required = true
        "--outdir", "-o"
        help = "The directory specified the directory you want to save the result."
        arg_type = AbstractString
        default = "."
        required = false
        "--scale"
        help = "{ftt,log,raw}-scaling of the value."
        arg_type = AbstractString
        default = "ftt"
        "--pseudocount", "-p"
        help = "The number specified to avoid NaN by log10(0) and used when `Feature_LogMeans.csv` <log10(mean+pseudocount) value of each feature> is generated."
        arg_type = Union{Number,AbstractString}
        default = 1.0f0
        "--dim", "-d"
        help = "The number of dimension of PCA."
        arg_type = Union{Number,AbstractString}
        default = 3
        "--chunksize", "-c"
        help = "The number of rows reading at once (e.g. 1)."
        arg_type = Union{Number,AbstractString}
        default = 1
        "--mode", "-m"
        help = "'dense', 'sparse_mm', or 'sparse_bincoo' can be specified."
        arg_type = AbstractString
        default = "dense"
    end

    return parse_args(s)
end

# Parse command line options (SPARSE_RSVD)
function parse_commandline(pca::SPARSE_RSVD)
    s = ArgParseSettings()

    @add_arg_table! s begin
        "--input"
        help = "Julia Binary file generated by `OnlinePCA.mm2bin` function."
        arg_type = AbstractString
        required = true
        "--outdir", "-o"
        help = "The directory specified the directory you want to save the result."
        arg_type = AbstractString
        default = "."
        required = false
        "--scale"
        help = "{ftt,log,raw}-scaling of the value."
        arg_type = AbstractString
        default = "ftt"
        "--rowmeanlist", "-m"
        help = "The mean of each row of matrix. The CSV file is generated by `OnlinePCA.sumr` functions."
        arg_type = AbstractString
        default = ""
        required = false
        "--rowvarlist", "-v"
        help = "The variance of each row of matrix. The CSV file is generated by `OnlinePCA.sumr` functions."
        arg_type = AbstractString
        default = ""
        required = false
        "--colsumlist"
        help = "The sum of counts of each columns of matrix. The CSV file is generated by `OnlinePCA.sumr` functions."
        arg_type = AbstractString
        default = ""
        required = false
        "--dim", "-d"
        help = "The number of dimension of PCA."
        arg_type = Union{Number,AbstractString}
        default = 3
        "--noversamples"
        help = "The number of over-sampling."
        arg_type = Union{Number,AbstractString}
        default = 5
        "--niter"
        help = "The number of power interation."
        arg_type = Union{Number,AbstractString}
        default = 3
        "--chunksize"
        help = "The number of rows reading at once (e.g. 1)."
        arg_type = Union{Number,AbstractString}
        default = 1
        "--initW"
        help = "The CSV file saving the initial values of eigenvectors."
        arg_type = Union{Nothing,AbstractString}
        default = nothing
        "--initV"
        help = "The CSV file saving the initial values of loadings."
        arg_type = Union{Nothing,AbstractString}
        default = nothing
        "--logdir", "-l"
        help = "The directory where intermediate files are saved, in every evalfreq (e.g. 1) iteration."
        arg_type = Union{Nothing,AbstractString}
        default = nothing
        "--perm"
        help = "Whether the data matrix is shuffled at random"
        arg_type = Union{Bool,AbstractString}
        default = false
        "--cper"
        help = "Count per X (e.g. CPM: Count per million <1e+6>)"
        arg_type = Union{Number,AbstractString}
        default = 1.0f0
    end

    return parse_args(s)
end

# Parse command line options (TENXPCA)
function parse_commandline(pca::TENXPCA)
    s = ArgParseSettings()

    @add_arg_table! s begin
        "--tenxfile"
        help = "10XHDF5 file"
        arg_type = AbstractString
        required = true
        "--outdir", "-o"
        help = "The directory specified the directory you want to save the result."
        arg_type = AbstractString
        default = "."
        required = false
        "--scale"
        help = "{sqrt,log,raw}-scaling of the value."
        arg_type = AbstractString
        default = "sqrt"
        "--rowmeanlist", "-m"
        help = "The mean of each row of matrix. The CSV file is generated by `OnlinePCA.sumr` functions."
        arg_type = AbstractString
        default = ""
        required = false
        "--rowvarlist", "-v"
        help = "The variance of each row of matrix. The CSV file is generated by `OnlinePCA.sumr` functions."
        arg_type = AbstractString
        default = ""
        required = false
        "--colsumlist"
        help = "The sum of counts of each columns of matrix. The CSV file is generated by `OnlinePCA.sumr` functions."
        arg_type = AbstractString
        default = ""
        required = false
        "--dim", "-d"
        help = "The number of dimension of PCA."
        arg_type = Union{Number,AbstractString}
        default = 3
        "--noversamples"
        help = "The number of over-sampling."
        arg_type = Union{Number,AbstractString}
        default = 5
        "--niter"
        help = "The number of power interation."
        arg_type = Union{Number,AbstractString}
        default = 3
        "--chunksize"
        help = "The number of rows reading at once (e.g. 1)."
        arg_type = Union{Number,AbstractString}
        default = 1
        "--group"
        help = "The group name of 10XHDF5 (e.g. mm10)."
        arg_type = AbstractString
        required = true
        "--initW"
        help = "The CSV file saving the initial values of eigenvectors."
        arg_type = Union{Nothing,AbstractString}
        default = nothing
        "--initV"
        help = "The CSV file saving the initial values of loadings."
        arg_type = Union{Nothing,AbstractString}
        default = nothing
        "--logdir", "-l"
        help = "The directory where intermediate files are saved, in every evalfreq (e.g. 1) iteration."
        arg_type = Union{Nothing,AbstractString}
        default = nothing
        "--perm"
        help = "Whether the data matrix is shuffled at random"
        arg_type = Union{Bool,AbstractString}
        default = false
        "--cper"
        help = "Count per X (e.g. CPM: Count per million <1e+6>)"
        arg_type = Union{Number,AbstractString}
        default = 1.0f0
    end

    return parse_args(s)
end

# Parse command line options (ALGORITHM971, HALKO, SINGLEPASS, SINGLEPASS2)
function parse_commandline(pca::Union{ALGORITHM971,HALKO,SINGLEPASS,SINGLEPASS2})
    s = ArgParseSettings()

    @add_arg_table! s begin
        "--input", "-i"
        help = "Julia Binary file generated by `OnlinePCA.csv2bin` function."
        arg_type = AbstractString
        required = true
        "--outdir", "-o"
        help = "The directory specified the directory you want to save the result."
        arg_type = AbstractString
        default = "."
        required = false
        "--scale"
        help = "{log,ftt,raw}-scaling of the value."
        arg_type = AbstractString
        default = "ftt"
        "--pseudocount", "-p"
        help = "The number specified to avoid NaN by log10(0) and used when `Feature_LogMeans.csv` <log10(mean+pseudocount) value of each feature> is generated."
        arg_type = Union{Number,AbstractString}
        default = 1.0f0
        "--rowmeanlist", "-m"
        help = "The mean of each row of matrix. The CSV file is generated by `OnlinePCA.sumr` functions."
        arg_type = AbstractString
        default = ""
        required = false
        "--rowvarlist", "-v"
        help = "The variance of each row of matrix. The CSV file is generated by `OnlinePCA.sumr` functions."
        arg_type = AbstractString
        default = ""
        required = false
        "--colsumlist"
        help = "The sum of counts of each columns of matrix. The CSV file is generated by `OnlinePCA.sumr` functions."
        arg_type = AbstractString
        default = ""
        required = false
        "--dim", "-d"
        help = "The number of dimension of PCA."
        arg_type = Union{Number,AbstractString}
        default = 3
        "--noversamples"
        help = "The number of over-sampling."
        arg_type = Union{Number,AbstractString}
        default = 5
        "--niter"
        help = "The number of power interation."
        arg_type = Union{Number,AbstractString}
        default = 3
        "--initW"
        help = "The CSV file saving the initial values of eigenvectors."
        arg_type = Union{Nothing,AbstractString}
        default = nothing
        "--initV"
        help = "The CSV file saving the initial values of loadings."
        arg_type = Union{Nothing,AbstractString}
        default = nothing
        "--logdir", "-l"
        help = "The directory where intermediate files are saved, in every evalfreq (e.g. 1) iteration."
        arg_type = Union{Nothing,AbstractString}
        default = nothing
        "--perm"
        help = "Whether the data matrix is shuffled at random"
        arg_type = Union{Bool,AbstractString}
        default = false
        "--cper"
        help = "Count per X (e.g. CPM: Count per million <1e+6>)"
        arg_type = Union{Number,AbstractString}
        default = 1.0f0
    end

    return parse_args(s)
end

# Parse command line options (only ARNOLDI,LANCZOS)
function parse_commandline(pca::Union{ARNOLDI,LANCZOS})
    s = ArgParseSettings()

    @add_arg_table! s begin
        "--input", "-i"
        help = "Julia Binary file generated by `OnlinePCA.csv2bin` function."
        arg_type = AbstractString
        required = true
        "--outdir", "-o"
        help = "The directory specified the directory you want to save the result."
        arg_type = AbstractString
        default = "."
        required = false
        "--scale"
        help = "{log,ftt,raw}-scaling of the value."
        arg_type = AbstractString
        default = "ftt"
        "--pseudocount", "-p"
        help = "The number specified to avoid NaN by log10(0) and used when `Feature_LogMeans.csv` <log10(mean+pseudocount) value of each feature> is generated."
        arg_type = Union{Number,AbstractString}
        default = 1.0f0
        "--rowmeanlist", "-m"
        help = "The mean of each row of matrix. The CSV file is generated by `OnlinePCA.sumr` functions."
        arg_type = AbstractString
        default = ""
        required = false
        "--rowvarlist", "-v"
        help = "The variance of each row of matrix. The CSV file is generated by `OnlinePCA.sumr` functions."
        arg_type = AbstractString
        default = ""
        required = false
        "--colsumlist"
        help = "The sum of counts of each columns of matrix. The CSV file is generated by `OnlinePCA.sumr` functions."
        arg_type = AbstractString
        default = ""
        required = false
        "--dim", "-d"
        help = "The number of dimension of PCA."
        arg_type = Union{Number,AbstractString}
        default = 3
        "--numepoch", "-e"
        help = "The number of epoch."
        arg_type = Union{Number,AbstractString}
        default = 5
        "--perm"
        help = "Whether the data matrix is shuffled at random"
        arg_type = Union{Bool,AbstractString}
        default = false
        "--expvar"
        help = "The calculation is determined as converged when captured variance is larger than this value (0 - 1)"
        arg_type = Union{Number,AbstractString}
        default = 0.1f0
        "--cper"
        help = "Count per X (e.g. CPM: Count per million <1e+6>)"
        arg_type = Union{Number,AbstractString}
        default = 1.0f0
    end

    return parse_args(s)
end

# Parse command line options (only ORTHITER, RBKITER)
function parse_commandline(pca::Union{ORTHITER,RBKITER})
    s = ArgParseSettings()

    @add_arg_table! s begin
        "--input", "-i"
        help = "Julia Binary file generated by `OnlinePCA.csv2bin` function."
        arg_type = AbstractString
        required = true
        "--outdir", "-o"
        help = "The directory specified the directory you want to save the result."
        arg_type = AbstractString
        default = "."
        required = false
        "--scale"
        help = "{log,ftt,raw}-scaling of the value."
        arg_type = AbstractString
        default = "ftt"
        "--pseudocount", "-p"
        help = "The number specified to avoid NaN by log10(0) and used when `Feature_LogMeans.csv` <log10(mean+pseudocount) value of each feature> is generated."
        arg_type = Union{Number,AbstractString}
        default = 1.0f0
        "--rowmeanlist", "-m"
        help = "The mean of each row of matrix. The CSV file is generated by `OnlinePCA.sumr` functions."
        arg_type = AbstractString
        default = ""
        required = false
        "--rowvarlist", "-v"
        help = "The variance of each row of matrix. The CSV file is generated by `OnlinePCA.sumr` functions."
        arg_type = AbstractString
        default = ""
        required = false
        "--colsumlist"
        help = "The sum of counts of each columns of matrix. The CSV file is generated by `OnlinePCA.sumr` functions."
        arg_type = AbstractString
        default = ""
        required = false
        "--dim", "-d"
        help = "The number of dimension of PCA."
        arg_type = Union{Number,AbstractString}
        default = 3
        "--numepoch", "-e"
        help = "The number of epoch."
        arg_type = Union{Number,AbstractString}
        default = 5
        "--lower"
        help = "Stopping Criteria (When the relative change of error is below this value, the calculation is terminated)"
        arg_type = Union{Number,AbstractString}
        default = 0
        "--upper"
        help = "Stopping Criteria (When the relative change of error is above this value, the calculation is terminated)"
        arg_type = Union{Number,AbstractString}
        default = 1.0f+38
        "--initW"
        help = "The CSV file saving the initial values of eigenvectors."
        arg_type = Union{Nothing,AbstractString}
        default = nothing
        "--initV"
        help = "The CSV file saving the initial values of loadings."
        arg_type = Union{Nothing,AbstractString}
        default = nothing
        "--logdir", "-l"
        help = "The directory where intermediate files are saved, in every evalfreq (e.g. 1) iteration."
        arg_type = Union{Nothing,AbstractString}
        default = nothing
        "--perm"
        help = "Whether the data matrix is shuffled at random"
        arg_type = Union{Bool,AbstractString}
        default = false
        "--expvar"
        help = "The calculation is determined as converged when captured variance is larger than this value (0 - 1)"
        arg_type = Union{Number,AbstractString}
        default = 0.1f0
        "--cper"
        help = "Count per X (e.g. CPM: Count per million <1e+6>)"
        arg_type = Union{Number,AbstractString}
        default = 1.0f0
    end

    return parse_args(s)
end

# Parse command line options (only CCIPCA)
function parse_commandline(pca::CCIPCA)
    s = ArgParseSettings()

    @add_arg_table! s begin
        "--input", "-i"
        help = "Julia Binary file generated by `OnlinePCA.csv2bin` function."
        arg_type = AbstractString
        required = true
        "--outdir", "-o"
        help = "The directory specified the directory you want to save the result."
        arg_type = AbstractString
        default = "."
        required = false
        "--scale"
        help = "{log,ftt,raw}-scaling of the value."
        arg_type = AbstractString
        default = "ftt"
        "--pseudocount", "-p"
        help = "The number specified to avoid NaN by log10(0) and used when `Feature_LogMeans.csv` <log10(mean+pseudocount) value of each feature> is generated."
        arg_type = Union{Number,AbstractString}
        default = 1.0f0
        "--rowmeanlist", "-m"
        help = "The mean of each row of matrix. The CSV file is generated by `OnlinePCA.sumr` functions."
        arg_type = AbstractString
        default = ""
        required = false
        "--rowvarlist", "-v"
        help = "The variance of each row of matrix. The CSV file is generated by `OnlinePCA.sumr` functions."
        arg_type = AbstractString
        default = ""
        required = false
        "--colsumlist"
        help = "The sum of counts of each columns of matrix. The CSV file is generated by `OnlinePCA.sumr` functions."
        arg_type = AbstractString
        default = ""
        required = false
        "--dim", "-d"
        help = "The number of dimension of PCA."
        arg_type = Union{Number,AbstractString}
        default = 3
        "--stepsize", "-s"
        help = "The parameter used in every iteration."
        arg_type = Union{Number,AbstractString}
        default = 1.0f3
        "--numepoch", "-e"
        help = "The number of epoch."
        arg_type = Union{Number,AbstractString}
        default = 5
        "--lower"
        help = "Stopping Criteria (When the relative change of error is below this value, the calculation is terminated)"
        arg_type = Union{Number,AbstractString}
        default = 0
        "--upper"
        help = "Stopping Criteria (When the relative change of error is above this value, the calculation is terminated)"
        arg_type = Union{Number,AbstractString}
        default = 1.0f+38
        "--evalfreq"
        help = "Evaluation Frequency of Reconstruction Error"
        arg_type = Union{Number,AbstractString}
        default = 5000
        "--offsetStoch"
        help = "Off set value for avoding overflow when calculating stochastic gradient"
        arg_type = Union{Number,AbstractString}
        default = 1.0f-15
        "--initW"
        help = "The CSV file saving the initial values of eigenvectors."
        arg_type = Union{Nothing,AbstractString}
        default = nothing
        "--initV"
        help = "The CSV file saving the initial values of loadings."
        arg_type = Union{Nothing,AbstractString}
        default = nothing
        "--logdir", "-l"
        help = "The directory where intermediate files are saved, in every evalfreq (e.g. 1) iteration."
        arg_type = Union{Nothing,AbstractString}
        default = nothing
        "--perm"
        help = "Whether the data matrix is shuffled at random"
        arg_type = Union{Bool,AbstractString}
        default = false
        "--expvar"
        help = "The calculation is determined as converged when captured variance is larger than this value (0 - 1)"
        arg_type = Union{Number,AbstractString}
        default = 0.1f0
        "--cper"
        help = "Count per X (e.g. CPM: Count per million <1e+6>)"
        arg_type = Union{Number,AbstractString}
        default = 1.0f0
    end

    return parse_args(s)
end

# Parse command line options (SGD、RSGD、SVRG、RSVRG)
function parse_commandline(pca::Union{SGD,RSGD,SVRG,RSVRG})
    s = ArgParseSettings()

    @add_arg_table! s begin
        "--input", "-i"
        help = "Julia Binary file generated by `OnlinePCA.csv2bin` function."
        arg_type = AbstractString
        required = true
        "--outdir", "-o"
        help = "The directory specified the directory you want to save the result."
        arg_type = AbstractString
        default = "."
        required = false
        "--scale"
        help = "{log,ftt,raw}-scaling of the value."
        arg_type = AbstractString
        default = "ftt"
        "--pseudocount", "-p"
        help = "The number specified to avoid NaN by log10(0) and used when `Feature_LogMeans.csv` <log10(mean+pseudocount) value of each feature> is generated."
        arg_type = Union{Number,AbstractString}
        default = 1.0f0
        "--rowmeanlist", "-m"
        help = "The mean of each row of matrix. The CSV file is generated by `OnlinePCA.sumr` functions."
        arg_type = AbstractString
        default = ""
        required = false
        "--rowvarlist", "-v"
        help = "The variance of each row of matrix. The CSV file is generated by `OnlinePCA.sumr` functions."
        arg_type = AbstractString
        default = ""
        required = false
        "--colsumlist"
        help = "The sum of counts of each columns of matrix. The CSV file is generated by `OnlinePCA.sumr` functions."
        arg_type = AbstractString
        default = ""
        required = false
        "--dim", "-d"
        help = "The number of dimension of PCA."
        arg_type = Union{Number,AbstractString}
        default = 3
        "--stepsize", "-s"
        help = "The parameter used in every iteration."
        arg_type = Union{Number,AbstractString}
        default = 1.0f3
        "--numbatch", "-b"
        help = "The number of batch size."
        arg_type = Union{Number,AbstractString}
        default = 100
        "--numepoch", "-e"
        help = "The number of epoch."
        arg_type = Union{Number,AbstractString}
        default = 5
        "--scheduling"
        help = "Learning parameter scheduling. `robbins-monro`, `momentum`, `nag`, and `adagrad` are available."
        arg_type = AbstractString
        default = "robbins-monro"
        "-g"
        help = "The parameter that is used when scheduling is specified as nag."
        arg_type = Union{Number,AbstractString}
        default = 0.9f0
        "--epsilon"
        help = "The parameter that is used when scheduling is specified as adagrad."
        arg_type = Union{Number,AbstractString}
        default = 1.0f-8
        "--lower"
        help = "Stopping Criteria (When the relative change of error is below this value, the calculation is terminated)"
        arg_type = Union{Number,AbstractString}
        default = 0
        "--upper"
        help = "Stopping Criteria (When the relative change of error is above this value, the calculation is terminated)"
        arg_type = Union{Number,AbstractString}
        default = 1.0f+38
        "--evalfreq"
        help = "Evaluation Frequency of Reconstruction Error"
        arg_type = Union{Number,AbstractString}
        default = 5000
        "--offsetFull"
        help = "Off set value for avoding overflow when calculating full gradient"
        arg_type = Union{Number,AbstractString}
        default = 1.0f-20
        "--offsetStoch"
        help = "Off set value for avoding overflow when calculating stochastic gradient"
        arg_type = Union{Number,AbstractString}
        default = 1.0f-6
        "--initW"
        help = "The CSV file saving the initial values of eigenvectors."
        arg_type = Union{Nothing,AbstractString}
        default = nothing
        "--initV"
        help = "The CSV file saving the initial values of loadings."
        arg_type = Union{Nothing,AbstractString}
        default = nothing
        "--logdir", "-l"
        help = "The directory where intermediate files are saved, in every evalfreq (e.g. 1) iteration."
        arg_type = Union{Nothing,AbstractString}
        default = nothing
        "--perm"
        help = "Whether the data matrix is shuffled at random"
        arg_type = Union{Bool,AbstractString}
        default = false
        "--expvar"
        help = "The calculation is determined as converged when captured variance is larger than this value (0 - 1)"
        arg_type = Union{Number,AbstractString}
        default = 0.1f0
        "--cper"
        help = "Count per X (e.g. CPM: Count per million <1e+6>)"
        arg_type = Union{Number,AbstractString}
        default = 1.0f0
    end

    return parse_args(s)
end

# Parse command line options (other PCA)
function parse_commandline(pca::Union{OJA,GD})
    s = ArgParseSettings()

    @add_arg_table! s begin
        "--input", "-i"
        help = "Julia Binary file generated by `OnlinePCA.csv2bin` function."
        arg_type = AbstractString
        required = true
        "--outdir", "-o"
        help = "The directory specified the directory you want to save the result."
        arg_type = AbstractString
        default = "."
        required = false
        "--scale"
        help = "{log,ftt,raw}-scaling of the value."
        arg_type = AbstractString
        default = "ftt"
        "--pseudocount", "-p"
        help = "The number specified to avoid NaN by log10(0) and used when `Feature_LogMeans.csv` <log10(mean+pseudocount) value of each feature> is generated."
        arg_type = Union{Number,AbstractString}
        default = 1.0f0
        "--rowmeanlist", "-m"
        help = "The mean of each row of matrix. The CSV file is generated by `OnlinePCA.sumr` functions."
        arg_type = AbstractString
        default = ""
        required = false
        "--rowvarlist", "-v"
        help = "The variance of each row of matrix. The CSV file is generated by `OnlinePCA.sumr` functions."
        arg_type = AbstractString
        default = ""
        required = false
        "--colsumlist"
        help = "The sum of counts of each columns of matrix. The CSV file is generated by `OnlinePCA.sumr` functions."
        arg_type = AbstractString
        default = ""
        required = false
        "--dim", "-d"
        help = "The number of dimension of PCA."
        arg_type = Union{Number,AbstractString}
        default = 3
        "--stepsize", "-s"
        help = "The parameter used in every iteration."
        arg_type = Union{Number,AbstractString}
        default = 1.0f3
        "--numepoch", "-e"
        help = "The number of epoch."
        arg_type = Union{Number,AbstractString}
        default = 5
        "--scheduling"
        help = "Learning parameter scheduling. `robbins-monro`, `momentum`, `nag`, and `adagrad` are available."
        arg_type = AbstractString
        default = "robbins-monro"
        "-g"
        help = "The parameter that is used when scheduling is specified as nag."
        arg_type = Union{Number,AbstractString}
        default = 0.9f0
        "--epsilon"
        help = "The parameter that is used when scheduling is specified as adagrad."
        arg_type = Union{Number,AbstractString}
        default = 1.0f-8
        "--lower"
        help = "Stopping Criteria (When the relative change of error is below this value, the calculation is terminated)"
        arg_type = Union{Number,AbstractString}
        default = 0
        "--upper"
        help = "Stopping Criteria (When the relative change of error is above this value, the calculation is terminated)"
        arg_type = Union{Number,AbstractString}
        default = 1.0f+38
        "--evalfreq"
        help = "Evaluation Frequency of Reconstruction Error"
        arg_type = Union{Number,AbstractString}
        default = 5000
        "--offsetFull"
        help = "Off set value for avoding overflow when calculating full gradient"
        arg_type = Union{Number,AbstractString}
        default = 1.0f-20
        "--offsetStoch"
        help = "Off set value for avoding overflow when calculating stochastic gradient"
        arg_type = Union{Number,AbstractString}
        default = 1.0f-6
        "--initW"
        help = "The CSV file saving the initial values of eigenvectors."
        arg_type = Union{Nothing,AbstractString}
        default = nothing
        "--initV"
        help = "The CSV file saving the initial values of loadings."
        arg_type = Union{Nothing,AbstractString}
        default = nothing
        "--logdir", "-l"
        help = "The directory where intermediate files are saved, in every evalfreq (e.g. 1) iteration."
        arg_type = Union{Nothing,AbstractString}
        default = nothing
        "--perm"
        help = "Whether the data matrix is shuffled at random"
        arg_type = Union{Bool,AbstractString}
        default = false
        "--expvar"
        help = "The calculation is determined as converged when captured variance is larger than this value (0 - 1)"
        arg_type = Union{Number,AbstractString}
        default = 0.1f0
        "--cper"
        help = "Count per X (e.g. CPM: Count per million <1e+6>)"
        arg_type = Union{Number,AbstractString}
        default = 1.0f0
    end

    return parse_args(s)
end

# Return N, M
function nm(input::AbstractString)
    N = zeros(UInt32, 1)
    M = zeros(UInt32, 1)
    open(input) do file
        stream = ZstdDecompressorStream(file)
        read!(stream, N)
        read!(stream, M)
        close(stream)
    end
    @assert isa(N[1], UInt32)
    @assert isa(M[1], UInt32)
    return N[], M[]
end

# Initialization (ALGORITHM971, HALKO, SINGLEPASS, SINGLEPASS2)
function init(input::AbstractString, pseudocount::Number, dim::Number, rowmeanlist::AbstractString, rowvarlist::AbstractString, colsumlist::AbstractString, initW::Union{Nothing,AbstractString}, initV::Union{Nothing,AbstractString}, logdir::Union{Nothing,AbstractString}, pca::Union{ALGORITHM971,HALKO,SINGLEPASS,SINGLEPASS2}, cper::Number, scale::AbstractString="ftt")
    N, M = nm(input)
    tmpN = zeros(UInt32, 1)
    tmpM = zeros(UInt32, 1)
    pseudocount = Float32(pseudocount)
    # Eigen vectors
    # Eigen vectors
    if initW == nothing
        W = zeros(Float32, M, dim)
        for i = 1:dim
            W[i, i] = 1
        end
    end
    if typeof(initW) == String
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
    x = zeros(UInt32, M)
    rowmeanvec = zeros(Float32, N, 1)
    rowvarvec = zeros(Float32, N, 1)
    colsumvec = zeros(Float32, M, 1)
    if rowmeanlist != ""
        rowmeanvec = read_csv(rowmeanlist, Float32)
    end
    if rowvarlist != ""
        rowvarvec = read_csv(rowvarlist, Float32)
    end
    if colsumlist != ""
        colsumvec = read_csv(colsumlist, Float32)
    end
    # N, M, All Variance
    TotalVar = 0
    open(input) do file
        stream = ZstdDecompressorStream(file)
        read!(stream, tmpN)
        read!(stream, tmpM)
        for n = 1:N
            # Data Import
            read!(stream, x)
            normx = normalizex(x, n, stream, scale, pseudocount, rowmeanlist, rowmeanvec, rowvarlist, rowvarvec, colsumlist, colsumvec, cper)
            TotalVar = TotalVar + normx'normx
            # Creating W from V
            if typeof(initV) == String
                W = W .+ (V[n, :] * normx')'
            end
        end
        close(stream)
    end
    TotalVar = TotalVar / M
    # directory for log file
    if logdir isa String
        if (!isdir(logdir))
            mkdir(logdir)
        end
    end
    return pseudocount, W, D, rowmeanvec, rowvarvec, colsumvec, N, M, TotalVar
end

# Initialization (only ARNOLDI,LANCZOS)
function init(input::AbstractString, pseudocount::Number, dim::Number, rowmeanlist::AbstractString, rowvarlist::AbstractString, colsumlist::AbstractString, pca::Union{ARNOLDI,LANCZOS}, numepoch::Number, cper::Number, scale::AbstractString="ftt")
    N, M = nm(input)
    tmpN = zeros(UInt32, 1)
    tmpM = zeros(UInt32, 1)
    pseudocount = Float32(pseudocount)
    # Eigen vectors
    W = rand(Float32, M, numepoch + 1)
    # Normalization
    for i = 1:(numepoch+1)
        W[:, i] = W[:, i] / norm(W[:, i])
    end
    X = zeros(Float32, M, dim + 1) # Temporal Vector (Same length
    D = Diagonal(reverse(1:dim)) # Diagonaml Matrix
    x = zeros(UInt32, M)
    rowmeanvec = zeros(Float32, N, 1)
    rowvarvec = zeros(Float32, N, 1)
    colsumvec = zeros(Float32, M, 1)
    if rowmeanlist != ""
        rowmeanvec = read_csv(rowmeanlist, Float32)
    end
    if rowvarlist != ""
        rowvarvec = read_csv(rowvarlist, Float32)
    end
    if colsumlist != ""
        colsumvec = read_csv(colsumlist, Float32)
    end
    # N, M, All Variance
    TotalVar = 0
    open(input) do file
        stream = ZstdDecompressorStream(file)
        read!(stream, tmpN)
        read!(stream, tmpM)
        for n = 1:N
            # Data Import
            read!(stream, x)
            normx = normalizex(x, n, stream, scale, pseudocount, rowmeanlist, rowmeanvec, rowvarlist, rowvarvec, colsumlist, colsumvec, cper)
            TotalVar = TotalVar + normx'normx
        end
        close(stream)
    end
    TotalVar = TotalVar / M
    return pseudocount, W, X, D, rowmeanvec, rowvarvec, colsumvec, N, M, TotalVar
end

# Initialization (ORTHITER, RBKITER)
function init(input::AbstractString, pseudocount::Number, dim::Number, rowmeanlist::AbstractString, rowvarlist::AbstractString, colsumlist::AbstractString, initW::Union{Nothing,AbstractString}, initV::Union{Nothing,AbstractString}, logdir::Union{Nothing,AbstractString}, pca::Union{ORTHITER,RBKITER}, lower::Number, upper::Number, cper::Number, scale::AbstractString="ftt")
    N, M = nm(input)
    tmpN = zeros(UInt32, 1)
    tmpM = zeros(UInt32, 1)
    pseudocount = Float32(pseudocount)
    lower = Float32(lower)
    upper = Float32(upper)
    # Eigen vectors
    if initW == nothing
        W = rand(Float32, M, dim)
        # Normalization
        for i = 1:dim
            W[:, i] = W[:, i] / norm(W[:, i])
        end
    end
    if typeof(initW) == String
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
    X = zeros(Float32, M, dim + 1) # Temporal Vector (Same length
    D = Diagonal(reverse(1:dim)) # Diagonaml Matrix
    x = zeros(UInt32, M)
    rowmeanvec = zeros(Float32, N, 1)
    rowvarvec = zeros(Float32, N, 1)
    colsumvec = zeros(Float32, M, 1)
    if rowmeanlist != ""
        rowmeanvec = read_csv(rowmeanlist, Float32)
    end
    if rowvarlist != ""
        rowvarvec = read_csv(rowvarlist, Float32)
    end
    if colsumlist != ""
        colsumvec = read_csv(colsumlist, Float32)
    end
    # N, M, All Variance
    TotalVar = 0
    open(input) do file
        stream = ZstdDecompressorStream(file)
        read!(stream, tmpN)
        read!(stream, tmpM)
        for n = 1:N
            # Data Import
            read!(stream, x)
            normx = normalizex(x, n, stream, scale, pseudocount, rowmeanlist, rowmeanvec, rowvarlist, rowvarvec, colsumlist, colsumvec, cper)
            TotalVar = TotalVar + normx'normx
            # Creating W from V
            if typeof(initV) == String
                W = W .+ (V[n, :] * normx')'
            end
        end
        close(stream)
    end
    TotalVar = TotalVar / M
    # directory for log file
    if logdir isa String
        if (!isdir(logdir))
            mkdir(logdir)
        end
    end
    return pseudocount, W, X, D, rowmeanvec, rowvarvec, colsumvec, N, M, TotalVar, lower, upper
end

# Initialization (only CCIPCA)
function init(input::AbstractString, pseudocount::Number, stepsize::Number, dim::Number, rowmeanlist::AbstractString, rowvarlist::AbstractString, colsumlist::AbstractString, initW::Union{Nothing,AbstractString}, initV::Union{Nothing,AbstractString}, logdir::Union{Nothing,AbstractString}, pca::CCIPCA, lower::Number, upper::Number, evalfreq::Number, offsetStoch::Number, cper::Number, scale::AbstractString="ftt")
    N, M = nm(input)
    tmpN = zeros(UInt32, 1)
    tmpM = zeros(UInt32, 1)
    pseudocount = Float32(pseudocount)
    stepsize = Float32(stepsize)
    lower = Float32(lower)
    upper = Float32(upper)
    evalfreq = Int64(evalfreq)
    offsetStoch = Float32(offsetStoch)
    # Eigen vectors
    if initW == nothing
        W = zeros(Float32, M, dim)
        for i = 1:dim
            W[i, i] = 1
        end
    end
    if typeof(initW) == String
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
    X = zeros(Float32, M, dim + 1) # Temporal Vector (Same length
    D = Diagonal(reverse(1:dim)) # Diagonaml Matrix
    x = zeros(UInt32, M)
    rowmeanvec = zeros(Float32, N, 1)
    rowvarvec = zeros(Float32, N, 1)
    colsumvec = zeros(Float32, M, 1)
    if rowmeanlist != ""
        rowmeanvec = read_csv(rowmeanlist, Float32)
    end
    if rowvarlist != ""
        rowvarvec = read_csv(rowvarlist, Float32)
    end
    if colsumlist != ""
        colsumvec = read_csv(colsumlist, Float32)
    end
    # N, M, All Variance
    TotalVar = 0
    open(input) do file
        stream = ZstdDecompressorStream(file)
        read!(stream, tmpN)
        read!(stream, tmpM)
        for n = 1:N
            # Data Import
            read!(stream, x)
            normx = normalizex(x, n, stream, scale, pseudocount, rowmeanlist, rowmeanvec, rowvarlist, rowvarvec, colsumlist, colsumvec, cper)
            TotalVar = TotalVar + normx'normx
            # Creating W from V
            if typeof(initV) == String
                W = W .+ (V[n, :] * normx')'
            end
        end
        close(stream)
    end
    TotalVar = TotalVar / M
    # directory for log file
    if logdir isa String
        if (!isdir(logdir))
            mkdir(logdir)
        end
    end
    return pseudocount, stepsize, W, X, D, rowmeanvec, rowvarvec, colsumvec, N, M, TotalVar, lower, upper, evalfreq, offsetStoch
end

# Initialization (other PCA)
function init(input::AbstractString, pseudocount::Number, stepsize::Number, g::Number, epsilon::Number, dim::Number, rowmeanlist::AbstractString, rowvarlist::AbstractString, colsumlist::AbstractString, initW::Union{Nothing,AbstractString}, initV::Union{Nothing,AbstractString}, logdir::Union{Nothing,AbstractString}, pca::Union{OJA,SGD,GD,RSGD,SVRG,RSVRG}, lower::Number, upper::Number, evalfreq::Number, offsetFull::Number, offsetStoch::Number, cper::Number, scale::AbstractString="ftt")
    N, M = nm(input)
    tmpN = zeros(UInt32, 1)
    tmpM = zeros(UInt32, 1)
    pseudocount = Float32(pseudocount)
    stepsize = Float32(stepsize)
    g = Float32(g)
    epsilon = Float32(epsilon)
    lower = Float32(lower)
    upper = Float32(upper)
    evalfreq = Int64(evalfreq)
    offsetFull = Float32(offsetFull)
    offsetStoch = Float32(offsetStoch)
    # Eigen vectors
    if initW == nothing
        W = zeros(Float32, M, dim)
        for i = 1:dim
            W[i, i] = 1
        end
    end
    if typeof(initW) == String
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
    v = zeros(Float32, M, dim) # Temporal Vector (Same length
    D = Diagonal(reverse(1:dim)) # Diagonaml Matrix
    x = zeros(UInt32, M)
    normx = zeros(Float32, M)
    rowmeanvec = zeros(Float32, N, 1)
    rowvarvec = zeros(Float32, N, 1)
    colsumvec = zeros(Float32, M, 1)
    if rowmeanlist != ""
        rowmeanvec = read_csv(rowmeanlist, Float32)
    end
    if rowvarlist != ""
        rowvarvec = read_csv(rowvarlist, Float32)
    end
    if colsumlist != ""
        colsumvec = read_csv(colsumlist, Float32)
    end
    # N, M, All Variance
    TotalVar = 0
    open(input) do file
        stream = ZstdDecompressorStream(file)
        read!(stream, tmpN)
        read!(stream, tmpM)
        for n = 1:N
            # Data Import
            read!(stream, x)
            normx = normalizex(x, n, stream, scale, pseudocount, rowmeanlist, rowmeanvec, rowvarlist, rowvarvec, colsumlist, colsumvec, cper)
            TotalVar = TotalVar + normx'normx
            # Creating W from V
            if typeof(initV) == String
                W = W .+ (V[n, :] * normx')'
            end
        end
        close(stream)
    end
    TotalVar = TotalVar / M
    # directory for log file
    if logdir isa String
        if !isdir(logdir)
            mkdir(logdir)
        end
    end
    return pseudocount, stepsize, g, epsilon, W, v, D, rowmeanvec, rowvarvec, colsumvec, N, M, TotalVar, lower, upper, evalfreq, offsetFull, offsetStoch
end

# Eigen value, Loading, Scores
function WλV(W::AbstractArray, input::AbstractString, dim::Number, scale::AbstractString, pseudocount::Number, rowmeanlist::AbstractString, rowmeanvec::AbstractArray, rowvarlist::AbstractString, rowvarvec::AbstractArray, colsumlist::AbstractString, colsumvec::AbstractArray, TotalVar::Number, cper::Number)
    N, M = nm(input)
    tmpN = zeros(UInt32, 1)
    tmpM = zeros(UInt32, 1)
    V = zeros(Float32, N, dim)
    Scores = zeros(Float32, M, dim)
    x = zeros(UInt32, M)
    normx = zeros(UInt32, M)
    open(input) do file
        stream = ZstdDecompressorStream(file)
        read!(stream, tmpN)
        read!(stream, tmpM)
        for n = 1:N
            # Data Import
            read!(stream, x)
            normx = normalizex(x, n, stream, scale, pseudocount, rowmeanlist, rowmeanvec, rowvarlist, rowvarvec, colsumlist, colsumvec, cper)
            V[n, :] = normx'W
        end
        close(stream)
    end
    # Eigen value
    σ = Float32[norm(V[:, x]) for x = 1:dim]
    for n = 1:dim
        V[:, n] ./= σ[n]
    end
    λ = σ .* σ ./ M

    # Sort by Eigen value
    idx = sortperm(λ, rev=true)
    W .= W[:, idx]
    λ .= λ[idx]
    V .= V[:, idx]
    for n = 1:dim
        Scores[:, n] .= λ[n] .* W[:, n]
    end
    ExpVar = sum(λ) / TotalVar
    # Return
    return W, λ, V, Scores, ExpVar, TotalVar
end

# Output log file （only GD）
function outputlog(s::Number, input::AbstractString, dim::Number, logdir::AbstractString, W::AbstractArray, pca::GD, TotalVar::Number, scale::AbstractString, pseudocount::Number, rowmeanlist::AbstractString, rowmeanvec::AbstractArray, rowvarlist::AbstractString, rowvarvec::AbstractArray, colsumlist::AbstractString, colsumvec::AbstractArray, lower::Number, upper::Number, stop::Number, cper::Number)
    REs = RecError(W, input, TotalVar, scale, pseudocount, rowmeanlist, rowmeanvec, rowvarlist, rowvarvec, colsumlist, colsumvec, cper)
    if s != 1
        old_E = read_csv(joinpath(logdir, "RecError_Epoch" * string(s - 1) * ".csv"))
        RelChange = abs(REs[1][2] - old_E[1, 2]) / REs[1][2]
        REs = [REs[1], REs[2], REs[3], REs[4], REs[5], REs[6], "RelChange" => RelChange]
        if RelChange < lower
            println("Relative change of reconstruction error is below the lower value (no change)")
            stop = 1
        end
        if RelChange > upper
            println("Relative change of reconstruction error is above the upper value (unstable)")
            stop = 2
        end
    end
    write_csv(joinpath(logdir, "RecError_Epoch" * string(s) * ".csv"), REs)
    write_csv(joinpath(logdir, "W_Epoch" * string(s) * ".csv"), W)
    return stop
end

# Output log file (other PCA)
function outputlog(N::Number, s::Number, n::Number, input::AbstractString, dim::Number, logdir::AbstractString, W::AbstractArray, pca::Union{OJA,SGD,CCIPCA,RSGD,SVRG,RSVRG}, TotalVar::Number, scale::AbstractString, pseudocount::Number, rowmeanlist::AbstractString, rowmeanvec::AbstractArray, rowvarlist::AbstractString, rowvarvec::AbstractArray, colsumlist::AbstractString, colsumvec::AbstractArray, lower::Number, upper::Number, stop::Number, evalfreq::Number, cper::Number)
    if (mod((N * (s - 1) + n), evalfreq) == 0)
        REs = RecError(W, input, TotalVar, scale, pseudocount, rowmeanlist, rowmeanvec, rowvarlist, rowvarvec, colsumlist, colsumvec, cper)
        if n != evalfreq && (N * (s - 1) + (n - evalfreq)) != 0
            old_E = read_csv(joinpath(logdir, "RecError_" * string((N * (s - 1) + (n - evalfreq))) * ".csv"))
            RelChange = abs(REs[1][2] - old_E[1, 2]) / REs[1][2]
            REs = [REs[1], REs[2], REs[3], REs[4], REs[5], REs[6], "RelChange" => RelChange]
            if RelChange < lower
                println("Relative change of reconstruction error is below the lower value (no change)")
                stop = 1
            end
            if RelChange > upper
                println("Relative change of reconstruction error is above the upper value (unstable)")
                stop = 2
            end
        end
        write_csv(joinpath(logdir, "W_" * string((N * (s - 1) + n)) * ".csv"), W)
        write_csv(joinpath(logdir, "RecError_" * string((N * (s - 1) + n)) * ".csv"), REs)
    end
    return stop
end

# Reconstuction Error
function RecError(W::AbstractArray, input::AbstractString, TotalVar::Number, scale::AbstractString, pseudocount::Number, rowmeanlist::AbstractString, rowmeanvec::AbstractArray, rowvarlist::AbstractString, rowvarvec::AbstractArray, colsumlist::AbstractString, colsumvec::AbstractArray, cper::Number)
    N, M = nm(input)
    tmpN = zeros(UInt32, 1)
    tmpM = zeros(UInt32, 1)
    dim = size(W)[2]
    V = zeros(Float32, N, dim)
    x = zeros(UInt32, M)
    normx = zeros(Float32, M)
    E = 0.0f0
    AE = 0.0f0
    RMSE = 0.0f0
    ARE = 0.0f0
    open(input) do file
        stream = ZstdDecompressorStream(file)
        read!(stream, tmpN)
        read!(stream, tmpM)
        for n = 1:N
            # Data Import
            read!(stream, x)
            normx = normalizex(x, n, stream, scale, pseudocount, rowmeanlist, rowmeanvec, rowvarlist, rowvarvec, colsumlist, colsumvec, cper)
            pc = W'normx
            E = E + dot(normx, normx) - dot(pc, pc)
            V[n, :] = pc
        end
        close(stream)
    end
    # Eigen value
    σ = Float32[norm(V[:, x]) for x = 1:dim]
    for n = 1:dim
        V[:, n] ./= σ[n]
    end
    λ = σ .* σ ./ M
    ExpVar = sum(λ) / TotalVar

    AE = E / M
    RMSE = sqrt(E / (N * M))
    ARE = sqrt(E / TotalVar)
    @assert E isa Float32
    @assert AE isa Float32
    @assert RMSE isa Float32
    @assert ARE isa Float32
    # Return
    return ["E" => E, "AE" => AE, "RMSE" => RMSE, "ARE" => ARE, "Explained Variance" => ExpVar, "Total Variance" => TotalVar]
end

# Row vector
function normalizex(x::Array{UInt32,1}, n::Number, stream, scale::AbstractString, pseudocount::Number, rowmeanlist::AbstractString, rowmeanvec::AbstractArray, rowvarlist::AbstractString, rowvarvec::AbstractArray, colsumlist::AbstractString, colsumvec::AbstractArray, cper::Number)
    # Arugment Check
    if rowmeanlist == ""
        error("No rowmeanlist is specified!")
    end
    if !(scale in ["log", "ftt", "raw"])
        error("scale must be specified as log, ftt, or raw")
    end

    # Input
    xx = convert(Vector{Float32}, x)

    # Normalization
    if colsumlist != ""
        @inbounds for i in 1:length(xx)
            xx[i] = cper * xx[i] / colsumvec[i, 1]
        end
    end

    # Variance Stabilizing Transformation
    if scale == "log"
        @inbounds for i in 1:length(xx)
            xx[i] = log10(xx[i] + pseudocount)
        end
    end
    if scale == "ftt"
        @inbounds for i in 1:length(xx)
            xx[i] = sqrt(xx[i]) + sqrt(xx[i] + 1.0f0)
        end
    end

    # Centering
    @inbounds for i in 1:length(xx)
        xx[i] = xx[i] - rowmeanvec[n, 1]
    end

    # Scaling
    if rowvarlist != ""
        @inbounds for i in 1:length(xx)
            xx[i] = xx[i] / rowvarvec[n, 1]
        end
    end

    # Return
    return xx
end

# Full Gradient
function ∇f(W::AbstractArray, input::AbstractString, D::AbstractArray, scale::AbstractString, pseudocount::Number, rowmeanlist::AbstractString, rowmeanvec::AbstractArray, rowvarlist::AbstractString, rowvarvec::AbstractArray, colsumlist::AbstractString, colsumvec::AbstractArray, stepsize::Number, offsetFull::Number, offsetStoch::Number, perm::Bool, cper::Number)
    N, M = nm(input)
    tmpN = zeros(UInt32, 1)
    tmpM = zeros(UInt32, 1)
    tmpW = zeros(Float32, size(W)[1], size(W)[2])
    x = zeros(UInt32, M)
    normx = zeros(Float32, M)
    open(input) do file
        stream = ZstdDecompressorStream(file)
        read!(stream, tmpN)
        read!(stream, tmpM)
        for n = 1:N
            # Data Import
            read!(stream, x)
            normx = normalizex(x, n, stream, scale, pseudocount, rowmeanlist, rowmeanvec, rowvarlist, rowvarvec, colsumlist, colsumvec, cper)
            if perm
                normx .= normx[randperm(length(normx))]
            end
            # Full Gradient
            tmpW .+= offsetFull * ∇fn(W, normx, D, M, stepsize, offsetStoch)
        end
        close(stream)
    end
    return tmpW / offsetFull
end

# Stochastic Gradient
function ∇fn(W::AbstractArray, x::Array{Float32,1}, D::AbstractArray, M::Number, stepsize::Number, offsetStoch::Number)
    return 1 / offsetStoch * stepsize * Float32(2 / M) * x * (offsetStoch * x'W * D)
end

# sym
function sym(Y::AbstractArray)
    return (Y + Y') / 2
end

# Riemannian Gradient
function Pw(Z::AbstractArray, W::AbstractArray)
    return Z - W * sym(W'Z)
end
