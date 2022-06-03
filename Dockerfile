FROM julia:1.8.0-rc1-buster

RUN apt-get update \
	&& apt-get install -y --no-install-recommends apt-utils unzip \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/* \
    && export JULIA_DEPOT_PATH="/usr/local/julia/" \
    && julia -e 'import Pkg; Pkg.add(url="https://github.com/rikenbit/OnlinePCA.jl"); Pkg.add("PlotlyJS")'
