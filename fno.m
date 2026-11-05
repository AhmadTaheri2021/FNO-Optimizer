function [bestCost, bestPosition, history] = fno(objective, nVars, lb, ub, popSize, maxEvals, initial)
%FNO Minimize a scalar objective within a box using the FNO algorithm.
%   [COST, X, HISTORY] = FNO(F, N, LB, UB, POPSIZE, MAXEVALS) calls F
%   with 1-by-N rows. Bounds can be scalars or N-element vectors.
%   HISTORY(k) is the best cost through evaluation k, including initialization.
%   Set rng before calling to reproduce a run.
%
%   An optional seventh argument supplies POPSIZE pre-evaluated individuals
%   with Position and Cost fields. These count toward MAXEVALS.

validateattributes(objective, {'function_handle'}, {'scalar'});
validateattributes(nVars, {'numeric'}, {'scalar','integer','positive','finite','real'});
validateattributes(popSize, {'numeric'}, {'scalar','integer','>=',2,'finite','real'});
validateattributes(maxEvals, {'numeric'}, {'scalar','integer','>=',popSize,'finite','real'});
nVars = double(nVars);
popSize = double(popSize);
maxEvals = double(maxEvals);
lb = expandBound(lb, nVars);
ub = expandBound(ub, nVars);
if any(lb > ub)
    error('fno:Bounds', 'Each lower bound must be at most its upper bound.');
end

positions = zeros(popSize, nVars);
costs = zeros(popSize, 1);
if nargin < 7
    for i = 1:popSize
        positions(i,:) = lb + rand(1,nVars) .* (ub - lb);
        costs(i) = checkedCost(objective(positions(i,:)));
    end
else
    if ~isstruct(initial) || numel(initial) ~= popSize || ...
            ~all(isfield(initial, {'Position','Cost'}))
        error('fno:InitialPopulation', 'Supply one Position and Cost per individual.');
    end
    for i = 1:popSize
        validateattributes(initial(i).Position, {'numeric'}, ...
            {'real','finite','vector','numel',nVars});
        x = double(initial(i).Position(:).');
        if any(x < lb | x > ub)
            error('fno:InitialBounds', 'Initial positions must lie inside the bounds.');
        end
        positions(i,:) = x;
        costs(i) = checkedCost(initial(i).Cost);
    end
end

[bestCost, index] = min(costs);
bestPosition = positions(index,:);
history = zeros(maxEvals, 1);
history(1:popSize) = cummin(costs);
evaluations = popSize;
while evaluations < maxEvals
    [fb, nw] = selectNeighbors(positions, costs, evaluations / maxEvals);
    % Fix neighbor indices for this sweep. Accepted moves are visible to
    % later individuals, as in the released implementation.
    for i = 1:min(popSize, maxEvals - evaluations)
        trial = propose(positions(i,:), positions(fb(i),:), ...
            positions(nw(i),:), evaluations / maxEvals);
        outside = trial < lb | trial > ub;
        trial(outside) = lb(outside) + rand(1,nnz(outside)) .* (ub(outside) - lb(outside));
        cost = checkedCost(objective(trial));
        if cost < costs(i)
            positions(i,:) = trial;
            costs(i) = cost;
            if cost < bestCost
                bestCost = cost;
                bestPosition = trial;
            end
        end
        evaluations = evaluations + 1;
        history(evaluations) = bestCost;
    end
end
end

function bound = expandBound(bound, nVars)
validateattributes(bound, {'numeric'}, {'vector','real','finite'});
if isscalar(bound)
    bound = repmat(double(bound), 1, nVars);
elseif numel(bound) == nVars
    bound = double(bound(:).');
else
    error('fno:BoundSize', 'Bounds must be scalar or have one element per dimension.');
end
end

function cost = checkedCost(cost)
validateattributes(cost, {'numeric'}, {'real','scalar','nonnan'});
cost = double(cost);
end

function [fb, nw] = selectNeighbors(positions, costs, progress)
[~, order] = sort(costs);
n = numel(costs);
fb = (1:n).';
nw = fb;
rank = zeros(n,1);
rank(order) = 1:n;
for i = 1:n
    distances = sum((positions - positions(i,:)).^2, 2);
    % Keep the randomized, shrinking prefix of the best ranks used in v1.
    count = ceil(max(1, rank(i)-1) * (1 - sqrt(progress)) * rand);
    if count > 0
        better = order(1:count);
        [~, j] = max(distances(better));
        fb(i) = better(j);
    end
    if rank(i) < n
        worse = order(rank(i)+1:end);
        [~, j] = min(distances(worse));
        nw(i) = worse(j);
    end
end
end

function trial = propose(x, better, worse, progress)
alpha = sqrt(1 - progress);
mu = rand;
focus = abs(mu - alpha + 2 * alpha * rand(size(x)));
weight = (1 + 2 * rand) * randi(2);
direction = sign(better - x);
sameSide = direction .* sign(worse - x) > 0;
trial = x;
trial(sameSide) = worse(sameSide);
trial = trial + direction .* rand(size(x)) .* abs(worse - x);
if rand >= 1 - progress
    trial = trial + weight .* focus .* (better - trial);
end
end
