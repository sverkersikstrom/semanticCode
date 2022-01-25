function [s h out1 out2 out3]=plotWordcount(s,words,xaxel,yaxel,notUsed1,notUsed2,figureType)
%words=words to plot,
%If length(xaxel)==1, length(yaxel)==1 then...
%xaxel=property index defining median split on x-axel,
%yaxel=property index defining median split on y-axel,
%If length(xaxel)>1, length(yaxel)>1 then
%xaxel=data that defines the x-axel
%yaxel=data that defines the y-axel
%s.par.figureType:1=keywords,2=Cluster of keywords, 3=Cluster of semantic
%associates,4=Cluster of all words, 5=wordcloud (base word frequency),
%6=wordcloud (high-low), 7=wordcloud (low-high),8=semantic LIWC,
%9=frequency LIWC, 10=predictions,11=variables, 12=wordclasses,
%13=functions, 14=clusters, 15=shared words
%figureTitels={'keywords','Cluster of keywords','Cluster of semantic associates','Cluster of all words','wordcloud (based on word frequency=','wordcloud (high-low), 7=wordcloud (low-high)','semantic LIWC','frequency LIWC', 'predictions','variables','wordclasses','functions','semantic clusters', 'Wordcloud (shared words)'};


if nargin<1 | isempty(s)
    s=getSpace;
end
if nargin<5 notUsed1=''; end
if nargin<6 notUsed2='y-axel'; end
if nargin<7
    if not(isempty(s.par.figureType))
        figureType=s.par.figureType;%-1
    else
        figureType=[];
    end
end

if isempty(figureType) | (length(figureType)==1 & figureType<=0);
    figureType=[];
    for i=1:length(s.handles.figuresSwap)
        if strcmpi(s.handles.figuresSwap(i).Checked,'on')
            figureType=[figureType length(s.handles.figuresSwap)-i+1];
        end
    end
end
figureType=sort(figureType);
h=[];
out1=[];out2=[];out3=[];

if nargin>=2 & length(words)<2 & not(isempty(words))
    out1.error='Error, at least two identifier are required';
    fprintf('%s\n',out1.error)
    h=[];
    return
end

if nargin<3
    xaxel=[];yaxel=[];
end

if nargin<4
    yaxel=[];
end


if length(xaxel)>1 | length(yaxel)>1 %Use numerical values 1 and 2 to do median split on!
    if not(length(xaxel)==length(words))
        out1.error='Lenght of data must match length of index, exiting';
        fprintf('%s\n',out1.error)
        return
    end
    [out1, s]=getdata(s,words,xaxel,figureType);
    s.par.clusterKeep=1;
    [out2, s]=getdata(s,words,yaxel,figureType);
    s.par.clusterKeep=0;
elseif strcmpi(get(s.handles.keywordsPlotRedo,'Checked'),'on')
    [file path]=uigetfile('plot*.mat','Choice datafile for x-axis');
    if file==0; return; end
    load([path file]);
    outTmp=out1;
    [file path]=uigetfile('plot*.mat','Choice datafile for y-axis');
    if file==0
        out2=[];
    else
        load([path file]);
        out2=out1;
    end
    out1=outTmp;
elseif nargin<2  %if ver==0 %Standard input New-simplified median split
    [words s]=getWordFromUser(s,'Choice words to plot');
    if words.N==0; return;end
    
    [xaxel s]=getWordFromUser(s,'Choice x-axel','',[]);%,1
    if xaxel.N==0; return;end
    par{1}=s.par;
    
    out3=[];zaxel.N=0;
    [yaxel s]=getWordFromUser(s,'Choice y-axel (escape = no y-axes!)','_m*',[]);%,1
    par{2}=s.par;
    if yaxel.N==0;
        yaxel.word{1}='';
    else
        [zaxel s]=getWordFromUser(s,'Choice z-axel (escape = no z-axes!)','_m*',[]);%,1
        if zaxel.N==0;
            zaxel.word{1}='';
        end
    end    
    par{3}=s.par;
    
    for i=1:length(xaxel.word)
        s.par=par{1};
        [out1 s]=getdataFromUser(s,words.index,xaxel.word{i},1,figureType);
        
        if yaxel.N>=i;
            s.par=par{2};
            s.par.clusterKeep=1;
            [out2 s]=getdataFromUser(s,words.index,yaxel.word{i},1,figureType);
            s.par=par{3};
            if zaxel.N>=i
                [out3 s]=getdataFromUser(s,words.index,zaxel.word{i},1,figureType);
            end
            s.par.clusterKeep=0;
        end
    end
elseif 1
    [out1 s]=getdataFromUser(s,words,s.fwords{xaxel},0,figureType);
    if length(yaxel)>0
        [out2 s]=getdataFromUser(s,words,s.fwords{yaxel},0,figureType);
    end
end

[s h out1]=plotWordcount2(s,out1,out2,out3,figureType);

if isempty(out1)
    out1.error='No data to plot';
    fprintf('%s\n',out1.error)
    return
else
    out1.results=sprintf('\n\n-------RESULTS FOR X-AXIS (%s)-------\n\n%s',s.par.plotXlabel, out1.results);
    if not(s.par.excelServer)
        fprintf('%s\n',out1.results)
    end
    if not(isempty(out2)) 
        out2.results=sprintf('\n\n-------RESULTS FOR Y-AXIS (%s)-------\n\n%s',s.par.plotYlabel, out2.results);
        if not(s.par.excelServer)
            fprintf('%s\n',out2.results); 
        end
    end
    if not(isempty(out3)) 
        out3.results=sprintf('\n\n-------RESULTS FOR Z-AXIS (%s)-------\n\n%s',s.par.plotZlabel, out3.results);
        if not(s.par.excelServer)
            fprintf('%s\n',out3.results);
        end
    end
end


function out4=matchWord(out1,out2)
if isempty(out2) | not(isfield(out2,'word'))
    out4=out2;
    return
end
N=length(out1.word);
j1=0;
index1=[];
index2=[];
for i=1:N
    j=find(strcmpi(out1.word(i),out2.word));
    if isempty(j) j=0;end
    j1=j1+1;
    index1(i)=i;
    index2(i)=j(1);
end
index=index2>0;
f=fields(out2);
N2=length(out2.word);
for i=1:length(out1.word)
    out4.word{i}='';
end
for i=1:length(f)
    if eval(['length(out2.' f{i} ')'])==N2
        eval(['out4.' f{i} '(index1(index))=out2.' f{i} '(index2(index));']);
        try
            eval(['out4.' f{i} '(index1(not(index)))=NaN;']);
        end
    else
        eval(['out4.' f{i} '=out2.' f{i} ';']);
    end
end

function [s, figureType, out1]=plotWordcount2(s,out1,out2,out3,figureType)
if length(s.par.plotXlabel)>0 out1.label=s.par.plotXlabel;end
if length(s.par.plotYlabel)>0 out2.label=s.par.plotYlabel;end
if length(s.par.plotZlabel)>0 out3.label=s.par.plotZlabel;end
out2=matchWord(out1,out2);
out3=matchWord(out1,out3);
for i=1:25;try;close(i);end;end
if nargin<4 out3=[]; end
h=[];
if isempty(out1)
    out1.error='No data to plot';
    fprintf('%s\n',out1.error)
    return
end
if s.par.parfor
    s.handles=[];
    parfor k=figureType
        [~, h(k),out{k}]=plotWordcount3(s,out1,out2,out3,k);
    end
    for k=figureType 
        if not(isnan(h(k))) & h(k)>0
            out1.results=[out1.results sprintf('\n') out{k}.text];
            h(k)=open([out{k}.filename '.fig']);
            out1.figureText{h(k)}=out{k}.figureNote;
        end
    end
else
    for k=figureType 
        try
            [s, h(k),out1]=plotWordcount3(s,out1,out2,out3,k);
            out1.figureText{k}=out1.figureNote;
        catch
            fprintf('Error in plotting figure %d\n',k);
        end
    end
end
figureType=h(not(isnan(h)) & h>0);

function [s, figureType, out1]=plotWordcount3(s,out1,out2,out3,figureType)
s.handles=getHandles;
out1.figureNote='';
out1.text='';
d.oneDimPlot=isempty(out2);
d.axisType='';

if out1.par.plotOnSemanticScale | (isfield(out2,'par') & out2.par.plotOnSemanticScale)
    if not(figureType==1 | figureType==5 |  figureType==6 | figureType==7) %figureType==2 |figureType==3 |
        fprintf('Semantic plotting of these figurs are not supported\n')
        figureType=NaN;
        return
    end
end
if out1.par.plotOnSemanticScale
    out1.axisType='z(p)';
    if isfield(out1,'w')
        out1.w=matchWord(out1,out1.w);
        out1=structCopy(out1,out1.w);
    end
end
if isfield(out2,'par') & out2.par.plotOnSemanticScale
    out2.axisType='z(p)';
    if isfield(out2,'w')
        out2.w=matchWord(out1.w,out2.w);
        out2=structCopy(out2,out2.w);
    end
end
if isfield(out3,'par') & out3.par.plotOnSemanticScale
    out3.axisType='z(p)';
    if isfield(out3,'w')
        out3.w=matchWord(out1.w,out3.w);
        out3=structCopy(out3,out3.w);
    end
end


if not(isfield(out2,'label')) out2.label='';end
out1=getScale(out1,s.par.keywordsPlotPvalue);

f=figure(figureType);

if isfield(s.par,'plotColor') & length(s.par.plotColor)>0
    colDef=s.par.plotColor;
else
    colDef='gkrbcmyg'; 
end

for i=1:length(colDef)
    h=plot(0,0,'x','color',colDef(i));
    colDef2{i}=get(h,'color');
end
colDef2{7}=[.7 .7 0];
colDef2{8}=[.0 .5 .5];

d.x1=[];d.y1=[];d.Nletters=[];
if not(s.par.plotBonferroni) %Bonferroni correction of cluster...
    d.Nc=1;
end
d.color=[];
for i=1:80
    d.color=[d.color colDef2];
end

%r,g,b,k,y
%Autoscale fontsize:
d.shrink=s.par.plotWordcountWeightCluster;
d.dcrit=s.par.keywordsPlotSpread;

clf;
hold on

if isfield(out1,'q')
    if not(isfield(out2,'q'))
        out2=out1;
        out2.q=zeros(1,length(out1.q));
        out2.q=nan(1,length(out1.q));
    end
    out2=getScale(out2,s.par.keywordsPlotPvalue);
    
    if isempty(find(not(isnan(out2.q))))
        %fprintf('Second dimension is empty, setting all values to zero!\n')
        out2.q=zeros(1,length(out2.q));
        out2.label='';
        out2.z1=zeros(1,length(out2.z1));
        out2.clusterP=1/2+zeros(1,length(out2.clusterP));
    end
    d.fontsizeI=((out1.f1+out1.f2)+(out2.f1+out2.f2));
    tmp=sort(d.fontsizeI,'descend');
    d.fontsize=parameter(s.handles.plotkeywordsFontsize)/median(tmp(1:min(end,10)));
end

if not(isempty(out3)) & not(figureType>=4 & figureType<=6)
    close(figureType);
    figure(figureType);
    h=plot3(0,0,0,'x','color',[1 1 1]);
    hold on
    xlabel(out1.label);ylabel(out2.label);zlabel(out3.label);
end

%Make different plots
if figureType==1
    d=plotKeywords(s,d,out1,out2,out3);
    d.Nc=length(out1.word);
elseif (figureType>=5 & figureType<=7) | figureType==15 %Wordcloud
    d=plotWordCloud2(s,d,out1,figureType);    
else %if (figureType>=8  & figureType<=14) | figureType>=2 & figureType<=4 %LIWC plots
    plotSignificantLines(s,d,out1,out2,out3,1);
    [d figureType]=plotLIWC(s,d,out1,out2,out3,figureType);
    if isnan(figureType) return; end
end


%Making a filename and title
filename=['Figure ' d.titleWord out1.label '-' out2.label];
try
    out1.pSemanticScale=out1.w.pTrain;
catch
    out1.pSemanticScale=NaN;
end
if out1.par.plotOnSemanticScale
    filename=[filename ' SemanticScale'];
    pscale=sprintf(' p(x)=%.4f',out1.pSemanticScale);
    try
        pscale=sprintf('%s, p(y)=%.4f',pscale, out2.w.pTrain);
    end
    title([filename pscale]);
else
    title(filename);
end

%Writing an explantory text
if not(isfield(f,'Number'))
    f=gcf;
end
text=[sprintf('\n%d: ',f.Number) filename sprintf('\n\n')];
if figureType==1 %Keywords
    text=[text sprintf('The figure shows words where the frequencies of occurrence are significant overrepresented in the high, or low end of the scale. ',0.05/d.Nc, s.par.keywordsPlotPvalue)];
    text=[text sprintf('The font size represents the frequency of occurrence of the words. ')];
elseif figureType==2 | figureType==3%Cluster of keywords
    text=[text sprintf('The figure shows color-coded clusters that significantly discriminate between the high and the low value of the scale. ')];
    if figureType==2 %cluster keywords
        text=[text sprintf('The words are significantly more frequently occurring in the high or low end of the scale. ')];
    else %Cluster semantic
        text=[text sprintf('The ten words that are most semantically closest to the cluster centroid are shown. ')];
    end
    text=[text sprintf('The font size represents the frequency of occurrence of the words. ')];
elseif figureType==4
    text=[text sprintf('The figure shows words where their semantic representations are clustered according to the k-mean cluster algorithm. ')];
elseif figureType==15
    if out1.plotwordCountCorrelation
        text=[text sprintf('Wordclouds of shared words: All words have correlations that are non-significant different from zero. The fontsizes are proportional to (N*p)^.5')];
    else
        text=[text sprintf('Wordclouds of shared words: All words have non-significant different word frequencies. The fontsizes are proportional to (N1*N2*p)^.5')];
    end
elseif strcmpi(d.axisType,'wordcloud') 
    text=[text sprintf('Wordclouds: The font sizes are proportional to the square roots of the Q-values in a Chi-2 tests based on word frequency of dataset 1 compared to ')];
    if figureType==5
        text=[text sprintf('general word frequency in the language. ')];
    elseif figureType==6
        text=[text sprintf('datset2. ')];
    else
        text=[text sprintf('datset1. ')];
    end
    text=[text sprintf('Colored words are significant following Bonferroni corrections for multiple comparisons (p=%.4f), and grey words significant without correction (p=%.4f). ',0.05/d.Nc, s.par.keywordsPlotPvalue)];
else
    text=[text sprintf('The plot shows the %s category. ',lower(d.titleWord))];
end
if figureType==4
    text=[text sprintf('The clusters are plotted on a circle. ')];
elseif strcmpi(out1.axisType,'q')
    text=[text sprintf('The axis represents Q-values in the Chi-square tests (q). ')];
elseif strcmpi(out1.axisType,'r')
    text=[text sprintf('The axis represents the correlation coifficient (r). ')];
elseif strcmpi(out1.axisType,'z(p)')
    text=[text sprintf('The axis represents z-transformed p-values z(p). ')];
end

if not(strcmpi(d.axisType,'wordcloud')) & (figureType<=3 |  figureType>=8) %| plotType>=16 %Plot significant levels etc.
    plotSignificantLines(s,d,out1,out2,out3);
    if d.oneDimPlot
        text=[text sprintf('The area outside of the inner grey lines represents significant differences (p=%.4f) and the areas outside of the outher grey lines represents significant values following Bonferroni corrections for multiple comparisons (p=%.4f)',s.par.keywordsPlotPvalue, 0.05/d.Nc)];
    else
        text=[text sprintf('The area outside of the inner grey box represents significant differences (p=%.4f) and the area outside of the greater grey box represents significant values following Bonferroni corrections for multiple comparisons (p=%.4f)',s.par.keywordsPlotPvalue, 0.05/d.Nc)];
    end
end

out1.figureNote=text;
if s.par.excelServer==0
    out1.results=[out1.results sprintf('\n') text];
end
out1.text=text;

set(gcf,'Color',[1 1 1]);
if isempty(out3)
    axis off
end

%Moving figures on the screen (do not resize)
if isfield(s.par,'plotPosition')
    set(gcf,'Position',s.par.plotPosition);%Move pictures
else
    try
        position=get(gcf,'Position');
        if isfield(gcf,'Position')
            position=gcf.Posiition;
        end
        position(1)=150*fix(figureType/3)*3+20;
        position(2)=300*(figureType-fix(figureType/3)*3)+20;
        set(f,'Position',position);%Move pictures
    catch
        fprintf('Could not move figures\n')
    end
end    

%Saving figures to harddrive
if not(s.par.excelServer)
    fprintf('Saving: %s\n',filename);
    try
        plotSaveFolder=['Figures ' out1.label '-' out2.label];
        if not(isempty(out3))
            filename=[filename '-' out3.label];
            plotSaveFolder=[plotSaveFolder '-' out3.label];
        end
        warning off; mkdir(plotSaveFolder); warning on;
        filename2=[plotSaveFolder '/' filename];
        hgx(figureType,filename2);
        out1.filename=filename2;
        
        %Make a 3-D movie
        if not(isempty(out3))
            try
                N=get(gcf,'position');%Moving figure, Do not resize
                clear F;
                for i=1:36*2
                    camorbit(10/2,0,'camera')
                    F(i)= getframe(gcf, [0 0 N(3) N(4)]);
                    drawnow
                end
                save([plotSaveFolder '/Movie' filename] ,'F');
                myVideo  = VideoWriter([plotSaveFolder '/Movie' filename]);%, 'Uncompressed AVI');
                myVideo.FrameRate = 4;  % Default 30
                myVideo.Quality = 100;    % Default 75
                open(myVideo);
                writeVideo(myVideo,F);
                close(myVideo);
            catch
                fprintf('Error: Could not rotate 3d figure\n')
            end
        end
    catch
        fprintf('Error during saveing of figure: %s\n',filename);
    end
end

function out1=getScale(out1,pvalue);
if not(isfield(out1,'p'))
    return
elseif isempty(pvalue)
    index1=[];
else
    index1=find(out1.p<pvalue);
end
out1.index1=index1;
minp=1e-15;
out1.fnorm1=out1.f1/sum(out1.f1);
out1.fnorm2=out1.f2/sum(out1.f2);
if sum(out1.f2)==0 | out1.par.plotOnSemanticScale
    %Semantic scale or correlation (no swaping)
    class1=out1.q>0;
else
    class1=out1.fnorm1<out1.fnorm2;
    out1.q(class1)=-out1.q(class1);%Chi-squrare test needs to swap denpding of relative frequency!
end
out1.fnorm12(class1)=out1.f1(class1);
out1.fnorm12(not(class1))=out1.f2(not(class1));

out1.z1=norminv(min(1-minp,max(minp,out1.p)));
out1.z1(class1)=-out1.z1(class1);

function [out1 s ]=getdataFromUser(s,index,label,askForFile,figureType)
if nargin<4; askForFile=0;end
filename=['plotWordCountData' label '.mat'];
if exist(filename) & askForFile
    if strcmpi('yes',questdlg(['Use existing datafile? ' label ],'Load from file','yes','no','no'))
        load(filename);
        return
    end
end
[r1,~,s]=getProperty(s,label,index);

[out1, s]=getdata(s,index,r1,figureType);

out1.label=regexprep(label,'_',' ');
out1.filename=filename;
save(filename,'out1');
f=fopen(['ResultsPlotText ' out1.label '.txt'],'w');
if isfield(out1,'results')
    fprintf('%s\n',out1.results);
    fprintf(f,'%s\n',out1.results);
end
fclose(f);

function [out, s]=getdata(s,index,r,figureType)
out.results='';

if figureType==5 & s.par.plotOnSemanticScale
    return
end
removeQ23=0;
removeMedian=0;
if removeQ23 %Keep lower 25% and higher 75%
    %This will not work for two dimensions because of problems with clustering of different
    %datasets....
    fprintf('Keep lower quartile and and higher quartile (removes half of the dataset)\n');
    [rsort indexr]=sort(r);
    rmin=rsort(fix(length(r)*1/4));
    rmax=rsort(fix(length(r)*3/4));
    keep=find(r<=rmin | r>=rmax);
    r=r(keep);
    index=index(keep);
end
if removeMedian
    fprintf('Removing median data\n')
    index1=find(r>nanmedian(r));
    index2=find(r<nanmedian(r));
else
    %fprintf('Keeping median data\n')
    rBinary=r>=nanmedian(r);
    index1=find(rBinary);
    index2=find(not(rBinary));
    index1b=find(r>nanmedian(r));
    index2b=find(r<=nanmedian(r));
    if abs(length(index1b)-length(index2b))<abs(length(index1)-length(index2))
        rBinary=r>nanmedian(r);
        index1=index1b;
        index2=index2b;
    end
end
fprintf('Datapoints N1=%d\tN2=%d\n',length(index1),length(index2))

rng('default');%Makes identical clusters....
out.results='';
if isempty(find(figureType<=7)) & not(figureType==15) & 1
    out=[];
elseif s.par.plotwordCountCorrelation %Correlation
    if isempty(r);return;end
    [out, s]=keywordsTest(s,index,NaN,0,'','',2,r);
else %Median split
    if isempty(index1) | isempty(index2)
        return
    end
    [out, s]=keywordsTest(s,index(index1),index(index2));
end
out.label='';
out.par=s.par;
out.index=index;
out.results='';
if s.par.plotwordCountCorrelation
    out.axisType='r';
elseif s.par.plotOnSemanticScale
    out.axisType='z(p)';
else 
    out.axisType='q';
end

parCategorySave=s.par.category;
s.par.category={''};
indexUse=[5 5 4 12 8 2];%Skip semantic dimensions: 6
for i=1:length(indexUse)
    if not(isempty(find(i==figureType-7)))
        [ ~,categories,indexCat]=getIndexCategory(indexUse(i),s);
        indexCat=indexCat(not(isnan(indexCat)));
        s.par.category{i}=cell2string(s.fwords(indexCat));%LIWC
        s.par.categoryLabel{i}=categories{indexUse(i)};
        if indexUse(i)==2 %Select functions with
            [a, b,s]=getProperty(s,1,indexCat);
            for j=1:length(b)
                a(j)=not(isnan(b{j}));
            end
            indexCat=indexCat(find(a));
            s.par.category{i}=cell2string(s.fwords(indexCat));%functions
        end
    end
end
%Change 1 to LIWC to semantic similarity:
s.par.CategoryGetPropertyShow{1}='noliwc';
try;s.par.categoryLabel{1}=['Semantic simliarity for ' s.par.categoryLabel{1}];end
%Add user selected LIWC
i=i+1;
s.par.category{i}=parCategorySave{1};
s.par.categoryLabel{i}='User selected LIWC';
s.par.categoryLabel{i}='cluster';

if s.par.plotwordCountCorrelation %Correlation
    [out ,s]=statisticOnGroupsOfIdentifers(s,index,NaN,out,r);
else
    [out ,s]=statisticOnGroupsOfIdentifers(s,index(index1),index(index2),out);
end

s.par.category=parCategorySave;

if s.par.plotOnSemanticScale
    s.par.trainSemanticKeywordsFrequency=max(1,par.trainSemanticKeywordsFrequency);
    trainSemanticKeywordsFrequency=s.par.trainSemanticKeywordsFrequency;
    s.par.trainSemanticKeywordsFrequency=max(1,s.par.trainSemanticKeywordsFrequency);
    [s info]= train(s,r,'',index,[],[]);
    s.par.trainSemanticKeywordsFrequency=trainSemanticKeywordsFrequency;
    out.w=info.w;
end



function a=fixchar2(a)
a=regexprep(a,char(26),'a');
a=regexprep(a,'?','a');
a=regexprep(a,'?','o');
a=regexprep(a,'?','a');
a=regexprep(a,char(26),'a');
a=regexprep(a,char(228),'a');
a=regexprep(a,char(228),'a');
a=regexprep(a,char(246),'o');
1;

function c=mkColor(s,word)
if not(isfield(s.par,'plotColor')) | isempty(s.par.plotColor)
    c=min(.8,rand(1,3));
else
    [a,~,s]=getProperty(s,s.par.plotColor,word);
    c(1)=a;
    c(2)=0;
    c(3)=1-a;
    c=max(0,min(1,c));
end

function d=plotWordCloud2(s,d,out1,plotType)
d.axisType='wordcloud';
if plotType==15 %Shared words
    d.titleWord=['Wordclouds ' out1.label ' - shared words'];
    if out1.plotwordCountCorrelation
        p=out1.p;
        fontsize=(p.*out1.f1).^.5/sum(out1.f1);
    else
        p=1-chi2cdf(abs(out1.q),1);
        fontsize=(p.*(out1.f1.*out1.f2)).^.5/sum(out1.f1.^2+out1.f2.^2)^.5;
    end
    if s.par.plotWordcloudNormalizedWithFrequency15
        fontsize=fontsize./out1.fNorm;
        fontsize(find(isinf(fontsize)))=0;
    end
    q=out1.q;
    class=ones(1,length(p));
    class(p<s.par.keywordsPlotPvalue | fontsize==0)=0;
    p=p*0;
else
     %Wordcloud - word frequency norm
    if plotType==5
        d.titleWord=['Wordclouds ' out1.label ' - frequency norm'];
        %Semantic scale
        if s.par.plotOnSemanticScale
            d2=plotWordCloud(s,out1.index);
            d.Nc=length(out1.f1);
            %d.titleWord=['Wordclouds ' out1.label ' - frequency norm'];
            return
        else
            f1=out1.f1;
            if s.par.plotWordcloudNormalizedWithFrequency5
                q=out1.qNorm1;
            else
                q=f1;
            end
            class=ones(1,length(f1));
            p=1-chi2cdf(q,1);
            fontsize=q.^.5;
            if out1.plotwordCountCorrelation
                p=ones(1,length(f1));
            end
        end
    elseif plotType==6
        d.titleWord=['Wordclouds ' out1.label ' (high - low)' ];
        f1=out1.f1;
        f2=out1.f2;
        q=out1.q;
        if out1.plotwordCountCorrelation
            class=out1.q>0;
            fontsize=out1.q;
            p=out1.p;
        else
            class=f1/nansum(f1)>f2/nansum(f2);
            fontsize=max(0,abs(q)).^.5;
            p=1-chi2cdf(abs(q),1);
        end
    else
        d.titleWord=['Wordclouds ' out1.label '(low - high)' ];
        f2=out1.f1;
        f1=out1.f2;
        q=out1.q;
        if out1.plotwordCountCorrelation
            class=out1.q<0;
            fontsize=-out1.q;
            p=out1.p;
        else
            class=f1/nansum(f1)>f2/nansum(f2);
            fontsize=max(0,abs(q)).^.5;
            p=1-chi2cdf(abs(q),1);
        end
    end
end

%Plot wordcloud
word=out1.word;
d.Nc=length(out1.f1);
wordCloud(s,d,word,p,fontsize,class);


function [d, figureType]=plotLIWC(s,d,out1,out2,out3,figureType)
minp=1e-15;
k=figureType-7;
if  figureType==3 | figureType==2
    if not(out1.plotwordCountCorrelation)
        out1.clusterQ(find(not(out1.clusterClass)))=-out1.clusterQ(find(not(out1.clusterClass)));
    end
    if not(out2.plotwordCountCorrelation)
        out2.clusterQ(find(not(out2.clusterClass)))=-out2.clusterQ(find(not(out2.clusterClass)));
    end
    try;
        if not(out3.plotwordCountCorrelation)
            out3.clusterQ(find(not(out3.clusterClass)))=-out3.clusterQ(find(not(out3.clusterClass)));
        end
    end
elseif figureType>=8 
    if not(isfield(out1,'category_p'))
        out1.error='Missing LIWC data, exiting';
        fprintf('%s\n',out1.error)
        return
    end
    if out1.plotwordCountCorrelation
        %d.axisType='r';
        if k>length(out1.pRLIWC) figureType=NaN; return; end
        out1.clusterP=out1.pRLIWC{k};
        out1.clusterClass=out1.rLIWC{k}>0;
        out1.clusterQ=out1.rLIWC{k};
    else
        if k>length(out1.category_p) figureType=NaN;return; end
        %d.axisType='z(p)';
        out1.clusterP=out1.category_p{k};
        out1.clusterClass=out1.categorySign{k};
        out1.clusterQ=norminv(min(1-minp,max(minp,out1.clusterP)));
        out1.clusterQ(find(out1.clusterClass))=-out1.clusterQ(find(out1.clusterClass));
    end
    if out2.plotwordCountCorrelation
        %d.axisType2='r';
        out2.clusterP=out2.pRLIWC{k};
        out2.clusterClass=out2.rLIWC{k}>0;
        out2.clusterQ=out2.rLIWC{k};
    else
        %d.axisType2='z(p)';
        out2.clusterP=out2.category_p{k};
        out2.clusterClass=out2.categorySign{k};
        out2.clusterQ=norminv(min(1-minp,max(minp,out2.clusterP)));
        out2.clusterQ(find(out2.clusterClass))=-out2.clusterQ(find(out2.clusterClass));
    end

    out1.clusterP(isnan(out1.clusterP))=0.5;
    out1.cluster=out1.categoryClass{k};
    out2.clusterP(isnan(out2.clusterP))=0.5;
    out2.cluster=out2.categoryClass{k};
    d.Nc=length(out2.category_p{k});
    if d.oneDimPlot
        out2.clusterP=zeros(1,length(out2.clusterP))+.5;
    end
end

out1.clusterZ=out1.clusterQ;
out2.clusterZ=out2.clusterQ;
if d.oneDimPlot
    sigCluster=out1.clusterP<s.par.keywordsPlotPvalue;
    out2.clusterZ=zeros(1,length(out2.clusterZ));
else
    sigCluster=out1.clusterP<s.par.keywordsPlotPvalue | out2.clusterP<s.par.keywordsPlotPvalue;
end

j=0;
hold on;
if figureType==2 | figureType==3 | figureType==4 
    d.Nc=length(out1.clusterZ);
    if figureType==4
        d.titleWord='Words prototypical to clusters';
        out1.clusterZ=2*sin((1:length(out1.clusterZ))/length(out1.clusterZ)*pi*2);
        out2.clusterZ=2*cos((1:length(out1.clusterZ))/length(out1.clusterZ)*pi*2);
        sigCluster=ones(1,length(sigCluster));%Plots all clusters
    else
        d.titleWord='Words prototypical to clusters divided into significant clusters';
    end
    selected=out1.clusterPrototyp<=fix(min(10,120/length(find(sigCluster))));%10
else
    if figureType>=8
        d.titleWord=['Significant words in the category: ' out1.categoryLabel{k}];
    else
        d.titleWord='Significant words divided into significant clusters';
    end
end
if out1.plotwordCountCorrelation
    d.titleWord=[d.titleWord ' (correlation) '];
else
    d.titleWord=[d.titleWord ' (chi2, median-split) '];
end
if s.par.plotOnSemanticScale
    d.titleWord=[d.titleWord  '(semantic)'];
else
    d.titleWord=[d.titleWord  '(frequency)'];
end

if out1.plotwordCountCorrelation
    const=.05/3;
else
    const=1.5;
end

%Plot centroids, or for figuure 8-14 plot items
for i=1:length(sigCluster) 
    if sigCluster(i)
        j=j+1;
        plot(out1.clusterZ(i),out2.clusterZ(i),'x','color',d.color{min(length(d.color),i)},'MarkerSize',15,'LineWidth',3)
        if figureType>=8 & isempty(out3)
            out1.categoryIdentifiers{k}{i}=regexprep(out1.categoryIdentifiers{k}{i},'_liwc','');
            out1.categoryIdentifiers{k}{i}=regexprep(out1.categoryIdentifiers{k}{i},'_','');
            h=text(out1.clusterZ(i),out2.clusterZ(i)+const,index2word(s,upper(fixchar2(out1.categoryIdentifiers{k}{i}))));
            set(h,'fontsize',14,'color',d.color{i},'HorizontalAlignment','center');
            d=findEmptySpace(d,h);
            H=get(h);
            plot([out1.clusterZ(i) H.Position(1) ],[out2.clusterZ(i) H.Position(2)],'--' ,'color',d.color{i})
        end
    else
        plot(out1.clusterZ(i),out2.clusterZ(i),'x','color',[.8 .8 .8],'MarkerSize',15,'LineWidth',3)
    end
    leg{i}=['Cluster ' num2str(i)];
    try; leg{i}=[leg{i} ' ' out1.word{find(out1.clusterPrototyp==1 & out1.cluster==i)}];end
end
if not(figureType==2 | figureType==3 | figureType==4 | figureType>=8 )
    legend(leg,'Location','Best');
end
%legend BOXOFF
minLim=max(abs(max([out1.clusterZ out2.clusterZ]))+2);
if isempty(d.x1)
    %return;
else
    lim=max(minLim,(1+d.shrink*0)*max(abs([d.x1])));
    if isempty(lim) lim=minLim;end
    set(gca,'Xlim',[-lim lim]);
    lim=max(.1, (1+d.shrink*0)*max(abs([d.y1])));
    if isempty(lim) lim=minLim;end
    if figureType>=8 & d.oneDimPlot
        set(gca,'Ylim',[-.5 2]);
    else
        set(gca,'Ylim',[-lim lim]);
    end
end

%Plot items close to clusters centroids (does not apply to figure 8-14)
if isfield(out1,'z1')
    selected=(out1.p<s.par.keywordsPlotPvalue | out2.p<s.par.keywordsPlotPvalue);
    d.Nc=length(selected);
    selected = selected & not(isnan(out1.q));
    if figureType==4
        selected=ones(1,length(out1.q));
    end
    [tmp indexSort]=sort(d.fontsizeI,'descend');
    for i2=1:min(2*s.par.plotWordcountMaxNumber,length(out1.z1))
        i=indexSort(i2);
        if not(isempty(sigCluster)) & out1.cluster(i)>0 & out2.cluster(i)>0 & sigCluster(out1.cluster(i)) & selected(i)
            x=d.shrink*out1.z1(i)+(1-d.shrink)*out1.clusterZ(out1.cluster(i));
            y=d.shrink*out2.z1(i)+(1-d.shrink)*out2.clusterZ(out2.cluster(i));
            fontsize2=min(s.par.fontsizeLimits(2),max(s.par.fontsizeLimits(1),d.fontsize*d.fontsizeI(i)));
            if s.par.plotWordPrintDots
                if not(isempty(out3))
                    z=out3.q(i);
                    c=[out1.p(i)<.05/d.Nc & x>0 out2.p(i)<.05/d.Nc & y>0 out3.p(i)<.05/d.Nc & z>0 ];
                    if sum(c)>2 c=[2/3 2/3 2/3];end
                    h=plot3(x,y,z,'x','color',c,'MarkerSize',fontsize2);
                else
                    h=plot(x,y,'x','color',d.color{out1.cluster(i)},'MarkerSize',fontsize2);
                end
            end
            if not(isempty(out3))
                if s.par.plotWordCountWords
                    h=text(x,y,z,index2word(s,fixchar2(out1.word{i})));
                    set(h,'fontsize',fontsize2,'color',c,'HorizontalAlignment','center');
                end
            elseif s.par.plotWordCountWords
                h=text(x,y,index2word(s,fixchar2(out1.word{i})));
                set(h,'fontsize',fontsize2,'color',d.color{out1.cluster(i)},'HorizontalAlignment','center');
                d=findEmptySpace(d,h);
                if s.par.plotWordPrintDots & s.par.plotWordCountWords
                    H=get(h);
                    plot([x H.Position(1) ],[y H.Position(2)],'--' ,'color',d.color{out1.cluster(i)})
                end
            end
        end
    end
end

function d=plotKeywords(s,d,out1,out2,out3);
index=unique([out1.index1 out2.index1]);
if s.par.plotBonferroni
    Nc=length(out1.z1);
else
    Nc=1;
end
limx=1.2*max([abs(out1.q(find(not(isinf(out1.z1)))))]);
if isnan(limx) limx=1; end
limy=1.2*max([abs(out2.q(find(not(isinf(out2.z1)))))]);
if isnan(limy) limy=1;end
if d.oneDimPlot
    limy=limx*.1;
elseif out1.plotwordCountCorrelation==out2.plotwordCountCorrelation
    limy=max(limy,limx);limx=limy;%Make it a square
end
if isempty(limx) limx=1;end
set(gca,'Xlim',[-limx limx]);
if isempty(limy) |  limy==0 limy=2;end
set(gca,'Ylim',[-limy limy]);
pCrit=-norminv(s.par.keywordsPlotPvalue/Nc);
fprintf('X-axis: N(significant & Bonferroni corrected)=%d, N(significant)=%d\n',sum(out1.pcorrected(index)<.05),sum(out1.p(index)<s.par.keywordsPlotPvalue))
fprintf('Y-axis: N(significant & Bonferroni corrected)=%d, N(significant)=%d\n',sum(out2.pcorrected(index)<.05),sum(out2.p(index)<s.par.keywordsPlotPvalue))
k=0;

selected=out1.pcorrected(index)<s.par.keywordsPlotPvalue | out2.pcorrected(index)<s.par.keywordsPlotPvalue;
tmp=sort(d.fontsizeI(selected),'descend');
d.fontsize=parameter(s.handles.plotkeywordsFontsize)/median(tmp(1:min(end,10)));

for i2=1:length(index)
    if selected(i2) & k<s.par.plotWordcountMaxNumber
        k=k+1;
        i=index(i2);
        x=out1.q(i);
        y=out2.q(i);
        if k>s.par.plotWordcountMaxNumber & 0
            fprintf('Omitting word:%s, because maximal words to plot is set to: %d\n',out1.word{i},s.par.plotWordcountMaxNumber)
        else
            tmpCol=1*(out1.q(i)>0) + (out1.q(i)>0) *2 +1;
            c=d.color{tmpCol};
            fontsize2=min(s.par.fontsizeLimits(2),max(s.par.fontsizeLimits(1),d.fontsize*d.fontsizeI(i)));
            if s.par.plotWordPrintDots
                if not(isempty(out3))
                    z=out3.q(i);
                    c=[out1.p(i)<.05/Nc & x>0 out2.p(i)<.05/Nc & y>0 out3.p(i)<.05/Nc & z>0 ];
                    if sum(c)>2 c=[2/3 2/3 2/3];end
                    h=plot3(x,y,z,'x','color',c,'MarkerSize',fontsize2);
                else
                    h=plot(x,y,'x','color',c,'MarkerSize',fontsize2);
                end
            end
            if not(isempty(out3))
                if s.par.plotWordCountWords
                    h=text(x,y,z,index2word(s,fixchar2(out1.word{i})));
                    set(h,'fontsize',fontsize2,'color',c,'HorizontalAlignment','center');
                end
            else
                if s.par.plotWordCountWords
                    h=text(x,y,index2word(s,fixchar2(out1.word{i})));
                    set(h,'fontsize',fontsize2,'color',c,'HorizontalAlignment','center');
                end
                d=findEmptySpace(d,h);
                H=get(h);
                xSpread=H.Position(1);
                ySpread=H.Position(2);
                if s.par.plotWordPrintDots & s.par.plotWordCountWords
                    plot([x xSpread],[y ySpread],'--' ,'color',c)
                end
            end
        end
    end
end
d.Nc=length(out1.pcorrected);
d.titleWord='Keywords';

function [z1i z2i]=plotSignificantLines(s,d,out1,out2,out3,getScales)
if nargin<6;getScales=0;end
if not(isfield(d,'Nc')) d.Nc=length(out1.word); end;
%if not(isfield(d,'axisType2')) d.axisType2=d.axisType; end; %REMOVE
pcrit=[0.05/d.Nc s.par.keywordsPlotPvalue];%0.01 0.001
for i=1:length(pcrit)
    if not(strcmpi(out1.axisType,'z(p)'))
        if out1.plotwordCountCorrelation==0
            z1=chi2inv(1-pcrit(i),1);
        else
            %d.axisType='r';
            n=d.Nc;
            if n==0
                z1=0.05;
            else
                banana=@(coef)abs(2*tcdf(-abs(coef.*sqrt((n-2)./(1-coef.^2))),n-2)-pcrit(i))+(coef>1)*coef;
                z1= fminsearch(banana,.05);
            end
        end
    else %not sure if this is used
        z1=-norminv(pcrit(i));
    end
    z1i(i)=z1;
    
    if not(strcmpi(out2.axisType,'z(p)'))
        if out2.plotwordCountCorrelation==0
            z2=chi2inv(1-pcrit(i),1);
        else
            %d.axisType2='r';
            n=d.Nc;
            if n==0
                z2=0.05;
            else
                banana=@(coef)abs(2*tcdf(-abs(coef.*sqrt((n-2)./(1-coef.^2))),n-2)-pcrit(i))+(coef>1)*coef;
                z2 = fminsearch(banana,.05);
            end
        end
    else
        z2=-norminv(pcrit(i));
    end
    %z2=z1;%REMOVE
    z2i(i)=z2;
    if getScales
        try
            if not(isfield(out1,'clusterQ')) out1.clusterQ=[];end
            if not(isfield(out2,'clusterQ')) out2.clusterQ=[];end
            set(gca,'Xlim',[min([out1.z1 out1.clusterQ -z1i*1.2])*1.2 max([out1.z1 out1.clusterQ z1i*1.2])*1.2])
            set(gca,'Ylim',[min([out2.z1 out2.clusterQ -z1i*1.2])*1.2 max([out2.z1 out2.clusterQ z1i*1.2])*1.2])
        end
        return
    end
    if i==1
        ptext='Bonferroni';
    else
        ptext=num2str(pcrit(i));
    end
    h=text(-z1,0,[index2word(s,fixchar(ptext)) char(13) char(10) out1.axisType '=' sprintf('%.2f',z1)],'HorizontalAlignment','center','Color','k');
    if d.oneDimPlot
        h=text(z1,0,index2word(s,fixchar2(ptext)),'HorizontalAlignment','center','Color','k');
        col=.0;
        plot([-z1 -z1],[-.01 .01]*z1i(1),'Color', col*[1 1 1],'LineWidth',1)
        plot([+z1 +z1],[-.01 .01]*z1i(1),'Color', col*[1 1 1],'LineWidth',1)
    %elseif 0 %Plot oval
    %    h=ezplot(['(x)^2/' num2str(z1) '^2 +(y)^2/' num2str(z1) '^2=1'],[-z1 +z1 -z1 +z1]);
    %    set(h, 'Color', [.8 .8 .8],'LineWidth',1);
    else %Plot rectangel
        if pcrit(i)==.05
            c1=1;
        else
            c1=2;
        end
        if not(isempty(out3))
            for j=-z1:2*z1:z1
                line([-z1 -z1 ],[-c1*z1 c1*z1 ],[j j],'Color', [.8 .8 .8],'LineWidth',1)
                line([z1 z1 ],[-c1*z1 c1*z1 ],[j j],'Color', [.8 .8 .8],'LineWidth',1)
                line([-c1*z1 c1*z1 ],[-z1 -z1 ],[j j],'Color', [.8 .8 .8],'LineWidth',1)
                line([-c1*z1 c1*z1 ],[z1 z1 ],[j j],'Color', [.8 .8 .8],'LineWidth',1)
                
                line([j j],[-z1 -z1 ],[-c1*z1 c1*z1 ],'Color', [.8 .8 .8],'LineWidth',1)
                line([j j],[z1 z1 ],[-c1*z1 c1*z1 ],'Color', [.8 .8 .8],'LineWidth',1)
                line([j j],[-c1*z1 c1*z1 ],[-z1 -z1 ],'Color', [.8 .8 .8],'LineWidth',1)
                line([j j],[-c1*z1 c1*z1 ],[z1 z1 ],'Color', [.8 .8 .8],'LineWidth',1)
            end
        else
            line([-z1 -z1 ],[-c1*z2 c1*z2 ],'Color', [.8 .8 .8],'LineWidth',1)
            line([z1 z1 ],[-c1*z2 c1*z2 ],'Color', [.8 .8 .8],'LineWidth',1)
            line([-c1*z1 c1*z1 ],[-z2 -z2 ],'Color', [.8 .8 .8],'LineWidth',1)
            line([-c1*z1 c1*z1 ],[z2 z2 ],'Color', [.8 .8 .8],'LineWidth',1)
        end
        Xlim=get(gca,'Xlim');
        Ylim=get(gca,'Ylim');
        if z1==z2
            Ylim=max(abs(Ylim),abs(Xlim));Ylim(1)=Ylim(2);Xlim=Ylim;%Make it a square
        end
        if Xlim(2)<z1*c1
            set(gca,'Xlim',[-z1*1.2 z1*1.2])
        end
        if Ylim(2)<z2*c1
            set(gca,'Ylim',[-z2*1.2 z2*1.2])
        end
    end
end

%Plot arrows
fontsize=12;
if not(isempty(out3))
    c1=[1 0 0];c2=[0 1 0];c3=[0 0 1];
else
    c1=[.5 .5 .5];c2=[.5 .5 .5];c3=[.5 .5 .5];
end

%x-axis
a1=z1i(1)*2;
a2=z2i(1)*2;
if d.oneDimPlot a11=.005; else a11=.05;end
if not(isempty(out3))
    h=text(a1*0.5,0,0,index2word(s,[fixchar2(out1.label) ' (' out3.axisType ')']),'Rotation',0,'FontSize',fontsize,'Color',c1,'HorizontalAlignment','center');
else
    h=text(0,-a2*a11,index2word(s,[fixchar2(out1.label) ' (' out1.axisType ')']),'Rotation',0,'FontSize',fontsize,'Color',c1);%'HorizontalAlignment','center',
end
plot(a1*[0 0.5],a2*[0 0]   ,'Color', c1,'LineWidth',1)
plot(a1*[.4 .5],a2*[+a11 0],'Color', c1,'LineWidth',1)
plot(a1*[.4 .5],a2*[-a11 0],'Color', c1,'LineWidth',1)

%y-axis
if not(d.oneDimPlot) 
    if not(isempty(out3))
        h=text(0,a2*.5 ,0   ,index2word(s,[fixchar2(out2.label) ' (' out2.axisType ')']),'Rotation',90,'FontSize',fontsize,'Color',c2,'HorizontalAlignment','center');
    else
        h=text(-a1*0.1,0,index2word(s,[fixchar2(out2.label) ' (' out2.axisType ')']),'Rotation',90,'FontSize',fontsize,'Color',c2);%'HorizontalAlignment','center',
    end
    plot(a1*[0 0],a2*[0 .5]    ,'Color', c2,'LineWidth',1)
    plot(a1*[+.05 0],a2*[.4 .5],'Color', c2,'LineWidth',1)
    plot(a1*[-.05 0],a2*[.4 .5],'Color', c2,'LineWidth',1)
end

%z-axis
if not(isempty(out3))
    h=text( 0,0,a2*.5   ,index2word(s,[fixchar2(out3.label) ' (' out3.axisType ')']),'Rotation',90,'FontSize',fontsize,'Color',c3,'HorizontalAlignment','center');
    plot3([0 0],a2*[0 0],a2*[0 .5]    ,'Color', c3,'LineWidth',1)
    plot3([0 0],a2*[+.05 0],a2*[.4 .5],'Color', c3,'LineWidth',1)
    plot3([0 0],a2*[-.05 0],a2*[.4 .5],'Color', c3,'LineWidth',1)
    axis off
end



