include("Utils.jl")

function gd(;input="", output=".", dim=3, stepsize=0.1, numepoch=5, scheduling="robbins-monro", g=0.9, epsilon=0.00000001, logfile=false)
    W = zeros(Float32, 0) # 固有ベクトル
    D = Diagonal(reverse(1:dim)) # 対角行列
    N = 0 # 遺伝子数
    M = 0 # 細胞数
    v = zeros(Float32, 0) # 中間ベクトル（xと同じ長さ）

    # Initialization
    open(input) do file
        N = read(file, Int64)
        M = read(file, Int64)
        W = zeros(Float32, M, dim)
        v = zeros(Float32, M, dim)
        for i=1:dim
            W[i,i] = 1
        end
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
        if scheduling == "robbins-monro"
            # GD × Robbins-Monro
            W .= W .+ ∇f(W, input, D * Float32(stepsize)/s, N, M)
        elseif scheduling == "momentum"
            # GD × Momentum
            v .= g .* v .+ ∇f(W, input, D * Float32(stepsize), N, M)
            W .= W .+ v
        elseif scheduling == "nam"
            # GD × NAM
            v = g .* v + ∇f(W - g .* v, input, D * Float32(stepsize), N, M)
            W .= W .+ v
        elseif scheduling == "adagrad"
            # GD × Adagrad
            grad = ∇f(W, input, D * Float32(stepsize), N, M)
            v .= v .+ grad .* grad
            W .= W .+ Float32(stepsize) ./ (sqrt.(v) + epsilon) .* grad
        else
            println("Specify the scheduling as robbins-monro, momentum, nam or adagrad")
            quit()
        end
        # Retraction
        W .= full(qrfact!(W)[:Q], thin=true)
        next!(progress)
        # save log file
        if typeof(logfile) == String
            writecsv(logfile * "/W_" * string(s) * ".csv", W)
            writecsv(logfile * "/RecError_" * string(s) * ".csv", RecError(W, input))
            touch(logfile * "/W_" * string(s) * ".csv")
            touch(logfile * "/RecError_" * string(s) * ".csv")
        end
    end
    # Return, W, λ, V
    WλV(W, input, dim)
end

# Parse Augment
function main()
    parsed_args = parse_commandline()
    println("Parsed args:")
    for (arg,val) in parsed_args
        println("  $arg  =>  $val")
    end

    out = gd(input=parsed_args["input"],
        output=parsed_args["output"],
        dim=parsed_args["dim"],
        stepsize=parsed_args["stepsize"],
        numepoch=parsed_args["numepoch"],
        scheduling=parsed_args["scheduling"],
        g=parsed_args["g"],
        epsilon=parsed_args["epsilon"],
        logfile=parsed_args["logfile"])

    writecsv(parsed_args["output"]*"/Eigen_vectors.csv", out[1])
    writecsv(parsed_args["output"]*"/Eigen_values.csv", out[2])
    touch(parsed_args["output"]*"/Eigen_vectors.csv")
    touch(parsed_args["output"]*"/Eigen_values.csv")
end

main()


# using BenchmarkTools
# @benchmark out1 = gd(input="test2.dat", dim=30, stepsize=0.1, numepoch=5)

# @profile out1 = gd(input="test.dat", dim=3, stepsize=0.1, numepoch=5)

# # test
# @time out1 = gd(input="test.dat", dim=3, stepsize=0.1, numepoch=5)
# @time out2 = gd(input="test2.dat", dim=3, stepsize=0.1, numepoch=5)
# @time out3 = gd(input="test3.dat", dim=3, stepsize=0.1, numepoch=5)
# @time out4 = gd(input="test3.dat", dim=30, stepsize=0.1, numepoch=5)

# # Batch PCAと比較
# Cval = readcsv("/data2/koki/ICCIPCA/Data/Cortical_SMART/PCA/Eigen_values.csv")
# Cvec = readcsv("/data2/koki/ICCIPCA/Data/Cortical_SMART/PCA/Eigen_vectors.csv")
# abs(cor(Cvec[1:10,:]', gd(input="test2.dat", dim=10, stepsize=0.1, numepoch=5)[1]))
