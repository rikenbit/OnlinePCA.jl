# OnlinePCA.jl (Julia API)

## Binarization
```@docs
csv2bin(;csvfile::AbstractString="", binfile::AbstractString="")
```

## Summarization
```@docs
sumr(;binfile::AbstractString="", outdir::AbstractString=".", pseudocount::Number=1.0)
```

## Filtering
```@docs
filtering(;binfile::AbstractString="", featurelist::AbstractString="", thr::Number=0, outdir::AbstractString=".")
```

## Identifying Highly Variable Genes
```@docs
hvg(;binfile::AbstractString="", rowmeanlist::AbstractString="", rowvarlist::AbstractString="", rowcv2list::AbstractString="", outdir::AbstractString=".")
```

## Oja
```@docs
oja(;input::AbstractString="", outdir::Union{Void,AbstractString}=nothing, logscale::Bool=true, pseudocount::Number=1.0, rowmeanlist::AbstractString="", colsumlist::AbstractString="", masklist::AbstractString="", dim::Number=3, stepsize::Number=0.1, numepoch::Number=5, scheduling::AbstractString="robbins-monro", g::Number=0.9, epsilon::Number=1.0e-8, logdir::Union{Void,AbstractString}=nothing)
```

## CCIPCA
```@docs
ccipca(;input::AbstractString="", outdir::Union{Void,AbstractString}=nothing, logscale::Bool=true, pseudocount::Number=1.0, rowmeanlist::AbstractString="", colsumlist::AbstractString="", masklist::AbstractString="", dim::Number=3, stepsize::Number=0.1, numepoch::Number=5, logdir::Union{Void,AbstractString}=nothing)
```

## GD
```@docs
gd(;input::AbstractString="", outdir::Union{Void,AbstractString}=nothing, logscale::Bool=true, pseudocount::Number=1.0, rowmeanlist::AbstractString="", colsumlist::AbstractString="", masklist::AbstractString="", dim::Number=3, stepsize::Number=0.1, numepoch::Number=5, scheduling::AbstractString="robbins-monro", g::Number=0.9, epsilon::Number=1.0e-8, logdir::Union{Void,AbstractString}=nothing)
```

## RSGD
```@docs
rsgd(;input::AbstractString="", outdir::Union{Void,AbstractString}=nothing, logscale::Bool=true, pseudocount::Number=1.0, rowmeanlist::AbstractString="", colsumlist::AbstractString="", masklist::AbstractString="", dim::Number=3, stepsize::Number=0.1, numepoch::Number=5, scheduling::AbstractString="robbins-monro", g::Number=0.9, epsilon::Number=1.0e-8, logdir::Union{Void,AbstractString}=nothing)
```

## SVRG
```@docs
svrg(;input::AbstractString="", outdir::Union{Void,AbstractString}=nothing, logscale::Bool=true, pseudocount::Number=1.0, rowmeanlist::AbstractString="", colsumlist::AbstractString="", masklist::AbstractString="", dim::Number=3, stepsize::Number=0.1, numepoch::Number=5, scheduling::AbstractString="robbins-monro", g::Number=0.9, epsilon::Number=1.0e-8, logdir::Union{Void,AbstractString}=nothing)
```

## RSVRG
```@docs
rsvrg(;input::AbstractString="", outdir::Union{Void,AbstractString}=nothing, logscale::Bool=true, pseudocount::Number=1.0, rowmeanlist::AbstractString="", colsumlist::AbstractString="", masklist::AbstractString="", dim::Number=3, stepsize::Number=0.1, numepoch::Number=5, scheduling::AbstractString="robbins-monro", g::Number=0.9, epsilon::Number=1.0e-8, logdir::Union{Void,AbstractString}=nothing)
```
