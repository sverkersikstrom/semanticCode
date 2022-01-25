function Yout=covariates(s,Y,covwords,index,covariate);
if nargin<5
    covariate=[];
end
Yout=Y;
if ischar(covwords) 
    covwords=string2cell(covwords);
end
if length(covwords)>0 | not(isempty(covariate))

    if isempty(covariate)
        covariate=ones(length(index),1);
        for k=1:length(covwords)
            fprintf('Covariate: %s ',covwords{k});
            covariate(:,k+1)=getProperty(s,covwords{k},index);
        end
        fprintf('\n');
    else
        N=size(covariate);
        if N(1)<N(2)
            covariate=covariate';
        end
        covariate=[ones(length(covariate),1)  covariate];
    end
    N=size(Y);
    if N(1)<N(2)
        Y=Y';
    end
    
    notIsNaN=not(isnan(mean(covariate')'+Y));
    if length(find(notIsNaN))<length(Y)
        fprintf('Warning %d missing data on covariates\n',length(Y)-length(find(notIsNaN)))
    end
    xY=covariate(notIsNaN,:)\Y(notIsNaN);
    xY(1)=0;
        
    Yout(notIsNaN)=Y(notIsNaN)-covariate(notIsNaN,:)*xY;%New version
end
