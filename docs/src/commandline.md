# OnlinePCA.jl (Command line tool)

All functions can be performed as command line tool in shell window.

After installation of `OnlinePCA.jl`, command line tools are saved at `YOUR_HOME_DIR/.julia/v0.x/OnlinePCA/bin/`.

## Binarization
```bash
shell> julia YOUR_HOME_DIR/.julia/v0.x/OnlinePCA/bin/csv2sl \
--csvfile Data.csv \
--slfile OUTDIR/Data.dat
```

## Summarization
```bash
shell> julia YOUR_HOME_DIR/.julia/v0.x/OnlinePCA/bin/sumr \
--slfile OUTDIR/Data.dat \
--outdir OUTDIR \
--pseudocount 1
```

## Filtering
```bash
shell> julia YOUR_HOME_DIR/.julia/v0.x/OnlinePCA/bin/filtering \
```

## Identifying Highly Variable Genes
```bash
shell> julia YOUR_HOME_DIR/.julia/v0.x/OnlinePCA/bin/hvg \
```

## Oja
```bash
shell> julia YOUR_HOME_DIR/.julia/v0.x/OnlinePCA/bin/oja \
--input OUTDIR/Data.dat \
--outdir OUTDIR \
--logscale true \
--pseudocount 1 \
--numepoch 5 \
--rowmeanlist OUTDIR/Feature_LogMeans.csv \
--colsumlist OUTDIR/Sample_NoCounts.csv \
--masklist OUTDIR/MASKLIST.csv \
--dim 3 \
--stepsize 0.1 \
--numepoch 5 \
--scheduling "robbins-monro" \
--g 0.9 \
--epsilon 0.00000001 \
--logfile false
```

## CCIPCA
```bash
shell> julia YOUR_HOME_DIR/.julia/v0.x/OnlinePCA/bin/ccipca \
--input OUTDIR/Data.dat \
--outdir OUTDIR \
--logscale true \
--pseudocount 1 \
--numepoch 5 \
--rowmeanlist OUTDIR/Feature_LogMeans.csv \
--colsumlist OUTDIR/Sample_NoCounts.csv \
--masklist OUTDIR/MASKLIST.csv \
--dim 3 \
--stepsize 0.1 \
--numepoch 5 \
--logfile false
```

## GD
```bash
shell> julia YOUR_HOME_DIR/.julia/v0.x/OnlinePCA/bin/gd \
--input OUTDIR/Data.dat \
--outdir OUTDIR \
--logscale true \
--pseudocount 1 \
--numepoch 5 \
--rowmeanlist OUTDIR/Feature_LogMeans.csv \
--colsumlist OUTDIR/Sample_NoCounts.csv \
--masklist OUTDIR/MASKLIST.csv \
--dim 3 \
--stepsize 0.1 \
--numepoch 5 \
--scheduling "robbins-monro" \
--g 0.9 \
--epsilon 0.00000001 \
--logfile false
```

## RSGD
```bash
shell> julia YOUR_HOME_DIR/.julia/v0.x/OnlinePCA/bin/rsgd \
--input OUTDIR/Data.dat \
--outdir OUTDIR \
--logscale true \
--pseudocount 1 \
--numepoch 5 \
--rowmeanlist OUTDIR/Feature_LogMeans.csv \
--colsumlist OUTDIR/Sample_NoCounts.csv \
--masklist OUTDIR/MASKLIST.csv \
--dim 3 \
--stepsize 0.1 \
--numepoch 5 \
--scheduling "robbins-monro" \
--g 0.9 \
--epsilon 0.00000001 \
--logfile false
```

## SVRG
```bash
shell> julia YOUR_HOME_DIR/.julia/v0.x/OnlinePCA/bin/svrg \
--input OUTDIR/Data.dat \
--outdir OUTDIR \
--logscale true \
--pseudocount 1 \
--numepoch 5 \
--rowmeanlist OUTDIR/Feature_LogMeans.csv \
--colsumlist OUTDIR/Sample_NoCounts.csv \
--masklist OUTDIR/MASKLIST.csv \
--dim 3 \
--stepsize 0.1 \
--numepoch 5 \
--scheduling "robbins-monro" \
--g 0.9 \
--epsilon 0.00000001 \
--logfile false
```

## RSVRG
```bash
shell> julia YOUR_HOME_DIR/.julia/v0.x/OnlinePCA/bin/rsvrg \
--input OUTDIR/Data.dat \
--outdir OUTDIR \
--logscale true \
--pseudocount 1 \
--numepoch 5 \
--rowmeanlist OUTDIR/Feature_LogMeans.csv \
--colsumlist OUTDIR/Sample_NoCounts.csv \
--masklist OUTDIR/MASKLIST.csv \
--dim 3 \
--stepsize 0.1 \
--numepoch 5 \
--scheduling "robbins-monro" \
--g 0.9 \
--epsilon 0.00000001 \
--logfile false
```
