function test_fno
% Regression checks shared by MATLAB and GNU Octave.
lb = [-2, 1, 0];
ub = [3, 1, 4];
calls = 0;
observed = [];
rng(17, 'twister');
[cost, x, history] = fno(@counted, 3, lb.', ub, 5, 23);
assert(calls == 23 && isequal(size(history), [23, 1]));
assert(isequal(history, cummin(observed)));
assert(cost == history(end) && cost == sum(x.^2));

rng(17, 'twister');
[cost2, x2, history2] = fno(@(v) sum(v.^2), 3, lb, ub, 5, 23);
assert(isequal(cost, cost2) && isequal(x, x2) && isequal(history, history2));

% A supplied population counts as already evaluated. Its best member
% can be anywhere in the array, including on the final initialization call.
initial = struct('Position', {2, 0, 1}, 'Cost', {4, 0, 1});
[h, c] = FNO_final(1, 3, -2, 2, initial, 3, 2);
assert(c == 0 && isequal(h, [4; 0; 0]));
[c, x, h] = fno(@(v) v.^2, 1, -2, 2, 3, 8, initial);
assert(c == 0 && x == 0 && isequal(h, [4; zeros(7,1)]));

% Non-improving trials on a flat objective keep the initial incumbent.
rng(3, 'twister');
first = rand;
rng(3, 'twister');
[c, x, h] = fno(@(~) 1, 1, 0, 1, 2, 9);
assert(c == 1 && x == first && all(h == 1));

mustFail(@() fno(@sum, 2, [0 0 0], 1, 3, 6));
mustFail(@() fno(@sum, 2, 1, 0, 3, 6));
mustFail(@() fno(@sum, 2, 0, 1, 3, 2));
mustFail(@() fno(@(~) NaN, 2, 0, 1, 3, 6));
fprintf('FNO regression tests passed.\n');

    function value = counted(v)
        assert(isequal(size(v), [1 3]) && all(v >= lb & v <= ub));
        value = sum(v.^2);
        calls = calls + 1;
        observed(calls,1) = value;
    end
end

function mustFail(operation)
try
    operation();
catch
    return
end
error('test_fno:ExpectedError', 'Invalid input was accepted.');
end
