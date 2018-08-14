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
filtering(;input::AbstractString="", featurelist::AbstractString="", samplelist::AbstractString="", thr1::Number=0, thr2::Number=0, direct1::AbstractString="+", direct2::AbstractString="+", output::AbstractString=".")
```

## Identifying Highly Variable Genes
```@docs
hvg(;binfile::AbstractString="", rowmeanlist::AbstractString="", rowvarlist::AbstractString="", rowcv2list::AbstractString="", outdir::AbstractString=".")
```

## Oja
```@docs
oja(;input::AbstractString="", outdir::Union{Void,AbstractString}=nothing, scale::AbstractString="ftt", pseudocount::Number=1.0, rowmeanlist::AbstractString="", rowvarlist::AbstractString="", colsumlist::AbstractString="", dim::Number=3, stepsize::Number=0.1, numepoch::Number=3, scheduling::AbstractString="robbins-monro", g::Number=0.9, epsilon::Number=1.0e-8, lower::Number=0, upper::Number=1.0f+38, expvar::Number=0.1f0, evalfreq::Number=5000, offsetFull::Number=1f-20, offsetStoch::Number=1f-6, logdir::Union{Void,AbstractString}=nothing, perm::Bool=false)
```

## CCIPCA
```@docs
ccipca(;input::AbstractString="", outdir::Union{Void,AbstractString}=nothing, scale::AbstractString="ftt", pseudocount::Number=1.0, rowmeanlist::AbstractString="", rowvarlist::AbstractString="",colsumlist::AbstractString="", dim::Number=3, stepsize::Number=0.1, numepoch::Number=3, lower::Number=0, upper::Number=1.0f+38, expvar::Number=0.1f0, evalfreq::Number=5000, offsetFull::Number=1f-20, offsetStoch::Number=1f-15, logdir::Union{Void,AbstractString}=nothing, perm::Bool=false)
```

## GD
```@docs
gd(;input::AbstractString="", outdir::Union{Void,AbstractString}=nothing, scale::AbstractString="ftt", pseudocount::Number=1.0, rowmeanlist::AbstractString="", rowvarlist::AbstractString="",colsumlist::AbstractString="", dim::Number=3, stepsize::Number=0.1, numepoch::Number=3, scheduling::AbstractString="robbins-monro", g::Number=0.9, epsilon::Number=1.0e-8, lower::Number=0, upper::Number=1.0f+38, expvar::Number=0.1f0, evalfreq::Number=5000, offsetFull::Number=1f-20, offsetStoch::Number=1f-6, logdir::Union{Void,AbstractString}=nothing, perm::Bool=false)
```

## RSGD
```@docs
rsgd(;input::AbstractString="", outdir::Union{Void,AbstractString}=nothing, scale::AbstractString="ftt", pseudocount::Number=1.0, rowmeanlist::AbstractString="", rowvarlist::AbstractString="",colsumlist::AbstractString="", dim::Number=3, stepsize::Number=0.1, numepoch::Number=3, scheduling::AbstractString="robbins-monro", g::Number=0.9, epsilon::Number=1.0e-8, lower::Number=0, upper::Number=1.0f+38, expvar::Number=0.1f0, evalfreq::Number=5000, offsetFull::Number=1f-20, offsetStoch::Number=1f-6, logdir::Union{Void,AbstractString}=nothing, perm::Bool=false)
```

## SVRG
```@docs
svrg(;input::AbstractString="", outdir::Union{Void,AbstractString}=nothing, scale::AbstractString="ftt", pseudocount::Number=1.0, rowmeanlist::AbstractString="", rowvarlist::AbstractString="", colsumlist::AbstractString="", dim::Number=3, stepsize::Number=0.1, numepoch::Number=3, scheduling::AbstractString="robbins-monro", g::Number=0.9, epsilon::Number=1.0e-8, lower::Number=0, upper::Number=1.0f+38, expvar::Number=0.1f0, evalfreq::Number=5000, offsetFull::Number=1f-20, offsetStoch::Number=1f-6, logdir::Union{Void,AbstractString}=nothing, perm::Bool=false)
```

## RSVRG
```@docs
rsvrg(;input::AbstractString="", outdir::Union{Void,AbstractString}=nothing, scale::AbstractString="ftt", pseudocount::Number=1.0, rowmeanlist::AbstractString="", rowvarlist::AbstractString="",colsumlist::AbstractString="", dim::Number=3, stepsize::Number=0.1, numepoch::Number=3, scheduling::AbstractString="robbins-monro", g::Number=0.9, epsilon::Number=1.0e-8, lower::Number=0, upper::Number=1.0f+38, expvar::Number=0.1f0, evalfreq::Number=5000, offsetFull::Number=1f-20, offsetStoch::Number=1f-6, logdir::Union{Void,AbstractString}=nothing, perm::Bool=false)
```
