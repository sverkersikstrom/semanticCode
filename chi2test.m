function [p q df]=chi2test(Y)


% Compute total number of trials
N=sum(sum(Y));
 
% Compute the totals for Attribute A (Gender)
nidot=sum(Y,2);
 
% Compute the totals for Attribute B (College)
ndotj=sum(Y);
 
% Compute the relative frequencies (probability estimates) 
% for Attribute B
pdotj = ndotj/N; 
 
% Compute the expected frequencies  (an outer product)
NP=nidot*pdotj;
 
% Compute the relative frequencies (probability estimates) 
% for Attribute A
pidot = nidot/N;
 
% Compute the chi-square statistic for the test of 
% independence of attributes
q=sum(sum(((Y-NP).^2)./NP));

[n1 n2]=size(Y);
df=(n1-1)*(n2-1);
if  0
    p=1-chi2cdfCach(q,df);
else
    p=1-chi2cdf(q,df);
end

function p=chi2cdfCach(q,df);
%persistent qsave;
global qsave
if df==1 %& q>.1
    m=25;
    maxN=1500;
    if isempty(qsave)
        qsave=nan(1,maxN+2);
        for i=0:maxN+1
            qsave(i+1)=chi2cdf(i/m,df);
        end
    end
    i=min(maxN,fix(q*m));
    if i>=maxN
        p=1;
    else
        w=q*m-i;
        p=w*qsave(i+2)+(1-w)*qsave(i+1);
    end
else
    p=chi2cdf(q,df);
end
