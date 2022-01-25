function [out,h,s]=plotWordCloud(s,indexText,numbers,par,labels,userNames)
%persistent plotRemoveWords;
%YOUR_PASSWORD
out.init=[];
out.pSemanticScale='';
out.figureNote=sprintf('Figure note: ');
try
    if length(numbers)>0 & length(numbers{1})>0 & length(indexText)>0 & not(length(indexText)==length(numbers{1}))
        out.error=sprintf('\nERROR: The length of index (N=%d) MUST match the length numbers{1} (N=%d) PLEASE CORRECT!!!\n',length(indexText),length(numbers{1}));
        fprintf('%s',out.error)
        h=[];
        return
    end
end

%plotWordCloud(s,[],[],rand(1,10));%This plots numbers only
if nargin<5
    labels{1}='x-axis';
    labels{2}='y-axis';
    labels{3}='z-axis';
end
if length(labels)<2 labels{2}='';end
if length(labels)<3 labels{3}='';end

if nargin<6
    userNames=[];
end
d=[];

if 0
    %inputs:
    
    par.plotCloudType='words';%options words users category%Plot words, users, or categories
    par.plotWordcloud=1;%options 0 1%Plot as wordcloud (1) or as scale (0)
    par.plotCluster=0;%options 0 1%Cluster the plot
    par.plotWordcloudType='';%options high low shared both nominal%Type of word cloud plot
    par.plotProperty='_predvalence';%Property to plot
    par.plotTestType='semanticTest';%options semanticTest train frequency property%Choose how the semantic scale is calculated
    
    s.par.plotTestType='semanticTest';%'semanticTest''train''frequency'
    s.par.plotWordcloud=1;
    s.par.plotCluster=0;%0 1
    i=5;
    type={'high','low','shared','both','nominal'};
    s.par.plotWordcloudType=type{i};
    numbers{1}=[zeros(1,length(indexText)) ones(1,length(index2)) ];indexText=[indexText index2];
    %highLightWords(h,word)
end
plotNumericData=[];
if nargin<1 %Get user inputs
    %Load new space from harddrive
    s=getSpace;
    
    [id s]=getWordFromUser(s,'Choice words to plot');
    condition_string=s.par.condition_string;
    indexText=id.index;
    for i=1:3
        par{i}=s.par;
        numbers{i}=[];
    end
    if length(s.par.plotNumericData)>0
        plotNumericData=textscan(s.par.plotNumericData,'%s');
        plotNumericData=plotNumericData{1};
        [numbers{1},~,s]=getProperty(s,indexText,plotNumericData);
        indexText=[];xaxel.N=0;
    else
        if id.N==0; return;end
    end
    
    [xaxel s]=getWordFromUser(s,'Choice x-axel (escape = no x-axes!)','',[]);%,1
    Ndim=0;
    if xaxel.N>0
        Ndim=1;
        par{1}=s.par;
        par{1}.plotProperty=xaxel.index(1);
        labels{1}=xaxel.input_clean;
        [numbers{1},~,s]=getProperty(s,xaxel.index,indexText);
        [yaxel s]=getWordFromUser(s,'Choice y-axel (escape = no y-axes!)','_m*',[]);%,1
        if yaxel.N>0;
            Ndim=2;
            par{2}=s.par;
            par{2}.plotProperty=yaxel.index(1);
            labels{2}=yaxel.input_clean;
            [numbers{2},~,s]=getProperty(s,yaxel.index,indexText);
            [zaxel s]=getWordFromUser(s,'Choice z-axel (escape = no z-axes!)','_m*',[]);%,1
            if zaxel.N>0;
                Ndim=3;
                par{3}=s.par;
                par{3}.plotProperty=zaxel.index(1);
                labels{3}=zaxel.input_clean;
                [numbers{3},~,s]=getProperty(s,zaxel.index,indexText);
            end
        else
            par{2}.plotTestType='';
        end
    end
    s.par.condition_string=condition_string;

    d.plotDrawCross=s.par.plotDrawCross;
    h=figure;
    maxFigures=5; %Maximum number of figures
    if 0 & h.Number>maxFigures
        try;close(maxFigures);end
        h=figure;
    end
    
else %Used in excelServer
    
    if 0 & nargin<2 %Debugging only
        %Create random indexText, index2 and numbers - for DEBUGGING only
        words='mother mother mother mother children father XXdX ';
        %words=[words cell2string(s.fwords(1+fix(rand(1,5)*1000)))];
        [s newword indexText]=setProperty(s,{'_reference1','_reference2','_reference3'},{'_text','_text','_text'},{words,'sweden norway finland denmark germany','volvo fiat mercedes saab'});
        indexText=indexText(1:2);
        %[s newword indexText]=setProperty(s,{'_reference1','_reference2'},{'_text','_text'},{'mother','sweden'});
        %[s newword index]=setProperty(s,{'_reference1','_reference2'},{'_text','_text'},{'mamma pappa barn xyzq kids grandfather mother father father father father father child parents love ','car'});
        %[s newword index2]=setProperty(s,{'_reference3','_reference4'},{'_text','_text'},{'car highway highway wheels','motorway finland',''});
        
        %Show all fonts (debugging)
        fonts=listfonts;
        figure(1);
        for i=1:length(fonts)
            text(0,i/100-1,[num2str(i) fonts{i}],'fontname',fonts{i})
        end
    end
    
    if nargin<2
        indexText=[];
    end
    if nargin<3
        numbers={[],[],[]};
    end
        
    
    %s.par.optimzeDimensionsConservative=0;%Makes traning faster, less accurate?
    s.par.NleaveOuts=5;
    s.par.fixProblemWithSemanticTestWordClouds=1;%Forces words in wordclouds to be in the 'right' side for semanticTest
    s.par.plotRemoveCharacters=':/\';
    s.par.saveSemanticScale=0;
    if strcmpi(s.par.callfrom,'3W') & length(s.par.plotRemoveWords)==0
        %For 3W, remove these words        
        s.par.plotRemoveWords='test 1 2 3 fuck one two three http com ,';
    end
    if s.par.excelServer & isempty(s.par.callfrom)
        fprintf('Please set s.par.callfrom, forcing it to SE. In WD is MUST be set to WD!!\n')
    end
    if strcmpi(s.par.callfrom,'3W') | strcmpi(s.par.callfrom,'WD')
        %For WD and 3W plot ALL words
        s.par.keywordsPlotPvalue=1;
        s.par.plotBonferroni=0;
    end %Otherwise for SE use default settings to plot ONLY significant words with bonferroni correction
    
    %s.par.plotSignificantColors=6;%Colormap
    %s.par.Ncluster=4;
    %s.par.plotTitle=' ';
    
    resetRandomGenator(s,1);
    if isempty(s.par.plotFontname)
        fonts=listfonts;
        s.par.plotFontname=fonts{fix(length(listfonts)*rand)+1};%options listfonts%Fontname used in wordclouds
    end
    %plotColorMap=strread('parula jet hsv hot summer autumn winter spring cool','%s');%
    %s.par.plotColorMap=plotColorMap{fix(length(plotColorMap)*rand)+1};
    
    if nargin<4
        par{1}=s.par;par{2}=s.par;par{3}=s.par;
    end
    
    for i=1:3 %Set default values on par1-3
        if length(numbers)<i
            numbers{i}=[];
        end
        if length(par)<i
            par{i}=s.par;
        end
    end
    
    
    if isfield(s.par,'plotNumber') & s.par.plotNumber>0
        h=s.par.plotNumber;
    else
        h=5;
        %try;
        figure(h);
        close(h);
        %catch
        %    fprintf('Unable to close figure\n')
        %end
        %fprintf('Ok closing figure\n')
        h=figure(h);
    end
    if s.par.plotNetWorkAnalysis Ndim=0;
    elseif isempty(numbers{1}) & not(strcmpi(par{1}.plotTestType,'property')) Ndim=0;
    elseif isempty(numbers{2}) & not(strcmpi(par{2}.plotTestType,'property')) Ndim=1;
    elseif isempty(numbers{3}) & not(strcmpi(par{3}.plotTestType,'property')) Ndim=2;
    else Ndim=3;
    end
    
end
if not(isfield(s,'handles')) s.handles=getHandles;end

if sum(s.par.plotBackGroundColor==[.94 .94 .94])<3
    plot([-2 2],[0 0],'linewidth',1000,'color',s.par.plotBackGroundColor)
end

y=[];
if length(s.par.plotXlabel)>0 labels{1}=s.par.plotXlabel;end
if length(s.par.plotYlabel)>0 labels{2}=s.par.plotYlabel;end
if length(s.par.plotZlabel)>0 labels{3}=s.par.plotZlabel;end
labelsOrg=labels;

%out.i.index1=indexText;
if strcmpi(s.par.plotCloudType,'predictions')
    plotPredictions(s,indexText,userNames);
    return
elseif (isempty(indexText) & length(numbers{1})>0) | strcmpi(s.par.plotCloudType,'histogram')
    [out,h,s]=plotNumerical(s,numbers,par,labels,userNames,h,plotNumericData,out)
    return
end

text2indexIgnore=s.par.text2indexIgnore;
if strcmpi(s.par.plotCloudType,'users')
    s.par.text2indexIgnore=1;
end
par{1}.text2indexIgnore=s.par.text2indexIgnore;
par{2}.text2indexIgnore=s.par.text2indexIgnore;
par{3}.text2indexIgnore=s.par.text2indexIgnore;

if ischar(s.par.plotNominalLabels)
    s.par.plotNominalLabels=strread(s.par.plotNominalLabels,'%s')';
end

[s,out f1 indexW1 word1 indexW1All]=mkfreq2(s,out,indexText);
try
    if s.par.plotRemoveNoneWords
        a=[];
        for i=1:size(out.fByIndex,1)
            if isnan(nanmean(s.x(find(out.fByIndex(i,:)>0),1)))
                a =[a ;string2cell(getText(s,indexText(i)))];
            end
        end
        tmp=cell2string(unique(a));
        if length(tmp)>0
            out.figureNote=[out.figureNote sprintf('These words were removed from the plot: "%s". ',tmp)];
        end
        s.par.plotRemoveWords=[s.par.plotRemoveWords ' ' tmp];
        %Remove duplicates
        [~, tmp]=text2index(s,s.par.plotRemoveWords);
        s.par.plotRemoveWords=cell2string(unique(tmp));
    end
end


out.word=word1;
d.plotSignificantLines=not(par{1}.plotWordcloud);
s.par.plotScale2=1;

if strcmpi(s.par.plotWordcloudType,'nominal')
    data{1}.f=f1;
    data{1}.word=word1;
    data{1}.z=zeros(1,length(f1));
    data{1}.zOrg=NaN(1,length(f1));
    data{1}.p=NaN(1,length(f1));
    data{2}=data{1};data{3}=data{1};
    fontsize=(data{1}.f.^.5);
    figure(h);
    
    
    %Nominal data
    y=numbers{1};
    N=length(unique(y(not(isnan(y)))));
    %Maka a maxium number of categories to 8
    %maxN=8;
    %if 0 &  N>maxN
    %    fprintf('Diminishing the number of categories from %d to %d\n',N,maxN)
    %    [dist crit]=hist(y,maxN-1);
    %    crit=[-1e20 crit +1e20];
    %    for i=1:length(crit)-1
    %        indexCrit=find(y>crit(i) & y<=crit(i+1));
    %        y(indexCrit)=nanmean(y(indexCrit));
    %        yrange(1,i)=nanmin(y(indexCrit));
    %        yrange(2,i)=nanmax(y(indexCrit));
    %    end
    %end
    
    yUnique=unique(y(not(isnan(y))));
    N=length(yUnique);
    wordNominal=[];pNominal=[];fNominal=[];xNominal=[];yNominal=[];zNominal=[];group=[];zOrgUser=[];
    
    for i=1:N
        if isnan(yUnique(i))
            index=isnan(y);
        else
            index=y==yUnique(i);
        end
        
        if 0 %Plot on a circle
            angle=2*pi*i/N-pi/2;
            xCluster(i)=sin(angle);
            yCluster(i)=cos(angle);
            yCluster(abs(yCluster)<1e-13)=0;%Correct for errors in machine memory precision
        elseif N<=4 %Plot on a row
            xCluster(i)=i-(N+1)/2;
            yCluster(i)=0;
            d.setLimits=[-(N+1)/2 N+1-(N+1)/2+.5     -1.5 2 -1 1];
        else %Plot on two rows
            d.setLimits=[-(N+1)/4 (N/2+1)-(N+1)/4+.5 -1.5 2 -1 1];
            if i<=N/2
                xCluster(i)=i-(N+1)/4;
                yCluster(i)=+1;
            else
                xCluster(i)=i-N/2-(N+1)/4;
                yCluster(i)=-1;
            end
        end
        zCluster(i)=0;
        pCluster(i)=0;
        
        if not(isfield(s.par,'plotNominalLabels'))
            for j=1:N;s.par.plotNominalLabels{j}=num2str(yUnique(j));end;
        end
        
        try
            text2=[s.par.plotNominalLabels{yUnique(i)} ' (' num2str(round(length(find(yUnique(i)==y))/length(y)*100)) '%)'];
            cCluster(i)=text(xCluster(i),yCluster(i)+.7,text2,'HorizontalAlignment','center','Color','k','fontsize',20,'FontWeight','Bold');
            if cCluster(i).Extent(3)>.30 | 0
                set(cCluster(i),'fontsize',min(20,.30/cCluster(i).Extent(3)*20));
            end
        catch
            fprintf('Error: y=%.2f must be a positive integer with a lenght macthing s.par.plotNominalLabels\n',yUnique(i))
        end
        [dataNominal s]=getData(s,out,indexText,index,par{1});
        
        d.plotSignificantLines=0;
        s.par.plotSignificantColors=3;
        
        if isfield(dataNominal,'f1isLargerThanf2Ratio')
            fR=dataNominal.f1isLargerThanf2Ratio;
        else
            fR=dataNominal.z>0;
        end
        wordNominal=[wordNominal dataNominal.word(fR)];
        
        %Remove categories with many words (i.e. plotWordcountMaxNumber/N(categories))
        Nmax=2*fix(s.par.plotWordcountMaxNumber/length(yUnique));
        if length(find(fR))>Nmax
            tmp=find(fR);
            [~, indexSort]=sort(dataNominal.p(fR));
            dataNominal.p(tmp(indexSort(Nmax+1:end)))=2;%Do not plot
            if isempty(findstr(out.figureNote,'The number of words per category has been limited '))
                out.figureNote=[out.figureNote sprintf('The number of words per category has been limited to %d. ', Nmax)];
            end
        end
        
        pNominal=[pNominal dataNominal.p(fR)];
        fNominal=[fNominal dataNominal.f(fR)];
        xNominal=[xNominal ones(1,length(dataNominal.p(fR)))*xCluster(i)];
        yNominal=[yNominal ones(1,length(dataNominal.p(fR)))*yCluster(i)];
        zNominal=[zNominal ones(1,length(dataNominal.p(fR)))*zCluster(i)];
        zOrgUser(i)=dataNominal.zOrgUser;
        group=[group ones(1,length(dataNominal.p(fR)))*i];
    end
    %This makes the fontsize smaller for many categories!
    s.par.plotScale2=s.par.plotScale2*10/(N+9);
    d=wordCloud(s,d,wordNominal,pNominal,fNominal.^.5,[],xNominal,yNominal,zNominal,labels,par,[],group);
    
    %Underline matching user!
    if not(isnan(nanmean(zOrgUser))) & isfield(s.par,'userIndex') & not(isempty(s.par.userIndex))
        [~,zOrgUserMax]=max(zOrgUser);
        line([cCluster(zOrgUserMax).Extent(1) cCluster(zOrgUserMax).Extent(1)+cCluster(zOrgUserMax).Extent(3)],cCluster(zOrgUserMax).Extent(4)*.1+[cCluster(zOrgUserMax).Extent(2) cCluster(zOrgUserMax).Extent(2)],'color','r','linewidth',4)
    end
    
else
    %Not nominal
    [data{1} s]=getData(s,out,indexText,numbers{1},par{1});
    par{1}.scale=data{1}.scale;
    fontsize=(data{1}.f.^.5);
    figure(h);
    
    if strcmpi(s.par.plotCloudType,'users')
        if strcmpi(s.par.plotCloudType,'users') & length(userNames)>0
            data{1}.word=userNames;
        end
    end
    
    if Ndim>=2
        [data{2} s]=getData(s,out,indexText,numbers{2},par{2});
        par{2}.scale=data{2}.scale;
        figure(h);
    else
        data{2}.z=zeros(1,length(data{1}.z));
        data{2}.zOrg=NaN(1,length(data{1}.z));
        data{2}.p=NaN(1,length(data{1}.z));
        data{2}.scale='';
    end
    
    if Ndim>=3
        [data{3} s]=getData(s,out,indexText,numbers{3},par{3});
        par{3}.scale=data{3}.scale;
        figure(h);
    else
        data{3}.z=zeros(1,length(data{1}.z));
        data{3}.zOrg=NaN(1,length(data{1}.z));
        data{3}.p=NaN(1,length(data{1}.z));
        data{3}.scale='';
    end
    
    %Do for cluster
    if not(strcmpi(s.par.plotCloudType,'category')) & s.par.plotCluster
        %Cluster
        if Ndim==0 %Plot all words if no dimensions!
            data{1}.p=data{1}.p*0;
        end
        if strcmpi(s.par.plotCloudType,'users')
            [s dataC]=clusterSpace(s,indexText,[],[],out);
            y=dataC.y(1:length(indexText));
        else
            [s,out2]=mkfreq2(s,out,indexW1);
            [s dataC]=clusterSpace(s,indexW1,[],[],out2);
            y=dataC.y(1:length(data{1}.z));
        end
        %Take care of NaN dataC
        indexNaN= find(isnan(data{1}.z));
        for i=1:length(indexNaN)
            data{1}.z(indexNaN(i))=nanmean(data{1}.z(y(indexNaN(i))==y));
            data{1}.p(indexNaN(i))=nanmedian(data{1}.p(y(indexNaN(i))==y));
            data{2}.z(indexNaN(i))=nanmean(data{2}.z(y(indexNaN(i))==y));
            data{2}.p(indexNaN(i))=nanmedian(data{2}.p(y(indexNaN(i))==y));
            data{3}.z(indexNaN(i))=nanmean(data{3}.z(y(indexNaN(i))==y));
            data{3}.p(indexNaN(i))=nanmedian(data{3}.p(y(indexNaN(i))==y));
        end
        data{1}.zTmp=NaN*data{1}.z;
        data{2}.zTmp=NaN*data{2}.z;
        data{3}.zTmp=NaN*data{3}.z;
        zCluster=[];
        pCluster=[];
        
        yUnique=unique(y(not(isnan(y))));
        N=length(yUnique);
        
        
        for i=1:N
            if isnan(yUnique(i))
                index=isnan(y);
            else
                index=y==yUnique(i);
            end
            if Ndim>0 &  length(find(not(index)))>1
                %Get x and y cordinates from data{1} and data{2}
                if length(find(index))>1 %For more than one dataC point, use ttest2
                    [~, pCluster(i) ]=ttest2(data{1}.zOrg(index),data{1}.zOrg(not(index)));
                    [~, pClusterY(i)]=ttest2(data{2}.zOrg(index),data{2}.zOrg(not(index)));
                    [~, pClusterZ(i)]=ttest2(data{3}.zOrg(index),data{3}.zOrg(not(index)));
                else  %If only one dataC point, use ttest
                    [~, pCluster(i) ]=ttest(data{1}.zOrg(not(index)),data{1}.zOrg(index));
                    [~, pClusterY(i)]=ttest(data{2}.zOrg(not(index)),data{2}.zOrg(index));
                    [~, pClusterZ(i)]=ttest(data{3}.zOrg(not(index)),data{3}.zOrg(index));
                end
                data{1}.p(index)=pCluster(i);
                data{2}.p(index)=pClusterY(i);
                data{3}.p(index)=pClusterZ(i);
                s.par.plotBonferroniN=N;
                
                
                %Plot clustermeans on values for x,y, and z
                data{1}.zTmp(index)=nanmean(data{1}.zOrg(index));%data{1}.zOrg ignores the binary value data{1}.z for worcloud=1;
                data{2}.zTmp(index)=nanmean(data{2}.zOrg(index));
                data{3}.zTmp(index)=nanmean(data{3}.zOrg(index));
                
            else
                %Get x and y cordinates from clusters only
                pCluster(i)=NaN;
                
                if N<=4 %Plot on a row
                    xCluster(i)=i-(N+1)/2;
                    yCluster(i)=0;
                    d.setLimits=[-(N+1)/2 N+1-(N+1)/2+.5     -1.5 2 -1 1];
                else %Plot on two rows
                    d.setLimits=[-(N+1)/4 (N/2+1)-(N+1)/4+.5 -1.5 2 -1 1];
                    if i<=N/2
                        xCluster(i)=i-(N+1)/4;
                        yCluster(i)=+1;
                    else
                        xCluster(i)=i-N/2-(N+1)/4;
                        yCluster(i)=-1;
                    end
                end
                
                data{1}.zTmp(index)=xCluster(i);
                data{2}.zTmp(index)=yCluster(i);
                data{3}.zTmp(index)=0;
            end
            fontsizeCluster(i)=12;
            
            
            %data{1}.zTmp(index)=xCluster(i);%+0*data{1}.z(index);
            %data{2}.zTmp(index)=yCluster(i);%+0*data{2}.z(index);
            %data{3}.zTmp(index)=zCluster(i);%+0*data{3}.z(index);
            
        end
        s.par.plotSignificantColors=3;
        
        
        d.pCluster=pCluster;
        if isempty(numbers{3})
            zCluster=0*zCluster;
            data{3}.zTmp=0*data{3}.zTmp;
        end
        
        data{1}.z=data{1}.zTmp;
        data{2}.z=data{2}.zTmp;
        data{3}.z=data{3}.zTmp;
        if length(fontsize)>length(data{1}.z)
            fontsize=fontsize(1:length(data{1}.z));
        end
        
    end
    
    
    
    if s.par.plotCluster
    elseif isfield(data{1},'f1isLargerThanf2Ratio')
        y=data{1}.f1isLargerThanf2Ratio+1;
    end
    if length(numbers{1})>0
        d.df=length(numbers{1});
    elseif length(numbers{2})>0
        d.df=length(numbers{3});
    elseif length(numbers{3})>0
        d.df=length(numbers{3});
    end
    try
        for i=1:length(data)
            if isfield(data{i},'semanticTest')
                labels{i}=[labels{i} sprintf('\n[r=%.2f,p=%0.4f]',data{i}.semanticTest.r,data{i}.semanticTest.p)];
            elseif isfield(data{i},'r') & length(data{i}.r)==1
                if isfield(data{i},'pTrain')
                    labels{i}=[labels{i} sprintf('\n[r=%.2f,p=%0.4f]',data{i}.r,data{i}.pTrain)];
                else
                    labels{i}=[labels{i} sprintf('\n[r=%.2f]',data{i}.r)];
                end
            end
        end
    catch
        fprintf('Error in plotWordCloud line 559\n')
    end
    if s.par.plotSignificantColors==8
        s.par.plotSignificantColors=3;
        if strcmpi(s.par.plotCloudType,'users')
            [s dataC]=clusterSpace(s,indexText,[],[],out);
            y=dataC.y(1:length(indexText));
        else
            [s dataC]=clusterSpace(s,indexW1,[],[],out);
            y=dataC.y(1:length(data{1}.z));
        end
    end
    plotNetworkModel=s.par.plotNetworkModel;
    if ischar(plotNetworkModel) plotNetworkModel=string2cell(plotNetworkModel)';end
    if strcmpi(s.par.plotColorCodesFor,'value')
        data{1}.p=data{1}.zOrg;
    end
    if s.par.plotOnCircle & Ndim==0 %& length(data{1}.z)<30
        [~,IndexSortColor]=sort(data{1}.p);
        Nadd=length(plotNetworkModel);
        i2=2*pi*(Nadd:length(data{1}.z)-1+Nadd);
        data{1}.z(IndexSortColor)=sin(i2/(length(data{1}.z)+Nadd));
        data{2}.z(IndexSortColor)=cos(i2/(length(data{1}.z)+Nadd));
    end
    show=ones(1,length(data{1}.p));
    d=wordCloud(s,d,data{1}.word,nanmin([data{1}.p; data{2}.p; data{3}.p]),fontsize,show,plotAxis(data{1},par{1}),plotAxis(data{2},par{2}),plotAxis(data{3},par{3}),labels,par,nanmax(abs([data{1}.zOrg; data{2}.zOrg; data{3}.zOrg])),y);
    if s.par.plotDrawLinesBetweenSimilarConcepts | s.par.plotNetWorkAnalysis
        hold on;
        
        %Plot the predictions models on a circle!
        for i=0:length(plotNetworkModel)-1
            i2=2*pi*i/(length(d.word)+length(plotNetworkModel));
            if 1
                d.skipLimits=1;
                pModel=normcdf(nanmean(norminv(data{1}.p)));%Remap to z-values, then take mean, map back to p-value
                d=wordCloud(s,d,plotNetworkModel,pModel,mean(fontsize),1,sin(i2),cos(i2),0,labels,par,nanmax(abs([data{1}.zOrg; data{2}.zOrg; data{3}.zOrg])),y);
                Ylim=ylim;
                set(gca,'Ylim',[Ylim(1) 1.2] );
                %else
                %    d.h(length(d.h)+1)=text(sin(i2),cos(i2),regexprep(plotNetworkModel{i+1},'_',''),'fontsize',get(d.h(1),'fontsize'),'HorizontalAlignment','center','fontname',s.par.plotFontname);
            end
        end
        index=word2index(s,[d.word plotNetworkModel]);
        if s.par.plotNetWorkAnalysis;
            if isnan(word2index(s,plotNetworkModel(1)))
                %This could be made faster by including this in an earlier
                %call to getSfromDB!!!
                s=getSfromDB(s,s.languagefile,s.filename,plotNetworkModel(1),[],'merge');
                index=word2index(s,[d.word plotNetworkModel]);
            end
            iNA=word2index(s,plotNetworkModel{1});
            if s.info{iNA}.specialword==13
                SS=s.x(index,:).*repmat(s.x(iNA,:),length(index),1);
            elseif not(isfield(s.info{iNA},'model')) | not(isfield(s.info{iNA}.model,'xTrain'))
                out.error=sprintf('Could not calculated network analysis, please update model: %s\n',plotNetworkModel{1});
                sprintf('%s',out.error);
                SS=NaN(length(index),1);
            else
                SS=s.x(index,:)*s.info{iNA}.model.xTrain';
            end
        end
        semSim=[];
        for i=1:length(index)
            if s.par.plotNetWorkAnalysis
                for i1=i+1:length(index)
                    [semSim(i,i1) p(i,i1)]=corr(SS(i,:)',SS(i1,:)');
                    semSim2(i,i1)=semSim(i,i1);
                    semSim2(i1,i)=semSim(i,i1);
                    semSim2(i,i)=1;
                end
            else
                indexTmp=i1+1:length(index);
                [semSim(i,indexTmp),~,s]=getProperty(s,index(i),index(indexTmp));
                %indexSimilar{i}=find(semSim(i,:)>.4 & not(i>1:length(index)));
            end
        end
        
        if s.par.plotNetWorkCovariates %Remove covariates
            semSim2(length(index),length(index))=1;
            
            for i=1:length(index)
                for j=i+1:length(index);
                    tmp=covariance(semSim2,find(not(1:length(index)==i | 1:length(index)==j)));
                    semSim3(i,j)=tmp(i,j);
                    p(i,j)=pvalPearson(semSim3(i,j), size(SS,2));
                end
            end
            semSim=semSim3;
        end
        
        
        %Limit connect lines to maxLine2print
        a=sort(abs(reshape(semSim,1,size(semSim,1)*size(semSim,2))),'descend');
        a=a(find(a>0 & not(isnan(a))));
        if length(a)==0
            crit=NaN;
        else
            crit=a(min(length(a),s.par.plotNetworkMaxLine2print));
        end
        
        %Print legend for correlation (r)
        j=-.2;
        for i=min(min(semSim)):max(a)/3:max(a) %crit:(max(a)-crit)/3:max(a)
            h=text(1.23,j,sprintf('r=%+.2f',i));%d.xscale2(2)*.2
            %if i<0 col=[0 0 1]; else col=[.9 .8 0];end
            if i<0 col=[0 1 0]; else col=[1 0 0];end
            plot([h.Extent(1)+h.Extent(3)*1.2 h.Extent(1)+h.Extent(3)*2],[j j],'linewidth',max(.0001,abs(i*15)),'color',col);
            j=j+h.Extent(4)*1.5;
        end
        
        %Print network arrows between words
        for i=1:length(index)-1
            indexSimilar{i}=find(abs(semSim(i,:))>=crit & not(i>1:length(index)));
            pos1=get(d.h(i),'position');
            yDiff=-.07;
            for j=1:length(indexSimilar{i})
                pos2=get(d.h(indexSimilar{i}(j)),'position');
                %plot(pos1(1),pos1(2),'x','Linewidth',10)
                %plot((d.Extent(j,1)+d.Extent(j,3))/2,(d.Extent(j,2)+d.Extent(j,4))/2,'x','Linewidth',10)
                colSign=semSim(i,indexSimilar{i}(j));
                %if colSign<0 col=[0 0 1]; else col=[.9 .8 0];end
                if colSign<0 col=[0 1 0]; else col=[1 0 0];end
                if abs(colSign)>0 & p(i,j)<.05/((length(index)^2-length(index))/2);
                    plot([pos1(1) pos2(1)],[pos1(2)+yDiff pos2(2)+yDiff],'linewidth',abs(colSign)*15,'color',col)
                end
            end
        end
        
        %Print '*' by each connected line
        for i=1:min(length(d.h),length(index))
            pos1=get(d.h(i),'position');
            plot(pos1(1),pos1(2)+yDiff,'o','Linewidth',5,'Color',[0 0 0 ])
            text(pos1(1),pos1(2),get(d.h(i),'String'),'color',get(d.h(i),'Color'),'HorizontalAlignment','center','fontname',s.par.plotFontname,'fontsize',get(d.h(i),'fontsize'))
        end
    end
end

try
    if length(data{1}.pSemanticScale)>0
        out.pSemanticScale=sprintf('p(x)=%.4f',data{1}.pSemanticScale);
        if Ndim>1
            out.pSemanticScale=[out.pSemanticScale sprintf(', p(y)=%.4f',data{2}.pSemanticScale)];
            if Ndim>2
                out.pSemanticScale=[out.pSemanticScale sprintf(', p(z)=%.4f',data{3}.pSemanticScale)];
            end
        end
    end
end
%end

out.Nc=length(word1);
if not(isfield(out,'h')) out.h=[];end
out.h=[out.h get(gcf,'number')];
s.par.text2indexIgnore=text2indexIgnore;
try
    if isfield(out,'error')
        out.figureNote=[out.figureNote out.error];
    end
    out.figureNote=[out.figureNote getFigureNotes(s,Ndim,d,data,labels)];
    dataText=[];
    for i=1:length(indexText)
        if i==1
            dataText=[dataText sprintf('words\t')];
            for j=1:Ndim
                dataText=[dataText sprintf('%s\t',labels{j})];
            end
            dataText=[dataText(1:end-1) sprintf('\n')];
        end
        
        dataText=[dataText sprintf('%s\t',getText(s,indexText(i)))];
        if Ndim>=1 & length(numbers{1})>=i
            dataText=[dataText sprintf('%.4f\t',numbers{1}(i))];
        end
        if Ndim>=2 & length(numbers{2})>=i
            dataText=[dataText sprintf('%.4f\t',numbers{2}(i))];
        end
        if Ndim>=3 & length(numbers{3})>=i
            dataText=[dataText sprintf('%.4f\t',numbers{3}(i))];
        end
        dataText=[dataText(1:end-1) sprintf('\n')];
    end
    out.dataText=dataText;
    out.dataTabel=sprintf('word\t%s\tclass\t',data{1}.scale);
    out.dataTabel=[out.dataTabel sprintf('x[%s]\tp(x)\t',data{1}.scale)];
    if Ndim>=2
        out.dataTabel=[out.dataTabel sprintf('y[%s]\tp(y)\t',data{2}.scale)];
    end
    if Ndim>=3
        out.dataTabel=[out.dataTabel sprintf('z[%s]\tp(z)\t',data{3}.scale)];
    end
    out.dataTabel=[out.dataTabel sprintf('\n')];
    
    [~,indexSort]=sort(data{1}.f,'descend');
    if length(y)<length(data{1}.word);y=NaN(1,length(data{1}.word));end
    for j=1:length(data{1}.f)
        i=indexSort(j);
        out.dataTabel=[out.dataTabel sprintf('%s\t%.4f\t%d\t',data{1}.word{i},full(data{1}.f(i)),y(i))];
        out.dataTabel=[out.dataTabel sprintf('%.4f\t%.4f\t',full(data{1}.z(i)),full(data{1}.p(i)))];
        if Ndim>=2
            out.dataTabel=[out.dataTabel sprintf('%.4f\t%.4f\t',data{2}.z(i),full(data{2}.p(i)))];
        end
        if Ndim>=3
            out.dataTabel=[out.dataTabel sprintf('%.4f\t%.4f\t',data{3}.z(i),full(data{3}.p(i)))];
        end
        out.dataTabel=[out.dataTabel sprintf('\n')];
    end
    %     if length(s.par.plotSaveFolder)>0
    %         try;
    %             f=fopen([d.file '.txt'],'w');
    %             fprintf(f,'%s\n\n%s\n\n',data{1}.results);
    %             fprintf(f,'%s\n\n%s\n\n',out.dataTabel);
    %         end
    %         fclose(f);
    %     end
    if not(s.par.excelServer)
        fprintf('\n%s\n',out.dataTabel)
        fprintf('%s\n',out.figureNote)
    end
catch err
    fprintf('\nError generating figur notes!\n');
    try
        save('MatlabErrorFigureNote')
        out.figureNote=['Error generating figure notes: ' out.figureNote];
    end
end
if s.par.plotAutoSaveFigure
    if not(exist('figure','dir')) mkdir('figure');end
    labels2='';for i=1:Ndim;labels2=[labels2 labelsOrg{i}];end
    if strcmpi(s.par.plotCloudType,'category')
        plotCategory=s.par.plotCategory;
    else
        plotCategory='';
    end
    
    figFile=['figure/Figure ' s.par.variableToCreateSemanticRepresentationFrom '-' s.par.plotTestType '-' labels2 '-' s.par.plotCloudType plotCategory s.par.condition_string];
    if s.par.plotWordcloud
        figFile=[figFile '-Cloud'];
    else
        figFile=[figFile '-Scale'];
    end
    if s.par.plotCluster
        figFile=[figFile '-Cluster=' num2str(s.par.Ncluster)];
    end
    saveas(h.Number,figFile, 'fig');
    hgx(h.Number,'',[figFile '.png']);
    fprintf('%s\n',out.figureNote);
    f=fopen([figFile '.txt'],'w');
    fprintf(f,'%s\n',out.figureNote);
    fprintf(f,'\n%s',out.dataTabel);
    fprintf(f,'%s\n\n%s\n\n',data{1}.results);
    fclose(f);
end
if not(s.par.excelServer)
    showOutput({regexprep(out.figureNote,'\.',['\.' char(13) ])},['Plot'])
end


function scale=plotAxis(data,par)
if  strcmpi(par.plotAxis,'default')
    scale=data.z;
elseif strcmpi(par.plotAxis,'1-p') & isfield(data,'p')
    scale=1-data.p;
elseif not(isfield(data,par.plotAxis))
    fprint('Warning: Can not set plotAxis to %s\n',par.plotAxis);
else
    try
        scale=eval(['data.' par.plotAxis]);
    end
end


function text=getFigureNotes(s,Ndim,d,data,labels);
%Writing an explantory text
text='';
if length(s.par.variableToCreateSemanticRepresentationFrom)>0
    text=[text sprintf('The figure is based on the text variable called %s. ',regexprep(s.par.variableToCreateSemanticRepresentationFrom,'_',''))];
end

if s.par.plotCluster %Cluster of keywords
    text=[text sprintf('The figure shows semantic themes generated by a clustering the semantic representation. ')];
end

if Ndim>0
    text=[text sprintf('The figure represents %d dimension(s). ',Ndim)];
end

if s.par.plotWordcloud
    text=[text sprintf('The data is arranged in word cloud(s). ')];
else
    text=[text sprintf('The data is arranged along (a) scale(s). ')];
end

if s.par.keywordsPlotPvalue==1
    correctionType='Non-signfanct words are displayed';
elseif s.par.plotBonferroni==1
    correctionType='Bonferroni correction for multiple comparisons';
elseif s.par.plotBonferroni==2
    correctionType='Holm''s correction for multiple comparisons';
else
    correctionType='Uncorrected p-values';
end

if Ndim==0
    text=[text sprintf('The data is compared to the frequency of how words are generally used in the corpus that the ''%s'' space is created from (e.g., Google N-gram dataset, where we used the five grams, see http://ngrams.googlelabs.com).',regexprep(s.languagefile,'space',''))];
    %if not(s.par.excelServer)
    %    text=[text sprintf(' using Google N-gram dataset, where we used the five grams (see http://ngrams.googlelabs.com). ')];
    %else
    %    text=[text sprintf('. ')];
    %end
elseif Ndim>0
    text=[text sprintf('The figure shows color-coded data-points that significantly discriminate between the text data associated to the low and the high values of the scale. ')];
    if s.par.plotWordcloud
    elseif Ndim==1
        text=[text sprintf('The areas outside of the inner grey lines represents significant differences without correction for multiple comparisons (p=%.4f) and the areas outside of the outer grey lines represent significant values following %s. ', s.par.keywordsPlotPvalue,correctionType)];
    elseif Ndim>1
        text=[text sprintf('The area outside of the inner grey box represents significant differences without correction for multiple comparions (p=%.4f) and the area outside of the greater grey box represents significant values following %s. ',s.par.keywordsPlotPvalue,correctionType)];
    end
end

if strcmpi(s.par.plotCloudType,'words')
    text=[text sprintf('The figure shows words. ')];
elseif strcmpi(s.par.plotCloudType,'users')
    text=[text sprintf('The figure show participants. ')];
elseif strcmpi(s.par.plotCloudType,'category')
    text=[text sprintf('The figure shows category %s. ',s.par.plotCategory)];
end


text=[text sprintf('Words in color were significant following %s, and non-significant are shown in grey. ',correctionType)];



if s.par.plotRemoveHFWords>0
    text=[text sprintf('Word with a natural word frequency (based on Google N-gram) higher than %.6f is not plotted (i.e. these words are typically function words that do not carry meaning). ',s.par.plotRemoveHFWords)];
end

if d.Nploted==s.par.plotWordcountMaxNumber
    text=[text sprintf('The number of plotted words has been limited to %d. ',s.par.plotWordcountMaxNumber)];
end
text=[text sprintf('The font size represents the frequency of the words in the data. ')];
if Ndim==0
    text=[text getXinfo(s,data{1},sprintf(''))];
else
    if Ndim>=1
        text=[text getXinfo(s,data{1},sprintf('The x-axis represents a variable called %s. ',labels{1}))];
    end
    if Ndim>=2
        text=[text getXinfo(s,data{2},sprintf('The y-axis represents a variable called %s. ',labels{2}))];
    end
    if Ndim>=3
        text=[text getXinfo(s,data{3},sprintf('The z-axis represents a variable called %s. ',labels{3}))];
    end
end
if Ndim>1
    [r,p]=corr(data{1}.z',data{2}.z');
    text=[text sprintf('The value on the x and the y axis correlates r=%.3f, p=%.4f. ',r,p) ];
    if Ndim>2
        [r,p]=corr(data{1}.z',data{3}.z');
        text=[text sprintf('The value on the x and the z axis correlates r=%.3f, p=%.4f. ',r,p) ];
        [r,p]=corr(data{2}.z',data{3}.z');
        text=[text sprintf('The value on the y and the z axis correlates r=%.3f, p=%.4f. ',r,p) ];
    end
end

function  text=getXinfo(s,data,title)
if (length(data.z)==0 | nanstd(data.p)==0 | isnan(nanmean(data.z))) & nargin<4
    text='';
else
    text=sprintf('%s This axis consists of %d significant data points after Bonferroni correction for multiple comparisons (%d data points are significant without correction for multiple-comparisons of a total of %d unique words). ',title,sum(data.p<=s.par.keywordsPlotPvalue/length(data.p)),sum(data.p<=s.par.keywordsPlotPvalue),length(data.p));
    if strcmpi(data.par.plotTestType,'semanticTest')
        text=[text sprintf('Significance testing was made on the semantic similarity scores using semantic t-tests on a word-by-word level, i.e., one t-test was carried out for each of the unique words. ')];
        %if 1 | not(s.par.excelServer)
        text=[text sprintf(['The semantic t-test is carried out in three steps (for details, see Arvidsson, Sikstr' char(246) 'm, & Werbart 2011). (1) First all the semantic representations for the two text data sets were summarized separately (if an interval scale rather than two groups are analysed, median split is employed to form two groups). Then one of the semantic representations were subtracted from the other representation to create a semantic comparison representation. '])];
        text=[text sprintf(['(2) Then the semantic similarities between the semantic comparison representation and each of the semantic representations of the words from the two text data sets were computed. '])];
        text=[text sprintf('To avoid biasing the results, the leave-N-out cross-validation procedure was employed, so that %.0f percent of the data points were left out while creating the semantic comparison representation in step one, and were these data points are evaluated in step two. Step one and two were then repeated until semantic similarities to the semantic comparison representation has been computed for all individual words. ',100/s.par.NleaveOuts)];
        text=[text sprintf('(3) In the last step, t-tests compare the semantic similarity scores from Step 2 of each unique word with all other words. The results give both p-values and z-values that indicate whether each individual word significantly differ in meaning from the compared set of text. ')];
        text=[text sprintf('For words that only occurs once, we t-test whether value on the word differs from the mean value of all other words. For words that do not have a semantic representation, chi-square tests for independencies are made for each word separately. ')];
        if data.semanticTest.p<.05
            text=[text sprintf('The semantic t-test between the two sets of texts was significant (t(%d)=%.2f, p=%.4f). ',data.semanticTest.df,data.semanticTest.t,data.semanticTest.p)];
        else
            text=[text sprintf('The semantic t-test between the two sets of texts was not significant, so the figure results should be interpretated with care.')];
        end
        %end
    elseif strcmpi(data.par.plotTestType,'frequency')
        text=[text sprintf('Significance testing was made by chi-square tests based on word frequency. ')];
    elseif strcmpi(data.par.plotTestType,'train')
        if s.par.excelServer
            tmp='';
        else
            tmp=[' (for details, see Kjell, Kjell, Garcia, & Sikstr' char(246) 'm, 2018)'];
        end
        text=[text sprintf(['Predictions on the are made by multiple linear regression' tmp '. Significance testing are made by Pearson correlation to a numeric variable using an N-leave-out-cross validation procedure. '])];
        try
            if data.train.p<.05
                text=[text sprintf('The correlation was significant (r(%d)=%.2f, p=%.4f). ',length(data.train.w.pred)-1,data.train.w.r,data.train.w.pTrain)];
            else
                text=[text sprintf('The correlation was not significant, the figure results should be taken with care.')];
            end
        end
    else
        text=[text sprintf('Significance testing are made by Pearson correlation to a numeric variable. ')];
    end
    if isfield(data,'df')
        text=[text sprintf(' (df=%d)',data.df)];
    end
end


%return
% if figureType==1 %Keywords
%     text=[text sprintf('The figure shows words where the frequencies of occurrence are significant overrepresented in the high, or low end of the scale. ',0.05/d.Nc, s.par.keywordsPlotPvalue)];
%     if figureType==2 %cluster keywords
%         text=[text sprintf('The words are significantly more frequently occurring in the high or low end of the scale. ')];
%     else %Cluster semantic
%         text=[text sprintf('The ten words that are most semantically closest to the cluster centroid are shown. ')];
%     end
%     text=[text sprintf('The font size represents the frequency of occurrence of the words. ')];
% elseif figureType==4
%     text=[text sprintf('The figure shows words where their semantic representations are clustered according to the k-mean cluster algorithm. ')];
% elseif figureType==15
%     if out1.plotwordCountCorrelation
%         text=[text sprintf('Wordclouds of shared words: All words have correlations that are non-significant different from zero. The fontsizes are proportional to (N*p)^.5')];
%     else
%         text=[text sprintf('Wordclouds of shared words: All words have non-significant different word frequencies. The fontsizes are proportional to (N1*N2*p)^.5')];
%     end
% elseif strcmpi(d.axisType,'wordcloud')
%     text=[text sprintf('Wordclouds: The font sizes are proportional to the square roots of the Q-values in a Chi-2 tests based on word frequency of dataset 1 compared to ')];
%     if figureType==5
%         text=[text sprintf('general word frequency in the language. ')];
%     elseif figureType==6
%         text=[text sprintf('datset2. ')];
%     else
%         text=[text sprintf('datset1. ')];
%     end
%     text=[text sprintf('Colored words are significant following Bonferroni corrections for multiple comparisons (p=%.4f), and grey words significant without correction (p=%.4f). ',0.05/d.Nc, s.par.keywordsPlotPvalue)];
% else
%     text=[text sprintf('The plot shows the %s category. ',lower(d.titleWord))];
% end
% if figureType==4
%     text=[text sprintf('The clusters are plotted on a circle. ')];
% elseif strcmpi(out1.axisType,'q')
%     text=[text sprintf('The axis represents Q-values in the Chi-square tests (q). ')];
% elseif strcmpi(out1.axisType,'r')
%     text=[text sprintf('The axis represents the correlation coifficient (r). ')];
% elseif strcmpi(out1.axisType,'z(p)')
%     text=[text sprintf('The axis represents z-transformed p-values z(p). ')];
% end


function [f_1,f_2]=mergeF(s,indexW1,indexW2,f1,f2);
f_1=sparse(0);f_2=sparse(0);
f_1(indexW1(1:length(f1)))=f1;
if isempty(f2)
    if isempty(indexW2)
        f_2=[];
    else
        if max(indexW2)>length(s.f) s.f(max(indexW2))=0;end
        f_2(indexW2(1:length(indexW2)))=s.f(indexW2)*10^6;
    end
else
    %f_2(indexW2(1:length(f2)))=f2;
    tmp=indexW2(1:length(f2));
    ok=not(isnan(tmp));
    f_2(tmp(ok))=f2(ok);
end

if length(f_1)<length(f_2)
    f_1(length(f_2))=0;
elseif length(f_1)>length(f_2)
    f_2(length(f_1))=0;
end


%Take non-unique inputs in indexW1-2 (i.e. repetitions of words) and
%produces unique output from a semanticTest2. f1-2 is unque
function out=getBinaryData(s,dim,out,indexW1,indexW2,f1,f2,par)
if nargin<7; f2=[];end
if nargin<8; par=s.par;end

[f_1,f_2]=mergeF(s,indexW1(1:length(f1)),indexW2(1:length(f2)),f1,f2);
if dim==0; f_2=0*f_2;end
index=find(f_1+f_2>0);


if strcmpi(par.plotTestType,'frequency')
    out.scale='phi';
    [f1_1,f1_2]=mergeF(s,indexW1,indexW2,f1,f2);
    indexF=find(f1_1+f1_2>0);
    [out.p out.q]=chi2testArray(full(f1_1(indexF)),full(f1_2(indexF)));
    out.z=(out.q/length(out.q)).^.5;
    indexSwap=f1_1(indexF)/nansum(f1_1)<f1_2(indexF)/nansum(f1_2);
    out.z(indexSwap)=-out.z(indexSwap);
else %SemanticTest
    out.scale='t';
    [r,s]=semanticTest(s,indexW1,indexW2);
    out.results=r.results;
    if not(s.par.excelServer)
        fprintf('%s\n',r.results);
    end
    out.semanticTest=r;
    if dim==0
        indexU=unique(indexW1);
    else
        indexU=unique([indexW1 indexW2]);
    end
    z=NaN(1,length(indexU));p=z;
    for i=1:length(indexU)
        xWord=[r.x1(find(indexU(i)==indexW1)) r.x2(find(indexU(i)==indexW2))];
        xBaseline=[r.x1(find(not(indexU(i)==indexW1))) r.x2(find(not(indexU(i)==indexW2)))];
        if length(xWord)>1
            %I have a concern here. The variabilyt of xWord is driven by
            %N-leave out crossvalidations. Is this how it should be?
            [h p(i) ci stats]=ttest2(xWord,xBaseline,.05,'both','unequal');
            z(i)=stats.tstat;
        else
            z(i)=(xWord-nanmean(xBaseline))/(nanvar(xBaseline)/length(xBaseline)+nanvar(xBaseline))^.5;
            p(i)=2*normcdf(-abs(z(i)));
        end
        %         if 0 %OLD
        %             indexU1=find(indexU(i)==indexW1);
        %             if length(indexU1)>1 %Assume unequal variance in ttest
        %                 [h p(i) ci stats]=ttest2(r.x1(indexU1),r.x2,.05,'both','unequal');
        %                 z(i)=stats.tstat;
        %             elseif not(isempty(indexU1)) & sum(s.x(indexU(i),:))>0
        %                 %if 0
        %                 %    z(i)=(r.x1(indexU1)-mean(r.x2))/std(r.x2);
        %                 %    p(i)=tpdf(z(i),length(indexU1));
        %                 %else %Assume zero variance in the tested words by using one-sample ttest
        %                 [h p(i) ci stats]=ttest(r.x2,r.x1(indexU1));
        %                 z(i)=-stats.tstat;
        %                 %end
        %             else %No semantic representation, use frequency chi2 test below instead
        %                 z(i)=NaN;
        %             end
        %end
    end
    
    %if 1
    %For words that does not have a semantic representation, use
    %chi2-test, where the baseline p-value is assumed to be
    %sum(f1)+sum(f2) (could be questioned)
    %Y(1,1)=sum(f1);%+sum(f2);%nansum(s.f)/nanmin(s.f);
    %v=(sum(f1)*nanvar(out.s.x1)+sum(f2)*nanvar(out.s.x2))/(sum(f1)+sum(f2));
    missing=find(isnan(z));
    for i=missing
        j1=find(indexU(i)==indexW1);
        if isempty(j1)
            Y(1,1)=0;
        else
            Y(1,1)=f1(j1(1));
        end
        j2=find(indexU(i)==indexW2);
        if isempty(j2)
            Y(1,2)=0;
        else
            Y(1,2)=f2(j2(1));
        end
        
        Y(2,1)=sum(f1)-Y(1,1);
        Y(2,2)=sum(f2)-Y(1,2);
        
        p(i)=chi2test(full(Y));
        z(i)=norminv(p(i));
    end
    %         missing=isnan(z2);
    %         for i=find(missing)
    %             j=find(indexW2(i)==indexW1);
    %             if isempty(j); Y(1,2)=0; else Y(1,2)=f1(j(find(j<=length(f1))));end
    %             Y(2,1)=sum(f2)-f2(i);Y(2,2)=f2(i);
    %             p2(i)=chi2test(full(Y));
    %             z2(i)=+norminv(p2(i));
    %             out.s.x2(i)=z2(i)*s12;
    %         end
    %         out.s.p1=p1;
    %         out.s.p2=p2;
    out.p=p;
    out.z=z;
    
end

out.word=s.fwords(index);
out.f1=f_1(index);
out.f2=f_2(index);
out.f=out.f1+out.f2;
out.f1isLargerThanf2Ratio=full(out.f1/(max(1,sum(out.f1)))>out.f2/sum(max(1,out.f2)));


function [s,out f indexW1 word indexW2]=mkfreq2(s,out,indexText);
[s,f , f1WC, out.fByIndex]=mkfreq(s,indexText);
indexW1=find(f);
f=f(f>0);
word=s.fwords(indexW1);
for i=1:length(indexW1)
    indexW1=[indexW1 ones(1,f(i)-1)*indexW1(i)];
end
indexW2=indexW1;
out.fByIndexMap=indexW2;


function [data,s]=getData(s,out,index,numbers,par);
%Take care of covariates
fByIndex=out.fByIndex;
if not(isempty(numbers))
    numbers=covariates(s,numbers,par.plotCovariateProperties,index);
end
data.semanticTest.p=NaN;
data.scale='';
data.results='';
parSave=s.par;
if nargin<5
    par=s.par;
else
    s.par=par;
end
if strcmpi(par.plotTestType,'semantic')
    if length(unique(numbers(not(isnan(numbers)))))<=2
        par.plotTestType='semanticTest';
    else
        par.plotTestType='train';
    end
end
if not(isfield(s,'db')) s.db=0;end
if strcmpi(par.plotCloudType,'category')
    data.scale='r';
    [~,categories]=getIndexCategory;
    categories{end+1}='semanticLIWC';
    i=find(strcmpi(regexprep(s.par.plotCategory,'-',' '),categories));%Descides category
    if not(isempty(i))
        cat=categories{i};
    else
        cat='';
    end
    getPropertyShow=s.par.getPropertyShow;
    if i==5
        [x,data.word,N]=getLIWC(s,index);
    else
        if strcmpi(cat,'semanticLIWC')%i==length(categories)
            i=5;s.par.getPropertyShow='noliwc';
        end
        [data.word,categories,indexC]=getIndexCategory(i,s);
        [x,~,s]=getProperty(s,indexC,index);%Get category data
        data.word=index2word(s,indexC);
        N=length(indexC);
        %indexKeep=find(abs(nansum(x'))>0);%Why is this needed?
    end
    if length(index)>1
        indexKeep=find(abs(nansum(x'))>0);%Why is this needed?
    else
        indexKeep=find(abs(x')>0);%Why is this needed?
    end
    if length(indexKeep)==0
        fprintf('No matching Word in the LIWC database\n')
    end
    
    %fByIndex=x';
    %fByIndex=fByIndex(:,indexKeep);
    x=x(indexKeep,:);
    data.word=data.word(indexKeep);
    N=length(indexKeep);
    1;
    
    if N(1)==0
        data.z=[];data.p=[];data.f=[];
        fprintf('Warning: the space %s has no data in %s\n',s.filename,s.par.plotCategory)
    elseif isempty(numbers)
        data.scale='z';
        [indexRand,s]=getRandomIndex(s,min(1000,length(index)*2+10));
        
        if i==5
            [xRand]=getLIWC(s,indexRand);
        else
            [xRand,~,s]=getProperty(s,indexC,indexRand);%Get category data
        end
        for j=1:N(1);%Correlation x
            [r1(j) data.p(j)]=ttest(x(j,:)'-nanmean(xRand(j,:)));
            data.f(j)=abs(nanmean(x(j,:)-nanmean(xRand(j,:))));
            data.z(j)=data.f(j)./std(x(j,:));
        end
    else
        for j=1:N(1);%Correlation x
            [data.z(j) data.p(j)]=nancorr(x(j,:)',numbers');
            data.f(j)=abs(data.z(j));
        end
    end
    s.par.getPropertyShow=getPropertyShow;
    
    data.z(isinf(data.z) | isnan(data.z))=0;
    data.p(isinf(data.p) | isnan(data.p))=1;
    data.f(isinf(data.f) | isnan(data.f))=0;
    for j=1:N(1);%Correlation x
        %data.word{j}=regexprep(data.word{j},'_liwckk','');
        data.word{j}=regexprep(data.word{j},'_liwc','');
        data.word{j}=regexprep(data.word{j},'_','');
        data.word{j}=regexprep(data.word{j},'processes','-processes');
        data.word{j}=regexprep(data.word{j},'tense','-tense');
        data.word{j}=regexprep(data.word{j},'emotion','-emotion');
        data.word{j}=regexprep(data.word{j},'pron','-pronouns');
        data.word{j}=regexprep(data.word{j},'verb','-verb');
        data.word{j}=regexprep(data.word{j},'words','-words');
        if length(data.word{j})>1 & data.word{j}(1)=='-'
            data.word{j}=data.word{j}(2:end);
        end
        %'_liwcbiologicalp...'_liwcpercepdata.word{j}tualp,'_liwcperceptualp'_liwcnegativeemo
        %'_liwcpositiveemo.'_liwcaffectivepr_liwcsocialproce...''_liwctotalpron'_liwcfuturetense
        %'_liwcpresenttense'_liwcauxiliaryverbs''_liwccommonverbs'_liwcimpersonalpron
    end
elseif strcmpi(par.plotTestType,'property')
    [s,out f1 indexW1 word1 indexW1All]=mkfreq2(s,out,index);
    data=out;
    data.scale='z';
    indexOk=indexW1<=s.N;
    data.z=nan(1,length(f1));
    if s.db
        if isnan(word2index(s,par.plotProperty))
            if iscell(par.plotProperty) plotProperty=par.plotProperty; else plotProperty={par.plotProperty}; end
            s=getSfromDB(s,s.languagefile,s.filename,plotProperty,[],'merge');
        end
    end
    [data.z(indexOk),~,s]=getProperty(s,par.plotProperty,indexW1(indexOk));
    
    %Fix missing data
    z2=nan(1,length(s.fwords));
    z2(indexW1(indexOk))=data.z(indexOk);
    missing=find(isnan(data.z));
    if 0
        for i=1:length(f1)
            textId= find(out.fByIndex(:,indexW1(i))>0);
            wordId=[];
            for j=1:length(textId)
                wordId=[wordId find(out.fByIndex(textId(j),:)>0)];
            end
            i1=find(not(wordId==indexW1(i)));
            i2=find(wordId==indexW1(i));
            zContext(i)=nanmean(z2(wordId(i1)));
            [h p(i)]=ttest(z2(wordId(i1))-nanmean(z2(wordId(i2))));
        end
        [a indexSort]=sort(p);
        for i=1:50
            fprintf('%s\t%.3f\t%.3f\n',word1{indexSort(i)},data.z(indexSort(i)),zContext(indexSort(i)))
        end
    end
    for i=1:length(missing)
        textId= find(out.fByIndex(:,indexW1(missing(i)))>0);
        wordId=[];
        for j=1:length(textId)
            wordId=[wordId find(out.fByIndex(textId(j),:)>0)];
        end
        data.z(missing(i))=nanmean(z2(wordId));
    end
    
    %Caculate z and p
    if 0
        v12=nanvar(data.z);
        for i=1:length(word1)
            indexWord=indexW1==indexW1(i);
            v1=v12/length(find(indexWord(indexOk)));
            v2=v12/length(find(not(indexWord(indexOk))));
            z(i)=(nanmean(data.z(indexWord(indexOk)))-nanmean(data.z(not(indexWord(indexOk)))))/(v1+v2)^.5;
        end
        data.z=z;
    else
        data.z=data.z(1:length(word1));
        z=(data.z-nanmean(data.z))/(nanstd(data.z)/length(data.z)^.5);
    end
    data.p=1-normcdf(abs(z));
    removeWords=find(isnan(data.p));
    if not(isempty(isnan(removeWords)))
        fprintf('Removing data points without semantic representations, and where neigbouring does not have a semantic represenation: %s\n',struct2string(word1(removeWords)))
        data.p(isnan(data.p))=2;%Remove NaN words! (unfortunate)
    end
    data.word=index2word(s,indexW1);
    data.f=f1;
elseif strcmpi(par.plotTestType,'frequency-correlation')
    data.scale='r';
    [s,data.f ,f1WC , fByIndex]=mkfreq(s,index);
    indexOk=find(data.f>0);
    data.word=index2word(s,indexOk);
    for i=1:length(indexOk)
        [data.r(i) data.p(i)]=nancorr(numbers',full(fByIndex(:,indexOk(i))));
    end
    data.f=data.f(indexOk);
    data.z=data.r;
elseif strcmpi(par.plotTestType,'semanticTest') | strcmpi(par.plotTestType,'frequency')
    if isempty(numbers)
        dim=0;
        index1=index;
    else
        dim=1;
        %Do median split
        [index1 index2]=getMedianSplitIndexes(numbers,index);
    end
    %Get word frequencies
    [s,out f1 indexW1 word1 indexW1All]=mkfreq2(s,out,index1);
    %fByIndex=out.fByIndex;
    if dim==0 & strcmpi(par.plotTestType,'frequency')
        indexW2=indexW1;word2=word1;
        f2=[];f2(length(f1))=0;
        ok=indexW2(1:length(f1))<=s.N;
        f2(ok)=s.f(indexW2(ok));
        f2=f2/min(s.f(s.f>0));
    else
        if dim==0
            [index2,s]=getRandomIndex(s,min(1000,sum(f1)+10));
        end
        [s,out f2 indexW2 word2 indexW2All]=mkfreq2(s,out,index2);
        out.fByIndex=fByIndex;
    end
    %Calculate binary statistics
    data=getBinaryData(s,dim,out,indexW1,indexW2,f1,f2,par);
    
else %Train
    %trainSemanticKeywordsFrequency=par.trainSemanticKeywordsFrequency;
    data.scale='z';
    s.par.trainSemanticKeywordsFrequency=max(1,par.trainSemanticKeywordsFrequency);
    if isempty(numbers)
        [s,out f1 indexW1 word1 indexW1All]=mkfreq2(s,out,index);
        [indexRand,s]=getRandomIndex(s,min(500,length(index)*2+10));
        numbersSplit=[ones(1,length(indexW1)) zeros(1,length(indexRand))];
        index=[indexW1 indexRand];
        index(index>s.N)=NaN;
        [s data]= train(s,numbersSplit,'',index);
        data.scale='z';
        data.z=(data.pred(1:length(f1))-nanmean(data.pred(numbersSplit==0)))/(nanstd(data.pred)/length(f1)^.5);
        data.p=2*(1-normcdf(abs(data.z)));
        data.f=f1;
        data.word=word1;
        %data=infoX.w;
    else
        [s infoX]= train(s,numbers,'',index);
        if not(s.par.excelServer)
            fprintf('%s\n',infoX.results)
        end
        data=infoX.w;
        data.train=infoX;
        data.results=infoX.results;
        if strcmpi(par.plotAxis,'predicted')
            data.z=data.pred;
            data.scale=par.plotAxis;
        else
            data.scale='z';
        end
        data.df=infoX.n-2;
    end
end

data.zOrg=data.z;
%Get user z-values
%If missing userIndex, set it to last user!
if not(isfield(s.par,'userIndex')) s.par.userIndex=[];end
if isempty(s.par.userIndex)
    userIndex=size(fByIndex,1);
else
    userIndex=s.par.userIndex;
end
%if isfield(s.par,'userIndex') & not(isempty(s.par.userIndex))
if ischar(userIndex) userIndex=find(strcmpi(s.fwords(index),userIndex)); end;
indexWord=word2index(s,data.word);
if size(fByIndex,1)<max(userIndex)
    fprintf('Error: s.par.userIndex does not match index! Ignoring user\n')
    data.zOrgUser=NaN;
elseif strcmpi(par.plotCloudType,'category')
    try
        data.zOrgUser=max(x(:,userIndex));
    end
else
    indexUser2=[];
    for j=1:length(userIndex) %If same user has answered multiple times, then average over them!
        indexUser=find(fByIndex(userIndex(j),:)>0);
        for i=1:length(indexUser) %Average over each word
            indexUser2=[indexUser2 find(strcmpi(s.fwords{indexUser(i)},out.word))];
        end
    end
    if isempty(data.zOrg)
        data.zOrgUser=[];
    else
        try
            data.zOrgUser=nanmean(data.zOrg(indexUser2));
        catch
            data.zOrgUser=NaN;
            sprintf('Error: Here\n')
        end
    end
end
if not(isfield(data,'results')) data.results='';end
%else
%    data.zOrgUser=NaN;
%end

if s.par.plotWordcloud
    if isempty(numbers) & not(strcmpi(par.plotTestType,'property'))
        data.p(find(data.z<0))=1;
        data.z=0*data.z;
        data.medianSplit=0;
    else
        [indexHigh indexLow data.medianSplit]=getMedianSplitIndexes(data.z);
        data.z(indexLow )=-1;
        data.z(indexHigh)= 1;
        if strcmpi(par.plotTestType,'semanticTest') & isfield(data,'f1') & parSave.fixProblemWithSemanticTestWordClouds %isfield(s.par,'fixProblemWithSemanticTestWordClouds') &
            data.z(find(data.z==-1 & data.f1==0))=+1;
            data.z(find(data.z== 1 & data.f2==0))=-1;
        end
    end
    if data.medianSplit>data.zOrgUser data.zUser=-1; else data.zUser=1;end
end
data.par=par;

s.par=parSave;

function [index1 index2 m]=getMedianSplitIndexes(numbers,index);
if nargin<2; index=1:length(numbers);end
m=nanmedian(numbers);
index1a=index(find(m<numbers));
index2a=index(find(m>=numbers));
a=abs(length(index1a)-length(index2a));
index1b=index(find(m<=numbers));
index2b=index(find(m>numbers));
b=abs(length(index1b)-length(index2b));

if a<b
    index1=index1a;
    index2=index2a;
else
    index1=index1b;
    index2=index2b;
end

function text=num2textFixDigits(num)
if num>10^9
    text=sprintf('%e',num);
elseif num>10^4
    text=sprintf('%.0f',num);
elseif num>.1 | num==0
    text=sprintf('%.2f',num);
elseif num>.001
    text=sprintf('%.5f',num);
else
    text=sprintf('%e',num);
end


function p = pvalPearson(rho, n)
%PVALPEARSON Tail probability for Pearson's linear correlation.
t = rho.*sqrt((n-2)./(1-rho.^2)); % +/- Inf where rho == 1
%switch tail
%case 'b' % 'both or 'ne'
p = 2*tcdf(-abs(t),n-2);


function [out,h,s]=plotNumerical(s,numbers,par,labels,userNames,h,plotNumericData,out)
%Plot numbers only
figure(h)
x=nanmean([min(numbers{1}) max(numbers{1})]);
if length(numbers{2})==0
    %Plot one-dimensional plot
    labels{2}='frequency';
    if strcmpi(s.par.plotWordcloudType,'nominal') & isfield(s.par,'plotNominalLabels')
        %Plots nominal/categorical data. Please set the following
        %variable:
        %s.par.plotNominalLabels={'man','women'};
        %Where numbers{1} should either have value 1 or 2 (in this case)
        for i=1:length(s.par.plotNominalLabels)
            x(i)=length(find(i==numbers{1}));%Set frequency values for nominal data
        end
        bar(x,'FaceColor',[0.5 0.5 1]);
        for i=1:length(s.par.plotNominalLabels)
            %Print the labels of the nominal data
            fontsize=40*7*2/(1+length(s.par.plotNominalLabels{i}))/length(s.par.plotNominalLabels);
            if fontsize<12
                %fontsize=max(8,fontsize);
                fontsize=min(25,max(12,12*20/length(s.par.plotNominalLabels{i})));
                c=text(i,.1,s.par.plotNominalLabels{i},'fontsize',fontsize,'Rotation',90);
                if not(isempty(s.par.userIndex)) & numbers{1}(s.par.userIndex)==i
                    line(-c.Extent(4)*.1+[c.Extent(1)+c.Extent(3) c.Extent(1)+c.Extent(3)],c.Extent(4)*.0+[c.Extent(2) c.Extent(2)+c.Extent(4)],'color','r','linewidth',4)
                end
            else
                c=text(i,(max(1/2,x(i)/2)),s.par.plotNominalLabels{i},'fontsize',fontsize,'HorizontalAlignment','center');
                if not(isempty(s.par.userIndex)) & numbers{1}(s.par.userIndex)==i
                    line([c.Extent(1) c.Extent(1)+c.Extent(3)],c.Extent(4)*.1+[c.Extent(2) c.Extent(2)],'color','r','linewidth',4)
                end
            end
        end
        out.figureNote=[out.figureNote sprintf('The figure shows the number of responses for: %s',cell2string(s.par.plotNominalLabels))];
        set(gca,'Xtick',min(get(gca,'Xtick')):1:max(get(gca,'Xtick')));
    else
        %Continous (non-nonminal data)
        Nnominal=min(10,length(unique(numbers{1})));
        
        Normalization='count';
        leg=[];
        hold on;
        
        if length(s.par.plotNetworkModel)>0
            plotNetworkModel=s.par.plotNetworkModel;
            if ischar(plotNetworkModel) plotNetworkModel=string2cell(plotNetworkModel)';end
            %pred=getProperty(s,plotNetworkModel);
            for i=1:length(plotNetworkModel)
                j=word2index(s,plotNetworkModel(i));
                Normalization='probability';
                if isfield(s.info{j},'y')
                    Normalization='probability';
                    labels{2}='probability';
                    
                    h=histogram(s.info{j}.y,Nnominal,'Displaystyle','stairs','Normalization',Normalization);
                    leg=[leg 'Trained data for ' regexprep(plotNetworkModel{i},'','')];
                elseif isfield(s.info{j},'trainDataStat')
                    m=s.info{j}.trainDataStat(1);
                    sd=s.info{j}.trainDataStat(2);
                    z=m-3*sd:m+3*sd;
                    plot(z, pdf('Normal',z,m,sd)*length(x1));
                    leg=[leg 'Normal distribution of trained data ' regexprep(plotNetworkModel{i},'','')];
                end
            end
        end
        
        y=[];
        for i=1:size(numbers{1},2)
            x1=numbers{1}(:,i);
            h=histogram(x1,Nnominal,'Displaystyle','stairs','Normalization',Normalization);
            if length(plotNumericData)<i
                plotNumericData{i}=['data ' num2str(i)];
            end
            leg=[leg plotNumericData(i)];
            if isempty(y)
                y=nanmean([0 max(h.Values)]);
            else
                y=y-nanmean([0 max(h.Values)])*.2;
            end
            
            numData=num2textFixDigits(nanmean(x1));
            xtext=sprintf('N=%d, std=%s,min=%s,max=%s',length(x1), num2textFixDigits(nanstd(x1)),num2textFixDigits(nanmin(x1)),num2textFixDigits(nanmax(x1)));
            if size(numbers{1},2)==1
                text(x,y,numData,'fontsize',65,'HorizontalAlignment','center')
                text(x,.8*y-.2,xtext,'fontsize',12,'HorizontalAlignment','center')
            elseif 0
                leg=[leg {sprintf('M=%s,N=%d, std=%s,min=%s,max=%s',num2textFixDigits(nanmean(x1)),length(x1), num2textFixDigits(nanstd(x1)),num2textFixDigits(nanmin(x1)),num2textFixDigits(nanmax(x1)))}];
                [i1 i2]=getMedianSplitIndexes(x1);
                h=histogram(x1(i1),Nnominal,'Displaystyle','stairs');
                h=histogram(x1(i2),Nnominal,'Displaystyle','stairs');
                leg=[leg {sprintf('M=%s,N=%d, std=%s,min=%s,max=%s',num2textFixDigits(nanmean(x1(i1))),length(x1(i1)), num2textFixDigits(nanstd(x1(i1))),num2textFixDigits(nanmin(x1)),num2textFixDigits(nanmax(x1(i1))))}];
                leg=[leg {sprintf('M=%s,N=%d, std=%s,min=%s,max=%s',num2textFixDigits(nanmean(x1(i2))),length(x1(i2)), num2textFixDigits(nanstd(x1(i2))),num2textFixDigits(nanmin(x1)),num2textFixDigits(nanmax(x1(i2))))}];
            end
        end
        
        
        %if size(numbers{1},2)>1
        legend(regexprep(leg,'_',' '));
        %end
        set(gcf,'Color',[1 1 1]);
        
        out.figureNote=[out.figureNote sprintf('The figure shows a histogram')];
        
        %Plot arrows pointing at user!
        diff=max(numbers{1})-min(numbers{1});
        if isfield(s.par,'userIndex') & length(s.par.userIndex)==1
            line([numbers{1}(s.par.userIndex) numbers{1}(s.par.userIndex)],[0 .5],'color','r','linewidth',4)
            line([numbers{1}(s.par.userIndex)-diff*.02 numbers{1}(s.par.userIndex)],[.125 0],'color','r','linewidth',4)
            line([numbers{1}(s.par.userIndex)+diff*.02 numbers{1}(s.par.userIndex)],[.125 0],'color','r','linewidth',4)
        end
    end
    %set(gca,'Ytick',min(get(gca,'Ytick')):1:max(get(gca,'Ytick')));
elseif length(numbers{3})==0
    y=nanmedian(numbers{2});
    plot(numbers{1},numbers{2},'x','color',[0 0 0])
    [r p]=nancorr(numbers{1}',numbers{2}');
    text(x,min(numbers{2}),sprintf('r=%.3f, p=%.4f',r,p),'color',[.6 .6 .6],'fontsize',12,'HorizontalAlignment','center')
    if length(userNames)>0
        for i=1:length(userNames)
            text(numbers{1}(i),numbers{2}(i),sprintf('%s',userNames{i}),'color',rand(1,3)/2,'fontsize',12,'HorizontalAlignment','center')
        end
    end
    out.figureNote=[out.figureNote sprintf('The figure shows two numerical variables plotted on the x and the y axses.')];
    %Plot two-dimensional plot
else
    plot3(numbers{1},numbers{2},numbers{3},'x','color',[0 0 0])
    out.figureNote=[out.figureNote sprintf('The figure shows three numerical variables plotted on the x, y and z axses.')];
end
xlabel(labels{1});
ylabel(labels{2});
zlabel(labels{3});
set(gcf,'color',[1 1 1]);
set(gca,'xColor',[.8 .8 .8])
set(gca,'yColor',[.8 .8 .8])


function plotPredictions(s,indexText,userNames);
%s.par.plotCloudType='predictions';
%s.par.plotNetworkModel='_predharmonyratingscale _predvalence';
% _predharmonyratingscale
plotNetworkModel=s.par.plotNetworkModel;
if ischar(plotNetworkModel) plotNetworkModel=string2cell(plotNetworkModel)';end
s=getSfromDB(s,s.languagefile,s.filename,plotNetworkModel,[],'merge');
pred=getProperty(s,indexText,plotNetworkModel);

%figure(h);
set(gcf,'Color',[1 1 1])
minPred=min(min(pred));
maxPred=max(max(pred));
plot([0 length(plotNetworkModel)+1],[minPred-.75*(maxPred-minPred) maxPred],'color',[1 1 1]); hold on
indexModels=word2index(s,plotNetworkModel);
axis off
text(0,fix(maxPred),num2str(fix(maxPred)),'fontsize',20)
text(0,fix(minPred),num2str(fix(minPred)),'fontsize',20)

xstep=.5;
for i=1:length(indexModels)
    if not(isnan(indexModels(i))) & isfield(s.info{indexModels(i)},'predDataStat')
        m=s.info{indexModels(i)}.predDataStat(1);
        sd=s.info{indexModels(i)}.predDataStat(2);
        col=[.5 .5 .5];
        plot([i*xstep i*xstep],[m-sd m+sd],'color',col)
        plot([i*xstep-.1 i*xstep+.1],[m-sd m-sd],'color',col)
        plot([i*xstep-.1 i*xstep+.1],[m+sd m+sd],'color',col)
    else
        fprintf('Error: Missing prediction model, or model data, for %s\n',plotNetworkModel{i});
    end
end

Xlim=get(gca,'xlim');
h2=get(gcf,'CurrentAxes');
Ylim=get(h2,'Ylim');
ratio=((Ylim(2)-Ylim(1))/(Xlim(2)-Xlim(1)));
colDef='rbcmk';
for i=1:length(indexModels)
    for j=1:length(indexText)
        col=colDef(min(length(colDef),j));
        if i==1 & length(userNames)>=i
            text(Xlim(2)*xstep,Ylim(2)-j*.05*(Ylim(2)-Ylim(1)),regexprep(userNames{j},'_',''),'color',col);
        end
        plotCircle(i*xstep,pred(j,i),.1,.1*ratio,2,col)
        if i<length(indexModels)
            line([i (i+1)]*xstep,[pred(j,i) pred(j,i+1)],'color',col,'LineStyle','--');
        end
    end
    fontsize=25*7/(max(8,length(plotNetworkModel{i})));
    text(i*xstep,Ylim(1),regexprep(plotNetworkModel{i},'_',''),'Rotation',90,'HorizontalAlignment','left','fontsize',fontsize);
end

