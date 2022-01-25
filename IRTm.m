function  OUTPUT=IRTm(SETTINGS,MODEL);
%Main function of the IRTm toolbox
%%Takes the SETTINGS structure, containing the information on the dataset
% and algorithm to be used, and the MODEL structure, containing the 
% specification of the statistical model, as %arguments to return the
% results of the optimized model. The OUTPUT structure will contain summary
% info on the data, main model optimization results and estimates
% Exact details can be found in the added documentation -> see the Appendix
% in the main help document in MATLAB
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%_________________________________________________________________________%
%
%IRTm Toolbox version0.0 2008 | code written by: Johan Braeken | 
%email: j.braeken@uvt.nl|j.braeken@flavus.org
%_________________________________________________________________________%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

tic;
%READ,COMPRESS and FORMAT DATA FOR ANALYSIS
BASE=IRTmDatastep(SETTINGS);
%INITIALIZE AND (CHECK) MODEL;
MODEL = IRTmCheck(MODEL);
%OPTIMIZE MODEL LOG LIKELIHOOD
if (size(MODEL.TM.D,1)<2 && SETTINGS.alg==0);
    %%%%%REGULAR QUASI-NEWTON GAUSS-HERMITE MARGINAL MAXIMUM LIKELIHOOD
    pcPr=1;cNR=1;
    if strcmp(SETTINGS.display,'on');SETTINGS.display='iter'; end
    options=optimset('LargeScale','off','Display',SETTINGS.display,'Diagnostics','off','Hessupdate','bfgs','MaxFunEvals',SETTINGS.func,'MaxIter',SETTINGS.iter);
    if SETTINGS.con==0;
        d=version();dd=strfind(d,'.');d=str2num(d(dd(1:2)-1));
        if (d>=76);options=optimset('Algorithm','active-set','LargeScale','off','Display',SETTINGS.display,'Diagnostics','off','Hessupdate','bfgs','MaxFunEvals',SETTINGS.func,'MaxIter',SETTINGS.iter);end
        [PARAM,LogL,EXITFLAG,OUTPUT,GRAD,HESSIAN]=fminunc('IRTmLL',MODEL.init,options,BASE,MODEL.A,MODEL.AD,MODEL.B,MODEL.BD,MODEL.C,MODEL.LM,MODEL.LS,MODEL.TM,MODEL.TS,MODEL.Copula,pcPr);
    else
        d=version();dd=strfind(d,'.');d=str2num(d(dd(1:2)-1));
        if (d>=76); options=optimset('Algorithm','active-set','Display',SETTINGS.display,'Diagnostics','off','Hessupdate','bfgs','MaxFunEvals',SETTINGS.func,'MaxIter',SETTINGS.iter); end;
        [PARAM,LogL,EXITFLAG,OUTPUT,GRAD,CONSTR,HESSIAN]=fmincon('IRTmLL',MODEL.init,MODEL.lin,MODEL.con,[],[],MODEL.lb,MODEL.ub,[],options,BASE,MODEL.A,MODEL.AD,MODEL.B,MODEL.BD,MODEL.C,MODEL.LM,MODEL.LS,MODEL.TM,MODEL.TS,MODEL.Copula,pcPr);
    end
else   
    %%%%%GENERALIZED EXPECTATION-MAXIMIZATION MARGINAL MAXIMUM LIKELIHOOD
    criterion=0;
    iter=1;
    cNR=size(MODEL.TM.D,1);
    Qhist=[10^10 10^10];
    LLhist=[10^10 0];
    PARAMhist=[MODEL.init zeros(length(MODEL.init),1)];
    options=optimset('LargeScale','off','Display','off','Diagnostics','off','Hessupdate','bfgs','MaxFunEvals',SETTINGS.func,'MaxIter',1);
    MODEL.TW.O(MODEL.TW.R)=MODEL.TW.O(MODEL.TW.R)+MODEL.TW.I;
    cW=MODEL.TW.D*MODEL.TW.O;
    nn=sum(BASE.N);
    nnn=repmat(BASE.N,[1 cNR]);
    if strcmpi(SETTINGS.display,'on');
        info=['maximum iterations = ',num2str(SETTINGS.iter),', stopping criterion = ',num2str(SETTINGS.crit)];
    end
    while(criterion==0);
        %%E-step%%
        cwPr=repmat(cW,[1 BASE.lX]);%format classweights
        mcPr= IRTmLikelihood(PARAMhist(:,1),BASE,MODEL.A,MODEL.AD,MODEL.B,MODEL.BD,MODEL.C,MODEL.LM,MODEL.LS,MODEL.TM,MODEL.TS,MODEL.Copula,cwPr); %marginal class probabilities = classweight * likelihood(param)
        SmcPr = sum(mcPr,2);
        pcPr = mcPr./repmat(SmcPr,[1 cNR]);%posterior class probabilities
        LLhist(:,2) = -sum(log(SmcPr).*BASE.N);
        cW=[sum(pcPr.*nnn)./nn]';%updated classweight = mean posterior class Pr
        %%M-step%%
        %optimize LL = (posterior class Pr x class weight)
        if SETTINGS.con==0;
            [PARAMhist(:,2),Qhist(2),EXITFLAG,OUTPUT,GRAD,HESSIAN]=fminunc('IRTmLL',PARAMhist(:,1),options,BASE,MODEL.A,MODEL.AD,MODEL.B,MODEL.BD,MODEL.C,MODEL.LM,MODEL.LS,MODEL.TM,MODEL.TS,MODEL.Copula,cW);
        else
            [PARAMhist(:,2),Qhist(2),EXITFLAG,OUTPUT,GRAD,CONSTR,HESSIAN]=fmincon('IRTmLL',PARAMhist(:,1),MODEL.lin,MODEL.con,[],[],MODEL.lb,MODEL.ub,[],options,BASE,MODEL.A,MODEL.AD,MODEL.B,MODEL.BD,MODEL.C,MODEL.LM,MODEL.LS,MODEL.TM,MODEL.TS,MODEL.Copula,cW);
        end
        %%criterion-step%%
        mdp = max(abs(PARAMhist(:,1)-PARAMhist(:,2)));
        dl = abs(LLhist(1)-LLhist(2));
        if strcmpi(SETTINGS.display,'on');
            iteration=[iter mdp dl Qhist LLhist]
        end
        
        if (mdp<SETTINGS.crit && dl<=SETTINGS.crit);
            if cNR>1;             PARAM = [PARAMhist(:,2); cW];
            else PARAM = PARAMhist(:,2);  MODEL.init=[MODEL.init;MODEL.TW.I];              end
            LogL=LLhist(:,2);
            criterion=1;
            OUTPUT.iterations=iter;
            OUTPUT.optim=1;
            OUTPUT.message='Optimization terminated: difference in LL/parameter values lower than SETTINGS.crit.';
        elseif iter==SETTINGS.iter;
            criterion=1;
            if cNR>1;             PARAM = [PARAMhist(:,2); cW];
            else PARAM = PARAMhist(:,2);  MODEL.init=[MODEL.init;MODEL.TW.I];              end
            LogL=LLhist(:,2);
            OUTPUT.iterations=iter;
            OUTPUT.optim=0;
            OUTPUT.message='Optimization terminated: number of iterations equal SETTINGS.iter.';
        end
        PARAMhist(:,1)=PARAMhist(:,2);
        Qhist(:,1)=Qhist(:,2);
        LLhist(:,1)=LLhist(:,2);
        iter=iter+1;%UPDATE
    end
    OUTPUT.algorithm='medium-scale: Generalized EM with Quasi-Newton line search iteration';
end
%GATHER MODEL OPTIMIZATION OUTPUT;
OUTPUT.init=MODEL.init;
OUTPUT.param=PARAM;
OUTPUT.LL=LogL;
if cNR==1; OUTPUT.optim=EXITFLAG; end
OUTPUT.HES=HESSIAN;
OUTPUT.HEScheck='Hessian check: ok';
if(~isempty(OUTPUT.HES));
ew=eig(OUTPUT.HES);
if(min(ew)<=0||max(ew)==inf);
    OUTPUT.HEScheck='Hessian check: not positive definite!';
end;
OUTPUT.paramSE=real(sqrt(diag(inv(OUTPUT.HES))));
else
    OUTPUT.paramSE=[];
end

if SETTINGS.con == 1;
    if(isfield(OUTPUT, 'lssteplength')); OUTPUT = rmfield(OUTPUT, 'lssteplength'); end
    if(isfield(OUTPUT, 'constrviolation'));OUTPUT = rmfield(OUTPUT, 'constrviolation'); end
end
subt=0;
if cNR>1;
    tp = pcPr(:,1)./cW(1)-pcPr(:,cNR)./cW(cNR);
    for ii=2:cNR-1;
        tp = [tp pcPr(:,ii)./cW(ii)-pcPr(:,cNR)./cW(cNR)];
    end
    se=sqrt(diag(inv(tp'*tp)));
    OUTPUT.paramSE=[OUTPUT.paramSE;se;0];
    subt=cNR-sum(MODEL.TW.R)+1;
end

%EMPIRICAL BAYES ESTIMATION FOR THETA
OUTPUT = IRTmEBE(PARAM,BASE,OUTPUT,MODEL.A,MODEL.AD,MODEL.B,MODEL.BD,MODEL.C,MODEL.LM,MODEL.LS,MODEL.TM,MODEL.TS,MODEL.Copula,pcPr');
%GATHER OTHER OUTPUT
OUTPUT.AIC=2*(OUTPUT.LL+length(OUTPUT.param)-subt);
OUTPUT.BIC=2*OUTPUT.LL+log(BASE.lN)*(length(OUTPUT.param)-subt);
if length(OUTPUT.param)>0; OUTPUT.p=1-chi2cdf((OUTPUT.param./OUTPUT.paramSE).^2,1); else OUTPUT.p=[]; end
OUTPUT.param=OUTPUT.param+MODEL.offset;
BASE.Y=reshape(BASE.Y,[BASE.lI BASE.lQP BASE.lX ]);OUTPUT.Y=squeeze(BASE.Y(:,1,:))';
OUTPUT.Freq=BASE.N;
OUTPUT.Index=BASE.index;
OUTPUT.muY=BASE.muY;
OUTPUT.muZ=BASE.muZ;
OUTPUT.lI=BASE.lI;
OUTPUT.lJ=BASE.lJ;
OUTPUT.lN=BASE.lN;
OUTPUT.lX=BASE.lX;
OUTPUT.Z=BASE.Z;
OUTPUT.S=sum(OUTPUT.Y,2);
OUTPUT.lP=length(OUTPUT.param)-subt;
OUTPUT = rmfield(OUTPUT, 'firstorderopt');
OUTPUT.time=toc;
OUTPUT=orderfields(OUTPUT);