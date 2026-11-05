% From the repository root: run('examples/sphere_demo.m')
% run() temporarily changes the working directory, so expose the solver.
addpath(fileparts(fileparts(mfilename('fullpath'))));
rng(42, 'twister');
sphereCost = @(x) sum(x.^2);
[bestCost, bestPosition, history] = fno(sphereCost, 5, -5, 5, 30, 3000);
fprintf('Sphere cost after %d evaluations: %.8g\n', numel(history), bestCost);
disp(bestPosition);
