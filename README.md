This repository includes Julia implementations of approximation and heuristic algorithms used for solving renewable generation asset siting problems.

Some of these algorithms, which are also used for submodular maximization, include:

- Random (Exhaustive) Search

- Top-to-Bottom Greedy Search (Berger et al. 2020)

- Classic Greedy Search (Nemhauser et al. 1978)

- Stochastic Greedy Search (Mirzasoleiman et al. 2015)

- Classic Local Search (Nemhauser et al. 1978)

- Simulated Annealing Local Search (Berger et al. 2020)

- IP and MILP formulations, built in Julia JuMP, which can be combined with local search to produce better heuristics.