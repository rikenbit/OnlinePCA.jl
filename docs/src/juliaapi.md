# OnlinePCA.jl (Julia API)

## Binarization (CSV file)
```@docs
csv2bin(;csvfile::AbstractString="", binfile::AbstractString="")
```

## Binarization (Matrix Market <MM> file)
```@docs
mm2bin(;mmfile::AbstractString="", binfile::AbstractString="")
```

## Binarization (Binary COO <BinCOO> file)
```@docs
bincoo2bin(;bincoofile::AbstractString="", binfile::AbstractString="")
```

## Summarization
```@docs
sumr(; binfile::AbstractString="", outdir::AbstractString=".", pseudocount::Number=1.0, sparse_mode::Bool=false)
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
gd(;input::AbstractString="", outdir::Union{Nothing,AbstractString}=nothing, scale::AbstractString="ftt", pseudocount::Number=1f0, rowmeanlist::AbstractString="", rowvarlist::AbstractString="",colsumlist::AbstractString="", dim::Number=3, stepsize::Number=0.1, numepoch::Number=3, scheduling::AbstractString="robbins-monro", g::Number=0.9, epsilon::Number=1.0e-8, lower::Number=0, upper::Number=1.0f+38, expvar::Number=0.1f0, evalfreq::Number=5000, offsetFull::Number=1f-20, offsetStoch::Number=1f-6, initW::Union{Nothing,AbstractString}=nothing, initV::Union{Nothing,AbstractString}=nothing, logdir::Union{Nothing,AbstractString}=nothing, perm::Bool=false, cper::Number=1f0)
```

## SGD-PCA
```@docs
sgd(;input::AbstractString="", outdir::Union{Nothing,AbstractString}=nothing, scale::AbstractString="ftt", pseudocount::Number=1f0, rowmeanlist::AbstractString="", rowvarlist::AbstractString="", colsumlist::AbstractString="", dim::Number=3, stepsize::Number=0.1, numbatch::Number=100, numepoch::Number=3, scheduling::AbstractString="robbins-monro", g::Number=0.9, epsilon::Number=1.0e-8, lower::Number=0, upper::Number=1.0f+38, expvar::Number=0.1f0, evalfreq::Number=5000, offsetFull::Number=1f-20, offsetStoch::Number=1f-6, initW::Union{Nothing,AbstractString}=nothing, initV::Union{Nothing,AbstractString}=nothing, logdir::Union{Nothing,AbstractString}=nothing, perm::Bool=false, cper::Number=1f0)
```

## Oja's method
```@docs
oja(;input::AbstractString="", outdir::Union{Nothing,AbstractString}=nothing, scale::AbstractString="ftt", pseudocount::Number=1f0, rowmeanlist::AbstractString="", rowvarlist::AbstractString="", colsumlist::AbstractString="", dim::Number=3, stepsize::Number=0.1, numepoch::Number=3, scheduling::AbstractString="robbins-monro", g::Number=0.9, epsilon::Number=1.0e-8, lower::Number=0, upper::Number=1.0f+38, expvar::Number=0.1f0, evalfreq::Number=5000, offsetFull::Number=1f-20, offsetStoch::Number=1f-6, initW::Union{Nothing,AbstractString}=nothing, initV::Union{Nothing,AbstractString}=nothing, logdir::Union{Nothing,AbstractString}=nothing, perm::Bool=false, cper::Number=1f0)
```

## CCIPCA
```@docs
ccipca(;input::AbstractString="", outdir::Union{Nothing,AbstractString}=nothing, scale::AbstractString="ftt", pseudocount::Number=1f0, rowmeanlist::AbstractString="", rowvarlist::AbstractString="",colsumlist::AbstractString="", dim::Number=3, stepsize::Number=0, numepoch::Number=3, lower::Number=0, upper::Number=1.0f+38, expvar::Number=0.1f0, evalfreq::Number=5000, offsetStoch::Number=1f-6, initW::Union{Nothing,AbstractString}=nothing, initV::Union{Nothing,AbstractString}=nothing, logdir::Union{Nothing,AbstractString}=nothing, perm::Bool=false, cper::Number=1f0)
```

## RSGD-PCA
```@docs
rsgd(;input::AbstractString="", outdir::Union{Nothing,AbstractString}=nothing, scale::AbstractString="ftt", pseudocount::Number=1f0, rowmeanlist::AbstractString="", rowvarlist::AbstractString="",colsumlist::AbstractString="", dim::Number=3, stepsize::Number=0.1, numbatch::Number=100, numepoch::Number=3, scheduling::AbstractString="robbins-monro", g::Number=0.9, epsilon::Number=1.0e-8, lower::Number=0, upper::Number=1.0f+38, expvar::Number=0.1f0, evalfreq::Number=5000, offsetFull::Number=1f-20, offsetStoch::Number=1f-6, initW::Union{Nothing,AbstractString}=nothing, initV::Union{Nothing,AbstractString}=nothing, logdir::Union{Nothing,AbstractString}=nothing, perm::Bool=false, cper::Number=1f0)
```

## SVRG-PCA
```@docs
svrg(;input::AbstractString="", outdir::Union{Nothing,AbstractString}=nothing, scale::AbstractString="ftt", pseudocount::Number=1f0, rowmeanlist::AbstractString="", rowvarlist::AbstractString="", colsumlist::AbstractString="", dim::Number=3, stepsize::Number=0.1, numbatch::Number=100, numepoch::Number=3, scheduling::AbstractString="robbins-monro", g::Number=0.9, epsilon::Number=1.0e-8, lower::Number=0, upper::Number=1.0f+38, expvar::Number=0.1f0, evalfreq::Number=5000, offsetFull::Number=1f-20, offsetStoch::Number=1f-6, initW::Union{Nothing,AbstractString}=nothing, initV::Union{Nothing,AbstractString}=nothing, logdir::Union{Nothing,AbstractString}=nothing, perm::Bool=false, cper::Number=1f0)
```

## RSVRG-PCA
```@docs
rsvrg(;input::AbstractString="", outdir::Union{Nothing,AbstractString}=nothing, scale::AbstractString="ftt", pseudocount::Number=1f0, rowmeanlist::AbstractString="", rowvarlist::AbstractString="",colsumlist::AbstractString="", dim::Number=3, stepsize::Number=0.1, numbatch::Number=100, numepoch::Number=3, scheduling::AbstractString="robbins-monro", g::Number=0.9, epsilon::Number=1.0e-8, lower::Number=0, upper::Number=1.0f+38, expvar::Number=0.1f0, evalfreq::Number=5000, offsetFull::Number=1f-20, offsetStoch::Number=1f-6, initW::Union{Nothing,AbstractString}=nothing, initV::Union{Nothing,AbstractString}=nothing, logdir::Union{Nothing,AbstractString}=nothing, perm::Bool=false, cper::Number=1f0)
```

## Orthogonal Iteration (Power method)
```@docs
orthiter(;input::AbstractString="", outdir::Union{Nothing,AbstractString}=nothing, scale::AbstractString="ftt", pseudocount::Number=1f0, rowmeanlist::AbstractString="", rowvarlist::AbstractString="",colsumlist::AbstractString="", dim::Number=3, numepoch::Number=10, lower::Number=0, upper::Number=1.0f+38, expvar::Number=0.1f0, initW::Union{Nothing,AbstractString}=nothing, initV::Union{Nothing,AbstractString}=nothing, logdir::Union{Nothing,AbstractString}=nothing, perm::Bool=false, cper::Number=1f0)
```

## Arnoldi method
```@docs
arnoldi(;input::AbstractString="", outdir::Union{Nothing,AbstractString}=nothing, scale::AbstractString="ftt", pseudocount::Number=1f0, rowmeanlist::AbstractString="", rowvarlist::AbstractString="",colsumlist::AbstractString="", dim::Number=3, numepoch::Number=10, perm::Bool=false, cper::Number=1f0)
```

## Lanczos method
```@docs
lanczos(;input::AbstractString="", outdir::Union{Nothing,AbstractString}=nothing, scale::AbstractString="ftt", pseudocount::Number=1f0, rowmeanlist::AbstractString="", rowvarlist::AbstractString="",colsumlist::AbstractString="", dim::Number=3, numepoch::Number=10, perm::Bool=false, cper::Number=1f0)
```

## Halko's method
```@docs
halko(;input::AbstractString="", outdir::Union{Nothing,AbstractString}=nothing, scale::AbstractString="ftt", pseudocount::Number=1f0, rowmeanlist::AbstractString="", rowvarlist::AbstractString="", colsumlist::AbstractString="", dim::Number=3, noversamples::Number=5, niter::Number=3, initW::Union{Nothing,AbstractString}=nothing, initV::Union{Nothing,AbstractString}=nothing, logdir::Union{Nothing,AbstractString}=nothing, perm::Bool=false, cper::Number=1f0)
```

## Algorithm 971
```@docs
algorithm971(;input::AbstractString="", outdir::Union{Nothing,AbstractString}=nothing, scale::AbstractString="ftt", pseudocount::Number=1f0, rowmeanlist::AbstractString="", rowvarlist::AbstractString="", colsumlist::AbstractString="", dim::Number=3, noversamples::Number=5, niter::Number=3, initW::Union{Nothing,AbstractString}=nothing, initV::Union{Nothing,AbstractString}=nothing, logdir::Union{Nothing,AbstractString}=nothing, perm::Bool=false, cper::Number=1f0)
```

## Randomized Block Krylov Iteration
```@docs
rbkiter(;input::AbstractString="", outdir::Union{Nothing,AbstractString}=nothing, scale::AbstractString="ftt", pseudocount::Number=1f0, rowmeanlist::AbstractString="", rowvarlist::AbstractString="",colsumlist::AbstractString="", dim::Number=3, numepoch::Number=10, lower::Number=0, upper::Number=1.0f+38, expvar::Number=0.1f0, initW::Union{Nothing,AbstractString}=nothing, initV::Union{Nothing,AbstractString}=nothing, logdir::Union{Nothing,AbstractString}=nothing, perm::Bool=false, cper::Number=1f0)
```

## Single-pass PCA type I
```@docs
singlepass(;input::AbstractString="", outdir::Union{Nothing,AbstractString}=nothing, scale::AbstractString="ftt", pseudocount::Number=1f0, rowmeanlist::AbstractString="", rowvarlist::AbstractString="", colsumlist::AbstractString="", dim::Number=3, noversamples::Number=5, niter::Number=3, initW::Union{Nothing,AbstractString}=nothing, initV::Union{Nothing,AbstractString}=nothing, logdir::Union{Nothing,AbstractString}=nothing, perm::Bool=false, cper::Number=1f0)
```

## Single-pass PCA type II
```@docs
singlepass2(;input::AbstractString="", outdir::Union{Nothing,AbstractString}=nothing, scale::AbstractString="ftt", pseudocount::Number=1f0, rowmeanlist::AbstractString="", rowvarlist::AbstractString="", colsumlist::AbstractString="", dim::Number=3, noversamples::Number=5, niter::Number=3, initW::Union{Nothing,AbstractString}=nothing, initV::Union{Nothing,AbstractString}=nothing, logdir::Union{Nothing,AbstractString}=nothing, perm::Bool=false, cper::Number=1f0)
```

## Summarization for 10X-HDF5
```@docs
tenxsumr(; tenxfile::AbstractString="", outdir::AbstractString=".", group::AbstractString="", chunksize::Number=5000)
```

## ALGORITHM971 for 10X-HDF5
```@docs
tenxpca(; tenxfile::AbstractString="", outdir::Union{Nothing,AbstractString}=nothing, scale::AbstractString="sqrt", rowmeanlist::AbstractString="", rowvarlist::AbstractString="", colsumlist::AbstractString="", dim::Number=3, noversamples::Number=5, niter::Number=3, chunksize::Number=5000, group::AbstractString, initW::Union{Nothing,AbstractString}=nothing, initV::Union{Nothing,AbstractString}=nothing, logdir::Union{Nothing,AbstractString}=nothing, perm::Bool=false, cper::Number=1.0f0)
```

## Sparse Randomized SVD (ALGORITHM971 for Binarized MM file)
```@docs
sparse_rsvd(; input::AbstractString="", outdir::Union{Nothing,AbstractString}=nothing, scale::AbstractString="ftt", rowmeanlist::AbstractString="", rowvarlist::AbstractString="", colsumlist::AbstractString="", dim::Number=3, noversamples::Number=5, niter::Number=3, chunksize::Number=1, initW::Union{Nothing,AbstractString}=nothing, initV::Union{Nothing,AbstractString}=nothing, logdir::Union{Nothing,AbstractString}=nothing, perm::Bool=false, cper::Number=1.0f0)
```

## Exact Out-of-Core PCA
```@docs
exact_ooc_pca(; input::AbstractString="", outdir::Union{Nothing,AbstractString}=nothing, scale::AbstractString="raw", pseudocount::Number=1.0f0, dim::Number=3, chunksize::Number=1, sparse_mode::Bool=false)
```