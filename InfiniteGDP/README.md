# Infinite Generalized Disjunctive Programming (InfiniteGDP) Case Studies
This folder contains the source code to the InfiniteGDP case study results presented in "Advanced to Modelling and Solving Infinite-Dimensional Optimization Problems in `InfiniteOpt.jl`" by Evelyn Gondosiswanto and Joshua L. Pulsipher.

To run the source code, the master version of `InfiniteOpt.jl` and `DisjunctiveProgramming.jl` are required and can be installed as follows:

```julia
julia> import Pkg

julia> Pkg.add(url = "https://github.com/infiniteopt/InfiniteOpt.jl", rev = "master")

julia> Pkg.add(url = "https://github.com/hdavid16/DisjunctiveProgramming.jl", rev = "infiniteopt_ext")
```

## Running the code
In order to run this code, you must ensure that the following Julia packages are locally installed and up-to-date on your computer:
- `Plots`

These Julia packages can be added in the Julia terminal as follows:
```julia
julia> ]
pkg> add [package-name]
```

You will also need the Gurobi solver. The solver can be downloaded at https://www.gurobi.com/downloads/gurobi-software/.

## Case Study 1: Tank Changeover Operation
The entirety of this case study is contained in `tankChangeover.jl` and can be run as a standalone file.

## Case Study 2: 1D Temperature Control of a Heated Strip
This case study is contained in two files: 
- `1DheatedStrip.jl`, which demonstrates the use of infinite logical variables.
- `InfiniteOpt-JuMP-timing.jl`, which reports the timing and memory usage results of reformulating an InfiniteOpt model and discretized JuMP model into an InfiniteGDP.

These files can each be run independently, depending on which results you're looking for.
