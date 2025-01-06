using InfiniteExaModels
using InfiniteOpt

function plate(; num_supports = 62, backend = nothing)
    # Set parameters
    Tmax = 1.1
    Tsp = 1.0
    num_1d_grid_pts = num_supports

    # Add the steady-state diffusion constraints
    D = 0.05 

    xs = collect(LinRange(-1, 1, num_1d_grid_pts))
    
    # Initialize the model and infinite parameter
    model = InfiniteModel(backend)
    @infinite_parameter(
        model,
        x[1:2] ∈ [-1, 1],
        independent = true,
        supports = xs,
        derivative_method = FiniteDifference(Central())
    )
    
    # Create the variables
    @variable(model, 0 <= T <= 5.5, Infinite(x...), start = 0)
    @variable(model, 0 ≤ u ≤ 50^2, Infinite(x...), start = 720) # heater
    
    # Set the objective function & initial conditions
    @objective(model, Min, ∫(∫((T - Tsp)^2, x[1]), x[2]))
    @constraint(model, (D * (@∂(T, x[1]^2) + @∂(T, x[2]^2)) - 0.1)^2 == u)
    @constraint(model, T(-1, x[2]) == 0)
    @constraint(model, T(1, x[2]) == 0)
    @constraint(model, T(x[1], -1) == 0)
    @constraint(model, T(x[1], 1) == 0)
    
    # Define hard constraint to ensure temp doesn't exceed Tmax = 1.1
    @expression(model, h, T - Tmax)
    @constraint(model, hard, model[:h] ≤ 0)
    return model
end