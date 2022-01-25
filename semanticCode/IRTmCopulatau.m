function delta=IRTmCopulatau(Tau);
%compute copula parameter for corresponding approximate kendall Tau value
% Returns copula parameter for Frank , Cook-Johnson and Gumbel-Hougaard
% copula, in that order, for a corresponding kendall Tau value 
% (For more info, see Nelsen,1999 or any copula related reference work)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%_________________________________________________________________________%
%
%IRTm Toolbox version0.0 2008 | code written by: Johan Braeken |
%Using this file implies that you agree with the license (see License.pdf)| 
%email: j.braeken@uvt.nl|j.braeken@flavus.org
%_________________________________________________________________________%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Fdelta=fzero(@frankRootFun,sign(Tau),[],Tau);
CJdelta=2*Tau /(1-Tau);
GHdelta=1/(1-Tau);

delta=[Fdelta CJdelta GHdelta];

function err = frankRootFun(alpha,targetTau)
if abs(alpha) < realmin
    tau = 0;
else
    tau = 1 - 4 .* (1-debye1(alpha)) ./ alpha;
end
err = tau - targetTau;

function D1 = debye1(x)
%DEBYE1 First order Debye function.
%   Y = DEBYE1(X) returns the first order Debye function, evaluated at X.
%   X is a scalar.  For positive X, this is defined as
%      (1/x) * integral from 0 to x of (t/(exp(t)-1)) dt
%   Written by Peter Perkins, The MathWorks, Inc.
%   Revision: 1.0  Date: 2003/09/05
%   This function is not supported by The MathWorks, Inc.
if abs(x) >= realmin
    D1 = quad(@debye1_integrand,0,abs(x))./abs(x) - (x < 0).*x./2;
else
    D1 = 1;
end
function y = debye1_integrand(t)
y = ones(size(t));
nz = (abs(t) >= realmin);
y(nz) = t(nz)./(exp(t(nz))-1);