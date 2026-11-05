# Farthest Better or Nearest Worse Optimizer (FNO)

Official MATLAB implementation of FNO for minimizing a scalar objective within box bounds. Each agent uses distances to higher- and lower-ranked agents to propose a move. The dynamic focus strategy narrows the search around the farthest better agent as the evaluation budget is consumed. [Read the paper in *Artificial Intelligence Review*](https://doi.org/10.1007/s10462-025-11443-z).

## Quick start

Clone the repository and open its root folder in MATLAB. The optimizer and Sphere example use base MATLAB.

```sh
git clone https://github.com/AhmadTaheri2021/FNO-Optimizer.git
cd FNO-Optimizer
```

Minimize the five-dimensional Sphere function with 30 agents and a budget of 3,000 objective evaluations. Its known minimum is zero at the origin.

```matlab
rng(42, 'twister');
objective = @(x) sum(x.^2);
[bestCost, bestPosition, history] = fno(objective, 5, -5, 5, 30, 3000);
plot(history);
xlabel('Objective evaluations');
ylabel('Best cost so far');
```

The same optimization is available as a runnable [demo](examples/sphere_demo.m).

## Solver interface

```matlab
[bestCost, bestPosition, history] = fno(objective, nVars, lb, ub, popSize, maxEvals)
```

- `objective(x)` receives a row vector and returns one real numeric cost. Smaller values are better. Use a penalty in the objective for constraints beyond the box bounds.
- `lb` and `ub` may be scalars or vectors with one entry per variable. Equal bounds fix a coordinate.
- `popSize` must be at least two. `maxEvals` includes population initialization and must be at least `popSize`.
- `bestPosition` is a row vector. The column vector `history` records the incumbent after every evaluation, including initialization.
- To start from evaluated solutions, pass a seventh argument containing `popSize` structs with fields `Position` and `Cost`. These costs must use the same objective and count toward the budget.

## Published implementation and CEC2014

The refactor follows the [released MATLAB implementation](https://github.com/AhmadTaheri2021/FNO-Optimizer/tree/67d87df7574a8860e7a4144e0c9cd925f1b77feb) where its operational details differ from the paper's notation. Each sweep samples a shrinking prefix of the better ranks, finds the farthest agent in that prefix and the nearest agent among worse ranks, then updates individuals sequentially. Ties follow sorted population order. The temporary move is kept with probability `1 - evaluations/maxEvals`. Otherwise, the focus step starts from that temporary position. Out-of-bounds coordinates are resampled uniformly within their own bounds.

For the original 30-dimensional CEC2014 F2 setup, make your CEC2014 MATLAB evaluator (`cec14_func`) and its required benchmark data available, then execute `Run_FNO`. The benchmark data and evaluator are external dependencies. The runner passes column vectors to CEC2014 and reports objective error after subtracting the function bias (`100 * functionID`).

Existing callers can use the original interface and output order:

```matlab
[history, bestCost] = FNO_final(N, MaxFEs, LB, UB, HM, nPop, functionID);
```

Compared with the initial release, the solver honors the caller's RNG, includes all initial evaluations in the budget, starts from the best of the entire population, and stops exactly at the budget even mid-sweep. These corrections change convergence traces. For historical experiments, use the linked release snapshot.

## Tests

From the repository root in MATLAB:

```matlab
addpath('tests');
test_fno
```

The tests check evaluation counts, incumbent history, repeatability, bounds, pre-evaluated populations, and the original output order.

## Citation

```bibtex
@article{taheri2026fno,
  author  = {Taheri, Ahmad and RahimiZadeh, Keyvan and Baumbach, Jan and
             Beheshti, Amin and Zolotareva, Olga and Al-Betar, Mohammed Azmi and
             Mirjalili, Seyedali and Gandomi, Amir H.},
  title   = {Farthest better or nearest worse optimizer: a novel metaheuristic algorithm},
  journal = {Artificial Intelligence Review},
  year    = {2026},
  volume  = {59},
  pages   = {79},
  doi     = {10.1007/s10462-025-11443-z}
}
```

## License

The implementation is distributed under the [MIT License](LICENSE).
