function MODEL = IRTmCheck(MODEL);
%MODEL initialization and check (beta-)
% beta version, for speed compatibility checks between data and model not
% (yet) implemented, possible for futur versions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%_________________________________________________________________________%
%
%IRTm Toolbox version0.0 2008 | code written by: Johan Braeken |
%Using this file implies that you agree with the license (see License.pdf)| 
%email: j.braeken@uvt.nl|j.braeken@flavus.org
%_________________________________________________________________________%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%MODEL INITIALIZATION
if (any(MODEL.A.R) && any(MODEL.A.D(:)) && isempty(MODEL.A.I)); MODEL.A.I=rand(size(MODEL.A.D,2),1)+1; end
if (any(MODEL.AD.R) && any(MODEL.AD.D(:)) && isempty(MODEL.AD.I)); MODEL.AD.I=rand(sum(MODEL.AD.P),1)./2; end
if (any(MODEL.B.R) && any(MODEL.B.D(:)) && isempty(MODEL.B.I)); MODEL.B.I=rand(size(MODEL.B.D,2)); end
if (any(MODEL.BD.R) && any(MODEL.BD.D(:)) && isempty(MODEL.BD.I)); MODEL.BD.I=rand(sum(MODEL.BD.P),1)./2; end
if (any(MODEL.C.R) && any(MODEL.C.D(:)) && isempty(MODEL.C.I)); MODEL.C.I=rand(size(MODEL.C.D,2),1)./6; end
if (any(MODEL.LM.R) && any(MODEL.LM.D(:)) && isempty(MODEL.LM.I)); MODEL.LM.I=rand(size(MODEL.LM.D,2),1); end
if (any(MODEL.LS.R) && any(MODEL.LS.D(:)) && isempty(MODEL.LS.I)); MODEL.LS.I=rand(size(MODEL.LS.D,2),1); end
if (any(MODEL.TM.R) && any(MODEL.TM.D(:)) && isempty(MODEL.TM.I)); MODEL.TM.I=rand(size(MODEL.TM.D,2),1); end
if (any(MODEL.TS.R) && any(MODEL.TS.D(:)) && isempty(MODEL.TS.I)); MODEL.TS.I=rand(size(MODEL.TS.D,2),1)+0.5; end
if (any(MODEL.TW.R) && any(MODEL.TW.D(:)) && isempty(MODEL.TW.I)); MODEL.TW.I=rand(size(MODEL.TW.D,1),1);MODEL.TW.I=MODEL.TW.I/sum(MODEL.TW.I); end;

%MODEL lower bound CONSTRAINTS
if (any(MODEL.A.R) && any(MODEL.A.D(:)) && isempty(MODEL.A.lb)); MODEL.A.lb=zeros(size(MODEL.A.D,2),1); end
if (any(MODEL.AD.R) && any(MODEL.AD.D(:)) && isempty(MODEL.AD.lb)); MODEL.AD.lb=(-inf)*ones(sum(MODEL.AD.P),1); end
if (any(MODEL.B.R) && any(MODEL.B.D(:)) && isempty(MODEL.B.lb)); MODEL.B.lb=(-inf)*ones(size(MODEL.B.D,2),1); end
if (any(MODEL.BD.R) && any(MODEL.BD.D(:)) && isempty(MODEL.BD.lb)); MODEL.BD.lb=(-inf)*ones(sum(MODEL.BD.P),1); end
if (any(MODEL.C.R) && any(MODEL.C.D(:)) && isempty(MODEL.C.lb)); MODEL.C.lb=zeros(size(MODEL.C.D,2),1); end
if (any(MODEL.LM.R) && any(MODEL.LM.D(:)) && isempty(MODEL.LM.lb)); MODEL.LM.lb=(-inf)*ones(size(MODEL.LM.D,2),1); end
if (any(MODEL.LS.R) && any(MODEL.LS.D(:)) && isempty(MODEL.LS.lb)); MODEL.LS.lb=(-inf)*ones(size(MODEL.LS.D,2),1); end
if (any(MODEL.TM.R) && any(MODEL.TM.D(:)) && isempty(MODEL.TM.lb)); MODEL.TM.lb=(-inf)*ones(size(MODEL.TM.D,2),1); end
if (any(MODEL.TS.R) && any(MODEL.TS.D(:)) && isempty(MODEL.TS.lb)); MODEL.TS.lb=zeros(size(MODEL.TS.D,2),1); end
%MODEL upper bound CONSTRAINTS
if (any(MODEL.A.R) && any(MODEL.A.D(:)) && isempty(MODEL.A.ub)); MODEL.A.ub=inf*ones(size(MODEL.A.D,2),1); end
if (any(MODEL.AD.R) && any(MODEL.AD.D(:)) && isempty(MODEL.AD.ub)); MODEL.AD.ub=inf*ones(sum(MODEL.AD.P),1); end
if (any(MODEL.B.R) && any(MODEL.B.D(:)) && isempty(MODEL.B.ub)); MODEL.B.ub=inf*ones(size(MODEL.B.D,2),1); end
if (any(MODEL.BD.R) && any(MODEL.BD.D(:)) && isempty(MODEL.BD.ub)); MODEL.BD.ub=inf*ones(sum(MODEL.BD.P),1); end
if (any(MODEL.C.R) && any(MODEL.C.D(:)) && isempty(MODEL.C.ub)); MODEL.C.ub=ones(size(MODEL.C.D,2),1); end
if (any(MODEL.LM.R) && any(MODEL.LM.D(:)) && isempty(MODEL.LM.ub)); MODEL.LM.ub=inf*ones(size(MODEL.LM.D,2),1); end
if (any(MODEL.LS.R) && any(MODEL.LS.D(:)) && isempty(MODEL.LS.ub)); MODEL.LS.ub=inf*ones(size(MODEL.LS.D,2),1); end
if (any(MODEL.TM.R) && any(MODEL.TM.D(:)) && isempty(MODEL.TM.ub)); MODEL.TM.ub=inf*ones(size(MODEL.TM.D,2),1); end
if (any(MODEL.TS.R) && any(MODEL.TS.D(:)) && isempty(MODEL.TS.ub)); MODEL.TS.ub=inf*ones(size(MODEL.TS.D,2),1); end


%COPULA PART
if (any(any(MODEL.Copula.R)) && isempty(MODEL.Copula.I));
    MODEL.Copula.I=[1+rand(size(MODEL.Copula.R,1),1) ones(size(MODEL.Copula.R,1),1)];
    uc=unique(MODEL.Copula.D(:,end));
    if(size(MODEL.Copula.D,1)>length(uc));
        for s=1:length(uc);
            ind=find(MODEL.Copula.D(:,end)==uc(s));
            ind2=MODEL.Copula.R(ind,2).*rand(length(ind),1)+MODEL.Copula.O(ind,2);
            MODEL.Copula.I(ind,2)=ind2./sum(ind2);
        end;end;
end
if (any(any(MODEL.Copula.R)) && isempty(MODEL.Copula.lb)); MODEL.Copula.lb=ones(size(MODEL.Copula.R,1),2)*0.0001;
    MODEL.Copula.lb(MODEL.Copula.D(:,1)==3,1)=1;
    MODEL.Copula.lb(MODEL.Copula.D(:,1)==4,1)=-inf;
    MODEL.Copula.lb(MODEL.Copula.D(:,1)==1 & MODEL.Copula.D(:,2)==2,1)=-inf;
end
if (any(any(MODEL.Copula.R)) && isempty(MODEL.Copula.ub)); MODEL.Copula.ub(:,1)=inf*ones(size(MODEL.Copula.R,1),1);MODEL.Copula.ub(:,2)=ones(size(MODEL.Copula.R,1),1)*0.9999;end
cop=MODEL.Copula.I(MODEL.Copula.R);
copO=MODEL.Copula.O(MODEL.Copula.R);
coplb=MODEL.Copula.lb(MODEL.Copula.R);
copub=MODEL.Copula.ub(MODEL.Copula.R);
MODEL.Copula.Indep=setdiff([1:size(MODEL.B.D,1)],reshape(MODEL.Copula.D(:,3:end-1),[1 numel(MODEL.Copula.D(:,3:end-1))]));
MODEL.Copula.lI=length(MODEL.Copula.Indep);

for s=1:size(MODEL.Copula.D,1);
    %vectorize recursive sum in probability formula copula model
    MODEL.Copula.DS{s}=recursivesum([0 1],MODEL.Copula.D(s,2));
end

%MODEL PARAMETERS TO BE ESTIMATED
MODEL.init = [MODEL.A.I(MODEL.A.R); MODEL.AD.I(MODEL.AD.R); MODEL.B.I(MODEL.B.R); MODEL.BD.I(MODEL.BD.R); MODEL.C.I(MODEL.C.R); cop(:); MODEL.LM.I(MODEL.LM.R); MODEL.LS.I(MODEL.LS.R); MODEL.TM.I(MODEL.TM.R); MODEL.TS.I(MODEL.TS.R) ];
MODEL.offset = [MODEL.A.O(MODEL.A.R); MODEL.AD.O(MODEL.AD.R); MODEL.B.O(MODEL.B.R); MODEL.BD.O(MODEL.BD.R); MODEL.C.O(MODEL.C.R); copO(:); MODEL.LM.O(MODEL.LM.R); MODEL.LS.O(MODEL.LS.R); MODEL.TM.O(MODEL.TM.R); MODEL.TS.O(MODEL.TS.R); MODEL.TW.O(MODEL.TW.R) ];
%MODEL bounds and constraints
MODEL.lb=[MODEL.A.lb(MODEL.A.R); MODEL.AD.lb(MODEL.AD.R); MODEL.B.lb(MODEL.B.R); MODEL.BD.lb(MODEL.BD.R); MODEL.C.lb(MODEL.C.R); coplb(:); MODEL.LM.lb(MODEL.LM.R); MODEL.LS.lb(MODEL.LS.R); MODEL.TM.lb(MODEL.TM.R); MODEL.TS.lb(MODEL.TS.R) ];
MODEL.ub=[MODEL.A.ub(MODEL.A.R); MODEL.AD.ub(MODEL.AD.R); MODEL.B.ub(MODEL.B.R); MODEL.BD.ub(MODEL.BD.R); MODEL.C.ub(MODEL.C.R); copub(:); MODEL.LM.ub(MODEL.LM.R); MODEL.LS.ub(MODEL.LS.R); MODEL.TM.ub(MODEL.TM.R); MODEL.TS.ub(MODEL.TS.R) ];
MODEL.lin=[];
MODEL.con=[];
if size(MODEL.Copula.D,1)>0;
    %convex sum copula
    uc=unique(MODEL.Copula.D(:,end));
    e=0+cumsum([sum(MODEL.A.R) sum(MODEL.AD.R) sum(MODEL.B.R) sum(MODEL.BD.R) sum(MODEL.C.R) sum(sum(MODEL.Copula.R)) sum(MODEL.LM.R) sum(MODEL.LS.R) sum(MODEL.TM.R) sum(MODEL.TS.R)]);
    if (length(uc)<size(MODEL.Copula.D,1));
        ucc=0;
        for s=1:length(uc);
            uci=find(MODEL.Copula.D(:,end)==uc(s));
            if(length(uci)>1);
                ucc=ucc+1;
                ucis=zeros(size(MODEL.Copula.R));
                ucis(uci,2)=MODEL.Copula.R(uci,2);
                ucis=ucis(MODEL.Copula.R)';
                MODEL.lin(ucc,:)=[zeros(1,e(5)) ucis zeros(1,e(end)-e(6))];
                MODEL.con(ucc,:)=1-sum(MODEL.Copula.O(uci,2));
            end
        end
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%HELP FUNCTIONS%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [M] = recursivesum(V,N)
% returns all combinations of 1/0 in recursive sum of copula probability
% M has the size (length(V).^N)-by-N + 1.
% NB Matrix sizes increases exponentially at rate (n^N)*(N+1).
% adapted from combn version 3.0 thx to jos@jasen.nl
nV = numel(V) ;
A = [0:nV^N-1] ;
B = nV.^(1-N:0);
IND = rem(floor(A(:) * B(:)'),nV) + 1 ;
M = V(IND)+1 ;
M=[M (-1).^sum(M,2)];