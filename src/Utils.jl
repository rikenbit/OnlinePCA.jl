# Types
struct SGD end
struct OJA end
struct CCIPCA end
struct GD end
struct RSGD end
struct SVRG end
struct RSVRG end
struct OOCPCA end
struct HALKO end

struct ROBBINS_MONRO end
struct MOMENTUM end
struct NAG end
struct ADAGRAD end

# Check NaN value (only GD)
function checkNaN(W::AbstractArray, pca::GD)
    if any(isnan, W)
        error("NaN values are generated. Select other stepsize")
    end
end

# Check NaN value (other PCA)
function checkNaN(N::Number, s::Number, n::Number, W::AbstractArray, evalfreq::Number, pca::Union{OJA,SGD,CCIPCA,RSGD,SVRG,RSVRG})
    if mod((N*(s-1)+n), evalfreq) == 0
        if any(isnan, W)
            error("NaN values are generated. Select other stepsize")
        end
    end
end

# Output the result of PCA
function output(outdir::AbstractString, out::Tuple, expvar::Number)
    writecsv(joinpath(outdir, "Eigen_vectors.csv"), out[1])
    writecsv(joinpath(outdir, "Eigen_values.csv"), out[2])
    writecsv(joinpath(outdir, "Loadings.csv"), out[3])
    writecsv(joinpath(outdir, "Scores.csv"), out[4])
    writecsv(joinpath(outdir, "ExpVar.csv"), out[5])
    if out[5] > expvar && out[6] == 1
        touch(joinpath(outdir, "Converged"))
    end
end

writecsv(filename::AbstractString, data) = writedlm(filename, data, ',')
readcsv(filename::AbstractString) = readdlm(filename, ',')
readcsv(filename::AbstractString, ::Type{T}) where {T} = readdlm(filename, ',', T)


# Parse command line options (only OOCPCA and HALKO)
function parse_commandline(pca::Union{OOCPCA,HALKO})
    s = ArgParseSettings()

    @add_arg_table s begin
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
            default = 1.0
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
        "--initW"
            help = "The CSV file saving the initial values of eigenvectors."
            arg_type = Union{Nothing,AbstractString}
            default = nothing
        "--initV"
            help = "The CSV file saving the initial values of loadings."
            arg_type = Union{Nothing,AbstractString}
            default = nothing
        "--logdir", "-l"
            help = "The directory where intermediate files are saved, in every evalfreq (e.g. 5000) iteration."
            arg_type = Union{Nothing,AbstractString}
            default = nothing
        "--perm"
            help = "Whether the data matrix is shuffled at random"
            arg_type = Union{Bool,AbstractString}
            default = false
    end

    return parse_args(s)
end

# Parse command line options (only CCIPCA)
function parse_commandline(pca::CCIPCA)
    s = ArgParseSettings()

    @add_arg_table s begin
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
            default = 1.0
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
            default = 1f-15
        "--initW"
            help = "The CSV file saving the initial values of eigenvectors."
            arg_type = Union{Nothing,AbstractString}
            default = nothing
        "--initV"
            help = "The CSV file saving the initial values of loadings."
            arg_type = Union{Nothing,AbstractString}
            default = nothing
        "--logdir", "-l"
            help = "The directory where intermediate files are saved, in every evalfreq (e.g. 5000) iteration."
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
    end

    return parse_args(s)
end

# Parse command line options (SGD、RSGD、SVRG、RSVRG)
function parse_commandline(pca::Union{SGD,RSGD,SVRG,RSVRG})
    s = ArgParseSettings()

    @add_arg_table s begin
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
            help = "The directory where intermediate files are saved, in every evalfreq (e.g. 5000) iteration."
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
    end

    return parse_args(s)
end

# Parse command line options (other PCA)
function parse_commandline(pca::Union{OJA,GD})
    s = ArgParseSettings()

    @add_arg_table s begin
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
            help = "The directory where intermediate files are saved, in every evalfreq (e.g. 5000) iteration."
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
    return N[], M[]
end

# Initialization (only OOCPCA and HALKO)
function init(input::AbstractString, pseudocount::Number, dim::Number, rowmeanlist::AbstractString, rowvarlist::AbstractString, colsumlist::AbstractString, initW::Union{Nothing,AbstractString}, initV::Union{Nothing,AbstractString}, logdir::Union{Nothing,AbstractString}, pca::Union{OOCPCA,HALKO}, scale::AbstractString="ftt")
    N, M = nm(input)
    tmpN = zeros(UInt32, 1)
    tmpM = zeros(UInt32, 1)
    pseudocount = Float32(pseudocount)
    # Eigen vectors
    # Eigen vectors
    if initW == nothing
        W = zeros(Float32, M, dim)
        for i=1:dim
            W[i, i] = 1
        end
    end
    if typeof(initW) == String
        if initV == nothing
            W = readcsv(initW, Float32)
        else
            error("initW and initV are not specified at once. You only have one choice.")
        end
    end
    if typeof(initV) == String
            V = readcsv(initV, Float32)
            V = V[:,1:dim]
    end
    D = Diagonal(reverse(1:dim)) # Diagonal Matrix
    x = zeros(UInt32, M)
    rowmeanvec = zeros(Float32, N, 1)
    rowvarvec = zeros(Float32, N, 1)
    colsumvec = zeros(Float32, M, 1)
    if rowmeanlist != ""
        rowmeanvec = readcsv(rowmeanlist, Float32)
    end
    if rowvarlist != ""
        rowvarvec = readcsv(rowvarlist, Float32)
    end
    if colsumlist != ""
        colsumvec = readcsv(colsumlist, Float32)
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
            normx = normalizex(x, n, stream, scale, pseudocount, rowmeanlist, rowmeanvec, rowvarlist, rowvarvec, colsumlist, colsumvec)
            TotalVar = TotalVar + normx'normx
            # Creating W from V
            if typeof(initV) == String
                W = W .+ (V[n,:]*normx')'
            end
        end
        close(stream)
    end
    TotalVar = TotalVar / M
    # directory for log file
    if logdir isa String
        if(!isdir(logdir))
            mkdir(logdir)
        end
    end
    return pseudocount, W, D, rowmeanvec, rowvarvec, colsumvec, N, M, TotalVar
end

# Initialization (only CCIPCA)
function init(input::AbstractString, pseudocount::Number, stepsize::Number, dim::Number, rowmeanlist::AbstractString, rowvarlist::AbstractString, colsumlist::AbstractString, initW::Union{Nothing,AbstractString}, initV::Union{Nothing,AbstractString}, logdir::Union{Nothing,AbstractString}, pca::CCIPCA, lower::Number, upper::Number, evalfreq::Number, offsetFull::Number, offsetStoch::Number, scale::AbstractString="ftt")
    N, M = nm(input)
    tmpN = zeros(UInt32, 1)
    tmpM = zeros(UInt32, 1)
    pseudocount = Float32(pseudocount)
    stepsize = Float32(stepsize)
    lower = Float32(lower)
    upper = Float32(upper)
    evalfreq = Int64(evalfreq)
    offsetFull = Float32(offsetFull)
    offsetStoch = Float32(offsetStoch)
    # Eigen vectors
    if initW == nothing
        W = zeros(Float32, M, dim)
        for i=1:dim
            W[i, i] = 1
        end
    end
    if typeof(initW) == String
        if initV == nothing
            W = readcsv(initW, Float32)
        else
            error("initW and initV are not specified at once. You only have one choice.")
        end
    end
    if typeof(initV) == String
            V = readcsv(initV, Float32)
            V = V[:,1:dim]
    end
    X = zeros(Float32, M, dim+1) # Temporal Vector (Same length
    D = Diagonal(reverse(1:dim)) # Diagonaml Matrix
    x = zeros(UInt32, M)
    rowmeanvec = zeros(Float32, N, 1)
    rowvarvec = zeros(Float32, N, 1)
    colsumvec = zeros(Float32, M, 1)
    if rowmeanlist != ""
        rowmeanvec = readcsv(rowmeanlist, Float32)
    end
    if rowvarlist != ""
        rowvarvec = readcsv(rowvarlist, Float32)
    end
    if colsumlist != ""
        colsumvec = readcsv(colsumlist, Float32)
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
            normx = normalizex(x, n, stream, scale, pseudocount, rowmeanlist, rowmeanvec, rowvarlist, rowvarvec, colsumlist, colsumvec)
            TotalVar = TotalVar + normx'normx
            # Creating W from V
            if typeof(initV) == String
                W = W .+ (V[n,:]*normx')'
            end
        end
        close(stream)
    end
    TotalVar = TotalVar / M
    # directory for log file
    if logdir isa String
        if(!isdir(logdir))
            mkdir(logdir)
        end
    end
    return pseudocount, stepsize, W, X, D, rowmeanvec, rowvarvec, colsumvec, N, M, TotalVar, lower, upper, evalfreq, offsetFull, offsetStoch
end

# Initialization (other PCA)
function init(input::AbstractString, pseudocount::Number, stepsize::Number, g::Number, epsilon::Number, dim::Number, rowmeanlist::AbstractString, rowvarlist::AbstractString, colsumlist::AbstractString, initW::Union{Nothing,AbstractString}, initV::Union{Nothing,AbstractString}, logdir::Union{Nothing,AbstractString}, pca::Union{OJA,SGD,GD,RSGD,SVRG,RSVRG}, lower::Number, upper::Number, evalfreq::Number, offsetFull::Number, offsetStoch::Number, scale::AbstractString="ftt")
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
        for i=1:dim
            W[i, i] = 1
        end
    end
    if typeof(initW) == String
        if initV == nothing
            W = readcsv(initW, Float32)
        else
            error("initW and initV are not specified at once. You only have one choice.")
        end
    end
    if typeof(initV) == String
            V = readcsv(initV, Float32)
            V = V[:,1:dim]
    end
    v = zeros(Float32, M, dim) # Temporal Vector (Same length
    D = Diagonal(reverse(1:dim)) # Diagonaml Matrix
    x = zeros(UInt32, M)
    normx = zeros(Float32, M)
    rowmeanvec = zeros(Float32, N, 1)
    rowvarvec = zeros(Float32, N, 1)
    colsumvec = zeros(Float32, M, 1)
    if rowmeanlist != ""
        rowmeanvec = readcsv(rowmeanlist, Float32)
    end
    if rowvarlist != ""
        rowvarvec = readcsv(rowvarlist, Float32)
    end
    if colsumlist != ""
        colsumvec = readcsv(colsumlist, Float32)
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
            normx = normalizex(x, n, stream, scale, pseudocount, rowmeanlist, rowmeanvec, rowvarlist, rowvarvec, colsumlist, colsumvec)
            TotalVar = TotalVar + normx'normx
            # Creating W from V
            if typeof(initV) == String
                W = W .+ (V[n,:]*normx')'
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
function WλV(W::AbstractArray, input::AbstractString, dim::Number, scale::AbstractString, pseudocount::Number, rowmeanlist::AbstractString, rowmeanvec::AbstractArray, rowvarlist::AbstractString, rowvarvec::AbstractArray, colsumlist::AbstractString, colsumvec::AbstractArray, TotalVar::Number)
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
            normx = normalizex(x, n, stream, scale, pseudocount, rowmeanlist, rowmeanvec, rowvarlist, rowvarvec, colsumlist, colsumvec)
            V[n, :] = normx'W
        end
        close(stream)
    end
    # Eigen value
    σ = Float32[norm(V[:, x]) for x=1:dim]
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
function outputlog(s::Number, input::AbstractString, dim::Number, logdir::AbstractString, W::AbstractArray, pca::GD, TotalVar::Number, scale::AbstractString, pseudocount::Number, rowmeanlist::AbstractString, rowmeanvec::AbstractArray, rowvarlist::AbstractString, rowvarvec::AbstractArray, colsumlist::AbstractString, colsumvec::AbstractArray, lower::Number, upper::Number, stop::Number)
    REs = RecError(W, input, TotalVar, scale, pseudocount, rowmeanlist, rowmeanvec, rowvarlist, rowvarvec, colsumlist, colsumvec)
    if s != 1
        old_E = readcsv(joinpath(logdir, "RecError_Epoch"*string(s-1)*".csv"))
        RelChange = abs(REs[1][2] - old_E[1,2]) / REs[1][2]
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
    writecsv(joinpath(logdir, "RecError_Epoch"*string(s)*".csv"), REs)
    writecsv(joinpath(logdir, "W_Epoch"*string(s)*".csv"), W)
    return stop
end

# Output log file (other PCA)
function outputlog(N::Number, s::Number, n::Number, input::AbstractString, dim::Number, logdir::AbstractString, W::AbstractArray, pca::Union{OJA,SGD,CCIPCA,RSGD,SVRG,RSVRG}, TotalVar::Number, scale::AbstractString, pseudocount::Number, rowmeanlist::AbstractString, rowmeanvec::AbstractArray, rowvarlist::AbstractString, rowvarvec::AbstractArray, colsumlist::AbstractString, colsumvec::AbstractArray, lower::Number, upper::Number, stop::Number, evalfreq::Number)
    if(mod((N*(s-1)+n), evalfreq) == 0)
        REs = RecError(W, input, TotalVar, scale, pseudocount, rowmeanlist, rowmeanvec, rowvarlist, rowvarvec, colsumlist, colsumvec)
        if n != evalfreq && (N*(s-1)+(n-evalfreq)) != 0
            old_E = readcsv(joinpath(logdir, "RecError_"*string((N*(s-1)+(n-evalfreq)))*".csv"))
            RelChange = abs(REs[1][2] - old_E[1,2]) / REs[1][2]
            REs = [REs[1], REs[2], REs[3], REs[4], REs[5], REs[6], "RelChange"=> RelChange]
            if RelChange < lower
                println("Relative change of reconstruction error is below the lower value (no change)")
                stop = 1
            end
            if RelChange > upper
                println("Relative change of reconstruction error is above the upper value (unstable)")
                stop = 2
            end
        end
        writecsv(joinpath(logdir, "W_"*string((N*(s-1)+n))*".csv"), W)
        writecsv(joinpath(logdir, "RecError_"*string((N*(s-1)+n))*".csv"), REs)
    end
    return stop
end

# Reconstuction Error
function RecError(W::AbstractArray, input::AbstractString, TotalVar::Number, scale::AbstractString, pseudocount::Number, rowmeanlist::AbstractString, rowmeanvec::AbstractArray, rowvarlist::AbstractString, rowvarvec::AbstractArray, colsumlist::AbstractString, colsumvec::AbstractArray)
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
            normx = normalizex(x, n, stream, scale, pseudocount, rowmeanlist, rowmeanvec, rowvarlist, rowvarvec, colsumlist, colsumvec)
            pc = W'normx
            E = E + dot(normx, normx) - dot(pc, pc)
            V[n, :] = pc
        end
        close(stream)
    end
    # Eigen value
    σ = Float32[norm(V[:, x]) for x=1:dim]
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
    return ["E"=>E, "AE"=>AE, "RMSE"=>RMSE, "ARE"=>ARE, "Explained Variance"=>ExpVar, "Total Variance"=>TotalVar]
end

# Row vector
function normalizex(x::Array{UInt32,1}, n::Number, stream, scale::AbstractString, pseudocount::Number, rowmeanlist::AbstractString, rowmeanvec::AbstractArray, rowvarlist::AbstractString, rowvarvec::AbstractArray, colsumlist::AbstractString, colsumvec::AbstractArray)
    # Input
    if !(scale in ["log", "ftt", "raw"])
        error("scale must be specified as log, ftt, or raw")
    end

    # Logscale, FTTscale, Raw
    if scale == "log"
        pc = UInt32(pseudocount)
        xx = Vector{Float32}(undef, length(x))
        @inbounds for i in 1:length(x)
            xx[i] = log10(x[i] + pc)
        end
    end
    if scale == "ftt"
        xx = Vector{Float32}(undef, length(x))
        @inbounds for i in 1:length(x)
            xx[i] = sqrt(x[i]) + sqrt(x[i] + 1.0f0)
        end
    end
    if scale == "raw"
        xx = convert(Vector{Float32}, x)
    end

    # Centering, Normalization
    if (rowmeanlist != "") && (rowvarlist == "") && (colsumlist == "")
        @inbounds for i in 1:length(xx)
            xx[i] = xx[i] - rowmeanvec[n, 1]
        end
    end
    if (rowmeanlist != "") && (rowvarlist != "") && (colsumlist == "")
        @inbounds for i in 1:length(xx)
            xx[i] = (xx[i] - rowmeanvec[n, 1]) / rowvarvec[n, 1]
        end
    end
    if (rowmeanlist != "") && (rowvarlist == "") && (colsumlist != "")
        @inbounds for i in 1:length(xx)
            xx[i] = (xx[i] - rowmeanvec[n, 1]) / colsumvec
        end
    end
    if (rowmeanlist != "") && (rowvarlist != "") && (colsumlist != "")
        @inbounds for i in 1:length(xx)
            xx[i] = (xx[i] - rowmeanvec[n, 1]) / (rowvarvec[n, 1] * colsumvec)
        end
    end
    # Return
    return xx
end

# Full Gradient
function ∇f(W::AbstractArray, input::AbstractString, D::AbstractArray, scale::AbstractString, pseudocount::Number, rowmeanlist::AbstractString, rowmeanvec::AbstractArray, rowvarlist::AbstractString, rowvarvec::AbstractArray, colsumlist::AbstractString, colsumvec::AbstractArray, stepsize::Number, offsetFull::Number, offsetStoch::Number, perm::Bool)
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
            normx = normalizex(x, n, stream, scale, pseudocount, rowmeanlist, rowmeanvec, rowvarlist, rowvarvec, colsumlist, colsumvec)
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
    return 1/offsetStoch * stepsize * Float32(2 / M) * x * (offsetStoch * x'W * D)
end

# sym
function sym(Y::AbstractArray)
    return (Y + Y') / 2
end

# Riemannian Gradient
function Pw(Z::AbstractArray, W::AbstractArray)
    return Z - W * sym(W'Z)
end
