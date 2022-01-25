function OUTPUT = IRTmEBE(param,BASE,OUTPUT,A,AD,B,BD,C,LM,LS,TM,TS,Copula,pcPr);
%Calculate empirical Bayes estimates of the latent trait
% OUTPUT = IRTmEBE(param,BASE,OUTPUT,A,AD,B,BD,C,LM,LS,TM,TS,Copula,pcPr); gives
% back posterior probabilities for the latent trait, empirical Bayes
% estimates and standard errors as well as the root mean squared error,
% predicted frequencies of observed response patterns and a related
% chi-square statistic.
% Possible Extensions for this module are reliability measures,
% standard plots involving the latent trait, and other diagnostic tests
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%_________________________________________________________________________%
%
%IRTm Toolbox version0.0 2008 | code written by: Johan Braeken |
%Using this file implies that you agree with the license (see License.pdf)| 
%email: j.braeken@uvt.nl|j.braeken@flavus.org
%_________________________________________________________________________%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[OUTPUT.l OUTPUT.ebe OUTPUT.ebeSE OUTPUT.trait] = IRTmLikelihood(param,BASE,A,AD,B,BD,C,LM,LS,TM,TS,Copula,pcPr);
OUTPUT.Npred = BASE.lN.*sum(OUTPUT.l,2);
OUTPUT.Chi2 = sum(((BASE.N - OUTPUT.Npred).^2)./OUTPUT.Npred);
OUTPUT.RMSE = sqrt(sum(BASE.N.*OUTPUT.ebeSE.^2)/BASE.lN);