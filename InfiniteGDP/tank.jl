using DisjunctiveProgramming, InfiniteOpt, Gurobi, Plots

# Define constants
τi = 0
τf = 6
I = 1:3     # number of disjuncts (flow modes/regimes)
J = 1:6     # number of disjunctions (number of time periods)

# Define endpoints for each time period
τ_end = [(τ, τ+1) for τ in τi:τf-1]
period_bounds = collect(0:1:6)

# Create the model
model = InfiniteGDPModel(Gurobi.Optimizer)

@infinite_parameter(model, τ[j in J] in [period_bounds[j], period_bounds[j+1]], num_supports = 60, independent = true, container = Array)
@variable(model, -5 ≤ y[j in J] ≤ 5, Infinite(τ[j]), container = Array)

# Define a vector of z values - "one z for each period"
@variable(model, -4 ≤ z ≤ 4)

# # Set our objective: a summation of 6 integrals, an integral for each period
@objective(model, Min, 10 * sum(∫(y[j]^2, τ[j]) for j in J))

@constraint(model, y[1](0) == 1)  # Initial condition y1(0) = 1
@constraint(model, [j = 2:6], y[j](period_bounds[j]) == y[j-1](period_bounds[j]))

@variable(model, W[i = I, j = J], Logical)  # Define logical variables for disjuncts
@constraint(model, [j in J], ∂(y[j], τ[j]) == -2*τ[j] + 0.3*z - 20*y[j], Disjunct(W[1, j]))   # Yk1
@constraint(model, [j in J], ∂(y[j], τ[j]) == -2*z + 0.4*τ[j] - 4, Disjunct(W[2, j]))    # Yk2
@constraint(model, [j in J], ∂(y[j], τ[j]) == 2*z + 4*(τ[j] - y[j] - 1), Disjunct(W[3, j]))    # Yk3
@disjunction(model, [j in J], W[:, j])

# Choose a reformulation method and solve
set_silent(model)
method = "bigM"
if method == "indicator"
    optimize!(model, gdp_method = Indicator())
elseif method == "bigM"
    optimize!(model, gdp_method = BigM())
elseif method == "hull"
    optimize!(model, gdp_method = Hull())
else
    error("Please specify a GDP method.")
end

# Check & extract the result values for plotting
if has_values(model)
    τ_vals = value.(τ)
    z_opt = value(z)
    y_opt = value.(y)
    W1_opt = value.(W[1, :])
    W2_opt = value.(W[2, :])
    W3_opt = value.(W[3, :])
    obj_opt = objective_value(model)
end

# Reformat the data for plotting the mode changes
mode_combined = [findfirst(y -> y == 1, [W1_opt[i], W2_opt[i], W3_opt[i]]) for i in 1:length(W1_opt)]
τ_mode = zeros(2*length(W1_opt))
y_mode = zeros(length(τ_mode))
τ_mode[end] = period_bounds[end]

for i in 2:length(period_bounds)-1
    τ_mode[2*period_bounds[i]] = period_bounds[i]
    τ_mode[2*period_bounds[i]+1] = period_bounds[i]
end

for j in J
    y_mode[2*j-1] = mode_combined[j]
    y_mode[2*j] = mode_combined[j]
end

# Plot the results
l = @layout [a ; b]
p1 = plot(τ_vals, y_opt, color = "blue", label="", title = "", dpi=300, ylabel = "System state (y)", xlabel = "Time (t)")
p2 = plot(τ_mode, y_mode, xticks = τ_mode, yticks = [k for k in 0:3], label = "", dpi = 300, ylabel = "Flow modes", xlabel = "Time (t)")
display(plot(p1, p2, layout = l, size = (500, 450)))
savefig("optimal-tank.png")
println("This is the optimal z value: $z_opt")