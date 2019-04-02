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
filtering(;input::AbstractString="", featurelist::AbstractString="", samplelist::AbstractString="", thr1::Number=0.0, thr2::Number=0.0, direct1::AbstractString="+", direct2::AbstractString="+", outdir::AbstractString=".")
```

## Identifying Highly Variable Genes
```@docs
hvg(;binfile::AbstractString="", rowmeanlist::AbstractString="", rowvarlist::AbstractString="", rowcv2list::AbstractString="", outdir::AbstractString=".")
```

## GD-PCA
```@docs
gd(;input::AbstractString="", outdir::Union{Nothing,AbstractString}=nothing, scale::AbstractString="ftt", pseudocount::Number=1.0, rowmeanlist::AbstractString="", rowvarlist::AbstractString="",colsumlist::AbstractString="", dim::Number=3, stepsize::Number=0.1, numepoch::Number=3, scheduling::AbstractString="robbins-monro", g::Number=0.9, epsilon::Number=1.0e-8, lower::Number=0, upper::Number=1.0f+38, expvar::Number=0.1f0, evalfreq::Number=5000, offsetFull::Number=1f-20, offsetStoch::Number=1f-6, initW::Union{Nothing,AbstractString}=nothing, initV::Union{Nothing,AbstractString}=nothing, logdir::Union{Nothing,AbstractString}=nothing, perm::Bool=false)
```

## SGD-PCA
```@docs
sgd(;input::AbstractString="", outdir::Union{Nothing,AbstractString}=nothing, scale::AbstractString="ftt", pseudocount::Number=1.0, rowmeanlist::AbstractString="", rowvarlist::AbstractString="", colsumlist::AbstractString="", dim::Number=3, stepsize::Number=0.1, numbatch::Number=100, numepoch::Number=3, scheduling::AbstractString="robbins-monro", g::Number=0.9, epsilon::Number=1.0e-8, lower::Number=0, upper::Number=1.0f+38, expvar::Number=0.1f0, evalfreq::Number=5000, offsetFull::Number=1f-20, offsetStoch::Number=1f-6, initW::Union{Nothing,AbstractString}=nothing, initV::Union{Nothing,AbstractString}=nothing, logdir::Union{Nothing,AbstractString}=nothing, perm::Bool=false)
```

## Oja's method
```@docs
oja(;input::AbstractString="", outdir::Union{Nothing,AbstractString}=nothing, scale::AbstractString="ftt", pseudocount::Number=1.0, rowmeanlist::AbstractString="", rowvarlist::AbstractString="", colsumlist::AbstractString="", dim::Number=3, stepsize::Number=0.1, numepoch::Number=3, scheduling::AbstractString="robbins-monro", g::Number=0.9, epsilon::Number=1.0e-8, lower::Number=0, upper::Number=1.0f+38, expvar::Number=0.1f0, evalfreq::Number=5000, offsetFull::Number=1f-20, offsetStoch::Number=1f-6, initW::Union{Nothing,AbstractString}=nothing, initV::Union{Nothing,AbstractString}=nothing, logdir::Union{Nothing,AbstractString}=nothing, perm::Bool=false)
```

## CCIPCA
```@docs
ccipca(;input::AbstractString="", outdir::Union{Nothing,AbstractString}=nothing, scale::AbstractString="ftt", pseudocount::Number=1.0, rowmeanlist::AbstractString="", rowvarlist::AbstractString="",colsumlist::AbstractString="", dim::Number=3, stepsize::Number=0, numepoch::Number=3, lower::Number=0, upper::Number=1.0f+38, expvar::Number=0.1f0, evalfreq::Number=5000, offsetStoch::Number=1f-6, initW::Union{Nothing,AbstractString}=nothing, initV::Union{Nothing,AbstractString}=nothing, logdir::Union{Nothing,AbstractString}=nothing, perm::Bool=false)
```

## RSGD-PCA
```@docs
rsgd(;input::AbstractString="", outdir::Union{Nothing,AbstractString}=nothing, scale::AbstractString="ftt", pseudocount::Number=1.0, rowmeanlist::AbstractString="", rowvarlist::AbstractString="",colsumlist::AbstractString="", dim::Number=3, stepsize::Number=0.1, numbatch::Number=100, numepoch::Number=3, scheduling::AbstractString="robbins-monro", g::Number=0.9, epsilon::Number=1.0e-8, lower::Number=0, upper::Number=1.0f+38, expvar::Number=0.1f0, evalfreq::Number=5000, offsetFull::Number=1f-20, offsetStoch::Number=1f-6, initW::Union{Nothing,AbstractString}=nothing, initV::Union{Nothing,AbstractString}=nothing, logdir::Union{Nothing,AbstractString}=nothing, perm::Bool=false)
```

## SVRG-PCA
```@docs
svrg(;input::AbstractString="", outdir::Union{Nothing,AbstractString}=nothing, scale::AbstractString="ftt", pseudocount::Number=1.0, rowmeanlist::AbstractString="", rowvarlist::AbstractString="", colsumlist::AbstractString="", dim::Number=3, stepsize::Number=0.1, numbatch::Number=100, numepoch::Number=3, scheduling::AbstractString="robbins-monro", g::Number=0.9, epsilon::Number=1.0e-8, lower::Number=0, upper::Number=1.0f+38, expvar::Number=0.1f0, evalfreq::Number=5000, offsetFull::Number=1f-20, offsetStoch::Number=1f-6, initW::Union{Nothing,AbstractString}=nothing, initV::Union{Nothing,AbstractString}=nothing, logdir::Union{Nothing,AbstractString}=nothing, perm::Bool=false)
```

## RSVRG-PCA
```@docs
rsvrg(;input::AbstractString="", outdir::Union{Nothing,AbstractString}=nothing, scale::AbstractString="ftt", pseudocount::Number=1.0, rowmeanlist::AbstractString="", rowvarlist::AbstractString="",colsumlist::AbstractString="", dim::Number=3, stepsize::Number=0.1, numbatch::Number=100, numepoch::Number=3, scheduling::AbstractString="robbins-monro", g::Number=0.9, epsilon::Number=1.0e-8, lower::Number=0, upper::Number=1.0f+38, expvar::Number=0.1f0, evalfreq::Number=5000, offsetFull::Number=1f-20, offsetStoch::Number=1f-6, initW::Union{Nothing,AbstractString}=nothing, initV::Union{Nothing,AbstractString}=nothing, logdir::Union{Nothing,AbstractString}=nothing, perm::Bool=false)
```

## Orthogonal Iteration (Power method)
```@docs
orthiter(;input::AbstractString="", outdir::Union{Nothing,AbstractString}=nothing, scale::AbstractString="ftt", pseudocount::Number=1.0, rowmeanlist::AbstractString="", rowvarlist::AbstractString="",colsumlist::AbstractString="", dim::Number=3, numepoch::Number=10, lower::Number=0, upper::Number=1.0f+38, expvar::Number=0.1f0, initW::Union{Nothing,AbstractString}=nothing, initV::Union{Nothing,AbstractString}=nothing, logdir::Union{Nothing,AbstractString}=nothing, perm::Bool=false)
```

## Arnoldi method
```@docs
arnoldi(;input::AbstractString="", outdir::Union{Nothing,AbstractString}=nothing, scale::AbstractString="ftt", pseudocount::Number=1.0, rowmeanlist::AbstractString="", rowvarlist::AbstractString="",colsumlist::AbstractString="", dim::Number=3, numepoch::Number=10, perm::Bool=false)
```

## Lanczos method
```@docs
lanczos(;input::AbstractString="", outdir::Union{Nothing,AbstractString}=nothing, scale::AbstractString="ftt", pseudocount::Number=1.0, rowmeanlist::AbstractString="", rowvarlist::AbstractString="",colsumlist::AbstractString="", dim::Number=3, numepoch::Number=10, perm::Bool=false)
```

## Halko's method
```@docs
halko(;input::AbstractString="", outdir::Union{Nothing,AbstractString}=nothing, scale::AbstractString="ftt", pseudocount::Number=1.0, rowmeanlist::AbstractString="", rowvarlist::AbstractString="", colsumlist::AbstractString="", dim::Number=3, noversamples::Number=5, niter::Number=3, initW::Union{Nothing,AbstractString}=nothing, initV::Union{Nothing,AbstractString}=nothing, logdir::Union{Nothing,AbstractString}=nothing, perm::Bool=false)
```

## Algorithm 971
```@docs
algorithm971(;input::AbstractString="", outdir::Union{Nothing,AbstractString}=nothing, scale::AbstractString="ftt", pseudocount::Number=1.0, rowmeanlist::AbstractString="", rowvarlist::AbstractString="", colsumlist::AbstractString="", dim::Number=3, noversamples::Number=5, niter::Number=3, initW::Union{Nothing,AbstractString}=nothing, initV::Union{Nothing,AbstractString}=nothing, logdir::Union{Nothing,AbstractString}=nothing, perm::Bool=false)
```

## Randomized Block Krylov Iteration
```@docs
rbkiter(;input::AbstractString="", outdir::Union{Nothing,AbstractString}=nothing, scale::AbstractString="ftt", pseudocount::Number=1.0, rowmeanlist::AbstractString="", rowvarlist::AbstractString="",colsumlist::AbstractString="", dim::Number=3, numepoch::Number=10, lower::Number=0, upper::Number=1.0f+38, expvar::Number=0.1f0, initW::Union{Nothing,AbstractString}=nothing, initV::Union{Nothing,AbstractString}=nothing, logdir::Union{Nothing,AbstractString}=nothing, perm::Bool=false)
```

## Single-pass PCA type I
```@docs
singlepass(;input::AbstractString="", outdir::Union{Nothing,AbstractString}=nothing, scale::AbstractString="ftt", pseudocount::Number=1.0, rowmeanlist::AbstractString="", rowvarlist::AbstractString="", colsumlist::AbstractString="", dim::Number=3, noversamples::Number=5, niter::Number=3, initW::Union{Nothing,AbstractString}=nothing, initV::Union{Nothing,AbstractString}=nothing, logdir::Union{Nothing,AbstractString}=nothing, perm::Bool=false)
```

## Single-pass PCA type II
```@docs
singlepass2(;input::AbstractString="", outdir::Union{Nothing,AbstractString}=nothing, scale::AbstractString="ftt", pseudocount::Number=1.0, rowmeanlist::AbstractString="", rowvarlist::AbstractString="", colsumlist::AbstractString="", dim::Number=3, noversamples::Number=5, niter::Number=3, initW::Union{Nothing,AbstractString}=nothing, initV::Union{Nothing,AbstractString}=nothing, logdir::Union{Nothing,AbstractString}=nothing, perm::Bool=false)
```

## Summarization for 10X-HDF5
```@docs
tenxsumr(;tenxfile::AbstractString="", outdir::AbstractString=".", group::AbstractString="", chunksize::Number=5000)
```

## ALGORITHM971 for 10X-HDF5
```@docs
tenxpca(;tenxfile::AbstractString="", outdir::Union{Nothing,AbstractString}=nothing, scale::AbstractString="sqrt", rowmeanlist::AbstractString="", rowvarlist::AbstractString="", colsumlist::AbstractString="", dim::Number=3, noversamples::Number=5, niter::Number=3, chunksize::Number=5000, group::AbstractString, initW::Union{Nothing,AbstractString}=nothing, initV::Union{Nothing,AbstractString}=nothing, logdir::Union{Nothing,AbstractString}=nothing, perm::Bool=false)
```