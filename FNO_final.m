function [BestCosts, BestSolCost] = FNO_final(N, MaxFEs, LB, UB, HM, nPop, CostFunction)
%FNO_FINAL Original CEC2014 interface. HM contains pre-evaluated solutions
%   with bias-adjusted costs. MaxFEs includes the first nPop evaluations.
validateattributes(CostFunction, {'numeric'}, {'scalar','integer','>=',1,'<=',30});
objective = @(x) cec14_func(x.', CostFunction) - 100 * CostFunction;
[BestSolCost, ~, BestCosts] = fno(objective, N, LB, UB, nPop, MaxFEs, HM(1:nPop));
end
