# OnlinePCA.jl (Julia API)

## Binarization
```@docs
csv2sl(;csvfile="", slfile="")
```

## Summarization
```@docs
sumr(;slfile="", outdir=".", pseudocount=1.0)
```

## Filtering
```@docs
filtering(;slfile="", featurelist="", thr=0, outdir=".")
```

## Identifying Highly Variable Genes
```@docs
hvg(;slfile="", rowmeanlist="", rowvarlist="", rowcv2list="", outdir=".")
```

## Oja
```@docs
oja(;input::String="", outdir=nothing, logscale::Bool=true, pseudocount::Float64=1.0, rowmeanlist::String="", colsumlist::String="", masklist::String="", dim::Int64=3, stepsize::Float64=0.1, numepoch::Int64=5, scheduling::String="robbins-monro", g::Float64=0.9, epsilon::Float64=1.0e-8, logdir=nothing)
```

## CCIPCA
```@docs
ccipca(;input::String="", outdir=nothing, logscale::Bool=true, pseudocount::Float64=1.0, rowmeanlist::String="", colsumlist::String="", masklist::String="", dim::Int64=3, stepsize::Float64=0.1, numepoch::Int64=5, logdir=nothing)
```

## GD
```@docs
gd(;input::String="", outdir=nothing, logscale::Bool=true, pseudocount::Float64=1.0, rowmeanlist::String="", colsumlist::String="", masklist::String="", dim::Int64=3, stepsize::Float64=0.1, numepoch::Int64=5, scheduling::String="robbins-monro", g::Float64=0.9, epsilon::Float64=1.0e-8, logdir=nothing)
```

## RSGD
```@docs
rsgd(;input::String="", outdir=nothing, logscale::Bool=true, pseudocount::Float64=1.0, rowmeanlist::String="", colsumlist::String="", masklist::String="", dim::Int64=3, stepsize::Float64=0.1, numepoch::Int64=5, scheduling::String="robbins-monro", g::Float64=0.9, epsilon::Float64=1.0e-8, logdir=nothing)
```

## SVRG
```@docs
svrg(;input::String="", outdir=nothing, logscale::Bool=true, pseudocount::Float64=1.0, rowmeanlist::String="", colsumlist::String="", masklist::String="", dim::Int64=3, stepsize::Float64=0.1, numepoch::Int64=5, scheduling::String="robbins-monro", g::Float64=0.9, epsilon::Float64=1.0e-8, logdir=nothing)
```

## RSVRG
```@docs
rsvrg(;input::String="", outdir=nothing, logscale::Bool=true, pseudocount::Float64=1.0, rowmeanlist::String="", colsumlist::String="", masklist::String="", dim::Int64=3, stepsize::Float64=0.1, numepoch::Int64=5, scheduling::String="robbins-monro", g::Float64=0.9, epsilon::Float64=1.0e-8, logdir=nothing)
```
