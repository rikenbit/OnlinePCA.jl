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
oja(;input="", outdir=".", logscale=true, pseudocount=1, rowmeanlist="", colsumlist="", masklist="", dim=3, stepsize=0.1, numepoch=5, scheduling="robbins-monro", g=0.9, epsilon=1.0e-8, logdir=nothing)
```

## CCIPCA
```@docs
ccipca(;input="", outdir=".", logscale=true, pseudocount=1, rowmeanlist="", colsumlist="", masklist="", dim=3, stepsize=0.1, numepoch=5, logdir=nothing)
```

## GD
```@docs
gd(;input="", outdir=".", logscale=true, pseudocount=1, rowmeanlist="", colsumlist="", masklist="", dim=3, stepsize=0.1, numepoch=5, scheduling="robbins-monro", g=0.9, epsilon=1.0e-8, logdir=nothing)
```

## RSGD
```@docs
rsgd(;input="", outdir=".", logscale=true, pseudocount=1, rowmeanlist="", colsumlist="", masklist="", dim=3, stepsize=0.1, numepoch=5, scheduling="robbins-monro", g=0.9, epsilon=1.0e-8, logdir=nothing)
```

## SVRG
```@docs
svrg(;input="", outdir=".", logscale=true, pseudocount=1, rowmeanlist="", colsumlist="", masklist="", dim=3, stepsize=0.1, numepoch=5, scheduling="robbins-monro", g=0.9, epsilon=1.0e-8, logdir=nothing)
```

## RSVRG
```@docs
rsvrg(;input="", outdir=".", logscale=true, pseudocount=1, rowmeanlist="", colsumlist="", masklist="", dim=3, stepsize=0.1, numepoch=5, scheduling="robbins-monro", g=0.9, epsilon=1.0e-8, logdir=nothing)
```
