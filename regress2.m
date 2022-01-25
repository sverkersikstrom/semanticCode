function model=regress2(X,Y,par,w)
if nargin<3
    par.model='';
end
x=[];stats=[];
if strcmpi(par.model,'logistic') %logistic regression
    try
        if min(Y)==0
            Y=Y+1;
        end
        [x dev stats]= mnrfit(X,Y);
        Nunique=length(unique(Y));
        %if 0 & size(x,2)<length(unique(Y)) & length(unique(Y))>2 %length(Y)
        %    fprintf('Correcting for dimension error in logistic function!\n')
        %    x(:,length(Y))=0;
        %end
        1;
    catch
        fprintf('Error during logistic fitting\n')
    end
elseif strcmpi(par.model,'ridge')  %Ridge regression 
    x = ridge(Y,[0*ones(1,length(Y))' X],par.ridgeK);
    stats=[];
elseif strcmpi(par.model,'similarity')  %Semantic similiarity 
    index=find(Y>mean(Y));
    if length(index)==1;
        x=X;
    else
        x = mean(X);
    end
    x=x/sum(x.^2)^.5;
    x=[0 x]';
    stats=[];
elseif strcmpi(par.model,'ensemble')  %Ensemble learning
    if isempty(Y)
        x=[];
    elseif strcmpi(par.trainEnsambleMethod,'bag')
        model.ens = fitensemble(X,Y,par.trainEnsambleMethod,par.trainNumberens,par.trainLearners,'type','regression');
    else
        model.ens = fitensemble(X,Y,par.trainEnsambleMethod,par.trainNumberens,par.trainLearners);
    end
elseif strcmpi(par.model,'lasso')  %Lasso
    %[x stats] = lasso([ones(1,length(Y))' X],Y,'CV',min(10,length(Y)));
    if not(isfield(par,'Lambda'))
        par.Lambda=.005;
    end
    %[x stats] = lasso(X,Y,'CV',min(10,length(Y)),'Lambda',par.Lambda);%'NumLambda',20);
    if isempty(X)
        x=[];fprintf('Missing data\n')
    else
        [x stats] = lasso(X,Y,'Lambda',par.Lambda,'RelTol',1e-6);%'NumLambda',20);
        %else
        %    [x stats] = lasso(X,Y,'CV',min(10,length(Y)),'NumLambda',20);
        %end
        model.x2=x;
        if not(isfield(stats,'IndexMinMSE'))
            stats.IndexMinMSE=1;
        end
        x=x(:,stats.IndexMinMSE);
        x=[stats.Intercept(stats.IndexMinMSE) ; x];
    end
elseif strcmpi(par.model,'LDA')  %LDA
    model.ens = fitcdiscr(X,Y);
elseif strcmpi(par.model,'lscov')  %Weigthed regression
    %w=X(:,size(X,2));
    [x,sew_b,msew] = lscov([ones(1,length(Y))' X],Y,w);
else %Regression is default
    warning off
    if isempty(Y)
        x=[];
    elseif nargout==1
        x = regress(Y,[ones(1,length(Y))' X]);
    else
        [x,BINT,R,RINT,STATS] = regress(Y,[ones(1,length(Y))' X]);
        warning on
        stats.beta=x;
        stats.p=STATS(3);
        stats.residd=R;
    end
    %x=X\Y;
end
model.x=x;
model.model=par.model;
model.stats=stats;

    