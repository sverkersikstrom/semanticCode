function s=updateContext(s,index)
%Update the s-structur according to paramters in s.par, for selected index(
indexBool=zeros(1,length(index));
par=setInfoPar(s.par);
for i=1:length(index)
    if not(isnan(index(i))) & index(i)<=s.N
        try
            if not(isfield(s.info{index(i)},'context')) & length(s.par.variableToCreateSemanticRepresentationFrom)==0
                %elseif isfield(s.info{index(i)},'specialword') & (s.info{index(i)}.specialword==2 | s.info{index(i)}.specialword==3 | s.info{index(i)}.specialword==4 | s.info{index(i)}.specialword==5 |  s.info{index(i)}.specialword==8  | (s.info{index(i)}.specialword==13 & not(s.par.updateNorms)))
            elseif isfield(s.info{index(i)},'specialword') & not(s.info{index(i)}.specialword==9 | (s.info{index(i)}.specialword==13 & s.par.updateNorms))
                %Update texts (9) and norms(13) if s.par.updateNorms=1;
                %D0 not update: functions(2), functions(3), preditions (4), LIWC(5),dimensions (6), scales (7),  wordclasses (8), words(10), stopwords (11), variables (12)
            elseif not(s.fwords{index(i)}(1)=='_')
            elseif  not(isfield(s.info{index(i)},'par')) | not(isfield(s.info{index(i)}.par,'contextVariables')) | not(strcmpi(s.info{index(i)}.par.contextVariables,par.contextVariables))
                indexBool(i)=1;
            end
        catch
            try
                fprintf('Error updating context %s\n',s.fwords{index(i)})
            catch
                fprintf('Error updating context %s - %d\n',num2str(index),i)
            end
        end
    end
end

index=index(find(indexBool));
if length(index)>0
    if length(index)>3
        s.par.fastAdd2Space=1;
        for i=1:length(index)
            s=update(s,index(i));
        end
        s.par.fastAdd2Space=2;
        s=addX2space(s);
    else
        for i=1:length(index)
            s=update(s,index(i));
        end
    end
end

function s=update(s,i)
        %Update the text
if (not(isfield(s.info{i},'.par')) ...
        | not(isfield(s.info{i}.par,'subtractSemanticRepresentation')) ...
        | not(strcmpi(s.par.variableToCreateSemanticRepresentationFrom,s.info{i}.par.variableToCreateSemanticRepresentationFrom))) ...
        | not(strcmpi(s.par.subtractSemanticRepresentation,s.info{i}.par.subtractSemanticRepresentation))
    if isfield(s.info{i},'wordclass')
        s.info{i}=rmfield(s.info{i},'wordclass');
    end
    text=getText(s,i);
    [x N Ntot t index s]=text2space(s,text);
    if length(s.par.subtractSemanticRepresentation)>0
        textSubtract=getText(s,i,s.par.subtractSemanticRepresentation);
        [xSubtract N Ntot t index s]=text2space(s,textSubtract);
        x=x-xSubtract;
    end
    s.info{i}.nwordsfound=N;
    s.info{i}.nwords=Ntot;
    s.info{i}.par=setInfoPar(s.par);
    if s.par.fastAdd2Space>0
        s=addX2space(s,s.fwords{i},x,s.info{i});
    else
        s.x(i,:)=x/sum(x.^2)^.5;
    end
else
    %Update the x-vector
    if not(isfield(s.info{i},'index'))
        s.info{i}.index=text2index(s,getText(s,i));
    end
    indexW1=s.info{i}.index;
    x=zeros(length(indexW1),s.Ndim);
    indexW2=indexW1(find(indexW1>0));
    x(find(indexW1>0),:)=s.x(indexW2,:);
    [x tmp s]=average_vector(s,x,indexW1,[],i);
    
    if s.par.fastAdd2Space>0
        info=s.info{i};
        s=addX2space(s,s.fwords{i},x,info);
    else %Old
        s.x(i,:)=x;
        s.info{i}.par=setInfoPar(s.par);
    end
end


