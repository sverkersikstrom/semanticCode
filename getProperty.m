function [r, resultStringNum,s]=getProperty(s,word1,word2,associationType,par1,par2)
%Calculates the relationsship between word1 and word2 where the data types
%of the words can be found in the getIndexCategory function
%function [id, categories, index,user,comments]=getIndexCategory(category,s,db2space);
%Numerical output is given in r, and string output in resultString with the
%with number of rows=size(word1) and number of columns=size(word2)

%Changes string input to index
if ischar(word1)
    w=word1;clear word1;word1{1}=w;
end

if ischar(word2)
    [index t]=text2index(s,word2);
    if length(index)>1
        word2=index;
    else
        w=word2;
        clear word2;word2{1}=w;
    end
end

if size(word2,1)>size(word2,2); word2=word2';end

index1=word2index(s,word1);
if isnumeric(word1)
    index1nan=find(isnan(index1) & not(isnan(word1)));
    clear word1;word1{length(index1)}='';
    for i=1:length(index1)
        if isnan(index1(i))
            word1{i}='';
        else
            word1{i}=s.fwords{index1(i)};
        end
    end
else
    index1nan=find(isnan(index1));
end
for i=1:length(index1nan) %Make a temporal identifier for first identifier
    %if length(word1{index1nan(i)})>0 & word1{index1nan(i)}(1)=='_'
    %Do not make a new identifier when texts start with _ !
    %else
    [s index1(index1nan(i)) word1{index1nan(i)}]=addText2space(s,word1{index1nan(i)},['_tempa' num2str(i)],[],'text');
    %end
end

index2=word2index(s,word2);
if isnumeric(word2) %Make a temporal identifier for second argument
    index2nan=find(isnan(index2) & not(isnan(index2)));
    word2=index2word(s,index2,0);
else
    index2nan=find(isnan(index2));
end
if length(index2nan)>0
    s.par.fastAdd2Space=1;
    for i=1:length(index2nan)
        [s index2(index2nan(i)) word2{index2nan(i)}]=addText2space(s,word2{index2nan(i)},['_temp' num2str(i)]);
    end
    s.par.fastAdd2Space=2;
    [s]=addX2space(s);
    index2(index2nan)=word2index(s, word2(index2nan));
end

if size(index2,2)==1; index2=index2';end
if s.par.freezeSecondsParameterGetProperty
    s=updateContext(s,index1);
    par=s.par;
    s.par=s.par2;
    s=updateContext(s,index2);
    s.par=par;
else
    s=updateContext(s,[index1 index2]);
end

if nargin<4;associationType=[];end
if nargin<5;par1=s.par;end
if nargin<6;par2=s.par;end

r=NaN(length(index1),length(index2));
for i=1:length(index1)
    [rTmp, resultStringNum(i,:),s]=getProperty2(s,index1(i),index2,associationType,par1,par2);
    if i==1 & size(rTmp,1)>1
        r=rTmp;
    else
        r(i,:)=rTmp;
    end
end

function [r, resultStringNum,s]=getProperty2(s,index1,index2,associationType,par1,par2);
global ij;

resultString{1}=[];
r=NaN(1,length(index2));
resultStringNum(1:length(index2))={''};

if length(index1)>1
    fprintf('ERROR: The first argument must have a length of 1, exiting!\n')
    return
end

if isnan(index1) | isnan(index2)
    return
end

resultStringNum{length(index2)}='';
r(1:length(index2))=NaN;


%This uses a non-default type of associations
if nargin>3 & not(isempty(associationType))
    if isnan(index1) | isnan(index1); r=NaN; return; end
    ver= find(strcmpi(associationType,{'_semantictest','_keywords','_correlation'}));
    if ver==1 | ver==2 | ver==3
        if not(isnan(getInfo(s,index1,'worddef'))) && not(isnan(getInfo(s,index2,'worddef')))
            [o1 s]=getWord(s,'',getInfo(s,index1,'worddef'));
            [o2 s]=getWord(s,'',getInfo(s,index2,'worddef'));
            if ver==1
                [out, s]=semanticTest(s,o1,o2);
                r(1)=out.p;
            elseif ver==2
                [out s]=keywordsTest(s,o1,o2);
                resultString{1}=out.keywords1;
            elseif ver==3
                if nargin>4
                    index1=find(strcmpi(s.fwords,par1));
                    if nargin>5 & length(par2)>0
                        index2=find(strcmpi(s.fwords,par2));
                    else
                        index2=index1;
                    end
                    out=semanticTestProperty(s,o1,o2,index1,index2);
                    r=out.p;
                    resultString{1}=out.results;
                else
                    resultString{1}='Error: Missing comparision property(ies) (arg4 [arg5]).';
                end
            end
            textOUt=resultString{1};
            return
        else
            resultString{1}='Error: Both associations needs to have multiple words asssociated. Suggestion use Add word.';
            textOUt=resultString{1};
            r=NaN;return
        end
    end
end

resultString{length(index2)}=[];
if index1>0 & isfield(s.info{index1},'specialword')
    specialword1=s.info{index1}.specialword;
else
    specialword1=0;
end
skipj=0;

%Set values for getPropertyShow
if strcmpi(s.par.getPropertyShow,'default')
    getPropertyShowV='';
else
    getPropertyShowV=s.par.getPropertyShow;
end
%These getPropertyShow parameters are used in
%getPropertyModel, and should not call
%getPropertShow
%choice={'noliwc','semanticSimilarity','predTextVariables','predNumericalVariables','pred2percentage','pred2percentageNorm','pred2z','pred2zNorm','pred2zStored','data2p','data2z'};

try
    isstring2=isstring(s.par.getPropertyShow);
catch
    %fprintf('THIS ERROR LIKELY OCCURS IN AN EARLIER VERSION THAN 2019 MATLAB\n')
    %This is an ugly workaround
    if length(s.par.getPropertyShow)==0
        isstring2
    else
        try
            s.par.getPropertyShow{1};
            isstring2=1;
        catch
            isstring2=0;
        end
    end
end 

x1=[];
for j=1:length(index2)
    if iscell(s.par.getPropertyShow) | isstring2
        getPropertyShowV=s.par.getPropertyShow{j};
    end
    
    try
        
        %Set specialword2
        if index2(j)>0 & isfield(s.info{index2(j)},'specialword')
            specialword2=s.info{index2(j)}.specialword;
        else
            specialword2=0;
        end
        
        if (specialword1==5 | specialword2==5) & length(s.par.getPropertyShow)==0
            getPropertyShowV='liwc';
        end
        
        if strcmp2(s,index1,index2(j),'_randomword')%s.P.Vrandomword,
            %Pick random word...
            random=round(rand*s.N+.5);
            while strcmpi(s.fwords{random}(1),'_');random=round(rand*s.N+.5);end
            if ij==index1
                index2(j)=random;
            else
                index1=random;
            end
        end
        
        if  skipj>=j | not(isnan(r(j))) | not(isempty(resultString{j})) |isnan(index2(j)) | index2(j)>s.N
            1;%skip for speed
        elseif specialword1==2 | specialword2==2
            %Get functions (specialword==2)
            if strcmp2(s,index1,index2(j),'_text2words')
                [~, resultString]=text2index(s,getText(s,index2(1)));
                if length(resultString)<length(index2) resultString{length(index2)}='';end
                skipj=length(index2)+1;
            elseif strcmp2(s,index1,index2(j),'_text2sentences')
                resultString=split2sentence(getText(s,index2(1)));
                if length(resultString)<length(index2) resultString{length(index2)}='';end
                skipj=length(index2)+1;
            elseif strcmp2(s,index1,index2(j),'_concatenate')
                resultString{1}=getText(s,index2);
                if length(resultString)<length(index2) resultString{length(index2)}='';end
                skipj=length(index2)+1;
            elseif strcmp2(s,index1,index2(j),'_sort')
                textTmp=getText(s,index2);
                [~,indexTmp]=sort(textTmp);
                resultString=textTmp(indexTmp);
            else
                [r(j), resultString(j),s]=getPropertyFunction(s,index1,index2(j));
            end
        elseif isfield(s.info{index1},'model') %Trained model
            [r, resultString,skipj]=getPropertyModel(s,index1,index2,r,resultString);
        elseif isfield(s.info{index2(j)},'model') %Trained model
            [r(j), resultString{j},skipj(j)]=getPropertyModel(s,index2(j),index1,r(j),resultString{j});
        elseif specialword1==8 | specialword2==8
            %Get wordclasses (specialword==8)
            try %Wordclassse properties...
                for k=1:length(s.classlabel)
                    if strcmp2(s,index1,index2(j),[fixpropertyname(s.classlabel{k}) 'probability']) | strcmp2(s,index1,index2(j),[fixpropertyname(s.classlabel{k})])
                        [info s]=getWordClassCash(s,ij);
                        tmp=find(info.wordclass==k);
                        if strcmp2(s,index1,index2(j),fixpropertyname(s.classlabel{k}))
                            if isfield(info,'index')
                                resultString{j}=cell2string(s.fwords(info.index(find(info.wordclass==k))));
                            else
                                resultString{j}=cell2string(s.fwords(ij(find(info.wordclass==k))));
                            end
                        else
                            r(j)=length(tmp)/length(info.wordclass);
                        end
                    end
                end
            end
            
        elseif length(getPropertyShowV)>0 & isempty(find(strcmpi(getPropertyShowV,'noliwc')))
            %getPropertyShow...
            [r resultString]=getProperyShow(s,index1,index2,getPropertyShowV,r,resultString,j);
        elseif isfield(s.info{index1},'specialword') & s.info{index1}.specialword==3  & isfield(s.info{index1},'cluster')
            %Cluster category!
            [similiarty index]=semanticSearch(s.x(index2,:),s.x(word2index(s,s.info{index1}.cluster),:));
            r=index(1,:);  
        elseif specialword1==12 | specialword2==12 % specialword1==3 | specialword1==2 
            if specialword1==12
                res=getInfo(s,index2(j),index1(1));
            else %if specialword2==12;  (specialword2==3 || specialword2==2)
                res=getInfo(s,index1(1),index2(j));
            end
            if iscell(res) %res includes text
                x =text2space(s,res);
                r(j)=sum(s.x(index2(j),:).*x);
                [r(j),resultString{j}]=setR(r(j),resultString{j},res{1});
            else
                [r(j),resultString{j}]=setR(r(j),resultString{j},res);
            end            
        else
            [c l]=getCL(s,index1,index2(j));
            if size(s.x,2)>0
                if isempty(x1);
                    [d,s]=getX(s,[index1 index2]);
                    if isempty(d.x) 
                        d.x=nan(length([index1 index2]),1);
                    end
                    x1=d.x(1,:);x2=d.x(2:size(d.x,1),:);
                end
                r(j)=sum(x2(j,:).*x1)*l+c;
                %r(j)=sum(s.x(index2(j),:).*s.x(index1,:))*l+c;
            end
        end
        
        
        
        
        if not(isempty(resultString{j}))
            if s.par.multinomialCategory
                tmp=str2double(resultString{j});
                if not(isnan((tmp)))
                    [tmp r(j)]=max(tmp);
                    resultString{j}='';
                end
            end
            try
                resultString{j}=regexprep(resultString{j},char(13),' ');
                resultString{j}=regexprep(resultString{j},char(10),' ');
            end
        end
        
        if nargout<=1
        elseif isnan(r(j))
            resultStringNum{j}=resultString{j};
        else
            resultStringNum{j}=num2str(r(j));
        end
    catch err
        resultString{j}=['Error in getProperty:' lasterr getReport(err) ];resultStringNum{j}=resultString{j};
        fprintf('%s\n',resultString{j})
        1;
    end
end

function [c l]=getCL(s,index1,index2);
c=0;l=1;
if isfield(s.info{index1},'c') 
    c=s.info{index1}.c; 
    if isfield(s.info{index1},'length') l=s.info{index1}.length; end
end
if isfield(s.info{index1},'l') l=s.info{index1}.l; end
%if isfield(s.info{index1},'length') l=s.info{index1}.length; else l=1; end
if isfield(s.info{index2},'c') c=s.info{index2}.c+c; end
if isfield(s.info{index2},'l') l=l*s.info{index2}.l; end
%if isfield(s.info{index2},'length') l=l*s.info{index2}.length; end


function [r,resultString]=setR(r,resultString,res);
if not(isnan(res))
    if ischar(res)
        if not(isnan(str2double(res)))
            r=str2double(res);
        else
            resultString=res;
        end
    else
        try
            r=res;
        catch
            r=NaN;
        end
    end
else
    r=NaN;
end


function [r, resultString,s]=getPropertyFunction(s,index1,index2);
global ij;
global figureNote;

if not(isfield(s,'P')) | not(isfield(s.P,'Vgetcategoryid')) %| not(strcmpi(s.languagefile,s.P.languagefile))
    s.P.languagefile=s.languagefile;
    s.P.V=NaN;
    s.P.Vadj=NaN;% 120012
    s.P.Vadjprobability=NaN;% 120025
    s.P.Vadp=NaN;% 120007
    s.P.Vadpprobability=NaN;% 120019
    s.P.Vadv=NaN;% 120006
    s.P.Vadvprobability=NaN;% 120018
    s.P.Vassociates=NaN;% 120108
    s.P.Vbigram=NaN;% 120148
    s.P.Vcategory=NaN;% 120167
    s.P.Vchange=NaN;% 120161
    s.P.Vclusterdistance=NaN;% 120029
    s.P.Vcoherence=NaN;% 120150
    s.P.Vcomment=NaN;% 120112
    s.P.Vconj=NaN;% 120010
    s.P.Vconjprobability=NaN;% 120022
    s.P.Vcontext=NaN;% 120107
    s.P.Vdate=NaN;% 120164
    s.P.Vdet=NaN;% 120009
    s.P.Vdetprobability=NaN;% 120021
    s.P.Vfrequency=NaN;% 120145
    s.P.Vfrequencyweightedmean=NaN;% 120694
    s.P.Vfurthestassociates=NaN;% 120109
    s.P.Videntifier=NaN;% 120111
    s.P.Vlanguage=NaN;% 120114
    s.P.Vlistproperty=NaN;% 120115
    s.P.Vlistpropertydata=NaN;% 120116
    s.P.Vlogfrequency=NaN;% 120146
    s.P.Vn=NaN;% 120155
    s.P.Vnan=NaN;% 120166
    %s.P.Vnday=NaN;% 120157
    s.P.Vneighbour=NaN;% 120696
    %s.P.Vnmonth=NaN;% 120156
    s.P.Vnoun=NaN;% 120013
    s.P.Vnounprobability=NaN;% 120026
    s.P.Vnumprobability=NaN;% 120024
    s.P.Vnwords=NaN;% 120143
    s.P.Vnwordsfound=NaN;% 120144
    s.P.Vp=NaN;% 120153
    %s.P.Vprevious=NaN;% 120165
    s.P.Vprintidentifiers=NaN;% 120680
    s.P.Vprobability=NaN;% 120016
    s.P.Vpron=NaN;% 120008
    s.P.Vpronprobability=NaN;% 120020
    s.P.Vprt=NaN;% 120011
    s.P.Vprtprobability=NaN;% 120023
    s.P.Vr=NaN;% 120154
    s.P.Vrand=NaN;% 120160
    s.P.Vrandomvector=NaN;% 120159
    s.P.Vrandomword=NaN;% 120158
    s.P.Vresults=NaN;% 120001
    s.P.Vsentencelength=NaN;% 120113
    s.P.Vseqdist=NaN;% 120162
    s.P.Vspace=NaN;% 120142
    s.P.Vspacelabel=NaN;% 120695
    s.P.Vtext=NaN;% 120106
    s.P.Vtextbyword=NaN;% 120697
    s.P.Vtime=NaN;% 120163
    s.P.Vtranslate=NaN;% 120163
    s.P.Vtypetokenratio=NaN;% 120149
    s.P.Vunknown=NaN;% 120003
    s.P.Vunknownprobability=NaN;% 120015
    s.P.Vvarcoherence=NaN;% 120151
    s.P.Vvariability=NaN;% 120152
    s.P.Vvariabilitypairwise=NaN;% 120028
    s.P.Vweight=NaN;% 120002
    s.P.Vword=NaN;% 120110
    s.P.Vwordclass=NaN;% 120117
    s.P.Vwordlength=NaN;% 120147
    s.P.Vx=NaN;% 120014
    s.P.Vxprobability=NaN;% 120027
    s.P.Vspaceinfo=NaN;% 120027
    s.P.Vwildcardexpansion=NaN;
    s.P.Vliwcall=NaN;
    s.P.VfigureNote=NaN;
    s.P.Vgetcategoryid=NaN; 
    [~,~, tmpI]=getIndexCategory(2,s,0);
    tmpW=index2word(s,tmpI,0);
    if length(tmpW)>1
        for i=1:length(tmpW)
            eval(['s.P.' regexprep(tmpW{i},'_','V') '=' num2str(tmpI(i)) ';']);
        end
    end
end

j=1;
r=NaN;resultString{j}=[];

if strcmp2(s,index1,index2(j),'_semanticsimilarity')
    %Semantic distances..
    if length(s.par.variableToCompareSemanticSimliarity)>0
        text2=getText(s,ij,s.par.variableToCompareSemanticSimliarity);
        if length(text2)==0
            resultString{j}=sprintf('Error: The property %s is empty in %s',s.par.variableToCompareSemanticSimliarity,s.fwords{ij});
        else
            [x N Ntot t index s]=text2space(s,text2);
            [c l]=getCL(s,index1,index2(j));
            r(j)=sum(s.x(ij,:).*x)*l+c;
        end
    else
        resultString{j}='Error: the Property variableToCompareSemanticSimliarity is empty';
    end
elseif strcmp2(s,index1,index2(j),s.P.Vgetcategoryid,'_getcategoryid')
    [~, categories]=getIndexCategory;
    c=find(strcmpi(getText(s,ij),categories));
    if not(isempty(c)) getcategoryid=categories{c}; else getcategoryid=s.par.getcategoryid;end
    [~,~,indexTmp]=getIndexCategory(getcategoryid,s,s.par.excelServer);
    resultString{j}=cell2string(s.fwords(indexTmp));
elseif strcmp2(s,index1,index2(j),s.P.Vnwordsfound,'_comment')
    r(j)=getInfo(s,ij,'nwordsfound');
    if isnan(r(j)) r(j)=1;end   
    %tmp=text2index(s,getText(s,index2(j)));
    %r(j)=sum(s.f(tmp(not(isnan(tmp))))>6.6493e-06);
elseif strcmp2(s,index1,index2(j),s.P.Vliwcall,'_liwcall')
    %Get predefined properties LIWC scores!
    if strcmpi(s.par.getPropertyShow,'noliwc')
        [~,categories,indexC]=getIndexCategory(5,s);
        rTmp=sum((s.x(indexC,:).*repmat(s.x(index2(j),:),length(indexC),1))');
        resultString{j}=num2str(full(rTmp),'%.4f ');
    else
        [x,labels,N]=getLIWC(s,ij);
        if sum(abs(x))==0 | isnan(sum(abs(x)))
            resultString{j}=cell2string(labels);
            try;resultString{j}=resultString{j}(2:end);end %Remove leading space
        else
            resultString{j}=num2str(full(x'),'%.4f ');
        end
    end  
elseif strcmp2(s,index1,index2(j),s.P.Vtranslate,'_translate')
    resultString{j}=gtranslate(s,getText(s,ij),s.par.translateTolanguage,s.par.translateFromlanguage,[],s.par.translateWordByWord);
elseif strcmp2(s,index1,index2(j),s.P.Vnwords,'_comment')
    r(j)=getInfo(s,ij,'nwords');
    if isnan(r(j)) r(j)=1;end
elseif strcmp2(s,index1,index2(j),s.P.Vcomment,'_comment')
    if isfield(s.info{ij},'comment')
        resultString{j}=s.info{ij}.comment;
    else
        [tmp, categories]=getIndexCategory;
        if isfield(s.info{ij},'specialword')
            specialword=s.info{ij}.specialword;
        else
            specialword=10;
        end
        resultString{j}=['This identifier belongs to the category: ' categories{specialword}];
    end
elseif strcmp2(s,index1,index2(j),s.P.Vrandomvector,'_randomvector')
    random=rand(1,s.Ndim);random=random/sum(random.^2)^.5;
    r(j)=sum(s.x(ij,:).*random);
elseif strcmp2(s,index1,index2(j),s.P.Vprintidentifiers,'_printidentifiers')
    if isfield(s.info{ij},'context')
        text=s.info{ij}.context;
    else
        text=s.fwords{ij};
    end
    if length(text)>25 %Remove * for longer texts.... May cause unpredicatable results...
        text=regexprep(text,'*',' ');
    end
    [tmp s]=getWord(s,text);
    resultString{j}=cell2string(tmp.word);
elseif strcmp2(s,index1,index2(j),'_dictionary')%???
    if j==1 | strcmpi(index2word(s,index2(j)),'_dictionary')
        if strcmpi(index2word(s,index2(j)),'_dictionary')
            [s, f1]=mkfreq(s,ij,[]);
        else
            [s, f1 ]=mkfreq(s,index2,[]);
        end
        [~,indexSort]=sort(f1,'descend');
        i=1;
        while f1(indexSort(i))>0
            resultString{j}=[resultString{j} sprintf('%s\t%d \n',s.fwords{indexSort(i)},f1(indexSort(i)))];
            i=i+1;
        end
    end
elseif strcmp2(s,index1,index2(j),s.P.Vrand,'_rand')
    r(j)=rand;
elseif strcmp2(s,index1,index2(j),s.P.VfigureNote,'_figurenote')
    resultString{j}=figureNote;
elseif strcmp2(s,index1,index2(j),s.P.Vfrequency,'_frequency')
    r(j)=nanmean(s.f(getContextIndex(s,ij)));
elseif strcmp2(s,index1,index2(j),s.P.Vwildcardexpansion,'_wildcardexpansion')
    [indexWord t s]=text2index(s,getText(s,index2(j)));
    tmp=getWildcardExpansion(s,t);
    resultString{j}=cell2string(tmp);
elseif strcmp2(s,index1,index2(j),s.P.Vfrequencyweightedmean,'_frequencyweightedmean') & 0
    [v,~,s]=getProperty(s,s.fwords{ij},find(s.f>0));
    f=full(s.f(s.f>0));
    r(j)=nansum(v.*f)/sum(f);
elseif strcmp2(s,index1,index2(j),s.P.Vword,'_word') | strcmp2(s,index1,index2(j),s.P.Videntifier,'_identifier')
    resultString{j}=s.fwords{ij};
elseif strcmp2(s,index1,index2(j),s.P.Vbigram,'_bigram')
    indexOk=getContextIndex(s,ij);
    tmp=NaN(1,length(indexOk));
    for k=1:length(indexOk)
        if isfield(s.info{indexOk(k)},'bigram')
            tmp(k)=s.info{indexOk(k)}.bigram;
        end
    end
    r(j)=nanmean(tmp);
elseif strcmp2(s,index1,index2(j),s.P.Vtypetokenratio,'_typetokenratio')
    [~, w]=text2index(s,getText(s,ij));
    r(j)=length(unique(w))/length(w);
elseif strcmp2(s,index1,index2(j),s.P.Vlogfrequency,'_logfrequency')
    r(j)=mean(log(s.f(getContextIndex(s,ij))));
elseif strcmp2(s,index1,index2(j),s.P.Vwordlength,'_wordlength')
    [~, w]=text2index(s,getText(s,ij));
    wl=NaN(1,length(w));
    for k=1:length(w)
        wl(k)=length(w{k});
    end
    r(j)=mean(wl);
elseif strcmp2(s,index1,index2(j),s.P.Vsentencelength,'_sentencelength')
    try
        sentences=split2sentence(getText(s,ij));
        for i=1:length(sentences)
            tmp=string2cell(sentences{i});
            nwords(i)=length(tmp);
        end
        r(j)=mean(nwords);
    catch
        r(j)=NaN;
    end
elseif strcmp2(s,index1,index2(j),s.P.Vtextbyword,'_textbyword')
    if not(isfield(s.info{ij},'index'))
        resultString{j}=[' ' s.fwords{ij} ' '];
    else
        tmpIndex=s.info{ij}.index>0;
        tmpWord(tmpIndex)=s.fwords(s.info{ij}.index(tmpIndex));
        if isfield(s.info{ij},'wordsMissing')
            tmpWord(not(tmpIndex))=s.info{ij}.wordsMissing;
        end
        resultString{j}=cell2string(tmpWord);
    end
elseif strcmp2(s,index1,index2(j),s.P.Vcontext,'_context') | strcmp2(s,index1,index2(j),s.P.Vtext,'_text')
    resultString{j}=getText(s,ij);
    r(j)=NaN;
elseif strcmp2(s,index1,index2(j),s.P.Vseqdist,'_seqdist')
    ok=1;k=0;clear d;ij2=ij;mark='c';d=[];
    while ok && not(isempty(findstr(s.fwords{ij2},[mark '1']))) %k<4
        k=k+1;
        w1=regexprep(s.fwords{ij2},[mark '1'],[mark num2str(k)]);
        w2=regexprep(s.fwords{ij2},[mark '1'],[mark num2str(k+1)]);
        [d(k),~,s]=getProperty(s,w1,w2);
        ok=not(isnan(d(k)));
    end
    r(j)=nanmean(d);
elseif strcmp2(s,index1,index2(j),s.P.Vclusterdistance,'_clusterdistance')
    r(j)=NaN;
    [tmp, texts,s]=getProperty(s,ij,s.P.Vcontext,'_context');
    if length(texts{1})>0
        [x_notused N_notused Ntot_notused t dindex]=text2space(s,texts{1});
        dindex=dindex(find(dindex>0));
        Ninclude=6;
        if length(dindex)>=Ninclude
            dindex=dindex(1:Ninclude);
            try
                [IDX, C, SUMD, D] = kmeans(s.x(dindex(1:Ninclude)), 2);
                for i=1:length(dindex)
                    Dmin(i)=D(i,IDX(i));
                end
                r(j)=mean(Dmin);
            end
        end
    end
elseif strcmp2(s,index1,index2(j),s.P.Vvariability,'_variability') | strcmp2(s,index1,index2(j),s.P.Vvariabilitypairwise,'_variabilitypairwise')
    texts=getText(s,ij);
    if length(texts)>0
        [x_notused N_notused Ntot_notused t dindex]=text2space(s,texts);
        dindex=dindex(find(dindex>0));
        if strcmp2(s,index1,index2(j),'_variability') %New - Fast, possible length artifacts
            x=average_vector(s,s.x(dindex,:));
            d=NaN(1,length(dindex));
            for k=1:length(dindex)
                d(k)=sum(s.x(dindex(k),:).*x);
            end
            r(j)=mean(d);
        else %Old - _variabilitypairwise, pairwise comparisions. No artifact of length!
            maxN=s.par.variablityN;
            if length(dindex)>maxN & 1
                dindex=dindex(1:maxN);
                quick=1;
            else
                quick=0;
            end
            k=0;d=[];
            for k1=1:length(dindex);
                tmp=sum(shiftdim(repmat(s.x(dindex(k1),:),length(dindex),1).*s.x(dindex,:),1));
                d(k1)=mean(tmp(tmp<.999999999));%Remove identicals
            end
            r(j)=nanmean(d);
            if quick
                resultString{j}=[num2str(d) ' Calculations have been limited to the ' num2str(maxN) ' first words, due to speed limits _variabilitypairwise due to speed limits, N2=' num2str(length(dindex)^2)];
            end
        end
    else
        r(j)=NaN;
    end
elseif strcmp2(s,index1,index2(j),s.P.Vspacelabel,'_spacelabel')
    d=getX(s,ij);
    resultString{j}=struct2string(d.label);
elseif strcmp2(s,index1,index2(j),s.P.Vspaceinfo,'_spaceinfo')
    try
        try;corpus='';corpus=s.meta.d.corpus;end
        try;createDate='';createDate=s.meta.d.date;end
        try;NSVD='';NSVD=s.meta.d.NSVD;end
        try;Ncol='';Ncol=s.meta.d.Ncol;end
        try;minf=NaN;minf=s.minf/min(s.f(s.f>0));end
        if not(isfield(s,'quality')) s.quality=NaN;end
        resultString{j}=sprintf('Number of dimensions: %d, Name: %s,\tQuality=%.4f, Based on N words=%d\t,corpus=%s,\t,createDate=%s,\tNSVD=%d,\tNcol=%d',s.Ndim,s.languagefile,s.quality,minf,corpus,createDate,NSVD,Ncol);
    end
elseif strcmp2(s,index1,index2(j),s.P.Vspace,'_space')
    tmp=getX(s,ij);
    resultString{j}=num2str(tmp.x);
elseif strcmp2(s,index1,index2(j),s.P.Vcoherence,'_coherence') | strcmp2(s,index1,index2(j),s.P.Vvarcoherence,'_varcoherence')
    try
        %dindex=s.info{ij}.index;
        [~,dindex]=getText(s,ij);
        dindex(find(dindex<=0))=word2index(s,'_nan');
        dindex=dindex(not(isnan(dindex)));
        dsum=NaN;
        dlength=s.par.coherenceN;
        Ndim=s.par.forceMaxDim;
        if isempty(Ndim) | Ndim==0; Ndim=s.Ndim;end
        identical=0;
        sameFirstChar=NaN(1,length(dindex));
        sameSecondChar=sameFirstChar;
        for k=1:length(dindex)-(2*dlength-1);
            if dlength<=1
                x1=s.x(dindex(k:k+dlength-1),1:Ndim);
                x2=s.x(dindex(k+dlength:k+dlength*2-1),1:Ndim);
            elseif 1
                x1=average_vector(s,s.x(dindex(k:k+dlength-1),1:Ndim));
                x2=average_vector(s,s.x(dindex(k+dlength:k+dlength*2-1),1:Ndim));
            else
                x1=average_vector(s,s.x(dindex(k:k+dlength-1),:));
                x2=average_vector(s,s.x(dindex(k+dlength:k+dlength*2-1),:));
                x1=x1(1:Ndim)/sum(x1(1:Ndim).^2)^.5;
                x2=x2(1:Ndim)/sum(x2(1:Ndim).^2)^.5;
            end
            dsum(k)=sum(x1(1:Ndim).*x2(1:Ndim));
            if k<length(dindex)
                sameFirstChar(k)=s.fwords{dindex(k)}(1)==s.fwords{dindex(k+1)}(1);
                if length(s.fwords{dindex(k)})>1 & s.fwords{dindex(k+1)}>1
                    sameSecondChar(k)=mean(s.fwords{dindex(k)}(1:2)==s.fwords{dindex(k)}(1:2))==1;
                end
            end
            
            if dsum(k)>.9999;
                identical=identical+1;
                dsum(k)=NaN;%Setting identical to NaN;
            end
        end
        if strcmp2(s,index1,index2(j),s.P.Vvarcoherence, '_varcoherence')
            r(j)=nanstd(dsum);
            Nd=length(dsum);
            if length(dsum)<4
                cohstdfirst4=NaN;
                m5=nan(1,4);
            else
                cohstdfirst4=nanstd(dsum(1:4));
                m5=sort(dsum(1:4));
            end
            cohfirst4=nanmean(dsum(1:min(Nd,4)));
            cohlast4=nanmean(dsum(max(1,Nd-3):Nd));
            cohdistword1n=sum(s.x(dindex(1),1:Ndim).*s.x(dindex(length(dindex)),1:Ndim));
            meanswitch=mean(dsum<0);
            sumswitch=sum(dsum<0);
            cohnoswitch=nanmean(dsum(dsum>=0));
            cohswitch=nanmean(dsum(dsum<0));
            if sumswitch==0
                clustersize=Nd;
            else
                clustersize=(Nd-sumswitch)/sumswitch;
            end
            dsum=[dsum nan(1,15)];dsum=dsum(1:15);
            r(j)=NaN;
            %meanfirst4, meanlast4, std14, dist from first word, mean_switching,sum_switch, cohherence_notswitch, clustersize, coherence per word...
            %_cohfirst4	_cohlast4	_cohstdfirst4	_cohdistword1n	_meanswitch	_sumswitch	_cohnoswitch	_cohswitch	_clustersize	_identical	_samefirstchar	_samesecondchar	_coh1	_coh2	_coh3	_coh4	_coh5	_coh6	_coh7	_coh8	_coh9	_coh10	_coh11	_coh12	_coh13	_coh14	_coh15
            
            resultString{j}=num2str([cohfirst4 cohlast4 cohstdfirst4 cohdistword1n meanswitch sumswitch cohnoswitch cohswitch clustersize identical nanmean(sameFirstChar) nanmean(sameSecondChar) dsum]);
            %resultString{j}=regexprep(resultString{j},' ',char(9));
        else
            r(j)=nanmean(dsum);
        end
    catch
        r(j)=NaN;
    end
elseif strcmp2(s,index1,index2(j),s.P.Vlanguage,'_language')
    if 1
        resultString{j}=getLanguage(getText(s,ij));
    elseif isfield(s.info{ij},'context')
        [tmp tmp tmp tmp newIndex]=text2space(s,getText(s,ij));
        add1=-ones(1,length(find(newIndex==0)));
        add2=log(s.f(newIndex(find(newIndex>0)))*10^6);
        r(j)=mean([add1 add2]);
    else
        r(j)=log(s.f(index2(j))*10^6);
    end
elseif strcmp2(s,index1,index2(j),s.P.Vwordclass,'_wordclass')
    [info s]=getWordClassCash(s,ij);
    r(j)=NaN;
    resultString{j}='';
    if isfield(info,'wordclass')
        for k=1:length(info.wordclass)
            stopword='';
            if isfield(info,'index') & not(isnan(info.index(k))) & info.index(k)>0
                wordWC=getText(s,info.index(k));
                %if isfield(s.info{info.index(k)},'stopword')
                %    stopword='+stopword';
                %end
            elseif k==1
                wordWC=getText(s,ij);
            else
                wordWC='wordHasNoSemanticRep';
            end
            if info.wordclass(k)==0 | length(s.classlabel)<info.wordclass(k)
                wordclass='';
            else
                wordclass=s.classlabel{info.wordclass(k)};
            end
            resultString{j}=[resultString{j}  wordWC '[' wordclass stopword '] '];
        end
    end
elseif strcmp2(s,index1,index2(j),s.P.Vassociates,'_associates') | strcmp2(s,index1,index2(j),s.P.Vfurthestassociates,'_furthestassociates') | strcmp2(s,index1,index2(j),s.P.Vneighbour,'_neighbour')
    if strcmp2(s,index1,index2(j),'_furthestassociates') ver='furthest'; else ver='noprint';end
    [tmp tmp resultString{j} tmp neighbour]=print_nearest_associations_s(s,ver,s.x(ij,:));
    if strcmp2(s,index1,index2(j),s.P.Vneighbour,'_neighbour')
        r(j)=neighbour;
    else
        resultString{j}=regexprep(resultString{j},'CLOSEST','');
        resultString{j}=regexprep(resultString{j},'FURTHEST','');
        resultString{j}=regexprep(resultString{j},char(9),' ');
        resultString{j}=regexprep(resultString{j},char(10),' ');
        resultString{j}=regexprep(resultString{j},': ','');
    end
elseif strcmp2(s,index1,index2(j),s.P.Vlistproperty,'_listproperty')
    resultString{j}=struct2text(s.info{ij});
elseif strcmp2(s,index1,index2(j),s.P.Vlistpropertydata,'_listpropertydata')
    f=fields(s.info{ij});
    resultString{j}='';
    for i=1:length(f)
        try
            d=eval(['s.info{ij}.' f{i}]);
            if isnumeric(d); d=num2str(d);end
            if iscell(d); d=d{1}; end
            resultString{j}=[resultString{j} '_' f{i} '=' d ' '];
        end
    end
elseif strcmp2(s,index1,index2(j),s.P.Vdate,'_date') & isfield(s.info{ij},'time')
    r(j)=NaN;
    try; resultString{j}=datestr(getInfo(s,ij,'time'));end
    
    %Ordered or time dependent functions....
elseif strcmp2(s,index1,index2(j),s.P.Vchange,'_change')
    if j==1
        r(j)=NaN;
    else
        x1=average_vector(s,s.x(index2(max(1,j-10):j-1),:));
        x2=average_vector(s,s.x(index2(j:min(length(index2),j+10)),:));
        r(j)=sum(x1.*x2)^.5;
    end
% elseif strcmp2(s,index1,index2(j),s.P.Vnmonth,'_nmonth')
%     time=getInfo(s,index2,'time');
%     r(j)=length(find(abs(time-time(j))<=15));
% elseif strcmp2(s,index1,index2(j),s.P.Vnday,'_nday')
%     time=getInfo(s,index2,'time');
%     r(j)=length(find(abs(time-time(j))<=.5));
% elseif strcmp2(s,index1,index2(j),s.P.Vprevious,'_previous')
%     if ij==1
%         r(j)=NaN;%no previous word
%     else
%         l=1;c=0;
%         r(j)=sum(s.x(ij,:).*s.x(ij-1,:))*l+c;
%     end
end


function [r resultString]=getProperyShow(s,index1,index2,getPropertyShow,r,resultString,j);
global ij;
%j=1;
%r=NaN;resultString{j}=[];

if isfield(s.info{index1},'index')
    indexWord1=s.info{index1}.index;
    indexWord1=indexWord1(find(indexWord1>0));
else
    indexWord1=index1;
end

if isfield(s.info{index2(j)},'index')
    indexWord2=s.info{index2(j)}.index;
    indexWord2=indexWord2(find(indexWord2>0));
else
    indexWord2=index2(j);
end

reverseOrder=(getInfo(s,index2(j),'specialword')==5 & not(s.par.reverseOrder)) | (getInfo(s,index1,'specialword')==5 & s.par.reverseOrder);
if  reverseOrder
    tmp=indexWord1;
    indexWord1=indexWord2;
    indexWord2=tmp;
end


choice={'property','standarddeviation','min','max','mean','positive','negative','positivenegative','sortwordcrit','sortword','sortwordLow2High','sortvalue','color'};
if not(isempty(find(strcmpi(getPropertyShow,choice))))
    r0=0;
    x=average_vector(s,s.x(indexWord1,:));
    [c l]=getCL(s,index1,index2(j));
    res=x*s.x(indexWord2,:)'*l+c;
    if isempty(res); res=NaN;end
    if strcmpi(s.par.getPropertyShow,'property')
        tmp2=index2word(s,indexWord2);
        for i=1:length(indexWord2)
            tmp2{i}=['_' tmp2{i}];
        end
        r(j)=nanmean(getInfo(s,tmp2,index1));
    elseif strcmpi(s.par.getPropertyShow,'standarddeviation')
        r(j)=nanstd(res);
    elseif strcmpi(s.par.getPropertyShow,'min')
        r(j)=nanmin(res);
    elseif strcmpi(s.par.getPropertyShow,'max')
        r(j)=nanmax(res);
    elseif strcmpi(s.par.getPropertyShow,'mean')
        r(j)=nanmean(res);
    elseif strcmpi(s.par.getPropertyShow,'positive')
        r(j)=(sum(max(res-r0,0).^2)/length(res))^.5;
    elseif strcmpi(s.par.getPropertyShow,'negative')
        r(j)=(sum(min(res-r0,0).^2)/length(res))^.5;
    elseif strcmpi(s.par.getPropertyShow,'positivenegative')
        r(j)=(sum(max(res-r0,0).^2)/length(res)) -(sum(min(res-r0,0).^2)/length(res))^.5;
    elseif strcmpi(s.par.getPropertyShow,'sortvalue')
        resultString{j}='';
        for i=1:length(res)
            resultString{j}=[resultString{j} s.fwords{indexWord2(i)} ' ' sprintf(' %.2f ',res(i))];
        end
    elseif strcmpi(s.par.getPropertyShow,'sortwordcrit') | strcmpi(s.par.getPropertyShow,'sortword') | strcmpi(s.par.getPropertyShow,'sortwordLow2High')
        if strcmpi(s.par.getPropertyShow,'sortwordLow2High')
            [tmp1 tmp2]=sort(res);
        else
            [tmp1 tmp2]=sort(-res);
            if strcmpi(s.par.getPropertyShow,'sortwordcrit')
                tmp2=tmp2(1:length(find(res>s.par.sortwordcrit)));
            end
        end
        indexTmp=indexWord2(tmp2(1:min(length(tmp2),s.par.number_of_ass2)));
        resultString{j}=cell2string(s.fwords(indexTmp));
    elseif strcmpi(s.par.getPropertyShow,'color')
        if isfield(s.info{index1},'c')
            c1=s.info{index1}.c;
        else
            c1=0;
        end
        for i=1:length(indexWord2)
            cprintf([1/(1+exp(-(res(i)-c1))),0,1/(1+exp(+(res(i)-c1)))],[s.fwords{indexWord2(i)} ' ']);
        end
        fprintf('\n');
    end
elseif strcmpi(s.par.getPropertyShow,'mergeTexts')
    resultString{j}=[getText(s,index1) ' ' getText(s,index2(j))];
elseif strcmpi(s.par.getPropertyShow,'subtractTexts')
    [~, t1]=text2index(s,getText(s,index1));
    [~, t2]=text2index(s,getText(s,index2(j)));
    for i=1:length(t2)
        if find(strcmpi(t2{i},t1))
            t2{i}='           ';
        end
    end
    resultString{j}=cell2string(t2);
elseif strcmpi(s.par.getPropertyShow,'meanFull')
    subset=0;maxN=100;
    if length(indexWord1)>maxN
        [tmp indexTmp]=sort(rand(1,length(indexWord1)));
        indexWord1=indexWord1(indexTmp(1:maxN));
        subset=1;
    end
    if length(indexWord2)>maxN
        [tmp indexTmp]=sort(rand(1,length(indexWord2)));
        indexWord2=indexWord2(indexTmp(1:maxN));
        subset=1;
    end
    res=nan(length(indexWord1),length(indexWord2));
    for k1=1:length(indexWord1)
        if 1 %Faster
            res(k1,:)=sum((repmat(s.x(indexWord1(k1),:),length(indexWord2),1).*s.x(indexWord2,:))');
        else %Slower
            for k2=1:length(index_2)
                res(k1,k2)=sum(s.x(index_1(k1),:).*s.x(index_2(k2),:));
            end
        end
    end
    [c l]=getCL(s,index1,index2(j));
    r(j)=nanmean(nanmean(res))'*l+c;
    if subset
        resultString{j}=sprintf('%.4f (based on random subset of N=%d words)',r(j),maxN);
    end
elseif length(getPropertyShow)>0
    resultsVariables1=s.par.resultsVariables;
    ok2=1;
    if strcmpi(s.par.getPropertyShow,'semanticTest')
        [out, s]=semanticTest(s,indexWord2,indexWord1,s.fwords{index2(j)},s.fwords{index1});
        if isempty(resultsVariables1)
            resultsVariables1='p r effectSize correct modelname';
        end
    elseif strcmpi(s.par.getPropertyShow,'targetword')
        [x, x1]=average_vector(s,s.x(indexWord1,:),indexWord1);
        N1=size(x1);
        indexWord2=s.info{index2(j)}.index;indexWord2=indexWord2(find(indexWord2>0));
        if s.par.freezeSecondsParameterGetProperty
            par=s.par;
            s.par=s.par2;
            [x, x2]=average_vector(s,s.x(indexWord2,:),indexWord2);N2=size(x2);
            s.par=par;
        else
            [x, x2]=average_vector(s,s.x(indexWord2,:),indexWord2);N2=size(x2);
        end
        s2.x=[x1; x2];
        s2.par=s.par;s2.Ndim=s.Ndim;s2.xmean2=s.xmean2;
        [out, s2]=semanticTest2(s2,x1,x2,'',1:N1(1),N1(1)+1:N1(1)+N2(1));%,'noprint',s.fwords{index2(j)},s.fwords{index1});
    elseif strcmpi(s.par.getPropertyShow,'seperator')
        seperator=word2index(s,s.par.contextSeperator);
        separtorIndex=[find(indexWord1==seperator) length(indexWord1)];
        start=1;
        x1=[];
        for m=1:length(separtorIndex)
            separtorIndex(m);
            [x1(m,:)]=average_vector(s,s.x(indexWord1(start:separtorIndex(m)),:));
            start=separtorIndex(m)+1;
        end
        separtorIndex=[find(indexWord2==seperator) length(indexWord2)];
        start=1;
        x2=[];
        for m=1:length(separtorIndex)
            separtorIndex(m);
            [x2(m,:)]=average_vector(s,s.x(indexWord2(start:separtorIndex(m)),:));
            start=separtorIndex(m)+1;
        end
        s2.x=[x1; x2];
        N1=size(x1);
        N2=size(x2);
        s2.par=s.par;
        [tmp s2.Ndim]=size(s2.x);
        [out, s2]=semanticTest2(s2,x1,x2,'',1:N1(1),N1(1)+1:N1(1)+N2(1));%,'noprint',s.fwords{index2(j)},s.fwords{index1});
    elseif strcmpi(s.par.getPropertyShow,'keywords')
        %[out, s]=keywordsTest(s,index2(j),index1,0,s.fwords{index2(j)},s.fwords{index1},0);
        %[out, s]=keywordsTest(s,index_2,index_1,0,s.fwords{index_2},s.fwords{index_1},0);
        s.par.getPropertyShow='';
        [out, s]=keywordsTest(s,indexWord2,indexWord1,0,'set1','set2',0);
        s.par.getPropertyShow=getPropertyShow;
        resultString{j}=out.results;
        %[r(j) resultString{j}]=resultsVariables(out,s.par.resultsVariables,out.keywords1);
        ok2=0;
    elseif strcmpi(getPropertyShow,'liwcAll') | strcmp2(s,index1,index2(j),'_liwcall')
        [x,labels,N]=getLIWC(s,index2(j));
        %for i=1:length(index2)
        out='';
        resultString{j}=num2str(full(x'),'%.4f ');
        %end
        ok2=0;
    elseif strcmpi(getPropertyShow,'liwc') | strcmpi(getPropertyShow,'unionText') | strcmpi(getPropertyShow,'unionPercentage') | strcmpi(getPropertyShow,'chi2test')  | strcmpi(getPropertyShow,'sortByFrequency') %| strcmpi(getPropertyShow,'liwcAll')
        ok2=0;
        
        if  s.par.excelServer & strcmp(s.fwords{index1},getText(s,index1,'text'))
            [s, f1 ]=mkfreq(s,index1,[],[],'context');%Very ugly code, but fixes a bug becuase LIWC is stored in context here
        elseif getInfo(s,index1,'specialword')==5
            [s, f1 ]=mkfreq(s,index1,[],[],'text');
        else
            [s, f1 ]=mkfreq(s,index1);
        end
        %Remove non-words
        indexSkip=word2index(s,{'!','.',',',';','-'});
        indexSkip=indexSkip(not(isnan(indexSkip)));
        f1(indexSkip)=0;
        for j2=j:length(index2)
            if  s.par.excelServer & strcmp(s.fwords{index2(j)},getText(s,index2(j),'text'))
                [s, f2 ]=mkfreq(s,index2(j),[],[],'context'); %Very ugly code, but fixes a bug becuase LIWC is stored in context here
            elseif getInfo(s,index2(j),'specialword')==5%For LIWC, use the 'text' text variables
                [s, f2 ]=mkfreq(s,index2(j2),[],[],'text');
            else
                [s, f2 ]=mkfreq(s,index2(j2));
            end
            f2(indexSkip)=0;
%             if s.par.contextWildcardExpansion %Should be moved to mkfreq!
%                 if isfield(s.info{index1},'wordsMissing')
%                     for k=1:length(s.info{index1}.wordsMissing)
%                         w=s.info{index1}.wordsMissing{k};
%                         if findstr(w,'*')>0
%                             a=regexprep(w,'*','\\w*');
%                             if w(end)=='*'
%                                 a=['^' a];
%                             end
%                             select=find(not(cellfun(@isempty,regexp(s.fwords(:),a))))';
%                             f1(select)=1;
%                         end
%                     end
%                 end
%             end
            if findstr(getText(s,index2(j2)),'*')>0
                indexTmp2=find(f2>0);
                for i=indexTmp2
                    if findstr(s.fwords{i},'*')>0 & not(strcmpi(s.fwords{i},'*'))
                        indexTmp1=find(f1>0);
                        a=regexprep(s.fwords(i),'*','\\w*');
                        select=find(not(cellfun(@isempty,regexp(s.fwords(indexTmp1),a))))';
                        f1(indexTmp1(select))=1;
                        f2(indexTmp1(select))=1;
                    end
                end
            end
            if findstr(getText(s,index1),'*')>0
                indexTmp1=find(f1>0);
                for i=indexTmp1
                    if findstr(s.fwords{i},'*')>0 & not(strcmpi(s.fwords{i},'*'))
                        indexTmp2=find(f2>0);
                        a=regexprep(s.fwords(i),'*','\\w*');
                        select=find(not(cellfun(@isempty,regexp(s.fwords(indexTmp2),a))))';
                        f1(indexTmp2(select))=1;
                        f2(indexTmp2(select))=1;
                    end
                end
            end
            
            if length(f1)>length(f2)
                f2(length(f1))=0;
            elseif length(f1)<length(f2)
                f1(length(f2))=0;
            end
            if reverseOrder
                indexTmp=find(f1>0); 
                r(j2)=sum(f1(indexTmp).*(f2(indexTmp)>0))/max(1,sum(f1(indexTmp)));
            else
                indexTmp=find(f2>0);  
                r(j2)=sum(f2(indexTmp).*(f1(indexTmp)>0))/max(1,sum(f2(indexTmp)));
            end
            if strcmpi(getPropertyShow,'unionText')
                resultString{j2}=[cell2string(s.fwords(f1>0 & f2>0)) ' '];
                r(j2)=NaN;
            elseif strcmpi(getPropertyShow,'unionPercentage')
                r(j2)=length(find(f1>0 & f2>0))/length(find(f1>0 | f2>0));
            elseif strcmpi(getPropertyShow,'sortByFrequency')
                [Nf Nindex]=sort(f2,'descend');
                
                resultString{j2}=' ';
                for k=1:length(Nf)
                    if Nf(k)>0
                        resultString{j2}=[resultString{j2} num2str(Nf(k)) ' ' s.fwords{Nindex(k)} ' '];
                    end
                end
                r(j2)=NaN;
            elseif strcmpi(getPropertyShow,'chi2test')
                y(1,1)=sum(f1==0 & f2==0);
                y(1,2)=sum(f1>0 & f2==0);
                y(2,1)=sum(f1==0 & f2>0);
                y(2,2)=sum(f1>0 & f2>0);
                [r(j2) q]=chi2test(y);
                ok2=0;
            end
        end
    elseif strcmpi(getPropertyShow,'noliwc')
        r(j)=sum(s.x(index2(j),:).*s.x(index1,:));ok2=0;
    else
        ok2=0;
        r(j)=sum(s.x(index2(j),:).*s.x(index1,:));ok2=0;
        %tmp=index2word(s,index1);
        %resultString{j}=sprintf('%s is not a trained model. %s is not an invalid option, try: word, targetword, keywords, seperator,seperator, mean, min, max, standarddeviation',tmp{1},getPropertyShow);
        %wordseperator
    end
    if ok2
        [r(j) resultString{j}]=resultsVariables(out,resultsVariables1,out.p);
    end
end



function[r, resultString,skipj]=getPropertyModel(s,index1,index2,r,resultString);
predTextVariables=[];
skipj=length(index2);
if isfield(s.info{index1}.model,'train')
    parSave=s.par;
    if not(isfield(s.info{index1}.model.train.par,'trainMultipelModelName'))
        ModelName={''}; 
    else
        ModelName=s.info{index1}.model.train.par.trainMultipelModelName;
    end
    
    if s.par.excelServer & length(ModelName)>1
        [s indexModel]=getSfromDB(s,s.languagefile,s.filename,ModelName,ModelName, 'update',s.par);%Adds documents referenced with "ref" consiting of text in "text" to the s2-structure, using the langugae in "lang" and we call this document "document"
        if isfield(s.info{indexModel(1)}.model.train.par,'trainMultipelNumericalSize')
            for i=1:s.info{indexModel(1)}.model.train.par.trainMultipelNumericalSize
                s.par.numericalData(1,i)=str2double(getText(s,index2(i+length(ModelName))));
            end
        else
            s.par.numericalData=[];
        end
        if not(length(index2)==length(ModelName)+length(s.par.numericalData))
            resultString{1}=sprintf('Error: The number if inputs (N=%d) does not match the required number for this model (N=%d). Expected inputs: %s',length(index2),length(ModelName),cell2string(ModelName));
            return
        end

        s.par.getPropertyShow='';
        numericalDataAll=[];
        indexNumeric=index2(end-length(s.par.numericalData)+1:end);
        for i=1:length(indexModel)
            tmp=getProperty(s,indexModel(i),[index2(i) indexNumeric]);
            numericalDataAll=[numericalDataAll; tmp(1)];%(j)
        end
        s.par.numericalData=numericalDataAll';
        s.par.variableToCreateSemanticRepresentationFrom=parSave.variableToCreateSemanticRepresentationFrom;
        [d,s]=getX(s,index2,s.info{index1}.model.train.par,s.info{index1}.model.train);
    elseif s.par.getPropertyMultipleInput & isfield(s.info{index1}.model.train.par,'trainOnCrossValidationOfMultipleTextsRecall')
        %This should be moved into getX row 324!
        predTextVariables=s.info{index1}.model.train.par.trainOnCrossValidationOfMultipleTextsRecall;
        s.par.getPropertyShow='';
        d.x=[];
        predictionProperties=s.info{index1}.model.train.par.predictionProperties;
        if not(length(predTextVariables)+length(predictionProperties)==length(index2))
            resultString{1}=sprintf('Incorrect number of arguments. Text variables: %s. Numerical variables: %s',cell2string(predTextVariables),cell2string(predictionProperties'));
        else
            for i=1:max(1,length(predTextVariables))
                for k=1:max(1,length(predictionProperties));%length(predTextVariables)+1:length(index2)
                    k2=k+length(predTextVariables);
                    d.x(k2)=str2double(getText(s,index2(k2)));
                    s=setInfo(s,index2(k),predictionProperties{k},d.x(k2));
                end
                d.x(i)=getProperty(s,[cell2mat(index2word(s,index1)) predTextVariables{i}(2:end)],index2(i));
            end
        end
        1;
    elseif isfield(s.info{index1}.model.train.par,'trainOnCrossValidationOfMultipleTextsRecall')
        %This should be moved into getX row 324!
        predTextVariables=s.info{index1}.model.train.par.trainOnCrossValidationOfMultipleTextsRecall;
        s.par.getPropertyShow='';
        numericalDataAll=[];
        getPropertyImped=s.par.getPropertyImped;
        s.par.getPropertyImped=0;
        for i=1:length(predTextVariables)
            s.par.variableToCreateSemanticRepresentationFrom=predTextVariables{i};
            numericalDataAll=[numericalDataAll; getProperty(s,[cell2mat(index2word(s,index1)) predTextVariables{i}(2:end)],index2)];%(j)
        end
        s.par.getPropertyImped=getPropertyImped;
        s.par.numericalData=numericalDataAll';
        s.par.variableToCreateSemanticRepresentationFrom=parSave.variableToCreateSemanticRepresentationFrom;
        [d,s]=getX(s,index2,s.info{index1}.model.train.par,s.info{index1}.model.train);
        if isfield(s.par,'getPropertyImpedAddNaNs') & s.par.getPropertyImpedAddNaNs>0
            for k=1:numel(d.x)
                if s.par.getPropertyImpedAddNaNs>rand;
                    d.x(k)=NaN;
                end
            end
        elseif isfield(s.par,'getPropertyImpedAddNaNsColumnwise') & s.par.getPropertyImpedAddNaNsColumnwise>0
            d.x(:,s.par.getPropertyImpedAddNaNsColumnwise)=NaN;
        end
    else
        if isfield(s.info{index1}.model.train.par,'trainMultipelNumericalSize')
            NumericalSize=s.info{index1}.model.train.par.trainMultipelNumericalSize;
            if NumericalSize>0
                for i=1:NumericalSize
                    s.par.numericalData(1,i)=str2double(getText(s,index2(i+length(ModelName))));
                end
            end
        else
            NumericalSize=0;
        end

        numericalData=s.par.numericalData;
        s.par=structCopy(s.par,s.info{index1}.model.train.par);
        s.par.contextPrintLabels=0;
        s.par.numericalData=numericalData;
        s.par.variableToCreateSemanticRepresentationFrom=parSave.variableToCreateSemanticRepresentationFrom;
        if NumericalSize==0
            [d,s]=getX(s,index2,                     s.par,s.info{index1}.model.train);
        else
            [d,s]=getX(s,index2(1:length(ModelName)),s.par,s.info{index1}.model.train);
        end
    end
    s.par=parSave;
else
    d.x=s.x(index2,:);
end
if  isfield(s.info{index1},'DLATK') %Trained DLATK model
    info=DLATK(s,NaN(1,length(index2)),getText(s,index2),s.info{index1}.DLATK.labels,s.info{index1}.DLATK);
    r=info.pred;
else
    if isfield(s.info{index1}.model,'xTrain') & s.par.getPropertyImped
        [d.x, d.Nimpeded]=impeadMissingData(s.info{index1}.model.xTrain,d.x,'');
    end
    [r rMultinomial]=predictReg(s.info{index1}.model,d.x,s.info{index1}.par);r=r';
    if length(r)<length(resultString)
        r=[r r(1)*ones(1,length(resultString)-length(r))];
        %r=[r NaN(1,length(resultString)-length(r))];
    end
end
if length(rMultinomial(1,:))>1
    if s.par.multinomialCategory
        [tmp r]=max(rMultinomial');
    else
        %r=r*NaN;
        for k=1:size(rMultinomial,1)
            resultString{k}=[num2str(rMultinomial(k,:))];
        end
    end
end
if isfield(s.info{index1},'predDataStat')
    if iscell(s.par.getPropertyShow)
        getPropertyShowCell=s.par.getPropertyShow;
    else
        getPropertyShowCell(1:length(r))={s.par.getPropertyShow};
    end
    for j1=1:length(r);
        if not(isfield(s.info{index1},'pred'))
            resultString{j1}='';%Old models does not have these data
        elseif isnan(r(j1))
            1;
        elseif strcmpi(getPropertyShowCell{j1},'predTextVariables') %& exist('predTextVariables','var')
            if isfield(s.info{index1}.model.train.par,'trainMultipelModelName')
                resultString{j1}=cell2string(s.info{index1}.model.train.par.trainMultipelModelName);
            elseif ~isempty(predTextVariables)
                resultString{j1}=cell2string(predTextVariables);
            else
                resultString{j1}=s.info{index1}.model.train.par.variableToCreateSemanticRepresentationFrom;
            end
            r(j1)=NaN;
        elseif strcmpi(getPropertyShowCell{j1},'predNumericalVariables')
            if isfield(s.info{index1}.model.train.par,'trainNumericLabels')
                resultString{j1}=cell2string(s.info{index1}.model.train.par.trainNumericLabels);
            else
                resultString{j1}=cell2string(s.info{index1}.model.train.par.predictionProperties);
            end
            r(j1)=NaN;
        elseif strcmpi(getPropertyShowCell{j1},'pred2z') | strcmpi(getPropertyShowCell{j1},'pred2percentage')
            r(j1)=nanmean(s.info{index1}.pred<r(j1));%Compares with predicted value
            if strcmpi(getPropertyShowCell{j1},'pred2z')
                r(j1)=norminv(r(j1));
            end
        elseif strcmpi(getPropertyShowCell{j1},'pred2zNorm') | strcmpi(getPropertyShowCell{j1},'pred2percentageNorm')
            r(j1)=(r(j1)-s.info{index1}.predDataStat(1))/s.info{index1}.predDataStat(2);
            if strcmpi(getPropertyShowCell{j1},'pred2percentageNorm')
                r(j1)=normcdf(r(j1));
            end
        elseif strcmpi(getPropertyShowCell{j1},'data2p')
            compare=str2double(getText(s,index2(j1)));
            r(j1)=nanmean(s.info{index1}.y<compare);%Percentage of
        elseif strcmpi(getPropertyShowCell{j1},'predProbability') | strcmpi(getPropertyShowCell{j1},'predProbabilityPlot')
            [~,indexSort]=sort(s.info{index1}.pred,'ascend');
            X=s.info{index1}.pred(indexSort);
            Y=s.info{index1}.y(indexSort);
            B=mnrfit(X,Y+1);
            %tmp=[find(not(isnan(r))) 1];
            if j1==1 & strcmpi(getPropertyShowCell{j1},'predProbabilityPlot')
                figure(1);hold off;
                plot(X,smooth(Y,25),'.');hold on;
                plot(X,1./(1+exp(B(1)+B(2)*X)),'.');
                xlabel('Predicted');ylabel('Emperical')
                saveas(1,'Pred-Emperical','jpg');
            end
            r(j1)=1./(1+exp(B(1)+B(2)*r(j1)));
        elseif strcmpi(getPropertyShowCell{j1},'data2z')
            compare=str2double(getText(s,index2(j1)));
            r(j1)=(compare-nanmean(s.info{index1}.y))/nanstd(s.info{index1}.y);
        elseif strcmpi(getPropertyShowCell{j1},'pred2zStored')
            iTmp=find(s.info{index1}.zIndex==index2(j1));
            if isempty(iTmp)
                r(j1)=(r(j1)-s.info{index1}.zM)/s.info{index1}.zS;
            else
                r(j1)=(s.info{index1}.z(iTmp)-s.info{index1}.zM)/s.info{index1}.zS;
            end
        end
        if s.par.mapPredictions2Labels(min(end,j1)) & (strcmpi(getPropertyShowCell{j1},'data2p') | strcmpi(getPropertyShowCell{j1},'pred2percentage'))
            if not(isfield(s.info{index1},'pred'))
                %Update model
            else %Set labels based on p-values in s.par.mapPredictions2LabelsP and text in s.par.mapPredictions2LabelsText
                tmp=find(r(j1)<s.par.mapPredictions2LabelsP);
                if isempty(tmp); tmp=length(s.par.mapPredictions2LabelsText);end
                resultString{j1}=s.par.mapPredictions2LabelsText{tmp(1)};
            end
            r(j1)=NaN;
        end
    end
end
if isfield(s.info{index1},'trainBinaryOutput') & s.info{index1}.trainBinaryOutput==1
    r=r>s.info{index1}.binaryThreshold;
end

