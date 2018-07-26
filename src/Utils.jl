# Types
struct OJA end
struct CCIPCA end
struct GD end
struct RSGD end
struct SVRG end
struct RSVRG end

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
function checkNaN(N::Number, s::Number, n::Number, W::AbstractArray, evalfreq::Number, pca::Union{OJA,CCIPCA,RSGD,SVRG,RSVRG})
    if mod((N*(s-1)+n), evalfreq) == 0
        if any(isnan, W)
            error("NaN values are generated. Select other stepsize")
        end
    end
end

# Output the result of PCA
function output(outdir::AbstractString, out::Tuple)
    writecsv(joinpath(outdir, "Eigen_vectors.csv"), out[1])
    writecsv(joinpath(outdir, "Eigen_values.csv"), out[2])
    writecsv(joinpath(outdir, "Loadings.csv"), out[3])
    writecsv(joinpath(outdir, "Scores.csv"), out[4])
    touch(joinpath(outdir, "Eigen_vectors.csv"))
    touch(joinpath(outdir, "Eigen_values.csv"))
    touch(joinpath(outdir, "Loadings.csv"))
    touch(joinpath(outdir, "Scores.csv"))
end

# Parse command line options (only CCIPCA)
function parse_commandline(pca::CCIPCA)
    s = ArgParseSettings()

    @add_arg_table s begin
        "--input", "-i"
            help = "input file"
            arg_type = AbstractString
            required = true
        "--outdir", "-o"
            help = "output directory"
            arg_type = AbstractString
            default = "."
            required = false
        "--scale"
            help = "{log,ftt,raw}-scaling of the value"
            arg_type = AbstractString
            default = "ftt"
        "--pseudocount", "-p"
            help = "log10(exp + pseudocount)"
            arg_type = Union{Number,AbstractString}
            default = 1.0
        "--rowmeanlist", "-m"
            help = "mean vector of each row"
            arg_type = AbstractString
            default = ""
            required = false
        "--rowvarlist", "-v"
            help = "var vector of each row"
            arg_type = AbstractString
            default = ""
            required = false
        "--colsumlist"
            help = "Sum of counts of each column"
            arg_type = AbstractString
            default = ""
            required = false
        "--masklist"
            help = "Columns to be remove"
            arg_type = AbstractString
            default = ""
            required = false
        "--dim", "-d"
            help = "dimention of PCA"
            arg_type = Union{Number,AbstractString}
            default = 3
        "--stepsize", "-s"
            help = "stepsize of PCA"
            arg_type = Union{Number,AbstractString}
            default = 0.1
        "--numepoch", "-e"
            help = "numepoch of PCA"
            arg_type = Union{Number,AbstractString}
            default = 5
        "--stop"
            help = "Stopping Criteria (Relative Change of Error)"
            arg_type = Union{Number,AbstractString}
            default = 1.0f-3
        "--evalfreq"
            help = "Evaluation Frequency of Reconstruction Error"
            arg_type = Union{Number,AbstractString}
            default = 5000
        "--offsetStoch"
            help = "Off set value for avoding overflow when calculating stochastic gradient"
            arg_type = Union{Number,AbstractString}
            default = 1.0f-6
        "--logdir", "-l"
            help = "saving log directory"
            arg_type = Union{Void,AbstractString}
            default = nothing
    end

    return parse_args(s)
end

# Parse command line options (other PCA)
function parse_commandline(pca::Union{OJA,GD,RSGD,SVRG,RSVRG})
    s = ArgParseSettings()

    @add_arg_table s begin
        "--input", "-i"
            help = "input file"
            arg_type = AbstractString
            required = true
        "--outdir", "-o"
            help = "output directory"
            arg_type = AbstractString
            default = "."
            required = false
        "--scale"
            help = "whether the value are converted to {log,ftt,raw}-scale"
            arg_type = AbstractString
            default = "ftt"
        "--pseudocount", "-p"
            help = "log10(exp + pseudocount)"
            arg_type = Union{Number,AbstractString}
            default = 1.0f0
        "--rowmeanlist", "-m"
            help = "mean vector of each row"
            arg_type = AbstractString
            default = ""
            required = false
        "--rowvarlist", "-v"
            help = "var vector of each row"
            arg_type = AbstractString
            default = ""
            required = false
        "--colsumlist"
            help = "Sum of counts of each column"
            arg_type = AbstractString
            default = ""
            required = false
        "--masklist"
            help = "Columns to be remove"
            arg_type = AbstractString
            default = ""
            required = false
        "--dim", "-d"
            help = "dimention of PCA"
            arg_type = Union{Number,AbstractString}
            default = 3
        "--stepsize", "-s"
            help = "stepsize of PCA"
            arg_type = Union{Number,AbstractString}
            default = 0.1f0
        "--numepoch", "-e"
            help = "numepoch of PCA"
            arg_type = Union{Number,AbstractString}
            default = 5
        "--scheduling"
            help = "Learning Rate Scheduling"
            arg_type = AbstractString
            default = "robbins-monro"
        "-g"
            help = "Ratio of non-SGD gradient"
            arg_type = Union{Number,AbstractString}
            default = 0.9f0
        "--epsilon"
            help = "a small number for avoiding zero division"
            arg_type = Union{Number,AbstractString}
            default = 1.0f-8
        "--stop"
            help = "Stopping Criteria (Relative Change of Error)"
            arg_type = Union{Number,AbstractString}
            default = 1.0f-3
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
        "--logdir", "-l"
            help = "saving log directory"
            arg_type = Union{Void,AbstractString}
            default = nothing
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

# Initialization (only CCIPCA)
function init(input::AbstractString, pseudocount::Number, stepsize::Number, dim::Number, rowmeanlist::AbstractString, rowvarlist::AbstractString, colsumlist::AbstractString, masklist::AbstractString, logdir::Union{Void,AbstractString}, pca::CCIPCA, stop::Number, evalfreq::Number, offsetFull::Number, offsetStoch::Number, scale::AbstractString="ftt")
    N, M = nm(input)
    tmpN = zeros(UInt32, 1)
    tmpM = zeros(UInt32, 1)
    pseudocount = Float32(pseudocount)
    stepsize = Float32(stepsize)
    stop = Float32(stop)
    evalfreq = Int64(evalfreq)
    offsetFull = Float32(offsetFull)
    offsetStoch = Float32(offsetStoch)
    W = zeros(Float32, M, dim) # Eigen vectors
    X = zeros(Float32, M, dim+1) # Temporal Vector (Same length
    D = Diagonal(reverse(1:dim)) # Diagonaml Matrix
    x = zeros(UInt32, M)
    for i=1:dim
        W[i,i] = 1
    end
    rowmeanvec = zeros(Float32, N, 1)
    rowvarvec = zeros(Float32, N, 1)
    colsumvec = zeros(Float32, M, 1)
    maskvec = zeros(Float32, M, 1)
    if rowmeanlist != ""
        rowmeanvec = readcsv(rowmeanlist, Float32)
    end
    if rowvarlist != ""
        rowvarvec = readcsv(rowvarlist, Float32)
    end
    if colsumlist != ""
        colsumvec = readcsv(colsumlist, Float32)
    end
    if masklist != ""
        maskvec = readcsv(masklist, Float32)
    end
    # N, M, All Variance
    AllVar = 0
    open(input) do file
        stream = ZstdDecompressorStream(file)
        read!(stream, tmpN)
        read!(stream, tmpM)
        for n = 1:N
            # Data Import
            read!(stream, x)
            normx = normalizex(x, n, stream, scale, pseudocount, masklist, maskvec, rowmeanlist, rowmeanvec, rowvarlist, rowvarvec, colsumlist, colsumvec)
            AllVar = AllVar + normx'normx
        end
        close(stream)
    end
    # directory for log file
    if logdir isa String
        if(!isdir(logdir))
            mkdir(logdir)
        end
    end
    return pseudocount, stepsize, W, X, D, rowmeanvec, rowvarvec, colsumvec, maskvec, N, M, AllVar, stop, evalfreq, offsetFull, offsetStoch
end

# Initialization (other PCA)
function init(input::AbstractString, pseudocount::Number, stepsize::Number, g::Number, epsilon::Number, dim::Number, rowmeanlist::AbstractString, rowvarlist::AbstractString, colsumlist::AbstractString, masklist::AbstractString, logdir::Union{Void,AbstractString}, pca::Union{OJA,GD,RSGD,SVRG,RSVRG}, stop::Number, evalfreq::Number, offsetFull::Number, offsetStoch::Number, scale::AbstractString="ftt")
    N, M = nm(input)
    tmpN = zeros(UInt32, 1)
    tmpM = zeros(UInt32, 1)
    pseudocount = Float32(pseudocount)
    stepsize = Float32(stepsize)
    g = Float32(g)
    epsilon = Float32(epsilon)
    stop = Float32(stop)
    evalfreq = Int64(evalfreq)
    offsetFull = Float32(offsetFull)
    offsetStoch = Float32(offsetStoch)
    W = zeros(Float32, M, dim) # Eigen vectors
    v = zeros(Float32, M, dim) # Temporal Vector (Same length
    D = Diagonal(reverse(1:dim)) # Diagonaml Matrix
    x = zeros(UInt32, M)
    normx = zeros(Float32, M)
    for i=1:dim
        W[i,i] = 1
    end
    rowmeanvec = zeros(Float32, N, 1)
    rowvarvec = zeros(Float32, N, 1)
    colsumvec = zeros(Float32, M, 1)
    maskvec = zeros(Float32, M, 1)
    if rowmeanlist != ""
        rowmeanvec = readcsv(rowmeanlist, Float32)
    end
    if rowvarlist != ""
        rowvarvec = readcsv(rowvarlist, Float32)
    end
    if colsumlist != ""
        colsumvec = readcsv(colsumlist, Float32)
    end
    if masklist != ""
        maskvec = readcsv(masklist, Float32)
    end
    # N, M, All Variance
    AllVar = 0
    open(input) do file
        stream = ZstdDecompressorStream(file)
        read!(stream, tmpN)
        read!(stream, tmpM)
        for n = 1:N
            # Data Import
            read!(stream, x)
            normx = normalizex(x, n, stream, scale, pseudocount, masklist, maskvec, rowmeanlist, rowmeanvec, rowvarlist, rowvarvec, colsumlist, colsumvec)
            AllVar = AllVar + normx'normx
        end
        close(stream)
    end
    # directory for log file
    if logdir isa String
        if(!isdir(logdir))
            mkdir(logdir)
        end
    end
    return pseudocount, stepsize, g, epsilon, W, v, D, rowmeanvec, rowvarvec, colsumvec, maskvec, N, M, AllVar, stop, evalfreq, offsetFull, offsetStoch
end

# Eigen value, Loading, Scores
function WλV(W::AbstractArray, input::AbstractString, dim::Number, scale::AbstractString, pseudocount::Number, masklist::AbstractString, maskvec::AbstractArray, rowmeanlist::AbstractString, rowmeanvec::AbstractArray, rowvarlist::AbstractString, rowvarvec::AbstractArray, colsumlist::AbstractString, colsumvec::AbstractArray)
    N, M = nm(input)
    tmpN = zeros(UInt32, 1)
    tmpM = zeros(UInt32, 1)
    V = zeros(Float32, N, dim)
    Scores = zeros(Float32, M, dim)
    x = zeros(UInt32, M)
    open(input) do file
        stream = ZstdDecompressorStream(file)
        read!(stream, tmpN)
        read!(stream, tmpM)
        for n = 1:N
            # Data Import
            read!(stream, x)
            normx = normalizex(x, n, stream, scale, pseudocount, masklist, maskvec, rowmeanlist, rowmeanvec, rowvarlist, rowvarvec, colsumlist, colsumvec)
            V[n, :] = normx'W
        end
        close(stream)
    end
    # Eigen value
    λ = Float32[norm(V[:, x]) for x=1:dim]
    for n = 1:dim
        V[:, n] ./= λ[n]
    end

    # λ .= λ .* λ ./ N
    # λ .= 1 ./ (M .* λ)
    λ .= λ .* λ ./ M

    # Sort by Eigen value
    idx = sortperm(λ, rev=true)
    W .= W[:, idx]
    λ .= λ[idx]
    V .= V[:, idx]
    for n = 1:dim
        Scores[:, n] .= (M .* λ[n])^(3/2) .* W[:, n]
    end

    # Return
    return W, λ, V, Scores
end

# Output log file （only GD）
function outputlog(s::Number, input::AbstractString, dim::Number, logdir::AbstractString, W::AbstractArray, pca::GD, AllVar::Number, scale::AbstractString, pseudocount::Number, masklist::AbstractString, maskvec::AbstractArray, rowmeanlist::AbstractString, rowmeanvec::AbstractArray, rowvarlist::AbstractString, rowvarvec::AbstractArray, colsumlist::AbstractString, colsumvec::AbstractArray, stop::Number, conv::Bool)
    REs = RecError(W, input, AllVar, scale, pseudocount, masklist, maskvec, rowmeanlist, rowmeanvec, rowvarlist, rowvarvec, colsumlist, colsumvec)
    if s != 1
        old_E = readcsv("$(logdir)/RecError_$(string(s-1)).csv")
        relChange = abs(REs[1][2] - old_E[1,2]) / REs[1][2]
        println("new Error: ", REs[1][2])
        println("old Error:", old_E[1,2])
        println("abs: ", abs(REs[1][2] - old_E[1,2]))
        println("relChange: ", relChange)
        if relChange < stop
            println("The calculation is converged")
            conv = true
            return conv
        end
    end
    writecsv("$(logdir)/W_$(string(s)).csv", W)
    writecsv("$(logdir)/RecError_$(string(s)).csv", REs)
    touch("$(logdir)/W_$(string(s)).csv")
    touch("$(logdir)/RecError_$(string(s)).csv")
    return conv
end

# Output log file (other PCA)
function outputlog(N::Number, s::Number, n::Number, input::AbstractString, dim::Number, logdir::AbstractString, W::AbstractArray, pca::Union{OJA,CCIPCA,RSGD,SVRG,RSVRG}, AllVar::Number, scale::AbstractString, pseudocount::Number, masklist::AbstractString, maskvec::AbstractArray, rowmeanlist::AbstractString, rowmeanvec::AbstractArray, rowvarlist::AbstractString, rowvarvec::AbstractArray, colsumlist::AbstractString, colsumvec::AbstractArray, stop::Number, conv::Bool, evalfreq::Number)
    if(mod((N*(s-1)+n), evalfreq) == 0)
        REs = RecError(W, input, AllVar, scale, pseudocount, masklist, maskvec, rowmeanlist, rowmeanvec, rowvarlist, rowvarvec, colsumlist, colsumvec)
        if n != evalfreq
            old_E = readcsv("$(logdir)/RecError_$(string((N*(s-1)+(n-evalfreq)))).csv")
            relChange = abs(REs[1][2] - old_E[1,2]) / REs[1][2]
            @show relChange
            if relChange < stop
                println("The calculation is converged")
                conv = true
                return conv
            end
        end
        writecsv("$(logdir)/W_$(string((N*(s-1)+n))).csv", W)
        writecsv("$(logdir)/RecError_$(string((N*(s-1)+n))).csv", REs)
        touch("$(logdir)/W_$(string((N*(s-1)+n))).csv")
        touch("$(logdir)/RecError_$(string((N*(s-1)+n))).csv")
    end
    return conv
end

# Reconstuction Error
function RecError(W::AbstractArray, input::AbstractString, AllVar::Number, scale::AbstractString, pseudocount::Number, masklist::AbstractString, maskvec::AbstractArray, rowmeanlist::AbstractString, rowmeanvec::AbstractArray, rowvarlist::AbstractString, rowvarvec::AbstractArray, colsumlist::AbstractString, colsumvec::AbstractArray)
    N, M = nm(input)
    tmpN = zeros(UInt32, 1)
    tmpM = zeros(UInt32, 1)
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
            normx = normalizex(x, n, stream, scale, pseudocount, masklist, maskvec, rowmeanlist, rowmeanvec, rowvarlist, rowvarvec, colsumlist, colsumvec)
            pc = W'normx
            E = E + dot(normx, normx) - dot(pc, pc)
        end
        close(stream)
    end
    AE = E / M
    RMSE = sqrt(E / (N * M))
    ARE = sqrt(E / AllVar)
    @assert E isa Float32
    @assert AE isa Float32
    @assert RMSE isa Float32
    @assert ARE isa Float32
    # Return
    return ["E"=>E, "AE"=>AE, "RMSE"=>RMSE, "ARE"=>ARE, "AllVar"=>AllVar]
end

# Row vector
function normalizex(x::Array{UInt32,1}, n::Number, stream, scale::AbstractString, pseudocount::Number, masklist::AbstractString, maskvec::AbstractArray, rowmeanlist::AbstractString, rowmeanvec::AbstractArray, rowvarlist::AbstractString, rowvarvec::AbstractArray, colsumlist::AbstractString, colsumvec::AbstractArray)
    # Input
    if !(scale in ["log", "ftt", "raw"])
        error("scale must be specified as log, ftt, or raw")
    end

    # Logscale, FTTscale, Raw
    if scale == "log"
        pc = UInt32(pseudocount)
        xx = Vector{Float32}(length(x))
        @inbounds for i in 1:length(x)
            xx[i] = log10(x[i] + pc)
        end
    end
    if scale == "ftt"
        xx = Vector{Float32}(length(x))
        @inbounds for i in 1:length(x)
            xx[i] = sqrt(x[i]) + sqrt(x[i] + 1.0f0)
        end
    end
    if scale == "raw"
        xx = convert(Vector{Float32}, x)
    end

    # Masking
    if masklist != ""
        xx = xx[maskvec]
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
function ∇f(W::AbstractArray, input::AbstractString, D::AbstractArray, scale::AbstractString, pseudocount::Number, masklist::AbstractString, maskvec::AbstractArray, rowmeanlist::AbstractString, rowmeanvec::AbstractArray, rowvarlist::AbstractString, rowvarvec::AbstractArray, colsumlist::AbstractString, colsumvec::AbstractArray, stepsize::Number, offsetFull::Number, offsetStoch::Number)
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
            normx = normalizex(x, n, stream, scale, pseudocount, masklist, maskvec, rowmeanlist, rowmeanvec, rowvarlist, rowvarvec, colsumlist, colsumvec)
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
