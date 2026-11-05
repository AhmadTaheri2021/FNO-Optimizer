# Farthest Better or Nearest Worse Optimizer (FNO)

FNO is a population-based optimizer for bounded minimization. Each agent uses two neighbors to propose its next move. The nearest worse agent helps it step away from a poorer region. The farthest better agent gives it a promising region to explore. An agent accepts a move only when its objective value improves. [Paper in *Artificial Intelligence Review*](https://doi.org/10.1007/s10462-025-11443-z)

## CEC2014 benchmark landscapes

These three surfaces show how the objective value changes with two decision variables. The CEC2014 IDs are the numbers passed to `cec14_func`. The FNO paper numbers functions across several benchmark suites.

| CEC2014 F3 · Rotated Discus | CEC2014 F4 · Shifted and Rotated Rosenbrock | CEC2014 F8 · Shifted Rastrigin |
| :---: | :---: | :---: |
| ![Rotated Discus surface with a single steep direction](docs/figures/cec14-f03-discus.png) | ![Shifted and rotated Rosenbrock surface with a curved valley](docs/figures/cec14-f04-rosenbrock.png) | ![Shifted Rastrigin surface with regularly spaced local minima](docs/figures/cec14-f08-rastrigin.png) |
| F08 in the FNO paper · optimum 300 | F09 in the FNO paper · optimum 400 | F13 in the FNO paper · optimum 800 |

The surface plots are Figures 3, 4(a), and 8 in the [CEC2014 benchmark definitions by Liang, Qu, and Suganthan](https://github.com/P-N-Suganthan/CEC2014/blob/master/Definitions%20of%20%20CEC2014%20benchmark%20suite%20Part%20A.pdf). The [MATLAB example](examples/cec14_benchmarks.m) runs FNO on these three functions and reports the objective value minus the known optimum. Add the repository root and its `examples` folder to the MATLAB path, then run `cec14_benchmarks` from the CEC2014 directory containing the evaluator and `input_data/`.

## Dynamic Focus Strategy (DFS)

Let $p$ be the fraction of the evaluation budget used. With probability $p$, FNO takes a focus step from the temporary position $t$ toward the farthest better position $b$. For each coordinate $j$, the proposal is

$$
x_j^{\mathrm{trial}} = t_j + W d_j (b_j-t_j), \qquad
d_j = \left|\mu + (2u_j-1)\sqrt{1-p}\right|.
$$

The coordinates share a uniform draw $\mu$ and a step weight $W$, while each $u_j$ is drawn independently and uniformly from $[0,1]$. Early in the run, the coordinate multipliers can differ substantially, spreading proposals to either side of the line through $t$ and $b$. As the budget runs down, the multipliers approach the shared value $\mu$, concentrating proposals near that line. A large step can carry the agent beyond $b$.

![Figure 8 from the FNO paper shows eight panels of candidate moves as the focus parameter decreases from 1 to 0.01.](docs/figures/fno-figure-8.jpg)

Figure 8 shows the current position (blue cross), the target (red cross), and possible new positions (asterisks). As the focus width decreases across the panels, the proposals concentrate along the line through the two crosses. Figure reproduced from [Taheri et al., *Artificial Intelligence Review* (2026)](https://doi.org/10.1007/s10462-025-11443-z).

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

## CEC2014 benchmark

For the 30-dimensional CEC2014 F2 setup, make your CEC2014 MATLAB evaluator (`cec14_func`) and its required benchmark data available, then execute `Run_FNO`. The benchmark data and evaluator are external dependencies. The runner passes column vectors to CEC2014 and reports objective error after subtracting the function bias (`100 * functionID`).

To use a pre-evaluated CEC2014 population, call:

```matlab
[history, bestCost] = FNO_final(N, MaxFEs, LB, UB, HM, nPop, functionID);
```

## Tests

From the repository root in MATLAB:

```matlab
addpath('tests');
test_fno
```

The tests check evaluation counts, incumbent history, repeatability, bounds, pre-evaluated populations, and the CEC2014 output order.

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
