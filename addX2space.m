function [s N word]=addX2space(s,word,x,info,normalize,comment,wordclass,keepDate);
if nargin<3
    x=[];
end
if isempty(x)
    x=nan(1,s.Ndim);
end
if nargin<4
    info=[];
end
if nargin<5
    normalize=0;
end
if nargin<6
    comment='';
end
if nargin<7
    wordclass=0;
end
if nargin<8
    keepDate=0;
end
if not(isempty(comment))
    info.comment=comment;
end

if s.par.fastAdd2Space>0 %Optimize adding to space 
    N=NaN;
    if not(isfield(s,'sTemp')) %Create small space...
        if s.par.fastAdd2Space==2
            s.par.fastAdd2Space=0;
            return
        end
        s.sTemp=initSpace;
        s.sTemp.par=s.par;
        s.sTemp.par.fastAdd2Space=0;
        s.sTemp.include=[];
        s.sTemp.languagefile=s.languagefile;
        s.sTemp.filename=s.filename;
        s.sTemp.Ndim=s.Ndim;
    end
    if s.par.fastAdd2Space==2 %End optimizing rutin...
        %s.sTemp=remove_words_now(s.sTemp,s.sTemp.include);
        s=mergeSpace(s,s.sTemp);
        s=rmfield(s,'sTemp');
        s.par.fastAdd2Space=0;
        return
    end
    s.sTemp.par.fastAdd2Space=0;
    [s.sTemp iAdded word]=addX2space(s.sTemp,word,x,info,normalize,comment,wordclass,keepDate);%Add to small space
    s.sTemp.include=[s.sTemp.include iAdded];
    if length(s.sTemp.include)>500 | s.par.fastAdd2Space==2
        s.sTemp=remove_words_now(s.sTemp,s.sTemp.include);
        par=s.par;
        s=mergeSpace(s,s.sTemp);
        s.sTemp=initSpace;
        s.sTemp.par=par;
        if s.par.fastAdd2Space==2
            s.par.fastAdd2Space=0;
        end
        s.sTemp.include=[];
    end
    %N=iAdded;
    return
end


if isnumeric(word)
    N=word;
else
    if not(isfield(info,'normalword') && info.normalword==0)
        prefix=s.par.regression_extension;
        word=fixpropertyname(word,s);
        if length(prefix)>0
            prefix=fixpropertyname(prefix);
            if not(strcmpi(prefix,word(1:min(length(word),length(prefix())))))
                if not(isfield(info,'specialword') && info.specialword==2)
                    word=fixpropertyname([prefix word ]);
                end
            end
        end
    end
             
    N=word2index(s,word);
end            
 
if isnan(N)
    if not(isempty(s.x))
        [tmp s.Ndim]=size(s.x);
    end
    s.N=length(s.fwords);
    N=s.N+1;
    s.hash.put(lower(word),N);
    s.f(N)=NaN;
    s.wordclass(N)=NaN;
    s.N=length(s.f);
    s.fwords{N}=word;
end
s.wordclass(N)=wordclass;


%Store info
info.length=nansum(x.*x)^.5;
s=setInfo(s,N,'lengthx',info.length);

%if normalize
%    info.length=1;
%end
if isfield(info,'specialword') & info.specialword==9
    if strcmpi(s.par.openNormFile,'norm')
        info.specialword=13;
    elseif strcmpi(s.par.openNormFile,'LIWC')
        info.specialword=5;
    end
end

info.par=setInfoPar(s.par);


%Store x
if info.length>0 & s.par.normalizeSpace
    x=x/info.length;
end
if s.Ndim>length(x)
   fprintf('Adding zeros to the stored vector\n')
   if size(x,1)>size(x,2)
       x=[x ; zeros(1,s.Ndim-length(x))'];
   else
       x=[x zeros(1,s.Ndim-length(x))];
   end
elseif s.Ndim>0 & s.Ndim<length(x)
    fprintf('Removing %d dimensions from the stored vector\n',length(x)-s.Ndim)
    x=x(1:s.Ndim);
end
s.x(N,:)=x;
if not(isfield(s.par,'documentId')) 
    s.par.documentId=0;
end
if s.par.documentId>0
    if not(isfield(s.par,'documentNumber')) | length(s.par.documentNumber)<s.par.documentId
        s.par.documentNumber(s.par.documentId)=sparse(1);
        s.par.documentTime(s.par.documentId)=sparse(now);
    else
        s.par.documentNumber(s.par.documentId)=s.par.documentNumber(s.par.documentId)+1;
        s.par.documentTime(s.par.documentId)=now;
    end
end

s.info{N}=info;
if isnan(s.f(N)) & isfield(s.info{N},'frequency') s.f(N)=info.frequency;end
if isfield(info,'specialword')
    if not(keepDate)
        s.info{N}.date=datestr(now);
    end
    [s, info]=saveToSpace(s,s.info{N},{word},N);
end

s.saved=0;


function [s, info]=saveToSpace(s,info,word,N)
if s.par.db2space
    if info.specialword==3 | info.specialword==4 |  info.specialword==7 | info.specialword==13
        categories{3}='Clusters';
        categories{4}='Prediction';
        categories{7}='Semantic scales';
        categories{13}='Norms';
        if not(s.par.excelServer)
            fprintf('Saving category:%s identifier: %s to space\n',categories{info.specialword},word{1});
        end
        %         if 0 %OLD
        %             s=getSfromDB(s,s.languagefile,'',word,{getText(s,N)},'updateAll');%Adds documents referenced with "ref" consiting of text in "text" to the s2-structure, using the langugae in "lang" and we call this document "document"
        %             if length(word)>1 fprintf('This can be optimized'); end
        %             for i=1:length(word)
        %                 id=word{i};
        %                 query =['DELETE FROM `space2`.`' s.languagefile '-Models` WHERE `id` = ''' id ''' '];
        %                 exec(getDb,query,0);
        %
        %                 query=['INSERT INTO `space2`.`' s.languagefile '-Models` (`id`, `datestr`) VALUES (''' id ''', ''' s.info{N}.date ''')'];
        %                 exec(getDb,query,0);
        %                 cashIdDate(id,s.info{N}.date);%Update cash
        %                 getIndexCategory(info.specialword,s,2);%Clear getIndexCategory cash!
        %             end
        %         else
        if info.specialword==3 | info.specialword==4
            s.info{N}.context=['Model version:' num2str(rand)];%This makes the prediction and cluster models to update if changed in getSfromDB
        end
        s.info{N}.version=rand;
        dbSpace(s.languagefile,'','save',s.fwords(N),s.x(N,:),s.info(N));
        %end
    end
end



