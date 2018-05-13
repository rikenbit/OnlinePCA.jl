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
function checkNaN(N::Number, s::Number, n::Number, W::AbstractArray, pca::Union{OJA,CCIPCA,RSGD,SVRG,RSVRG})
    if mod((N*(s-1)+n), 5000) == 0
        if any(isnan, W)
            error("NaN values are generated. Select other stepsize")
        end
    end
end

# Output the result of PCA
function output(outdir::AbstractString, out::Tuple)
    writecsv(outdir * "/Eigen_vectors.csv", out[1])
    writecsv(outdir *"/Eigen_values.csv", out[2])
    writecsv(outdir *"/Loadings.csv", out[3])
    writecsv(outdir *"/Scores.csv", out[4])
    touch(outdir * "/Eigen_vectors.csv")
    touch(outdir *"/Eigen_values.csv")
    touch(outdir *"/Loadings.csv")
    touch(outdir *"/Scores.csv")
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
        "--logscale"
            help = "whether the value are converted to log-scale"
            arg_type = Union{Bool,AbstractString}
            default = true
        "--pseudocount", "-p"
            help = "log10(exp + pseudocount)"
            arg_type = Union{Number,AbstractString}
            default = 1.0
        "--rowmeanlist", "-m"
            help = "mean vector of each row"
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
        "--logscale"
            help = "whether the value are converted to log-scale"
            arg_type = Union{Bool,AbstractString}
            default = true
        "--pseudocount", "-p"
            help = "log10(exp + pseudocount)"
            arg_type = Union{Number,AbstractString}
            default = Float32(1)
        "--rowmeanlist", "-m"
            help = "mean vector of each row"
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
            default = Float32(0.1)
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
            default = Float32(0.9)
        "--epsilon"
            help = "a small number for avoiding zero division"
            arg_type = Union{Number,AbstractString}
            default = Float32(1.0e-8)
            "--logdir", "-l"
            help = "saving log directory"
            arg_type = Union{Void,AbstractString}
            default = nothing
    end

    return parse_args(s)
end

# Return N, M
function nm(input::AbstractString)
    N = 0
    M = 0
    AllVar = 0
    open(input) do file
        N = read(file, Int64)
        M = read(file, Int64)
    end
    return N, M
end

# Initialization (only CCIPCA)
function init(input::AbstractString, pseudocount::Number, stepsize::Number, dim::Number, rowmeanlist::AbstractString, colsumlist::AbstractString, masklist::AbstractString, logdir::Union{Void,AbstractString}, pca::CCIPCA, logscale::Bool=true)
    N, M = nm(input)
    pseudocount = Float32(pseudocount)
    stepsize = Float32(stepsize)
    W = zeros(Float32, M, dim) # Eigen vectors
    X = zeros(Float32, M, dim+1) # Temporal Vector (Same length
    D = Diagonal(reverse(1:dim)) # Diagonaml Matrix
    for i=1:dim
        W[i,i] = 1
    end
    rowmeanvec = zeros(Float32, N, 1)
    colsumvec = zeros(Float32, M, 1)
    maskvec = zeros(Float32, M, 1)
    if rowmeanlist != ""
        rowmeanvec = readcsv(rowmeanlist, Float32)
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
        N = read(file, Int64) # Number of Features (e.g. Genes)
        M = read(file, Int64) # Number of samples (e.g. Cells)
        for n = 1:N
            # Data Import
            x = deserializex(n, file, logscale, pseudocount, masklist, maskvec, rowmeanlist, rowmeanvec, colsumlist, colsumvec)
            AllVar = AllVar + x' * x
        end
    end
    # directory for log file
    if typeof(logdir) == String
        if(!isdir(logdir))
            mkdir(logdir)
        end
    end
    return pseudocount, stepsize, W, X, D, rowmeanvec, colsumvec, maskvec, N, M, AllVar
end

# Initialization (other PCA)
function init(input::AbstractString, pseudocount::Number, stepsize::Number, g::Number, epsilon::Number, dim::Number, rowmeanlist::AbstractString, colsumlist::AbstractString, masklist::AbstractString, logdir::Union{Void,AbstractString}, pca::Union{OJA,GD,RSGD,SVRG,RSVRG}, logscale::Bool=true)
    N, M = nm(input)
    pseudocount = Float32(pseudocount)
    stepsize = Float32(stepsize)
    g = Float32(g)
    epsilon = Float32(epsilon)
    W = zeros(Float32, M, dim) # Eigen vectors
    v = zeros(Float32, M, dim) # Temporal Vector (Same length
    D = Diagonal(reverse(1:dim)) # Diagonaml Matrix
    for i=1:dim
        W[i,i] = 1
    end
    rowmeanvec = zeros(Float32, N, 1)
    colsumvec = zeros(Float32, M, 1)
    maskvec = zeros(Float32, M, 1)
    if rowmeanlist != ""
        rowmeanvec = readcsv(rowmeanlist, Float32)
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
        N = read(file, Int64) # Number of Features (e.g. Genes)
        M = read(file, Int64) # Number of samples (e.g. Cells)
        for n = 1:N
            # Data Import
            x = deserializex(n, file, logscale, pseudocount, masklist, maskvec, rowmeanlist, rowmeanvec, colsumlist, colsumvec)
            AllVar = AllVar + x' * x
        end
    end
    # directory for log file
    if typeof(logdir) == String
        if(!isdir(logdir))
            mkdir(logdir)
        end
    end
    return pseudocount, stepsize, g, epsilon, W, v, D, rowmeanvec, colsumvec, maskvec, N, M, AllVar
end

# Eigen value, Loading, Scores
function WλV(W::AbstractArray, input::AbstractString, dim::Number)
    V = zeros(Float32, 0)
    Scores = zeros(Float32, 0)
    N = 0
    M = 0
    open(input) do file
        N = read(file, Int64)  # Number of Features (e.g. Genes)
        M = read(file, Int64) # Number of samples (e.g. Cells)
        V = zeros(Float32, N, dim)
        Scores = zeros(Float32, M, dim)
        for n = 1:N
            # Data Import
            x = deserialize(file)
            V[n, :] = x' * W
        end
    end
    # Eigen value
    λ = Float32[norm(V[:, x]) for x=1:dim]
    for n = 1:dim
        V[:, n] .= V[:, n] ./ λ[n]
    end

    # λ .= λ .* λ ./ N
    λ .= 1 ./ (M .* λ)

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
function outputlog(s::Number, input::AbstractString, logdir::AbstractString, W::AbstractArray, pca::GD, AllVar::Number, logscale::Bool, pseudocount::Number, masklist::AbstractString, maskvec::AbstractArray, rowmeanlist::AbstractString, rowmeanvec::AbstractArray, colsumlist::AbstractString, colsumvec::AbstractArray)
    REs = RecError(W, input, AllVar, logscale, pseudocount, masklist, maskvec, rowmeanlist, rowmeanvec, colsumlist, colsumvec)
    writecsv("$(logdir)/W_$(string(s)).csv", W)
    writecsv("$(logdir)/RecError_$(string(s)).csv", REs)
    touch("$(logdir)/W_$(string(s)).csv")
    touch("$(logdir)/RecError_$(string(s)).csv")
end

# Output log file (other PCA)
function outputlog(N::Number, s::Number, n::Number, input::AbstractString, logdir::AbstractString, W::AbstractArray, pca::Union{OJA,CCIPCA,RSGD,SVRG,RSVRG}, AllVar::Number, logscale::Bool, pseudocount::Number, masklist::AbstractString, maskvec::AbstractArray, rowmeanlist::AbstractString, rowmeanvec::AbstractArray, colsumlist::AbstractString, colsumvec::AbstractArray)
    if(mod((N*(s-1)+n), 5000) == 0)
        REs = RecError(W, input, AllVar, logscale, pseudocount, masklist, maskvec, rowmeanlist, rowmeanvec, colsumlist, colsumvec)
        writecsv("$(logdir)/W_$(string((N*(s-1)+n))).csv", W)
        writecsv("$(logdir)/RecError_$(string((N*(s-1)+n))).csv", REs)
        touch("$(logdir)/W_$(string((N*(s-1)+n))).csv")
        touch("$(logdir)/RecError_$(string((N*(s-1)+n))).csv")
    end
end

# Reconstuction Error
function RecError(W::AbstractArray, input::AbstractString, AllVar::Number, logscale::Bool, pseudocount::Number, masklist::AbstractString, maskvec::AbstractArray, rowmeanlist::AbstractString, rowmeanvec::AbstractArray, colsumlist::AbstractString, colsumvec::AbstractArray)
    N = 0
    M = 0
    E = 0.0
    AE = 0.0
    RMSE = 0.0
    ARE = 0.0
    open(input) do file
        N = read(file, Int64)  # Number of Features (e.g. Genes)
        M = read(file, Int64) # Number of samples (e.g. Cells)
        for n = 1:N
            # Data Import
            x = deserializex(n, file, logscale, pseudocount, masklist, maskvec, rowmeanlist, rowmeanvec, colsumlist, colsumvec)
            preE = W * (W' * x) .- x
            E = E + dot(preE, preE)
        end
    end
    AE = E / M
    RMSE = sqrt(E / (N * M))
    AllVar = sqrt(AllVar)
    ARE = sqrt(E) / AllVar
    # Return
    return ["E"=>E, "AE"=>AE, "RMSE"=>RMSE, "ARE"=>ARE, "AllVar"=>AllVar]
end

# deserialization
function deserializex(n::Number, file::IOStream, logscale::Bool, pseudocount::Number, masklist::AbstractString, maskvec::AbstractArray, rowmeanlist::AbstractString, rowmeanvec::AbstractArray, colsumlist::AbstractString, colsumvec::AbstractArray)
    x = deserialize(file)
    if logscale
        @fastmath x = log10.(x + pseudocount)
    end
    if masklist != ""
        x = x[maskvec]
    end
    if (rowmeanlist != "") && (colsumlist != "")
        x = (x - rowmeanvec[n, 1]) ./ colsumvec
    end
    if (rowmeanlist != "") && (colsumlist == "")
        x .= x .- rowmeanvec[n, 1]
    end
    if (rowmeanlist == "") && (colsumlist != "")
        x = x ./ colsumvec
    end
    return x
end

# Full Gradient
function ∇f(W::AbstractArray, input::AbstractString, D::AbstractArray, logscale::Bool, pseudocount::Number, masklist::AbstractString, maskvec::AbstractArray, rowmeanlist::AbstractString, rowmeanvec::AbstractArray, colsumlist::AbstractString, colsumvec::AbstractArray)
    tmpW = W
    open(input) do file
        N = read(file, Int64) # Number of Features (e.g. Genes)
        M = read(file, Int64) # Number of samples (e.g. Cells)
        for n = 1:N
            # Data Import
            x = deserializex(n, file, logscale, pseudocount, masklist, maskvec, rowmeanlist, rowmeanvec, colsumlist, colsumvec)
            # Full Gradient
            tmpW .= tmpW .+ ∇fn(W, x, D, M)
        end
    end
    return tmpW
end

# Stochastic Gradient
function ∇fn(W::AbstractArray, x::AbstractArray, D::AbstractArray, M::Number)
    return Float32(2 / M) * x * (x' * W * D)
end

# sym
function sym(Y::AbstractArray)
    return (Y + Y') / 2
end

# Riemannian Gradient
function Pw(Z::AbstractArray, W::AbstractArray)
    return Z - W * sym(W' * Z)
end
