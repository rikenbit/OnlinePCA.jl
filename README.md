# OnlinePCA.jl
Online Principal Component Analysis

# Description
OnlinePCA.jl has some preprocess functions and PCA functions for extreamly large scale matrix.

# Algorithms
- SGD-PCA（Oja's method) : ?????
- GD-PCA : ?????
- RSGD-PCA : ?????
- SVRG-PCA : ?????
- RSVRG-PCA : ?????

# Learning Parameter Scheduling
- Robbins-Monro : ?????
- Momentum : ?????
- Nesterov's Accelerated Gradient Descent（NAG） : ?????
- ADAGRAD : ????

# Installation
<!-- ```julia
julia> Pkg.add("OnlinePCA")
```
 -->
```julia
julia> Pkg.clone("git://github.com/rikenbit/OnlinePCA.jl.git")
```

# Basic API usage
## SGD-PCA
```julia
using OnlinePCA, Gadfly


```

## GD-PCA
```julia


```

## RSGD-PCA
```julia

```

## SVRG-PCA
```julia

```

## RSVRG-PCA
```julia

```

## CCIPCA
```julia

```

# Command line usage
```bash
julia bin/oja.jl
```