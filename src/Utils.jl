# using ProgressMeter
# using ArgParse
# using StatsBase
# using DataFrames
# using GLM
# using Distributions

function init(slfile)
    N = 0
    M = 0
    open(slfile) do file
        N = read(file, Int64)
        M = read(file, Int64)
    end
    return N, M
end

# Eigen value, Loading, Scores
function WλV(W, input, dim)
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

# Reconstuction Error
function RecError(W, input)
    N = 0
    M = 0
    E = 0.0
    AE = 0.0
    RMSE = 0.0
    AllVar = 0.0
    ARE = 0.0
    open(input) do file
        N = read(file, Int64)  # Number of Features (e.g. Genes)
        M = read(file, Int64) # Number of samples (e.g. Cells)
        for n = 1:N
            # Data Import
            x = deserialize(file)
            AllVar = AllVar + x' * x
            preE = (x' * W) * W' .- x'
            E = E + sum(preE .* preE)
        end
    end
    AE = E / M
    RMSE = sqrt(E / (N * M))
    AllVar = sqrt(AllVar)
    ARE = sqrt(E) / AllVar
    # Return
    return ["E"=>E, "AE"=>AE, "RMSE"=>RMSE, "ARE"=>ARE, "AllVar"=>AllVar]
end

# Full Gradient
function ∇f(W, input, D, N, M)
    tmpW = W
    open(input) do file
        N = read(file, Int64) # Number of Features (e.g. Genes)
        M = read(file, Int64) # Number of samples (e.g. Cells)
        for n = 1:N
            # Data Import
            x = deserialize(file)
            # Full Gradient
            tmpW .= tmpW .+ ∇fn(W, x, D, M)
        end
        return tmpW
    end
end

# Stochastic Gradient
function ∇fn(W, x, D, M)
    return Float32(2 / M) * x * (x' * W * D)
end

# sym
function sym(Y)
    return (Y + Y') / 2
end

# Riemannian Gradient
function Pw(Z, W)
    return Z - W * sym(W' * Z)
end

# Options
function parse_commandline()
    s = ArgParseSettings()

    @add_arg_table s begin
        "--input", "-i"
            help = "input file"
            required = true
        "--output", "-o"
            help = "output file"
            default = "."
            required = false
        "--logscale"
            help = "whether the value are converted to log-scale"
            arg_type = Bool
            default = true
        "--pseudocount", "-p"
            help = "log10(exp + pseudocount)"
            arg_type = Float64
            default = 1.0
        "--meanlist", "-m"
            help = "mean vector of each gene"
            default = ""
            required = false
        "--liblist"
            help = "library size of each cell"
            default = ""
            required = false
        "--cellmasklist"
            help = "Cells to be remove"
            default = ""
            required = false
        "--dim", "-d"
            help = "dimention of PCA"
            arg_type = Int
            default = 3
        "--stepsize", "-s"
            help = "stepsize of PCA"
            arg_type = Float64
            default = 0.1
        "--numepoch", "-e"
            help = "numepoch of PCA"
            arg_type = Int
            default = 5
        "--scheduling"
            help = "Learning Rate Scheduling"
            arg_type = String
            default = "robbins-monro"
        "-g"
            help = "Ratio of non-SGD gradient"
            arg_type = Float64
            default = 0.9
        "--epsilon"
            help = "a small number for avoiding zero division"
            arg_type = Float64
            default = 0.00000001
        "--logfile", "-l"
            help = "saving log file"
            default = false
    end

    return parse_args(s)
end
