# InfiniteExaModels Case Studies
This folder contains the source code to the InfiniteExaModels case study results presented in "Advances to Modelling and Solving Infinite-Dimensional Optimization Problems in `InfiniteOpt.jl`" by Evelyn Gondosiswanto and Joshua L. Pulsipher.

To run the source code, the master version of `InfiniteOpt.jl` is required and can be installed as follows:

```julia
julia> import Pkg

julia> Pkg.add(url = "https://github.com/infiniteopt/InfiniteOpt.jl", rev = "master")
```

## Running the code
These case studies can be run using any of the two files below:
- `run_cases_cpu.jl`, which runs CPU-based workflows `JuMP`, `MathOptSymbolicAD`, `AMPL`, `ExaModelsMOI.jl` and `InfiniteExaModels.jl` with `Ipopt.jl` as the solver
- `run_cases_gpu.jl`, which runs GPU-based workflows `ExaModelsMOI.jl` and `InfiniteExaModels.jl` with `MadNLP.jl` as the solver

When running the case studies, CSV files will be generated in a folder called "results". If this folder and/or CSV files from a previous run already exists, then those files will be overwritten by the latest run.

In order to run the code, you must ensure that the following Julia packages are locally installed and up-to-date on your computer:
- `Ipopt`
- `AmplNLWriter`
- `NLPModelsIpopt`
- `ExaModels`
- `DelimitedFiles`
- `Ipopt_jll`
- `HSL_jll`
- `MadNLPGPU`
- `CUDA`
- `CUDSS`

These Julia packages can be added in the Julia terminal as follows:
```julia
julia> ]
pkg> add [package-name]
```

Please note that in order to run the GPU case studies with the `MadNLP.jl` solver, you will need a NVIDIA GPU that's compatible with CUDA.

## Case Study 1: Optimal Control of a Quadcopter
The source code for this case study is contained in `quadrotor.jl` annd is run using one of the `run_cases` files.

## Case Study 2: 2D Temperature Control of a Heated Plate
The source code for this case study is contained in `heatedPlate.jl` annd is run using one of the `run_cases` files.

## Case Study 3: Stochastic Optimal Power Flow
The source code for this case study is contained in `acopf.jl` and is run using one of the `run_cases` files.