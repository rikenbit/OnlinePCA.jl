include("Utils.jl")

function rsvrg(;input="", output=".", dim=3, stepsize=0.1, numepoch=5, scheduling="robbins-monro", g=0.9, epsilon=0.00000001, logfile=false)
    W = zeros(Float32, 0) # 固有ベクトル
    Ws = zeros(Float32, 0) # 固有ベクトル
    D = Diagonal(reverse(1:dim)) / 10^5 # 対角行列
    N = 0 # 遺伝子数
    M = 0 # 細胞数
    v = zeros(Float32, 0) # 中間ベクトル（xと同じ長さ）

    # Initialization
    open(input) do file
        N = read(file, Int64)
        M = read(file, Int64)
    end
    W = zeros(Float32, M, dim)
    v = zeros(Float32, M, dim)
    for i=1:dim
        W[i,i] = 1
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
        u = ∇f(W, input, D)
        Ws = W
        open(input) do file
            N = read(file, Int64)
            M = read(file, Int64)
            for n = 1:N
                # Data Import
                x = deserialize(file)

                if scheduling == "robbins-monro"
                    # RSVRG × Robbins-Monro
                    W .= W .+ stepsize/(N*(s-1)+n) .* (Pw(∇fn(W, x, D), W) .- Pw(∇fn(Ws, x, D), Ws) .+ u)
                elseif scheduling == "momentum"
                    # RSVRG × Momentum
                    v .= g .* v .+ Float32(stepsize) .* (Pw(∇fn(W, x, D), W) .- Pw(∇fn(Ws, x, D), Ws) .+ u)
                    W .= W .+ v
                elseif scheduling == "nam"
                    # RSVRG × NAM
                    v = g .* v + Float32(stepsize) .* (Pw(∇fn(W - g .* v, x, D), W - g .* v) .- Pw(∇fn(Ws, x, D), Ws) .+ u)
                    W .= W .+ v
                elseif scheduling == "adagrad"
                    # RSVRG × Adagrad
                    grad = (Pw(∇fn(W, x, D), W) .- Pw(∇fn(Ws, x, D), Ws) .+ u)
                    v .= v .+ grad .* grad
                    W .= W .+ Float32(stepsize) ./ (sqrt.(v) + epsilon) .* grad
                else
                    println("Specify the scheduling as robbins-monro, momentum, nam or adagrad")
                    quit()
                end

                # Retraction
                W .= full(qrfact!(W)[:Q], thin=true)
                # save log file
                if typeof(logfile) == String
                     if(mod((N*(s-1)+n), 1000) == 0)
                        writecsv(logfile * "/W_" * string((N*(s-1)+n)) * ".csv", W)
                        touch(logfile * "/W_" * string((N*(s-1)+n)) * ".csv")
                    end
                end
            end
        end
        next!(progress)
    end
    # Return, W, λ, V
    WλV(W, input, dim)
end

function main()
    parsed_args = parse_commandline()
    println("Parsed args:")
    for (arg,val) in parsed_args
        println("  $arg  =>  $val")
    end

    out = rsvrg(input=parsed_args["input"],
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

# # test
# @time out1 = rsvrg(input="test.dat", dim=3, stepsize=0.1, numepoch=5)
# @time out2 = rsvrg(input="test2.dat", dim=3, stepsize=0.1, numepoch=5)
# @time out3 = rsvrg(input="test3.dat", dim=3, stepsize=0.1, numepoch=5)
# @time out4 = rsvrg(input="test3.dat", dim=30, stepsize=0.1, numepoch=5)

# # Batch PCAと比較
# Cval = readcsv("/data2/koki/ICCIPCA/Data/Cortical_SMART/PCA/Eigen_values.csv")
# Cvec = readcsv("/data2/koki/ICCIPCA/Data/Cortical_SMART/PCA/Eigen_vectors.csv")
# abs(cor(Cvec[1:10,:]', rsvrg(input="test2.dat", dim=10, stepsize=0.1, numepoch=5)[1]))
