function LL = IRTmLL(param,BASE,A,AD,B,BD,C,LM,LS,TM,TS,Copula,pcPr)
%Calculate the loglikehood of the model
% LL = IRTmLL(param,BASE,A,AD,B,BD,C,LM,LS,TM,TS,Copula,pcPr)
% internal function to be optimized.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%_________________________________________________________________________%
%
%IRTm Toolbox version0.0 2008 | code written by: Johan Braeken |
%Using this file implies that you agree with the license (see License.pdf)| 
%email: j.braeken@uvt.nl|j.braeken@flavus.org
%_________________________________________________________________________%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

l = IRTmLikelihood(param,BASE,A,AD,B,BD,C,LM,LS,TM,TS,Copula,pcPr);
LL=-sum(log(sum(l,2)).*BASE.N);