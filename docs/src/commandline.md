# OnlinePCA.jl (Command line tool)

All functions can be performed as command line tool in shell window and same options in [OnlinePCA.jl (Julia API)](@ref) are available.

After installation of `OnlinePCA.jl`, command line tools are saved at `YOUR_HOME_DIR/.julia/v0.x/OnlinePCA/bin/`.

The functions can be performed as below.

## Binarization
```bash
shell> julia YOUR_HOME_DIR/.julia/v0.x/OnlinePCA/bin/csv2bin \
--csvfile Data.csv \
--binfile OUTDIR/Data.zst
```

## Summarization
```bash
shell> julia YOUR_HOME_DIR/.julia/v0.x/OnlinePCA/bin/sumr \
--binfile OUTDIR/Data.zst \
--outdir OUTDIR \
--pseudocount 1.0
```

## Filtering
```bash
shell> julia YOUR_HOME_DIR/.julia/v0.x/OnlinePCA/bin/filtering \
--binfile OUTDIR/Data.zst \
--featurelist OUTDIR/Feature_Means.csv \
--thr1 10 \
--direct1 "+" \
--outdir OUTDIR
```

## Identifying Highly Variable Genes
```bash
shell> julia YOUR_HOME_DIR/.julia/v0.x/OnlinePCA/bin/hvg \
--binfile OUTDIR/Data.zst \
--rowmeanlist OUTDIR/Feature_Means.csv \
--rowvarlist OUTDIR/Feature_Vars.csv \
--rowcv2list OUTDIR/Feature_CV2s.csv \
--outdir OUTDIR
```

## GD
```bash
shell> julia YOUR_HOME_DIR/.julia/v0.x/OnlinePCA/bin/gd \
--input OUTDIR/Data.zst \
--outdir OUTDIR \
--scale ftt \
--pseudocount 1 \
--rowmeanlist OUTDIR/Feature_FTTMeans.csv \
--colsumlist OUTDIR/Sample_NoCounts.csv \
--masklist OUTDIR/MASKLIST.csv \
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
--initW OUTDIR/Eigen_vectors.csv \
--logdir OUTDIR \
--perm false
```

## Oja
```bash
shell> julia YOUR_HOME_DIR/.julia/v0.x/OnlinePCA/bin/oja \
--input OUTDIR/Data.zst \
--outdir OUTDIR \
--scale ftt \
--pseudocount 1 \
--rowmeanlist OUTDIR/Feature_FTTMeans.csv \
--rowvarlist OUTDIR/Feature_FTTVars.csv \
--colsumlist OUTDIR/Sample_NoCounts.csv \
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
--initW OUTDIR/Eigen_vectors.csv \
--logdir OUTDIR \
--perm false
```

## CCIPCA
```bash
shell> julia YOUR_HOME_DIR/.julia/v0.x/OnlinePCA/bin/ccipca \
--input OUTDIR/Data.zst \
--outdir OUTDIR \
--scale ftt \
--pseudocount 1 \
--rowmeanlist OUTDIR/Feature_FTTMeans.csv \
--rowvarlist OUTDIR/Feature_FTTVars.csv \
--colsumlist OUTDIR/Sample_NoCounts.csv \
--dim 3 \
--stepsize 0.1 \
--numepoch 3 \
--lower 0 \
--upper 1.0f+38 \
--expvar 0.1f0 \
--evalfreq 5000 \
--offsetStoch 1f-15 \
--initW OUTDIR/Eigen_vectors.csv \
--logdir OUTDIR \
--perm false
```

## SGD
```bash
shell> julia YOUR_HOME_DIR/.julia/v0.x/OnlinePCA/bin/rsgd \
--input OUTDIR/Data.zst \
--outdir OUTDIR \
--scale ftt \
--pseudocount 1 \
--rowmeanlist OUTDIR/Feature_FTTMeans.csv \
--colsumlist OUTDIR/Sample_NoCounts.csv \
--masklist OUTDIR/MASKLIST.csv \
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
--initW OUTDIR/Eigen_vectors.csv \
--logdir OUTDIR \
--perm false
```

## RSGD
```bash
shell> julia YOUR_HOME_DIR/.julia/v0.x/OnlinePCA/bin/rsgd \
--input OUTDIR/Data.zst \
--outdir OUTDIR \
--scale ftt \
--pseudocount 1 \
--rowmeanlist OUTDIR/Feature_FTTMeans.csv \
--colsumlist OUTDIR/Sample_NoCounts.csv \
--masklist OUTDIR/MASKLIST.csv \
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
--initW OUTDIR/Eigen_vectors.csv \
--logdir OUTDIR \
--perm false
```

## SVRG
```bash
shell> julia YOUR_HOME_DIR/.julia/v0.x/OnlinePCA/bin/svrg \
--input OUTDIR/Data.zst \
--outdir OUTDIR \
--scale ftt \
--pseudocount 1 \
--rowmeanlist OUTDIR/Feature_FTTMeans.csv \
--colsumlist OUTDIR/Sample_NoCounts.csv \
--masklist OUTDIR/MASKLIST.csv \
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
--initW OUTDIR/Eigen_vectors.csv \
--logdir OUTDIR \
--perm false
```

## RSVRG
```bash
shell> julia YOUR_HOME_DIR/.julia/v0.x/OnlinePCA/bin/rsvrg \
--input OUTDIR/Data.zst \
--outdir OUTDIR \
--scale ftt \
--pseudocount 1 \
--rowmeanlist OUTDIR/Feature_FTTMeans.csv \
--colsumlist OUTDIR/Sample_NoCounts.csv \
--masklist OUTDIR/MASKLIST.csv \
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
--initW OUTDIR/Eigen_vectors.csv \
--logdir OUTDIR \
--perm false
```

## HALKO
```bash
shell> julia YOUR_HOME_DIR/.julia/v0.x/OnlinePCA/bin/halko \
--input OUTDIR/Data.zst \
--outdir OUTDIR \
--scale ftt \
--pseudocount 1 \
--rowmeanlist OUTDIR/Feature_FTTMeans.csv \
--rowvarlist OUTDIR/Feature_FTTVars.csv \
--colsumlist OUTDIR/Sample_NoCounts.csv \
--masklist OUTDIR/MASKLIST.csv \
--dim 3 \
--initW OUTDIR/Eigen_vectors.csv \
--logdir OUTDIR \
--perm false
```

## OOCPCA
```bash
shell> julia YOUR_HOME_DIR/.julia/v0.x/OnlinePCA/bin/halko \
--input OUTDIR/Data.zst \
--outdir OUTDIR \
--scale ftt \
--pseudocount 1 \
--rowmeanlist OUTDIR/Feature_FTTMeans.csv \
--rowvarlist OUTDIR/Feature_FTTVars.csv \
--colsumlist OUTDIR/Sample_NoCounts.csv \
--masklist OUTDIR/MASKLIST.csv \
--dim 3 \
--initW OUTDIR/Eigen_vectors.csv \
--logdir OUTDIR \
--perm false
```
