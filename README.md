This repository includes Julia implementations of approximation and heuristic algorithms used for solving renewable generation asset siting problems.

Some of these algorithms, which are also used for submodular maximization, include:

- Random (Exhaustive) Search

- Top-to-Bottom Greedy Search (Berger et al. 2020)

- Classic Greedy Search (Nemhauser et al. 1978)

- Stochastic Greedy Search (Mirzasoleiman et al. 2015)

- Classic Local Search (Nemhauser et al. 1978)

- Simulated Annealing Local Search (Berger et al. 2020)

- IP and MILP formulations, built in Julia JuMP, which can be combined with local search to produce better heuristics.

The data used in the paper "Siting Renewable Generation Assets with Combinatorial Optimisation" can be downloaded from the following repository:

https://dox.uliege.be/index.php/s/1XLvBJhaO106Cen

TESTED VIA JULIA 1.4 & 1.5

PACKAGE REQUIREMENTS:

DelimitedFiles (Standard Library)
StatsBase 0.32.0
StatsPlots v0.12.0 
PyCall v1.91.4
JuMP v0.20.2
Gurobi v0.8.1
Cbc v0.7.0
Distributions v0.23.8