function [l varargout] = IRTmLikelihood(param,BASE,A,AD,B,BD,C,LM,LS,TM,TS,Copula,pcPr)
%Extract parameters, build up model and compute likelihood
% See documentation for the exact model likelihood to be optimized
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%_________________________________________________________________________%
%
%IRTm Toolbox version0.0 2008 | code written by: Johan Braeken |
%Using this file implies that you agree with the license (see License.pdf)| 
%email: j.braeken@uvt.nl|j.braeken@flavus.org
%_________________________________________________________________________%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

e=0+cumsum([sum(A.R) sum(AD.R) sum(B.R) sum(BD.R) sum(C.R) sum(sum(Copula.R)) sum(LM.R) sum(LS.R) sum(TM.R) sum(TS.R)]);
if any(A.R); A.O(A.R)=A.O(A.R)+param(1:e(1)); end;
if any(AD.R); AD.O(AD.R)=AD.O(AD.R)+param(1+e(1):e(2)); end;
if any(B.R); B.O(B.R)=B.O(B.R)+param(1+e(2):e(3)); end
if any(BD.R); BD.O(BD.R)=BD.O(BD.R)+param(1+e(3):e(4)); end
if any(C.R); C.O(C.R)=C.O(C.R)+param(1+e(4):e(5)); end
if any(any(Copula.R)); Copula.O(Copula.R)=Copula.O(Copula.R)+param(1+e(5):e(6));end
if any(LM.R); LM.O(LM.R)=LM.O(LM.R)+param(1+e(6):e(7)); end
if any(LS.R); LS.O(LS.R)=LS.O(LS.R)+param(1+e(7):e(8)); end
if any(TM.R); TM.O(TM.R)=TM.O(TM.R)+param(1+e(8):e(9)); end
if any(TS.R); TS.O(TS.R)=TS.O(TS.R)+param(1+e(9):e(10)); end

alpha=repmat(A.D*A.O,[1 BASE.lQP BASE.lX]);
beta=repmat(B.D*B.O,[1 BASE.lQP BASE.lX]);
ceta=repmat(C.D*C.O,[1 BASE.lQP BASE.lX]);
if(isempty(BASE.Z));
    lambda=0;sigma=0;ad=0;bd=0;
else
    lambda=repmat(shiftdim(BASE.Z*LM.D*LM.O,-2),[BASE.lI BASE.lQP 1]);
    sigma=repmat(shiftdim(BASE.Z*LS.D*LS.O,-2),[BASE.lI BASE.lQP 1]);
    ap=0;bp=0;
    ad=zeros(BASE.lI,BASE.lJ);
    bd=zeros(BASE.lI,BASE.lJ);
    for ii=1:BASE.lJ;
        if(~isempty(AD.D));
            ad(:,ii)=AD.D(:,ap+1:ap+AD.P(ii))*AD.O(ap+1:ap+AD.P(ii));
            ap=ap+AD.P(ii);
        end
        if(~isempty(BD.D));
            bd(:,ii)=BD.D(:,bp+1:bp+BD.P(ii))*BD.O(bp+1:bp+BD.P(ii));
            bp=bp+BD.P(ii);
        end
    end
    if(~isempty(AD.D));
        ad=repmat(permute(BASE.Z*ad',[2 3 1]),[1 BASE.lQP 1]);
    else
        ad=0;
    end
    if(~isempty(BD.D));
        bd=repmat(permute(BASE.Z*bd',[2 3 1]),[1 BASE.lQP 1]);
    else
        bd=0;
    end
end
THmu=TM.D*TM.O;
THsigma=TS.D*TS.O;
%%unvectorized dimensions are lI x lQP x lX;
ceta=ceta(:);

%PREALLOCATE
Pjo=zeros(size(pcPr,1),BASE.lX*BASE.lQP);
l=zeros(BASE.lX,size(pcPr,1));
if nargout==3;
    ebec=zeros(BASE.lX,size(pcPr,1));
    sec=zeros(BASE.lX,size(pcPr,1));
end
for class=1:size(pcPr,1);
    eta = (alpha(:)-ad(:)).*( sqrt(2).*sqrt(THsigma(class)+sigma(:)).*BASE.TH + THmu(class)+lambda(:) -beta(:)-bd(:) );%IRT
    %Pr = BASE.Y.*ceta + (1-ceta).*exp(BASE.Y.*eta)./(1+exp(eta));
    %Pr(BASE.Y==0)= (1-ceta(BASE.Y==0))./(1+exp(eta(BASE.Y==0)));
    %Pr(BASE.Y==1)=ceta(BASE.Y==1)+exp(eta(BASE.Y==1))./(1+exp(eta(BASE.Y==1)));
    F=(1-ceta)./(1+exp(eta));
    Pr=F;Pr(BASE.Y==1)=1-Pr(BASE.Y==1);
    Pr = reshape(Pr,[BASE.lI BASE.lX*BASE.lQP]);
    %LOCAL INDEPENDENT ITEMS
    Pjo(class,:) = prod(Pr(Copula.Indep,:));
    %LOCAL DEPENDENT ITEMS
    if (isempty(Copula.D)==0);
        Y=reshape(BASE.Y,[BASE.lI BASE.lX*BASE.lQP]);
        F=reshape(F,[BASE.lI BASE.lX*BASE.lQP]);
        cs=unique(Copula.D(:,end));
        if length(cs)-size(Copula.D,1)<0;
            for s=1:length(cs);
                uci=find(Copula.D(:,end)==cs(s));
                if(length(uci)>1);
                    Copula.O(logical(1-Copula.R(uci,2)),2)=1-sum(Copula.O(uci,2));
                end
            end
        end

        pjoc=zeros(1,BASE.lX*BASE.lQP,size(Copula.D,1));
        for c=1:size(Copula.D,1);
            subset=Copula.D(c,3:2+Copula.D(c,2));
            D=Copula.DS{c};        K=size(D,1);
            Y_subset=repmat(Y(subset,:),[1 1 K]);
            F_subset=repmat(F(subset,:),[1 1 K]);
            d=repmat(permute(D(:,1:end-1),[2 3 1]),[1 BASE.lX*BASE.lQP 1]);
            d=abs(Y_subset-d+1).*F_subset+(Y_subset.*(d-1));
            dsign=repmat(shiftdim(D(:,end),-2),[1 BASE.lX*BASE.lQP 1]);
            if (VW(Copula.D(c,1),Copula.O(c,1)));
                pjoc(:,:,c)=Copula.O(c,2).*sum(copulaCDF(d,Copula.D(c,1),Copula.O(c,1)).*dsign,3);
            else
                %Switch to Regular independence case when copula moves to independence limit;
                pjoc(:,:,c)=Copula.O(c,2).*prod(Pr(subset,:));
            end
        end;

        for css=1:length(cs);
            cind=find(Copula.D(:,end)==cs(css));
            if nargout==2;
                copr=sum(pjoc(:,:,cind),3);
                copl(:,class,c)=sum(reshape(copr.*BASE.W,[BASE.lQP BASE.lX])).*pcPr(class);
            end
            Pjo(class,:) = Pjo(class,:).*sum(pjoc(:,:,cind),3);
        end;
    end
    l(:,class)=sum(reshape(Pjo(class,:).*BASE.W,[BASE.lQP BASE.lX])).*pcPr(class,:);

    if nargout==4;
        th=reshape(sqrt(2).*sqrt(THsigma(class)+sigma(:)).*BASE.TH,[BASE.lI BASE.lX*BASE.lQP]);
        th=th(1,:);

        ebec(:,class)=(sum(reshape(Pjo(class,:).*BASE.W.*th,[BASE.lQP BASE.lX])).*pcPr(class,:))./l(:,class)';
        thh=repmat(shiftdim(ebec(:,class),-1),[BASE.lQP 1]);
        sec(:,class)=(sum(reshape(Pjo(class,:).*BASE.W.*(th-thh(:)').^2,[BASE.lQP BASE.lX])).*pcPr(class))./l(:,class)';
    end;
end
if nargout==2;
    copLL=zeros(1,size(Copula.D,1));
    for c=1:size(Copula.D,1);
        copLL(c)=-sum(log(sum(copl(:,:,c),2)).*BASE.N);
    end
    if isempty(Copula.D); copLL=0; end;
    varargout(1)={copLL};
elseif nargout==4;
    sebe=sum(ebec,2);
    varargout(1)={sebe};%EBE
    varargout(2)={sqrt(sum(sec,2))};%SE
    varargout(3)={sebe+BASE.Z*LM.D*LM.O};%fixed+residual part of latent trait
end;




%%%%%%%%%%%%%%HELPFUNCTIONS%%%%%%%%%%%%%%%%%%%%%%
function outcome=VW(ctype,delta)
switch ctype;
    %independence
    case 0; outcome=0;
        %Frank's copula;
    case 1; outcome=abs(delta)>0.0001;
        %CookJohnson's copula;
    case 2; outcome=delta>0.0001;
        %Gumbel-Hougaard copula
    case 3; outcome=delta>1.0001;
        %Plackett
    case 4; outcome=((delta>0.0001 & delta<0.999)|delta>1.0001);
    otherwise; outcome=1;
end
function copulaF = copulaCDF(d,ctype,delta)
switch ctype;
        %Frank;
    case 1;        copulaF=(-1/delta).*log(1-(1-exp(-delta)).*prod((1-exp(-delta.*d))./(1-exp(-delta)),1));
        %CookJohnson copula;
    case 2;        copulaF=(1+sum((d.^(-delta))-1,1)).^(-1/delta);
        %Gumbel-Hougaard copula
    case 3;        copulaF=exp(-(sum((-log(d)).^delta)).^(1/delta));
        %Plackett: only implemented for bivariate case, multivariate-extension not available in straightforward way
    case 4;        copulaF=(0.5*(delta-1)^(-1)).*(1+(delta-1).*sum(d,1)-(((1+(delta-1).*sum(d,1)).^2)+4*delta*(1-delta).*prod(d,1)).^0.5);
        %FrechetHoeffding lowerbound W
    case 5;        copulaF=max(sum(d,1)+1-size(d,1),0);
        %FrechetHoeffding upperbound M
    case 6;        copulaF=min(d,[],1);
end