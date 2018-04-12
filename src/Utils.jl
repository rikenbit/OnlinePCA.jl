using ProgressMeter
using ArgParse
using HDF5

# 固有値と逆側の固有ベクトルを返す
function WλV(W, input, dim)
    V = zeros(Float32, 0)
    N = 0
    M = 0
    open(input) do file
        N = read(file, Int64)  # no.gene
        M = read(file, Int64) # no.cell
        V = zeros(Float32, N, dim)
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
    λ .= λ .* λ ./ N
    # 多分
    # λ .= 1 ./ (λ .* N)
    # が正解
    # Sort by Eigen value
    idx = sortperm(λ, rev=true)
    W .= W[:, idx]
    λ .= λ[idx]
    V .= V[:, idx]
    # Return
    return W, λ, V
end

# 再構築誤差
function RecError(W, input)
    N = 0
    M = 0
    E = 0.0
    AE = 0.0
    RMSE = 0.0
    AllVar = 0.0
    ARE = 0.0
    open(input) do file
        N = read(file, Int64)  # no.gene
        M = read(file, Int64) # no.cell
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

# 全勾配
function ∇f(W, input, D, N, M)
    tmpW = W
    open(input) do file
        N = read(file, Int64) # no. gene
        M = read(file, Int64) # no. cell
        for n = 1:N
            # Data Import
            x = deserialize(file)
            # Full Gradient
            tmpW .= tmpW .+ ∇fn(W, x, D, M)
        end
        return tmpW
    end
end

# 確率勾配
function ∇fn(W, x, D, M)
    return Float32(2 / M) * x * (x' * W * D)
end

# sym
function sym(Y)
    return (Y + Y') / 2
end

# リーマン勾配
function Pw(Z, W)
    return Z - W * sym(W' * Z)
end

# オプション設定
function parse_commandline()
    s = ArgParseSettings()

    @add_arg_table s begin
        "--input", "-i"
            help = "input file"
            required = true
        "--output", "-o"
            help = "output file"
            default = "."
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
