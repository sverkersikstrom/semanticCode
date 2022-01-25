function U=IRTmArchimedCrnd(type,n,c,delta);
%Simulation of random positive dependent uniform variables using copulas
% U=IRTmArchimedCrnd(type,n,c,delta) uses the Mixture of Powers distribution
% formulation of Archimedean copulas (See Oakes1982 & Marshall&Olkin1988)
% with n = #persons, c = #margins, type =     Archimedean copula type
% type:            Frank=1 Cook-Johnson=2 Gumbel-Hougaard=3
% parameter range:  ]0,OO[       ]0,OO[              ]1,OO[
% delta =    copula parameter(s)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%_________________________________________________________________________%
%
%IRTm Toolbox version0.0 2008 | code written by: Johan Braeken |
%Using this file implies that you agree with the license (see License.pdf)| 
%email: j.braeken@uvt.nl|j.braeken@flavus.org
%_________________________________________________________________________%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

U=[];
%%SIMULATE
switch type;
    case 1;
        if ((size(delta)>[1,1])|abs(delta)<=0.0001)
            display('Frank: single value in the interval ]-OO,OO[/{0}');
            return;
        end
        %FRANK: logarithmic series distribution with p=1-exp(-delta);
        V=rand(n,2);
        s=repmat(round(1+(log(V(:,1))./log(1-exp(-delta.*V(:,2))) ) ),1,c);
        %phi=(-1/delta)*log(1-(1-exp(-delta))*exp(-s);
        %phi^-1=-log((1-exp(-delta*U))/(1-exp(-delta)));
        V=(rand(n,c)).^(1./s);
        U=(-1/delta).*log(1-(1-exp(-delta)).*V);
    case 2;
        if ((size(delta)>[1,1])|delta<=0)
            display('Cook-Johnson: single value in the interval ]0,OO[');
            return;
        end
        %COOK_JOHNSON: Gamma distribution (1/delta,1);
        s=repmat(gamrnd((1/delta),1,n,1),1,c);
        %phi=(1+s)^(-1/delta);
        %phi^-1=(U^-delta)-1;
        V=exprnd(1,n,c)./s;
        U=(1+V).^(-1/delta);
    case 3;
        if ((size(delta)>[1,1])|delta<=1)
            display('Gumbel-Hougaard: single value in the interval ]1,OO[');
            return;
        end
        %GUMBEL-HOUGAARD: (positive) stable with parameters (1/delta,1);
        V=unifrnd(0,pi,n,1);
        W=exprnd(1,n,1);
        delta2=1/delta;
        ma=(1-delta2)/delta2;
        teller=sin(delta2.*V).*((sin((1-delta2).*V)).^ma);
        noemer=(sin(V).^(1/delta2)).*(W.^ma);
        s=(teller./noemer)*ones(1,c);
        %phi=exp(-s^(1/delta));
        %phi^-1=(-log(U))^delta;
        V=(exprnd(1,n,c))./s;
        U=exp(-V.^delta2);
end;
