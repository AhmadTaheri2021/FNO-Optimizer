function cec14_benchmarks
% Run FNO on the two-dimensional CEC2014 functions shown in the README.
% Add this folder, fno.m and cec14_func to the path, and run from the
% benchmark directory containing input_data/.
global initial_flag
for functionID = [3, 4, 8]
    initial_flag = 0;
    rng(42, 'twister');
    objective = @(x) cec14_func(x.', functionID) - 100 * functionID;
    [errorValue, point] = fno(objective, 2, -100, 100, 30, 3000);
    fprintf('CEC2014 F%02d  x = [% .6f, % .6f]  objective error = %.6g\n', ...
        functionID, point(1), point(2), errorValue);
end
end
