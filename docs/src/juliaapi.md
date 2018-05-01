# OnlinePCA.jl (Julia API)

## Binarization
```@docs
csv2sl(;csvfile="", slfile="")
```

## Summary of data
```@docs
sumr(;slfile="", outdir=".", pseudocount=1.0)
```

## Oja
```@docs
oja(;input="", output=".", logscale=true, pseudocount=1, meanlist="", liblist="", cellmasklist="", dim=3, stepsize=0.1, numepoch=5, scheduling="robbins-monro", g=0.9, epsilon=0.00000001, logfile=false)
```

## CCIPCA
```@docs
ccipca(;input="", output=".", logscale=true, pseudocount=1, meanlist="", liblist="", cellmasklist="", dim=3, stepsize=0.1, numepoch=5, logfile=false)
```

## GD
```@docs
gd(;input="", output=".", logscale=true, pseudocount=1, meanlist="", liblist="", cellmasklist="", dim=3, stepsize=0.1, numepoch=5, scheduling="robbins-monro", g=0.9, epsilon=0.00000001, logfile=false)
```

## RSGD
```@docs
rsgd(;input="", output=".", logscale=true, pseudocount=1, meanlist="", liblist="", cellmasklist="", dim=3, stepsize=0.1, numepoch=5, scheduling="robbins-monro", g=0.9, epsilon=0.00000001, logfile=false)
```

## SVRG
```@docs
svrg(;input="", output=".", logscale=true, pseudocount=1, meanlist="", liblist="", cellmasklist="", dim=3, stepsize=0.1, numepoch=5, scheduling="robbins-monro", g=0.9, epsilon=0.00000001, logfile=false)
```

## RSVRG
```@docs
rsvrg(;input="", output=".", logscale=true, pseudocount=1, meanlist="", liblist="", cellmasklist="", dim=3, stepsize=0.1, numepoch=5, scheduling="robbins-monro", g=0.9, epsilon=0.00000001, logfile=false)
```
