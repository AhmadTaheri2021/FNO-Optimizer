%------------------------------------
% FNO Algorithm
% 
% Github: 
%------------------------------------
clear;
clc;
%%            settings 
   Func_id = 2;        % CEC2014 1~30
   nPop=30;            % Population Size
   N = 30;             % number of Decision variables 
   MaxFEs= N * 10000;  % Maximum number of function evaluations
   NumofExper = 1;     % Number of test
  % Benchmark = 3;     % 1:Classic 2:CEC2005 3:CEC2014 
   
   %FileName = [ FileName ' D30_NFE300K_30t ']; 

% =====================================================================================

global initial_flag
initial_flag = 0;
%% 
Function_name=['F' num2str(Func_id)];
%========== CEC2014 ==========
fhd=str2func('cec14_func');
CostFunction=Func_id;
LB=-100;%lb;
UB=100;%ub;
Opt = 100:100:3000;
%================
 
LB = LB.*ones(1,N);       %   Lower Bound
UB = UB.*ones(1,N);       %   Upper Bound

% Empty Solution Structure
empty_Solution.Position=[];
empty_Solution.Cost=[];

% Initialize 
Population=repmat(empty_Solution,nPop,1);
SumBestCostFNO_=zeros(MaxFEs,1);
BestSolCostFNO= []; %zeros(MaxFEs,1);

%===================================================

for ii=1:NumofExper
    
 
  rand('state',sum(100*clock));
  initial_flag = 0; % should set the flag to 0 for each run, each function
  
   % Create Initial Population
for i=1:nPop
    Population(i).Position= LB+rand(1,N).*(UB-LB); %LB+rand(1,N).*(UB-LB);    
    Population(i).Cost = feval(fhd,Population(i).Position',CostFunction) -  (CostFunction*100); % CEC2014 F(X) - F(X*)
end  
    
   %% 
%tic;
  
[BestCostFNO_,BestSolCostFNO(ii)]=FNO_final(N,MaxFEs,LB,UB,Population,nPop,CostFunction);  
SumBestCostFNO_=SumBestCostFNO_+ BestCostFNO_(1:MaxFEs);
%T2 = toc;
end


AveBestCostFNO_=SumBestCostFNO_ ./ NumofExper;
%% 
Mean = mean(BestSolCostFNO);

SD   = std(BestSolCostFNO);

%filename=['FNO Result ' FileName ' _' Function_name '.mat']
%save(filename);
f1=figure;
semilogy(AveBestCostFNO_,'r-','LineWidth',2);
grid on;
hold off;
xlabel('FEs');
str=['F(x) = ' Function_name];
ylabel(str);
legend('FNO');