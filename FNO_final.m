function [BestCosts,BestSolCost]=FNO_final(N,MaxFEs,LB,UB,HM,nPop,CostFunction)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Farthest better Nearest worse Optimizer (FNO) Algorithm             % 
% version 1.0                                                            %
% Github:                                                                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% nPop = 50
%%%%%%%%%%%%%%%%%%
rand('state',sum(100*clock));
fhd=str2func('cec14_func');
%fhd=@cec19_func;  
%% Problem Definition
% Cost Function
nVar = N;                        %  Number of Unknown Variables
VarSize =  [1 nVar];             %  Variables Matrix Size
VarMin  =  LB.*ones(1,N);        %  Variables Lower Bound
VarMax  =  UB.*ones(1,N);        %  Variables Upper Bound

%% FNO Parameters
MaxFEs = MaxFEs;                 %  Maximum Number of Iterations
nPop = nPop;                     %  Population Size

%% Initialization 
% Empty Structure for Individuals
empty_Position.Position=[];
empty_Position.Cost=[];
empty_Position.Fy=[];
empty_Position.Gx=[];

Diver = 0;
% Initialize Population Array
Position = repmat(empty_Position, nPop, 1);
% Initialize Best Solution
Position = HM(1:nPop);
BestPosition = Position(1);

for i=1:nPop
    positions(i,:) = Position(i).Position;
    Costs(i,1) =  Position(i).Cost;
end
% Initialize Best Score Record
BestCosts = ones(MaxFEs,1)+realmax;
BestCosts(1) = BestPosition.Cost;

  FEs = 1;
  alpha = 1;
  %% FNO Main Loop
while FEs < MaxFEs 
   
  %% Determine Farthest Better and Nearest Worse positions for each candidate
  [~ , sortedindxs] = sort([Position.Cost]); 
  DP = pdist2(positions,positions,'euclidean'); % minkowski / correlation / cityblock / euclidean
  
  for i = 1:nPop
    [~ ,  PosiRank] = find(sortedindxs == i);
    if PosiRank == nPop || PosiRank == 1
       if PosiRank == 1
          Betters = sortedindxs(1:PosiRank);
          Worses = sortedindxs(PosiRank+1:end);
       else
          Betters = sortedindxs(1:PosiRank-1);
          Worses = sortedindxs(PosiRank:end); 
       end
    else
      Betters = sortedindxs(1:PosiRank-1);
      Worses = sortedindxs(PosiRank+1:end);
    end
    
    Betters = Betters(1:ceil(length(Betters)* (1-(FEs/MaxFEs)^0.5) * rand ));
    %Betters = Betters(1:ceil(length(Betters)));
    NW(i) = i; FB(i) = i; NB(i) = i; FW(i) = i;
    if ~isempty(Betters) 
        [~,INd] = max(DP(Betters,i));
        FB(i) = Betters(INd);
     end 
    if ~isempty(Worses) 
        [~,INd] = min(DP(Worses,i));
        NW(i) = Worses(INd);
    end 
   end
 
 %% --------------------
   
 
 %%   
 for i= 1 : nPop 
 
      newPos = Position(i);          
     
   % ----------------------- Dynamic Focus Factor -------------------------    
      %alpha = (1-(FEs/MaxFEs)^(1/2));
      alpha = (1-(FEs/MaxFEs))^(1/2);
      Mu = rand;
      DFF = abs(unifrnd((Mu-alpha),(Mu+alpha),VarSize));
  
   % ----------------------- W ------------------------ 
      W = (2 + unifrnd(-1,+1))*randi([1 2]);
   % -----------------------  ------------------------- 
      S = max(0, sign(Position(FB(i)).Position - Position(i).Position) .* sign(Position(NW(i)).Position - Position(i).Position));
     
      Pos_temp = (S) .*  Position(NW(i)).Position + (1-S) .*  Position(i).Position + ...
            sign(Position(FB(i)).Position - Position(i).Position).* rand(VarSize) .*(abs(Position(NW(i)).Position - Position(i).Position));
     
      if rand < 1-(FEs/MaxFEs)
   % ----------------------- Jump over (if S==1) or escape from (if S==0) the NW -------------------------    
          newPos.Position = Pos_temp;
      else
   % ----------------------- Apply the Dynamic Focus Strategy (DFS) and Explore the FB -------------------       
        Exp =   DFF .* (Position(FB(i)).Position - Pos_temp);
        newPos.Position = Pos_temp + W .* Exp;
      end
        
   % ------------------------------- Clipping ------------------------------
         
      newPos = Clipping(VarMin,VarMax,newPos);
   
   % ------------------------------- Evaluation ----------------------------    
     % newPos.Cost = feval(fhd,newPos.Position',CostFunction); % CEC 2019 
      newPos.Cost = feval(fhd,newPos.Position',CostFunction) -  (CostFunction*100); % CEC2014 F(X) - F(X*)
      
      FEs = FEs + 1;
           
   % ------------------------------- Comparision ---------------------------
      if newPos.Cost < Position(i).Cost
         Position(i) = newPos;
          
         if newPos.Cost < BestPosition.Cost
             BestPosition = newPos;
         end    
      end    
  % ----------------------- Record the best score for Current Iteration -----------
      BestCosts(FEs) = BestPosition.Cost;
  
 end % nPop for 
 
  
 for i=1:nPop
    positions(i,:) = Position(i).Position;
    Costs(i,1) =  Position(i).Cost;
 end
  positions = positions(1:nPop,:);
  Costs = Costs(1:nPop,:);
 
 %%
     % Show Iteration Information
 %   if size(find(BestSol.Gx < 0)) == 0 
 %       flg='*';
 %   else
 %       flg=' ';
 %   end
  formatSpec = '%10.7e';
  disp(['Iteration ' num2str(FEs) ':  Best Cost = ' num2str(BestCosts(FEs),formatSpec) ' alpha:' num2str(alpha) ]);
    
 
end
% Rate = Rate ./ FERate;
BestSolCost=BestPosition.Cost
CostFunction
%BestSolCost=BestSol.Cost
%disp('----F---');
%BestSol.Fy
%disp('----Gx---');
%BestSol.Gx
%disp('----Xi---');
%BestSol.Position
end

function [newsol] = Clipping(VarMin,VarMax,newsol)
     % Clipping
     [~,underLB] = find(newsol.Position < VarMin);
     [~,uperUB] = find(newsol.Position > VarMax);
     
     if ~isempty(underLB)
        newsol.Position(underLB) = VarMin(underLB) + unifrnd(0,1,1,size(underLB,2)).* ( VarMax(underLB) - VarMin(underLB)); 
     end
     if ~isempty(uperUB)    
        newsol.Position(uperUB)  = VarMin(uperUB)  + unifrnd(0,1,1,size(uperUB,2)) .* ( VarMax(uperUB) - VarMin(uperUB));
     end      
end

