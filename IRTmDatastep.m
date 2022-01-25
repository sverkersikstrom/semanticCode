function BASE=IRTmDatastep(SETTINGS);
%Utility function to define the SETTINGS of the data and algorithm
% BASE=IRTmDatastep(SETTINGS) reads and extracts data in more compressed form
% and sets up the optimization algorithm
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%_________________________________________________________________________%
%
%IRTm Toolbox version0.0 2008 | code written by: Johan Braeken |
%Using this file implies that you agree with the license (see License.pdf)| 
%email: j.braeken@uvt.nl|j.braeken@flavus.org
%_________________________________________________________________________%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ischar(SETTINGS.input);
    if isempty(SETTINGS.delim)==1; SETTINGS.delim=' ';end;
    rawdata=dlmread(SETTINGS.input,SETTINGS.delim);
else rawdata=SETTINGS.input; end
if isempty(SETTINGS.Sel); SETTINGS.Sel=1:size(rawdata,1); end;
Y=rawdata(SETTINGS.Sel,SETTINGS.I);Ymu=mean(Y,1);
Z=rawdata(SETTINGS.Sel,SETTINGS.J);Zmu=mean(Z,1);
rawdata = [Y Z]*10.^[0:length(SETTINGS.I)+length(SETTINGS.J)-1]';
[X D INDEX]=unique(rawdata);
for x=1:length(X);
    Freq(x,1)=sum(INDEX==x);
end
Y=Y(D,:); Z=Z(D,:);

%%ALGORITHMIC SETTINGS PART;
%GAUSS-HERMITE POINTS
if isfield(SETTINGS,'qp');
    [GHQp GHQw]=IRTmGHQ(SETTINGS.qp);
    GHQp=repmat(GHQp,[length(SETTINGS.I) 1 length(X)]);
    GHQw=repmat(GHQw,[1 1 length(X)]);
    Y=shiftdim(repmat(Y,[1 1 SETTINGS.qp]),1);
end
BASE=struct('Y',Y(:),'Z',Z,'TH',GHQp(:),'W',GHQw(:)','N',Freq,'index',INDEX,'muY',Ymu,'muZ',Zmu,'lI',length(SETTINGS.I),'lJ',length(SETTINGS.J),'lN',length(SETTINGS.Sel),'lX',length(X),'lQP',SETTINGS.qp);


function [GHQp GHQw]=IRTmGHQ(n);
%[GHQp GHQw]=IRTm_GHQ(n)
%Generate n number of Gauss-Hermite quadrature points GHQp and weights GHQw
x=[]; w=[];
hn=1.0d0./n;
zl=-1.1611d0+1.46d0.*n.^0.5;
for  nr=1:fix(n./2);
    if (nr == 1) z=zl; end;
    if (nr ~= 1) z=z-hn.*(fix(n./2)+1-nr); end;
    it=0;
    while (1);
        it=it+1;
        z0=z;
        f0=1.0d0;
        f1=2.0d0.*z;
        for  k=2:n;
            hf=2.0d0.*z.*f1-2.0d0.*(k-1.0d0).*f0;
            hd=2.0d0.*k.*f1;
            f0=f1;
            f1=hf;
        end;
        p=1.0d0;
        for  i=1:nr-1;
            p=p.*(z-x(i));
        end;
        fd=hf./p;
        q=0.0d0;
        for  i=1:nr-1;
            wp=1.0d0;
            for  j=1:nr-1;
                if (~(j == i)) wp=wp.*(z-x(j)); end;
            end;
            q=q+wp;
        end;
        gd=(hd-q.*fd)./p;
        z=z-fd./gd;
        if (~(it <= 40&abs((z-z0)./z) > 1.0d-15)) break; end;
    end;
    x(nr)=z;
    x(n+1-nr)=-z;
    r=1.0d0;
    for  k=1:n;
        r=2.0d0.*r.*k;
    end;
    w(nr)=3.544907701811d0.*r./(hd.*hd);
    w(n+1-nr)=w(nr);
end;
if (n ~= 2.*fix(n./2)) ;
    r1=1.0d0;
    r2=1.0d0;
    for  j=1:n;
        r1=2.0d0.*r1.*j;
        if (j >= fix((n+1)./2)) r2=r2.*j; end;
    end;
    w(fix(n./2)+1)=0.88622692545276d0.*r1./(r2.*r2);
    x(fix(n./2)+1)=0.0d0;
end;
%OUTPUT
GHQp=x(1:n); GHQw=w(1:n)./sqrt(pi);