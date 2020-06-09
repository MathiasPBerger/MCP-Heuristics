using DelimitedFiles
using PyCall
#using Plots
using StatsPlots

include("optimisation_models.jl")
include("MCP_heuristics.jl")

pickle = pyimport("pickle")

#################### Useful Functions #######################

function myunpickle(filename)

  r = nothing
  @pywith pybuiltin("open")(filename,"rb") as f begin
    r = pickle.load(f)
  end
  return r

end

function mypickle(filename, obj)

  out = open(filename,"w")
  pickle.dump(obj, out)
  close(out)

 end

 function compute_distances(x_1::Array{Float64,2}, x_2::Array{Float64,2}, dist_function)

   R = size(x_SA)[1]
   dist = zeros(R, R)
   for r1 in 1:R
     for r2 in 1:R
       dist[r1, r2] = dist_function(x_1[r1, :], x_2[r2, :])
     end
   end
   return dist

 end

 function compute_LB_diff(LB_1::Array{Float64,1}, LB_2::Array{Float64,1})

   R = size(LB_1)[1]
   diff = zeros(R, R)
   for r1 in 1:R
     for r2 in 1:R
       diff[r1, r2] = LB_1[r1] - LB_2[r2]
     end
   end
   return diff

 end

#################### Runs #######################

c = 12.
n = 100.
unpickled = myunpickle("../data/5y_runs/20200608_111903/offshore_country_5y_max.p")
unpickled_index_dict, unpickled_deployment_dict = unpickled["index_dict"], unpickled["deployment_dict"]
index_dict = Dict([(convert(Int64, k), convert(Int64, unpickled_index_dict[k])) for k in keys(unpickled_index_dict)])
deployment_dict = Dict([(convert(Int64, k), convert(Int64, unpickled_deployment_dict[k])) for k in keys(unpickled_deployment_dict)])
D  = convert.(Float64, unpickled["criticality_matrix"])
W, L = size(D)
P = maximum(values(index_dict))
I = 150
E = 500
N = 1
T_init = 200.
R = 10
n_partitions = [unpickled_deployment_dict[i] for i in 1:P]

x_init = solve_MILP_partitioning(D, c, n_partitions, index_dict, "Gurobi")
#x_init = solve_MILP(D, c, n, "Gurobi")

#x_sol_G, LB_sol_G = Array{Float64, 2}(undef, R, L), Array{Float64, 1}(undef, R)
x_sol_SALS, LB_sol_SALS, obj_sol_SALS = Array{Float64, 2}(undef, R, L), Array{Float64, 1}(undef, R), Array{Float64, 2}(undef, R, I)
x_sol_GLS, LB_sol_GLS, obj_sol_GLS = Array{Float64, 2}(undef, R, L), Array{Float64, 1}(undef, R), Array{Float64, 2}(undef, R, I)
for r = 1:R
  println("Run ", r, "/", R)
  x_sol_GLS[r, :], LB_sol_GLS[r], obj_sol_GLS[r, :] = greedy_local_search_partition(D, c, n_partitions, N, I, E, x_init, index_dict)
  x_sol_SALS[r, :], LB_sol_SALS[r], obj_sol_SALS[r, :] = simulated_annealing_local_search_partition(D, c, n_partitions, N, I, E, x_init, T_init, index_dict)
#  x_sol_G[r, :], LB_sol_G[r] = randomised_greedy_heuristic_partition(D, c, n_partitions, index_dict)
end

## Plotting

plotly(size=(1400, 700))
#boxplot(["Randomised Greedy Heuristic" "Relaxation + Simulated Annealing Local Search" "Relaxation + Greedy Local Search"], [LB_sol_G LB_sol_SALS LB_sol_GLS])
#boxplot(["Relaxation + Simulated Annealing Local Search" "Relaxation + Greedy Local Search"], [LB_sol_SALS LB_sol_GLS])
boxplot(["Relaxation + Simulated Annealing Local Search" "Relaxation + Greedy Local Search"], [LB_sol_SALS LB_sol_GLS], title="Performance of Approximation Algorithms (partitioned, max. norm., L=454, n=38, c=12, W=43824)")
boxplot!(ylabel="Objective Value")

plot([i for i=1:I], obj_sol_GLS[1, :], title="Performance of Approximation Algorithms (partitioned, max.norm., L=454, n=38, c=12, W=43824)", color="red", label="MILP Relaxation + Greedy Local Search", legend=:bottomright)
plot!([i for i=1:I], obj_sol_GLS[2:R, :]', color="red", label="", legend=:bottomright)
plot!([i for i=1:I], obj_sol_SALS[1, :], color="blue", label="MILP Relaxation + Simulated Annealing Local Search", legend=:bottomright)
plot!([i for i=1:I], obj_sol_SALS[2:R, :]', color="blue", label="", legend=:bottomright)
plot!(xlabel="Iteration Count", ylabel="Objective Value")
#plot([i for i in 1:I], obj_sol')
#plot!(xlabel="Iteration Count", ylabel="Objective Value", title="Performance of Relaxation + Greedy Local Search Algorithm")

#pyplot(size=(600, 400))
#p_LB_diff_GLS = plot(heatmap(LB_diff_GLS), title="Difference between Greedy Local Search Lower Bounds", xlabel="Run Number", ylabel="Run Number")

## Printing

filename = "../output/output_5y_runs_090620/offshore_country_5y_max_SALS_n38_c12.p"
mypickle(filename, [LB_sol_SALS x_sol_SALS])
