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
hvg(slfile, rowmeanlist, rowvarlist, rowcv2list, outdir)
```

## Oja
```@docs
oja(;input="", output=".", logscale=true, pseudocount=1, rowmeanlist="", colsumlist="", masklist="", dim=3, stepsize=0.1, numepoch=5, scheduling="robbins-monro", g=0.9, epsilon=1.0e-8, logfile=false)
```

## CCIPCA
```@docs
ccipca(;input="", output=".", logscale=true, pseudocount=1, rowmeanlist="", colsumlist="", masklist="", dim=3, stepsize=0.1, numepoch=5, logfile=false)
```

## GD
```@docs
gd(;input="", output=".", logscale=true, pseudocount=1, rowmeanlist="", colsumlist="", masklist="", dim=3, stepsize=0.1, numepoch=5, scheduling="robbins-monro", g=0.9, epsilon=1.0e-8, logfile=false)
```

## RSGD
```@docs
rsgd(;input="", output=".", logscale=true, pseudocount=1, rowmeanlist="", colsumlist="", masklist="", dim=3, stepsize=0.1, numepoch=5, scheduling="robbins-monro", g=0.9, epsilon=1.0e-8, logfile=false)
```

## SVRG
```@docs
svrg(;input="", output=".", logscale=true, pseudocount=1, rowmeanlist="", colsumlist="", masklist="", dim=3, stepsize=0.1, numepoch=5, scheduling="robbins-monro", g=0.9, epsilon=1.0e-8, logfile=false)
```

## RSVRG
```@docs
rsvrg(;input="", output=".", logscale=true, pseudocount=1, rowmeanlist="", colsumlist="", masklist="", dim=3, stepsize=0.1, numepoch=5, scheduling="robbins-monro", g=0.9, epsilon=1.0e-8, logfile=false)
```
