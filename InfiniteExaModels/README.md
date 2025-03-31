# InfiniteExaModels Case Studies
This folder contains the source code to the InfiniteExaModels case study results presented in "Advances to Modelling and Solving Infinite-Dimensional Optimization Problems in `InfiniteOpt.jl`" by Evelyn Gondosiswanto and Joshua L. Pulsipher.

To run the source code, the master version of `InfiniteOpt.jl` is required and can be installed as follows:

```julia
julia> import Pkg

julia> Pkg.add(url = "https://github.com/infiniteopt/InfiniteOpt.jl", rev = "master")
```

### Running the code
To configure the required packages, it is recommended to create a Julia environment using the `Project.toml` file. Creating the environment and running the case studies on CPU can be done as follows:
```julia
julia> cd("[PATH_TO_FILES]/InfiniteGDP/")

julia> ]

(@v1.10) pkg> activate .

(InfiniteGDP) pkg> instantiate

julia> include("run_cases_cpu.jl")
```

To run on GPU, you can do so via:
```julia
julia> cd("[PATH_TO_FILES]/InfiniteGDP/")

julia> ]

(@v1.10) pkg> activate .

(InfiniteGDP) pkg> instantiate

julia> include("run_cases_gpu.jl")
```

## Case Study 1: Optimal Control of a Quadcopter
The source code for this case study is contained in `quadrotor.jl` and is run using one of the `run_cases` files.

## Case Study 2: 2D Temperature Control of a Heated Plate
The source code for this case study is contained in `heatedPlate.jl` and is run using one of the `run_cases` files.

## Case Study 3: Stochastic Optimal Power Flow
The source code for this case study is contained in `acopf.jl` and is run using one of the `run_cases` files.