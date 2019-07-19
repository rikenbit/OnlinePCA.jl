# OnlinePCA.jl (Command line tool)

All functions can be performed as command line tool in shell window and same options in [OnlinePCA.jl (Julia API)](@ref) are available.

After installation of `OnlinePCA.jl`, command line tools are saved at `YOUR_HOME_DIR/.julia/v1.x/OnlinePCA/bin/`.

The functions can be performed as below.

## Binarization
```bash
shell> julia YOUR_HOME_DIR/.julia/v1.x/OnlinePCA/bin/csv2bin \
--csvfile Data.csv \
--binfile OUTDIR/Data.zst
```

## Summarization
```bash
shell> julia YOUR_HOME_DIR/.julia/v1.x/OnlinePCA/bin/sumr \
--binfile OUTDIR/Data.zst \
--outdir OUTDIR \
--pseudocount 1f0
```

## Filtering
```bash
shell> julia YOUR_HOME_DIR/.julia/v1.x/OnlinePCA/bin/filtering \
--binfile OUTDIR/Data.zst \
--featurelist OUTDIR/Feature_Means.csv \
--thr1 10 \
--direct1 "+" \
--outdir OUTDIR
```

## Identifying Highly Variable Genes
```bash
shell> julia YOUR_HOME_DIR/.julia/v1.x/OnlinePCA/bin/hvg \
--binfile OUTDIR/Data.zst \
--rowmeanlist OUTDIR/Feature_Means.csv \
--rowvarlist OUTDIR/Feature_Vars.csv \
--rowcv2list OUTDIR/Feature_CV2s.csv \
--outdir OUTDIR
```

## GD-PCA
```bash
shell> julia YOUR_HOME_DIR/.julia/v1.x/OnlinePCA/bin/gd \
--input Data.zst \
--outdir OUTDIR \
--scale ftt \
--pseudocount 1f0 \
--rowmeanlist Feature_FTTMeans.csv \
--colsumlist Sample_NoCounts.csv \
--dim 3 \
--stepsize 0.1 \
--numepoch 5 \
--scheduling "robbins-monro" \
--g 0.9 \
--epsilon 1.0e-8 \
--lower 0 \
--upper 1.0f+38 \
--expvar 0.1f0 \
--evalfreq 5000 \
--offsetFull 1f-20 \
--initW Eigen_vectors.csv \
--initV Loadings.csv \
--logdir OUTDIR \
--perm false \
--cper 1f0
```

## SGD-PCA
```bash
shell> julia YOUR_HOME_DIR/.julia/v1.x/OnlinePCA/bin/rsgd \
--input Data.zst \
--outdir OUTDIR \
--scale ftt \
--pseudocount 1f0 \
--rowmeanlist Feature_FTTMeans.csv \
--colsumlist Sample_NoCounts.csv \
--dim 3 \
--stepsize 0.1 \
--numepoch 5 \
--scheduling "robbins-monro" \
--g 0.9 \
--epsilon 1.0e-8 \
--lower 0 \
--upper 1.0f+38 \
--expvar 0.1f0 \
--evalfreq 5000 \
--offsetStoch 1f-6 \
--initW Eigen_vectors.csv \
--initV Loadings.csv \
--logdir OUTDIR \
--perm false \
--cper 1f0
```

## Oja's method
```bash
shell> julia YOUR_HOME_DIR/.julia/v1.x/OnlinePCA/bin/oja \
--input Data.zst \
--outdir OUTDIR \
--scale ftt \
--pseudocount 1f0 \
--rowmeanlist Feature_FTTMeans.csv \
--rowvarlist Feature_FTTVars.csv \
--colsumlist Sample_NoCounts.csv \
--dim 3 \
--stepsize 0.1 \
--numepoch 3 \
--scheduling "robbins-monro" \
--g 0.9 \
--epsilon 1.0e-8 \
--lower 0 \
--upper 1.0f+38 \
--expvar 0.1f0 \
--evalfreq 5000 \
--offsetStoch 1f-6 \
--initW Eigen_vectors.csv \
--initV Loadings.csv \
--logdir OUTDIR \
--perm false \
--cper 1f0
```

## CCIPCA
```bash
shell> julia YOUR_HOME_DIR/.julia/v1.x/OnlinePCA/bin/ccipca \
--input Data.zst \
--outdir OUTDIR \
--scale ftt \
--pseudocount 1f0 \
--rowmeanlist Feature_FTTMeans.csv \
--rowvarlist Feature_FTTVars.csv \
--colsumlist Sample_NoCounts.csv \
--dim 3 \
--stepsize 0.1 \
--numepoch 3 \
--lower 0 \
--upper 1.0f+38 \
--expvar 0.1f0 \
--evalfreq 5000 \
--offsetStoch 1f-15 \
--initW Eigen_vectors.csv \
--initV Loadings.csv \
--logdir OUTDIR \
--perm false \
--cper 1f0
```

## RSGD-PCA
```bash
shell> julia YOUR_HOME_DIR/.julia/v1.x/OnlinePCA/bin/rsgd \
--input Data.zst \
--outdir OUTDIR \
--scale ftt \
--pseudocount 1f0 \
--rowmeanlist Feature_FTTMeans.csv \
--rowvarlist Feature_FTTVars.csv \
--colsumlist Sample_NoCounts.csv \
--dim 3 \
--stepsize 0.1 \
--numepoch 5 \
--scheduling "robbins-monro" \
--g 0.9 \
--epsilon 1.0e-8 \
--lower 0 \
--upper 1.0f+38 \
--expvar 0.1f0 \
--evalfreq 5000 \
--offsetStoch 1f-6 \
--initW Eigen_vectors.csv \
--initV Loadings.csv \
--logdir OUTDIR \
--perm false \
--cper 1f0
```

## SVRG-PCA
```bash
shell> julia YOUR_HOME_DIR/.julia/v1.x/OnlinePCA/bin/svrg \
--input Data.zst \
--outdir OUTDIR \
--scale ftt \
--pseudocount 1f0 \
--rowmeanlist Feature_FTTMeans.csv \
--rowvarlist Feature_FTTVars.csv \
--colsumlist Sample_NoCounts.csv \
--dim 3 \
--stepsize 0.1 \
--numepoch 5 \
--scheduling "robbins-monro" \
--g 0.9 \
--epsilon 1.0e-8 \
--lower 0 \
--upper 1.0f+38 \
--expvar 0.1f0 \
--evalfreq 5000 \
--offsetFull 1f-20 \
--offsetStoch 1f-6 \
--initW Eigen_vectors.csv \
--initV Loadings.csv \
--logdir OUTDIR \
--perm false \
--cper 1f0
```

## RSVRG-PCA
```bash
shell> julia YOUR_HOME_DIR/.julia/v1.x/OnlinePCA/bin/rsvrg \
--input Data.zst \
--outdir OUTDIR \
--scale ftt \
--pseudocount 1f0 \
--rowmeanlist Feature_FTTMeans.csv \
--rowvarlist Feature_FTTVars.csv \
--colsumlist Sample_NoCounts.csv \
--dim 3 \
--stepsize 0.1 \
--numepoch 5 \
--scheduling "robbins-monro" \
--g 0.9 \
--epsilon 1.0e-8 \
--lower 0 \
--upper 1.0f+38 \
--expvar 0.1f0 \
--evalfreq 5000 \
--offsetFull 1f-20 \
--offsetStoch 1f-6 \
--initW Eigen_vectors.csv \
--initV Loadings.csv \
--logdir OUTDIR \
--perm false \
--cper 1f0
```

## Orthogonal Iteration (Power method)
```bash
shell> julia YOUR_HOME_DIR/.julia/v1.x/OnlinePCA/bin/orthiter \
--input Data.zst \
--outdir OUTDIR \
--scale ftt \
--pseudocount 1f0 \
--rowmeanlist Feature_FTTMeans.csv \
--rowvarlist Feature_FTTVars.csv \
--colsumlist Sample_NoCounts.csv \
--dim 3 \
--numepoch 10 \
--lower 0 \
--upper 1.0f+38 \
--expvar 0.1f0 \
--initW Eigen_vectors.csv \
--initV Loadings.csv \
--logdir OUTDIR \
--perm false \
--cper 1f0
```

## Arnoldi method
```bash
shell> julia YOUR_HOME_DIR/.julia/v1.x/OnlinePCA/bin/arnoldi \
--input Data.zst \
--outdir OUTDIR \
--scale ftt \
--pseudocount 1f0 \
--rowmeanlist Feature_FTTMeans.csv \
--rowvarlist Feature_FTTVars.csv \
--colsumlist Sample_NoCounts.csv \
--dim 3 \
--numepoch 10 \
--perm false \
--cper 1f0
```

## Lanczos method
```bash
shell> julia YOUR_HOME_DIR/.julia/v1.x/OnlinePCA/bin/lanczos \
--input Data.zst \
--outdir OUTDIR \
--scale ftt \
--pseudocount 1f0 \
--rowmeanlist Feature_FTTMeans.csv \
--rowvarlist Feature_FTTVars.csv \
--colsumlist Sample_NoCounts.csv \
--dim 3 \
--numepoch 10 \
--perm false \
--cper 1f0
```

## Halko's method
```bash
shell> julia YOUR_HOME_DIR/.julia/v1.x/OnlinePCA/bin/halko \
--input Data.zst \
--outdir OUTDIR \
--scale ftt \
--pseudocount 1f0 \
--rowmeanlist Feature_FTTMeans.csv \
--rowvarlist Feature_FTTVars.csv \
--colsumlist Sample_NoCounts.csv \
--dim 3 \
--initW Eigen_vectors.csv \
--initV Loadings.csv \
--logdir OUTDIR \
--perm false \
--cper 1f0
```

## Algorithm 971
```bash
shell> julia YOUR_HOME_DIR/.julia/v1.x/OnlinePCA/bin/algorithm971 \
--input Data.zst \
--outdir OUTDIR \
--scale ftt \
--pseudocount 1f0 \
--rowmeanlist Feature_FTTMeans.csv \
--rowvarlist Feature_FTTVars.csv \
--colsumlist Sample_NoCounts.csv \
--dim 3 \
--initW Eigen_vectors.csv \
--initV Loadings.csv \
--logdir OUTDIR \
--perm false \
--cper 1f0
```

## Randomized Block Krylov Iteration
```bash
shell> julia YOUR_HOME_DIR/.julia/v1.x/OnlinePCA/bin/rbkiter \
--input Data.zst \
--outdir OUTDIR \
--scale ftt \
--pseudocount 1f0 \
--rowmeanlist Feature_FTTMeans.csv \
--rowvarlist Feature_FTTVars.csv \
--colsumlist Sample_NoCounts.csv \
--dim 3 \
--numepoch 10 \
--lower 0 \
--upper 1.0f+38 \
--expvar 0.1f0 \
--initW Eigen_vectors.csv \
--initV Loadings.csv \
--logdir OUTDIR \
--perm false \
--cper 1f0
```

## Single-pass PCA type I
```bash
shell> julia YOUR_HOME_DIR/.julia/v1.x/OnlinePCA/bin/singlepass \
--input Data.zst \
--outdir OUTDIR \
--scale ftt \
--pseudocount 1f0 \
--rowmeanlist Feature_FTTMeans.csv \
--rowvarlist Feature_FTTVars.csv \
--colsumlist Sample_NoCounts.csv \
--dim 3 \
--noversamples 5 \
--niter 3 \
--initW Eigen_vectors.csv \
--initV Loadings.csv \
--logdir OUTDIR \
--perm false \
--cper 1f0
```

## Single-pass PCA type II
```bash
shell> julia YOUR_HOME_DIR/.julia/v1.x/OnlinePCA/bin/singlepass2 \
--input Data.zst \
--outdir OUTDIR \
--scale ftt \
--pseudocount 1f0 \
--rowmeanlist Feature_FTTMeans.csv \
--rowvarlist Feature_FTTVars.csv \
--colsumlist Sample_NoCounts.csv \
--dim 3 \
--noversamples 5 \
--niter 3 \
--initW Eigen_vectors.csv \
--initV Loadings.csv \
--logdir OUTDIR \
--perm false \
--cper 1f0
```

## Summarization for 10X-HDF5
```bash
shell> julia YOUR_HOME_DIR/.julia/v1.x/OnlinePCA/bin/tenxsumr \
--tenxfile Data.zst \
--outdir OUTDIR \
--group mm10 \
--chunksize 5000
```

## ALGORITHM971 for 10X-HDF5
```bash
shell> julia YOUR_HOME_DIR/.julia/v1.x/OnlinePCA/bin/tenxpca \
--tenxfile Data.h5 \
--outdir OUTDIR \
--scale sqrt \
--rowmeanlist Feature_FTTMeans.csv \
--rowvarlist Feature_FTTVars.csv \
--colsumlist Sample_NoCounts.csv \
--dim 3 \
--noversamples 5 \
--niter 3 \
--chunksize 5000 \
--group mm10 \
--initW Eigen_vectors.csv \
--initV Loadings.csv \
--logdir OUTDIR \
--perm false \
--cper 1f0
```