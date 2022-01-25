function [Y th ind] = IRTmSim(MODEL,N,varargin);
%IRTm Data simulation
% [Y th ind] = IRTmSim(MODEL,N,varargin) True MODEL design underlying the data
% with Offset fields containing the model parameter values
% N = sample size | varargin Z = covariate data persons by covariates
% The function returns 3 matrices
%   Y is matrix of simulated binary item responses
%   th is vector of generated latent traits (sum of fixed part due to covariates and random part)
%   ind is component membership
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%_________________________________________________________________________%
%
%IRTm Toolbox version0.0 2008 | code written by: Johan Braeken |
%Using this file implies that you agree with the license (see License.pdf)| 
%email: j.braeken@uvt.nl|j.braeken@flavus.org
%_________________________________________________________________________%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin==3;
    Z=varargin{:};
else
    Z=[];
end
alpha=repmat(MODEL.A.D*MODEL.A.O,[1 N])';
beta=repmat(MODEL.B.D*MODEL.B.O,[1 N])';
ceta=repmat(MODEL.C.D*MODEL.C.O,[1 N])';

[ignore,shuf] = sort(rand(1,N));
[ignore,resetshuf] = sort(shuf);
if(isempty(Z));
    lambda=zeros(N,1);sigma=zeros(N,1);ad=1;bd=0;
else
    if size(Z,1)~=N; error('Covariate information is needed for all N fictive persons.');end
    lambda=Z*MODEL.LM.D*MODEL.LM.O;
    sigma=Z*MODEL.LS.D*MODEL.LS.O;
    ap=0;bp=0;
    for ii=1:size(Z,2);
        if(~isempty(MODEL.AD.D));
            ad(:,ii)=MODEL.AD.D(:,ap+1:ap+MODEL.AD.P(ii))*MODEL.AD.O(ap+1:ap+MODEL.AD.P(ii));
            ap=ap+MODEL.AD.P(ii);
        end
        if(~isempty(MODEL.BD.D));
            bd(:,ii)=MODEL.BD.D(:,bp+1:bp+MODEL.BD.P(ii))*MODEL.BD.O(bp+1:bp+MODEL.BD.P(ii));
            bp=bp+MODEL.BD.P(ii);
        end
    end
    if(~isempty(MODEL.AD.D));
        ad=Z*ad';
    else
        ad=1;
    end
    if(~isempty(MODEL.BD.D));
        bd=Z*bd';
    else
        bd=0;
    end
    sigma=sigma(shuf);
    lambda=lambda(shuf);
end
THmu=MODEL.TM.D*MODEL.TM.O;
THsigma=MODEL.TS.D*MODEL.TS.O;
THw=MODEL.TW.D*MODEL.TW.O;
compN=cumsum([0;round(THw.*N)]);
compN(end)=N;
ind=zeros(N,1);
for ii=1:length(compN)-1;
    th(compN(ii)+1:compN(ii+1))=randn(length(compN(ii)+1:compN(ii+1)),1).*sqrt(THsigma(ii)+sigma(compN(ii)+1:compN(ii+1)))+THmu(ii)+lambda(compN(ii)+1:compN(ii+1));
    ind(compN(ii)+1:compN(ii+1))=ii;
end
th=th(resetshuf)';
ind=ind(resetshuf);
eta = (alpha.*ad).*(repmat(th,[1 size(beta,2)])-beta-bd);
F=(1-ceta)./(1+exp(eta));
U=rand(N,size(beta,2));
%COPULA PART
if ~isempty(MODEL.Copula.D);
    u=zeros(N,max(MODEL.Copula.D(:,2)));
    for c=1:size(MODEL.Copula.D,1);
        set=MODEL.Copula.D(c,3:2+MODEL.Copula.D(c,2));
        u(:,1:length(set),c)=IRTmArchimedCrnd(MODEL.Copula.D(c,1),N,MODEL.Copula.D(c,2),MODEL.Copula.O(c,1)).*MODEL.Copula.O(c,2);
    end
    cs=unique(MODEL.Copula.D(:,end));
    for c=1:length(cs);
        index=find(MODEL.Copula.D(:,end)==c);
        U(:,MODEL.Copula.D(index(1),3:2+MODEL.Copula.D(index(1),2)))=sum(u(:,1:MODEL.Copula.D(index(1),2),index),3);
    end
end
%DATA
Y=U>F;
Y=Y+0;