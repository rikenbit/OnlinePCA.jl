# OnlinePCA.jl
Online Principal Component Analysis

[![](https://img.shields.io/badge/docs-stable-blue.svg)](https://rikenbit.github.io/OnlinePCA.jl/stable)
[![](https://img.shields.io/badge/docs-latest-blue.svg)](https://rikenbit.github.io/OnlinePCA.jl/latest)
[![Build Status](https://travis-ci.org/rikenbit/OnlinePCA.jl.svg?branch=master)](https://travis-ci.org/rikenbit/OnlinePCA.jl)

## Description
OnlinePCA.jl binarizes CSV file, summarizes the information of data matrix and, performs some online-PCA functions for extreamly large scale matrix.

## Algorithms
- Gradient-based
	- GD-PCA
	- SGD-PCA
	- Oja's method : [Erkki Oja et. al., 1985](https://www.sciencedirect.com/science/article/pii/0022247X85901313), [Erkki Oja, 1992](https://www.sciencedirect.com/science/article/pii/S0893608005800899)
	- CCIPCA : [Juyang Weng et. al., 2003](http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.7.5665&rep=rep1&type=pdf)
	- RSGD-PCA : [Silvere Bonnabel, 2013](https://arxiv.org/abs/1111.5280)
	- SVRG-PCA : [Ohad Shamir, 2015](http://proceedings.mlr.press/v37/shamir15.pdf)
	- RSVRG-PCA : [Hongyi Zhang, et. al., 2016](http://papers.nips.cc/paper/6515-riemannian-svrg-fast-stochastic-optimization-on-riemannian-manifolds.pdf), [Hiroyuki Sato, et. al., 2017](https://arxiv.org/abs/1702.05594)
- Random projection-based
	- Halko's method : [Halko, N., et. al., 2011](https://arxiv.org/abs/0909.4061), [Halko, N. et. al., 2011](https://epubs.siam.org/doi/abs/10.1137/100804139)
	- oocPCA (Out-of-core PCA) : [George C. Linderman, et. al., 2017](https://arxiv.org/abs/1712.09005), [Huamin, Li, et. al., 2017](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC5625842/)

## Learning Parameter Scheduling
- Robbins-Monro : [Herbert Robbins, et. al., 1951](https://projecteuclid.org/download/pdf_1/euclid.aoms/1177729586)
- Momentum : [Ning Qian, 1999](http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.57.5612&rep=rep1&type=pdf)
- Nesterov's Accelerated Gradient Descent（NAG） : [Nesterov, 1983](https://scholar.google.com/scholar?cluster=9343343034975135646&hl=en&oi=scholarr)
- ADAGRAD : [John Duchi, et. al., 2011](http://www.jmlr.org/papers/volume12/duchi11a/duchi11a.pdf)

## Installation
<!-- ```julia
julia> Pkg.add("OnlinePCA")
```
 -->
```julia
# push the key "]" and type the following command.
(v1.0) pkg> add https://github.com/rikenbit/OnlinePCA.jl
(v1.0) pkg> add PlotlyJS
# After that, push Ctrl + C to leave from Pkg REPL mode
```

## Basic API usage

### Preprocess of CSV
```julia
using OnlinePCA
using OnlinePCA: readcsv, writecsv
using Distributions
using DelimitedFiles

# CSV
tmp = mktempdir()
input = Int64.(ceil.(rand(NegativeBinomial(1, 0.5), 300, 99)))
input[1:50, 1:33] .= 100*input[1:50, 1:33]
input[51:100, 34:66] .= 100*input[51:100, 34:66]
input[101:150, 67:99] .= 100*input[101:150, 67:99]
writecsv(tmp*"/Data.csv", input)

# Binarization
csv2bin(csvfile=tmp*"/Data.csv", binfile=tmp*"/Data.zst")

# Summary of data
sumr(binfile=tmp*"/Data.zst", outdir=tmp)
```

### Setting for plot
```julia
using DataFrames
using PlotlyJS

function subplots(respca, group)
	# data frame
	data_left = DataFrame(pc1=respca[1][:,1], pc2=respca[1][:,2], group=group)
	data_right = DataFrame(pc2=respca[1][:,2], pc3=respca[1][:,3], group=group)
	# plot
	p_left = Plot(data_left, x=:pc1, y=:pc2, mode="markers", marker_size=10, group=:group)
	p_right = Plot(data_right, x=:pc2, y=:pc3, mode="markers", marker_size=10, group=:group, showlegend=false)
	p_left.data[1]["marker_color"] = "red"
	p_left.data[2]["marker_color"] = "blue"
	p_left.data[3]["marker_color"] = "green"
	p_right.data[1]["marker_color"] = "red"
	p_right.data[2]["marker_color"] = "blue"
	p_right.data[3]["marker_color"] = "green"
	p_left.data[1]["name"] = "group1"
	p_left.data[2]["name"] = "group2"
	p_left.data[3]["name"] = "group3"
	p_left.layout["title"] = "PC1 vs PC2"
	p_right.layout["title"] = "PC2 vs PC3"
	p_left.layout["xaxis_title"] = "pc1"
	p_left.layout["yaxis_title"] = "pc2"
	p_right.layout["xaxis_title"] = "pc2"
	p_right.layout["yaxis_title"] = "pc3"
	plot([p_left p_right])
end

group=vcat(repeat(["group1"],inner=33), repeat(["group2"],inner=33), repeat(["group3"],inner=33))
```

### GD-PCA
```julia
out_gd1 = gd(input=tmp*"/Data.zst", dim=3, scheduling="robbins-monro", stepsize=1E-3,
    numepoch=10, rowmeanlist=tmp*"/Feature_LogMeans.csv")
out_gd2 = gd(input=tmp*"/Data.zst", dim=3, scheduling="momentum", stepsize=1E-3,
    numepoch=10, rowmeanlist=tmp*"/Feature_LogMeans.csv")
out_gd3 = gd(input=tmp*"/Data.zst", dim=3, scheduling="nag", stepsize=1E-3,
    numepoch=10, rowmeanlist=tmp*"/Feature_LogMeans.csv")
out_gd4 = gd(input=tmp*"/Data.zst", dim=3, scheduling="adagrad", stepsize=1E-0,
    numepoch=10, rowmeanlist=tmp*"/Feature_LogMeans.csv")

subplots(out_gd1, group) # Top, Left
subplots(out_gd2, group) # Top, Right
subplots(out_gd3, group) # Bottom, Left
subplots(out_gd4, group) # Bottom, Right
```
![GD-PCA](./docs/src/figure/gd.png)

### SGD-PCA
```julia
out_sgd1 = sgd(input=tmp*"/Data.zst", dim=3, scheduling="robbins-monro", stepsize=1E-3,
    numbatch=100, numepoch=10, rowmeanlist=tmp*"/Feature_LogMeans.csv")
out_sgd2 = sgd(input=tmp*"/Data.zst", dim=3, scheduling="momentum", stepsize=1E-3,
    numbatch=100, numepoch=10, rowmeanlist=tmp*"/Feature_LogMeans.csv")
out_sgd3 = sgd(input=tmp*"/Data.zst", dim=3, scheduling="nag", stepsize=1E-3,
    numbatch=100, numepoch=10, rowmeanlist=tmp*"/Feature_LogMeans.csv")
out_sgd4 = sgd(input=tmp*"/Data.zst", dim=3, scheduling="adagrad", stepsize=1E-0,
    numbatch=100, numepoch=10, rowmeanlist=tmp*"/Feature_LogMeans.csv")

subplots(out_sgd1, group) # Top, Left
subplots(out_sgd2, group) # Top, Right
subplots(out_sgd3, group) # Bottom, Left
subplots(out_sgd4, group) # Bottom, Right
```
![SGD-PCA](./docs/src/figure/sgd.png)

### Oja's method
```julia
out_oja1 = oja(input=tmp*"/Data.zst", dim=3, scheduling="robbins-monro", stepsize=1E+0,
    numepoch=10, rowmeanlist=tmp*"/Feature_LogMeans.csv")
out_oja2 = oja(input=tmp*"/Data.zst", dim=3, scheduling="momentum", stepsize=1E-3,
    numepoch=10, rowmeanlist=tmp*"/Feature_LogMeans.csv")
out_oja3 = oja(input=tmp*"/Data.zst", dim=3, scheduling="nag", stepsize=1E-3,
    numepoch=10, rowmeanlist=tmp*"/Feature_LogMeans.csv")
out_oja4 = oja(input=tmp*"/Data.zst", dim=3, scheduling="adagrad", stepsize=1E-1,
    numepoch=10, rowmeanlist=tmp*"/Feature_LogMeans.csv")

subplots(out_oja1, group) # Top, Left
subplots(out_oja2, group) # Top, Right
subplots(out_oja3, group) # Bottom, Left
subplots(out_oja4, group) # Bottom, Right
```
![Oja](./docs/src/figure/oja.png)

### CCIPCA
```julia
out_ccipca1 = ccipca(input=tmp*"/Data.zst", dim=3, stepsize=1E-0,
    numepoch=10, rowmeanlist=tmp*"/Feature_LogMeans.csv")

subplots(out_ccipca1, group)
```
![CCIPCA](./docs/src/figure/ccipca.png)

### RSGD-PCA
```julia
out_rsgd1 = rsgd(input=tmp*"/Data.zst", dim=3, scheduling="robbins-monro", stepsize=1E+2,
    numepoch=10, rowmeanlist=tmp*"/Feature_LogMeans.csv")
out_rsgd2 = rsgd(input=tmp*"/Data.zst", dim=3, scheduling="momentum", stepsize=1E-3,
    numepoch=10, rowmeanlist=tmp*"/Feature_LogMeans.csv")
out_rsgd3 = rsgd(input=tmp*"/Data.zst", dim=3, scheduling="nag", stepsize=1E-3,
    numepoch=10, rowmeanlist=tmp*"/Feature_LogMeans.csv")
out_rsgd4 = rsgd(input=tmp*"/Data.zst", dim=3, scheduling="adagrad", stepsize=1E-1,
    numepoch=10, rowmeanlist=tmp*"/Feature_LogMeans.csv")

subplots(out_rsgd1, group) # Top, Left
subplots(out_rsgd2, group) # Top, Right
subplots(out_rsgd3, group) # Bottom, Left
subplots(out_rsgd4, group) # Bottom, Right
```
![RSGD-PCA](./docs/src/figure/rsgd.png)

### SVRG-PCA
```julia
out_svrg1 = svrg(input=tmp*"/Data.zst", dim=3, scheduling="robbins-monro", stepsize=1E-5,
    numepoch=10, rowmeanlist=tmp*"/Feature_LogMeans.csv")
out_svrg2 = svrg(input=tmp*"/Data.zst", dim=3, scheduling="momentum", stepsize=1E-5,
    numepoch=10, rowmeanlist=tmp*"/Feature_LogMeans.csv")
out_svrg3 = svrg(input=tmp*"/Data.zst", dim=3, scheduling="nag", stepsize=1E-5,
    numepoch=10, rowmeanlist=tmp*"/Feature_LogMeans.csv")
out_svrg4 = svrg(input=tmp*"/Data.zst", dim=3, scheduling="adagrad", stepsize=1E-2,
    numepoch=10, rowmeanlist=tmp*"/Feature_LogMeans.csv")

subplots(out_svrg1, group) # Top, Left
subplots(out_svrg2, group) # Top, Right
subplots(out_svrg3, group) # Bottom, Left
subplots(out_svrg4, group) # Bottom, Right
```
![SVRG-PCA](./docs/src/figure/svrg.png)

### RSVRG-PCA
```julia
out_rsvrg1 = rsvrg(input=tmp*"/Data.zst", dim=3, scheduling="robbins-monro", stepsize=1E-6,
    numepoch=10, rowmeanlist=tmp*"/Feature_LogMeans.csv")
out_rsvrg2 = rsvrg(input=tmp*"/Data.zst", dim=3, scheduling="momentum", stepsize=1E-6,
    numepoch=10, rowmeanlist=tmp*"/Feature_LogMeans.csv")
out_rsvrg3 = rsvrg(input=tmp*"/Data.zst", dim=3, scheduling="nag", stepsize=1E-6,
    numepoch=10, rowmeanlist=tmp*"/Feature_LogMeans.csv")
out_rsvrg4 = rsvrg(input=tmp*"/Data.zst", dim=3, scheduling="adagrad", stepsize=1E-2,
    numepoch=10, rowmeanlist=tmp*"/Feature_LogMeans.csv")

subplots(out_rsvrg1, group) # Top, Left
subplots(out_rsvrg2, group) # Top, Right
subplots(out_rsvrg3, group) # Bottom, Left
subplots(out_rsvrg4, group) # Bottom, Right
```
![RSVRG-PCA](./docs/src/figure/rsvrg.png)

### Halko's method
```julia
out_halko = halko(input=tmp*"/Data.zst", dim=3, rowmeanlist=tmp*"/Feature_LogMeans.csv")

subplots(out_halko, group)
```
![Halko's method](./docs/src/figure/halko.png)

### oocPCA
```julia
out_oocpca = oocpca(input=tmp*"/Data.zst", dim=3, rowmeanlist=tmp*"/Feature_LogMeans.csv")

subplots(out_oocpca, group)
```
![oocPCA](./docs/src/figure/oocpca.png)

## Command line usage
All the CSV preprocess functions and PCA functions also can be performed as command line tools with same parameter names like below.

```bash
# CSV → Julia Binary
julia YOUR_HOME_DIR/.julia/v0.x/OnlinePCA/bin/csv2bin \
    --csvfile Data.csv --binfile Data.zst

# Summary statistics extracted from Julia Binary
julia YOUR_HOME_DIR/.julia/v0.x/OnlinePCA/bin/sumr \
    --binfile Data.zst

# PCA
julia YOUR_HOME_DIR/.julia/v0.x/OnlinePCA/bin/gd \
    --input Data.zst --dim 3 --scheduling robbins-monro --stepsize 10 \
    --numepoch 10 --rowmeanlist Feature_LogMeans.csv
```

## Distributed Computing with Multiple Stepsize Setting
The online PCA algorithms are performed until the reconstruction error is converged. In the default stopping criteria, the calculation is stopped when the relative change is bellow 1E-3 or above 0.03. These values can be changed by *lower* and *upper* options, respectively.

The convergence is depend on the step size parameter and default value is set as 1000. This value is tuned for single-cell RNA-Seq dataset, but the appropriate level may change according to the size and dynamic range of data matrix.

Combined with [Grid Engine](https://en.wikipedia.org/wiki/Oracle_Grid_Engine), this step is easily paralled, because each calculation of different step size are independently performed. For example, we firstly make the following template file (e.g., oja_template) containing the online PCA script,

```bash
#!/bin/bash

julia YOUR_HOME_DIR/.julia/v0.x/OnlinePCA/bin/oja \
--scale log \
--input Data.zst \
--outdir XXXXX \
--rowmeanlist Feature_LogMeans.csv \
--dim 10 \
--stepsize YYYYY \
--logdir XXXXX/log
```

and then rewrite the template to set different step size by sed command and submit each job by qsub command.

```bash
#!/bin/bash

Steps=(1 10 100 1000 10000 100000 1000000)
for i in ${Step[@]}; do
	OUT="Step"$i
	mkdir -p $OUT
	sed -e "s|XXXXX|$OUT|g" oja_template > TMP_oja_scData.sh
	sed -e "s|YYYYY|$i|g" TMP_oja_scData.sh > oja_scData.sh
	chmod +x oja_scData.sh
	qsub oja_scData.sh
done
```

Even if there are no distributed computational environment, background process is applicable (just adding & in the end of command).

```bash
#!/bin/bash

Steps=(1 10 100 1000 10000 100000 1000000)
for i in ${Steps[@]}; do
	mkdir -p "Step"$i
	julia YOUR_HOME_DIR/.julia/v0.x/OnlinePCA/bin/oja \
	--scale log \
	--input Data.zst \
	--outdir "Step"$i \
	--rowmeanlist Feature_LogMeans.csv \
	--dim 10 \
	--stepsize $i \
	--logdir "Step"$i/log &
done

ps | grep julia
```