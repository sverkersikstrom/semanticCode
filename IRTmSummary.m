function r=IRTmSummary(OUTPUT,type,varargin);
%OUTPUT summary utility function (-beta)
% IRTmSummary(OUTPUT,type,MODEL) takes two arguments (and a third optional)
%  an IRTm OUTPUT structure and type
%  type being 'pred' to get a table with observed
%   and predicted response patterns as well as latent trait estimates for
%   each pattern
%  type being 'param' to get a basic model parameter estimates table with
%   standard errors and wald p-values
%   Formulating the optional third argument, an IRTm MODEL structure provides
%   the parameter estimates from parameter labels according to the fitted model
%  type being 'gof' to get basic goodness-of-fit criteria
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%_________________________________________________________________________%
%
%IRTm Toolbox version0.0 2008 | code written by: Johan Braeken |
%Using this file implies that you agree with the license (see License.pdf)| 
%email: j.braeken@uvt.nl|j.braeken@flavus.org
%_________________________________________________________________________%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
results=' ';
if strcmp(type,'param');
    for ii=1:length(OUTPUT);
        if nargin==3;
        MODEL(ii)=varargin{1}(ii);
        l=sum(MODEL(ii).A.R); A=[repmat('alpha_{',[l 1]),num2str([1:l]'),repmat('}',[l 1])];
        l=sum(MODEL(ii).AD.R);VS=[repmat('varsigma_{',[l 1]),num2str([1:l]'),repmat('}',[l 1])];
        l=sum(MODEL(ii).B.R);B=[repmat('beta_{',[l 1]),num2str([1:l]'),repmat('}',[l 1])];
        l=sum(MODEL(ii).BD.R);Z=[repmat('zeta_{',[l 1]),num2str([1:l]'),repmat('}',[l 1])];
        l=sum(MODEL(ii).C.R);O=[repmat('omega_{',[l 1]),num2str([1:l]'),repmat('}',[l 1])];
        l=sum(sum(MODEL(ii).Copula.R));D=[repmat('delta_{',[l 1]),num2str([1:l]'),repmat('}',[l 1])];
        l=sum(MODEL(ii).LM.R);L=[repmat('lambda_{',[l 1]),num2str([1:l]'),repmat('}',[l 1])];
        l=sum(MODEL(ii).LS.R);P=[repmat('psi_{',[l 1]),num2str([1:l]'),repmat('}',[l 1])];
        l=sum(MODEL(ii).TM.R);M=[repmat('mu_{',[l 1]),num2str([1:l]'),repmat('}',[l 1])];
        l=sum(MODEL(ii).TS.R);S=[repmat('sigma_{',[l 1]),num2str([1:l]'),repmat('}',[l 1])];
        l=sum(MODEL(ii).TW.R);W=[repmat('pi_{',[l 1]),num2str([1:l]'),repmat('}',[l 1])];
        labels=strvcat(A,VS,B,Z,O,D,L,P,M,S,W);
        else
            labels=repmat([' '],[length(OUTPUT(ii).param) 1]);
        end
        fieldsize=length( num2str( max(max(round([OUTPUT(ii).param OUTPUT(ii).paramSE OUTPUT(ii).p]))) ) )+5;
        format=['% ',num2str(fieldsize),'.3f '];
        base=[labels,repmat('  ',[length(OUTPUT(ii).param) 1]),num2str([OUTPUT(ii).param OUTPUT(ii).paramSE OUTPUT(ii).p],repmat(format,[1 3]))];
        space=' ';
        col=['est ',repmat(space,[1,fieldsize-3]),'se',repmat(space,[1,fieldsize-2]),'  p  '];
        col=[repmat(space,[1,size(base,2)-length(col)]),col];
        line=repmat('_',[1 length(col)]);
        table=strvcat(' ',['Model ',num2str(ii)],[line;col;line;base;line],' ');
        results=table;
    end
elseif strcmp(type,'pred');
    for ii=1:length(OUTPUT);
        ypat=OUTPUT(ii).Y*10.^[0:OUTPUT(ii).lI-1]';
        base=[num2str([ypat OUTPUT(ii).Z OUTPUT(ii).S round2(OUTPUT(ii).Freq,1)])  repmat(' ',[OUTPUT(ii).lX 4]) num2str(round2(OUTPUT(ii).Npred,1),['%',num2str(length(num2str(OUTPUT.lN))+1),'.1f '])   repmat(' ',[OUTPUT.lX 4])  num2str(round2([OUTPUT(ii).ebe OUTPUT(ii).ebeSE OUTPUT(ii).trait],3),'% 3.3f   ')];
        line=repmat('_',[1 size(base,2)]);
        x=[repmat(' ',[1 OUTPUT(ii).lI-1]),'Y',repmat(' ',[1 OUTPUT(ii).lJ+1]),'X',repmat(' ',[1 length(num2str(max(OUTPUT(ii).S)))+4]),'S',repmat(' ',[1 length(num2str(max(OUTPUT(ii).lX)))+4]),'No',repmat(' ',[1 length(num2str(max(OUTPUT(ii).Npred)))-1]),'Np',repmat(' ',[1 length(num2str(max(OUTPUT(ii).ebe)))+1]),'res',repmat(' ',[1 length(num2str(max(OUTPUT(ii).ebeSE)))]),'se',repmat(' ',[1 length(num2str(max(OUTPUT(ii).trait)))]),'tot'];

        results=strvcat(' ',line,['Model ',num2str(ii)],x,[line;base;line],['chisquare_obs:',num2str(OUTPUT(ii).Chi2),'        RMSE_lt:',num2str(OUTPUT(ii).RMSE)],line,' ');
    end
elseif strcmp(type,'gof');
    fieldsize=length( num2str( max(max(round([OUTPUT.LL;OUTPUT.lP;OUTPUT.AIC;OUTPUT.BIC]))) ) )+5;
    format=['% ',num2str(fieldsize),'.2 '];
    base=num2str([[1:length(OUTPUT)];round([OUTPUT.LL;OUTPUT.lP;OUTPUT.AIC;OUTPUT.BIC]*100)/100]);
    col=strvcat('Model','Loglikelihood','#par','AIC','BIC');
    base=[col,repmat(' ',[size(base,1) 1]),base];
    line=repmat('_',[1 size(base,2)]);
    results=strvcat(' ',[line;base(1,:);line;base(2:end,:);line],' ');
end
r=[];
for i=1:size(results,1)
r=[r sprintf('%s\n',results(i,:))];
end
1;


function b = round2(a, n)
%Round to a specified number of decimals.
% ROUND2(a, n)   rounds the elements of A to decimals specified in N.
t2n = 10.^floor(n);
b = roundfn(a.*t2n)./t2n;
function b = roundfn(s)
b = round(s);
tf = @(r) round(10*abs(r - fix(r))) == 5;
if isreal(s)
    k = tf(s);
    b(k) = 2*fix(b(k)/2);
else
    x = real(b);
    y = imag(b);
    k = tf(real(s));
    x(k) = 2*fix(x(k)/2);
    k = tf(imag(s));
    y(k) = 2*fix(y(k)/2);
    b = complex(x,y);
end