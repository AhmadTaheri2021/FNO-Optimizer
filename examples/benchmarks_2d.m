% Minimize three two-dimensional test functions. Each has minimum value zero.
addpath(fileparts(fileparts(mfilename('fullpath'))));
names = {'Sphere', 'Rosenbrock', 'Rastrigin'};
objectives = {@(x) sum(x.^2), ...
    @(x) (1-x(1))^2 + 100*(x(2)-x(1)^2)^2, ...
    @(x) 20 + sum(x.^2 - 10*cos(2*pi*x))};
lower = {[-5 -5], [-2 -1], [-5.12 -5.12]};
upper = {[5 5], [2 3], [5.12 5.12]};
for k = 1:numel(names)
    rng(42, 'twister');
    [cost, x] = fno(objectives{k}, 2, lower{k}, upper{k}, 30, 3000);
    fprintf('%-10s  x = [% .6f, % .6f]  f(x) = %.6g\n', ...
        names{k}, x(1), x(2), cost);
end
