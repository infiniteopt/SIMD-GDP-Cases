using DisjunctiveProgramming, InfiniteOpt, Gurobi, CSV, DataFrames
# Set parameters
Tsp = 1.38  
num_pts = 2001
x0 = -1
xf = 1
# Add the steady-state diffusion coefficient
D = 0.05

xs = collect(LinRange(x0, xf, num_pts))
num_heaters = 6 # choose such that (num_pts - num_heaters) / (num_heaters + 1) is an integer
spacing = Int((num_pts - num_heaters) / (num_heaters + 1)) + 1

# Function for creating the InfiniteOpt model
function infOpt(num_grid_pts)
    # Determine heater placements
    heater_positions = xs[spacing:spacing:num_pts] 

    # Initialize the model
    model = InfiniteGDPModel(Gurobi.Optimizer)
    @infinite_parameter(model, x ∈ [x0, xf], independent = true, num_supports = num_grid_pts, derivative_method = FiniteDifference(Central()))

    # Create the variables
    @variable(model, 0 ≤ T ≤ 2.0, Infinite(x))
    @variable(model, u == 0, Infinite(x)) # heater input

    # Make it so heater only heats at certain points
    for xp in heater_positions
            u_pt = u(xp)
            unfix(u_pt)
            set_lower_bound(u_pt, 0.0)
            set_upper_bound(u_pt, 50)
            set_start_value(u_pt, 25)
    end

    # Set up global constraints
    @constraint(model, D * ∂(T, x, x) + u - 0.3 == 0)
    @constraint(model, T(x0) == 0)
    @constraint(model, T(xf) == 0)

    # Set up disjunctions
    @variable(model, Y[1:2], InfiniteLogical(x))
    @variable(model, Q, InfiniteLogical(x))
    @constraint(model, T ≤ 1.9, Disjunct(Y[1]))
    @constraint(model, T ≤ 1.4, Disjunct(Y[2]))
    @disjunction(model, Y)

    # Add logical proposition
    @constraint(model, Y[1] ⟹ Q := true)

    # Set the objective function
    @objective(model, Min, ∫((T - Tsp)^2 + 1E-02*binary_variable(Q), x))

    return model

end

# Function for creating the discretized JuMP model
function discJUMP(num_grid_pts)
    Δt = (xf - x0)/(num_grid_pts - 1)
    X = 1:num_grid_pts
    xheat = collect(X)
    heater_positions = xheat[spacing:spacing:num_grid_pts]

    # Initialize the model
    model = GDPModel(Gurobi.Optimizer)

    # Create the variables
    @variable(model, 0 ≤ T[x ∈ X] ≤ 2.0)
    @variable(model, u[x ∈ X] == 0) # heater input

    # Make it so heater only heats at certain points
    for xp in heater_positions
            u_pt = u[xp]
            unfix(u_pt)
            set_lower_bound(u_pt, 0.0)
            set_upper_bound(u_pt, 50)
            set_start_value(u_pt, 25)
    end

    # Set up global constraints
    @constraint(model, [x ∈ 2:num_grid_pts-1], (T[x+1] + T[x-1] - 2*T[x])/(Δt^2) == (0.3 - u[x])/D)
    @constraint(model, T[1] == 0)
    @constraint(model, T[end] == 0)

    # Set up disjunctions
    @variable(model, Y[i ∈ 1:2, x ∈ X], Logical)
    @variable(model, Q[x ∈ X], Logical)
    @constraint(model, [x ∈ X], T[x] ≤ 1.9, Disjunct(Y[1, x]))
    @constraint(model, [x ∈ X], T[x] ≤ 1.4, Disjunct(Y[2, x]))
    @disjunction(model, [x ∈ X], [Y[1, x], Y[2, x]])

    # Add logical proposition
    @constraint(model, [x ∈ X], Y[1, x] ⟹ Q[x] := true)

    # Set the objective function
    @objective(model, Min, sum((T[x] - Tsp)^2 + 1E-02*binary_variable(Q[x]) for x in X))

    return model
end

# Function for timing the model reformulation
function timing(model, method)
    stats = @timed reformulate_model(model, method)
    reform_time = stats.time
    memory_use = stats.bytes / 1024^2
    return reform_time, memory_use
end

function model_size(model, jump_model = false)
    nvar = num_variables(model)
    if jump_model
        ncon = num_constraints(model, count_variable_in_set_constraints = false)
    else
        ncon = num_constraints(model)
    end
    return nvar, ncon
end

# Initialize a DataFrame to save results
results = DataFrame(
    "Model type" => String[],
    "Reformulation method" => String[],
    "Time (s)" => Float64[],
    "Memory usage (MB)" => Float64[])

# Define a mapping dictionary for method names
method_map = Dict(
    Indicator() => "Indicator",
    BigM() => "BigM",
    Hull() => "Hull"
)

# Loop through methods and collect results
for method in [Indicator(), BigM(), Hull()]
    # Create the InfiniteOpt & discretized JuMP models
    infOptmodel = infOpt(num_pts)
    JUMPmodel = discJUMP(num_pts)

    # Get number of variables/constraints before reformulation
    inf_nvar_before, inf_ncon_before = model_size(infOptmodel)
    JUMP_nvar_before, JUMP_ncon_before = model_size(JUMPmodel, true)
    println("Before reformulation ($(method_map[method])): InfiniteOpt - $inf_nvar_before variables, $inf_ncon_before constraints")
    println("Before reformulation ($(method_map[method])): JuMP - $JUMP_nvar_before variables, $JUMP_ncon_before constraints")

    # Reformulate the models
    infOpt_time, infOpt_mem, = timing(infOptmodel, method)
    JUMP_time, JUMP_mem = timing(JUMPmodel, method)

    # Get number of variables/constraints after reformulation
    inf_nvar_after, inf_ncon_after = model_size(infOptmodel)
    JUMP_nvar_after, JUMP_ncon_after = model_size(JUMPmodel, true)
    println("After reformulation ($(method_map[method])): InfiniteOpt - $inf_nvar_after variables, $inf_ncon_after constraints")
    println("After reformulation ($(method_map[method])): JuMP - $JUMP_nvar_after variables, $JUMP_ncon_after constraints")

    # Append infOpt results
    push!(results, ("InfiniteOpt", method_map[method], infOpt_time, infOpt_mem))

    # Append JUMP results
    push!(results, ("Discretized JuMP", method_map[method], JUMP_time, JUMP_mem))
end

# Export results to a CSV file
CSV.write("timing_results.csv", results)