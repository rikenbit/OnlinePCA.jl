# OnlinePCA.jl (Command line tool)

All functions can be performed as command line tool in shell window and same options in [OnlinePCA.jl (Julia API)](@ref) are available.

After installation of `OnlinePCA.jl`, command line tools are saved at `YOUR_HOME_DIR/.julia/v0.x/OnlinePCA/bin/`.

The functions can be performed as below.

## Binarization
```bash
shell> julia YOUR_HOME_DIR/.julia/v0.x/OnlinePCA/bin/csv2bin \
--csvfile Data.csv \
--binfile OUTDIR/Data.dat
```

## Summarization
```bash
shell> julia YOUR_HOME_DIR/.julia/v0.x/OnlinePCA/bin/sumr \
--binfile OUTDIR/Data.dat \
--outdir OUTDIR \
--pseudocount 1
```

## Filtering
```bash
shell> julia YOUR_HOME_DIR/.julia/v0.x/OnlinePCA/bin/filtering \
--binfile OUTDIR/Data.dat \
--featurelist OUTDIR/Feature_Means.csv \
--thr 10 \
--outdir OUTDIR
```

## Identifying Highly Variable Genes
```bash
shell> julia YOUR_HOME_DIR/.julia/v0.x/OnlinePCA/bin/hvg \
--binfile OUTDIR/Data.dat \
--rowmeanlist OUTDIR/Feature_Means.csv \
--rowvarlist OUTDIR/Feature_Means.csv \
--rowcv2list OUTDIR/Feature_Means.csv \
--outdir OUTDIR
```

## Oja
```bash
shell> julia YOUR_HOME_DIR/.julia/v0.x/OnlinePCA/bin/oja \
--input OUTDIR/Data.dat \
--outdir OUTDIR \
--logscale true \
--pseudocount 1 \
--rowmeanlist OUTDIR/Feature_LogMeans.csv \
--colsumlist OUTDIR/Sample_NoCounts.csv \
--masklist OUTDIR/MASKLIST.csv \
--dim 3 \
--stepsize 0.1 \
--numepoch 5 \
--scheduling "robbins-monro" \
--g 0.9 \
--epsilon 1.0e-8 \
--logdir OUTDIR
```

## CCIPCA
```bash
shell> julia YOUR_HOME_DIR/.julia/v0.x/OnlinePCA/bin/ccipca \
--input OUTDIR/Data.dat \
--outdir OUTDIR \
--logscale true \
--pseudocount 1 \
--rowmeanlist OUTDIR/Feature_LogMeans.csv \
--colsumlist OUTDIR/Sample_NoCounts.csv \
--masklist OUTDIR/MASKLIST.csv \
--dim 3 \
--stepsize 0.1 \
--numepoch 5 \
--logdir OUTDIR
```

## GD
```bash
shell> julia YOUR_HOME_DIR/.julia/v0.x/OnlinePCA/bin/gd \
--input OUTDIR/Data.dat \
--outdir OUTDIR \
--logscale true \
--pseudocount 1 \
--rowmeanlist OUTDIR/Feature_LogMeans.csv \
--colsumlist OUTDIR/Sample_NoCounts.csv \
--masklist OUTDIR/MASKLIST.csv \
--dim 3 \
--stepsize 0.1 \
--numepoch 5 \
--scheduling "robbins-monro" \
--g 0.9 \
--epsilon 1.0e-8 \
--logdir OUTDIR
```

## RSGD
```bash
shell> julia YOUR_HOME_DIR/.julia/v0.x/OnlinePCA/bin/rsgd \
--input OUTDIR/Data.dat \
--outdir OUTDIR \
--logscale true \
--pseudocount 1 \
--rowmeanlist OUTDIR/Feature_LogMeans.csv \
--colsumlist OUTDIR/Sample_NoCounts.csv \
--masklist OUTDIR/MASKLIST.csv \
--dim 3 \
--stepsize 0.1 \
--numepoch 5 \
--scheduling "robbins-monro" \
--g 0.9 \
--epsilon 1.0e-8 \
--logdir OUTDIR
```

## SVRG
```bash
shell> julia YOUR_HOME_DIR/.julia/v0.x/OnlinePCA/bin/svrg \
--input OUTDIR/Data.dat \
--outdir OUTDIR \
--logscale true \
--pseudocount 1 \
--rowmeanlist OUTDIR/Feature_LogMeans.csv \
--colsumlist OUTDIR/Sample_NoCounts.csv \
--masklist OUTDIR/MASKLIST.csv \
--dim 3 \
--stepsize 0.1 \
--numepoch 5 \
--scheduling "robbins-monro" \
--g 0.9 \
--epsilon 1.0e-8 \
--logdir OUTDIR
```

## RSVRG
```bash
shell> julia YOUR_HOME_DIR/.julia/v0.x/OnlinePCA/bin/rsvrg \
--input OUTDIR/Data.dat \
--outdir OUTDIR \
--logscale true \
--pseudocount 1 \
--rowmeanlist OUTDIR/Feature_LogMeans.csv \
--colsumlist OUTDIR/Sample_NoCounts.csv \
--masklist OUTDIR/MASKLIST.csv \
--dim 3 \
--stepsize 0.1 \
--numepoch 5 \
--scheduling "robbins-monro" \
--g 0.9 \
--epsilon 1.0e-8 \
--logdir OUTDIR
```
