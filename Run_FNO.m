% CEC2014 experiment. Run from a directory where the evaluator finds its data.
if isempty(which('cec14_func'))
    error('fno:MissingCEC2014', ...
        'Add the CEC2014 MATLAB evaluator and its data, or run examples/sphere_demo.m.');
end

Func_id = 2;
N = 30;
nPop = 30;
MaxFEs = N * 10000;
NumofExper = 1;
rng(1, 'twister');

global initial_flag
objective = @(x) cec14_func(x.', Func_id) - 100 * Func_id;
SumBestCostFNO_ = zeros(MaxFEs, 1);
BestSolCostFNO = zeros(1, NumofExper);
for ii = 1:NumofExper
    initial_flag = 0;
    [BestSolCostFNO(ii), bestPosition, BestCostFNO_] = ...
        fno(objective, N, -100, 100, nPop, MaxFEs);
    SumBestCostFNO_ = SumBestCostFNO_ + BestCostFNO_;
end
AveBestCostFNO_ = SumBestCostFNO_ / NumofExper;
Mean = mean(BestSolCostFNO);
SD = std(BestSolCostFNO);
fprintf('CEC2014 F%d final error: mean %.8g, SD %.8g (%d runs)\n', ...
    Func_id, Mean, SD, NumofExper);
figure;
semilogy(AveBestCostFNO_);
xlabel('Objective evaluations');
ylabel('Mean best objective error');
grid on;
