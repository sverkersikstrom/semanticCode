function d=wordCloud(s,d,word,p,fontsize,class,x,y,z,labels,par,zOrg,cluster)
if not(isfield(d,'word')); d.word=[];end;
if nargin<6
    class=[];
end
if isempty(class)
    class=ones(1,length(fontsize));
end
if nargin<7; x=[];y=[];z=[];end
if nargin<10;labels{1}='';labels{2}='';labels{3}='';end
labels=regexprep(labels,'_','');
if isnan(nanmean(x)) x=zeros(1,length(x));end
if isnan(nanmean(y)) y=zeros(1,length(y));end
if isnan(nanmean(z)) z=zeros(1,length(z));end

if nargin>=9 & nanstd(z)>0
    dimensions=3;
elseif nargin>=8 & nanstd(y)>0 dimensions=2;
elseif nargin>=7 & nanstd(x)>0 dimensions=1;
else dimensions=0;end
d.dimensions=dimensions;
if nargin<11;
    par{1}=s.par;par{2}=s.par;par{3}=s.par;
end

if nargin<13; cluster=[];end

%Remove outliers
if s.par.plotRemoveOutliers
    x=removeOutliers(x);
    y=removeOutliers(y);
    z=removeOutliers(z);
end

%Replace words
if length(s.par.plotReplaceWords)>0
    plotReplaceWords=textscan(s.par.plotReplaceWords,'%s','delimiter',',');plotReplaceWords=plotReplaceWords{1};
    for i=1:length(plotReplaceWords)
       ReplaceWords=textscan(plotReplaceWords{i},'%s');ReplaceWords=ReplaceWords{1};
       if length(ReplaceWords)==2
           word=regexprep(word,ReplaceWords{1},ReplaceWords{2});
       end
    end
end

%Remove words....
t=[];
%Remove predefined words....
if length(s.par.plotRemoveWords)>0
    if ischar(s.par.plotRemoveWords)
        [tmp t]=text2index(s,s.par.plotRemoveWords);
    else
        t=s.par.plotRemoveWords;        
    end
end
%Remove high frequency words (.001)
if s.par.plotRemoveHFWords>0  
    select=getProperty(s,'_frequency',word);
    if s.par.plotRemoveHFWords>1
        tmp=sort(select,'descend');
        plotRemoveHFWords=tmp(length(find(isnan(select)))+s.par.plotRemoveHFWords);
    else
        plotRemoveHFWords=s.par.plotRemoveHFWords;
    end
    t=[t word(find(select>plotRemoveHFWords))];
end
%Now remove the words
for i=1:length(t)
    j=find(strcmpi(t{i},word));
    for k=1:length(j);
        word{j(k)}='';
        if j(k)<=length(fontsize)
            fontsize(j(k))=0;
        end
    end
end


if length(s.par.plotRemoveCharacters)>0
    [tmp t]=text2index(s,s.par.plotRemoveCharacters);
    for j=1:length(t) %Consider making this faster somehow...
        for i=1:length(labels)
            labels{i}=regexprep(labels{i},t{j},'');
        end
        for i=1:length(word)
            word{i}=regexprep(word{i},t{j},'');
        end
    end
end


if not(isfield(d,'x')) d.x=0;end
if not(isfield(d,'y')) d.y=0;end
if not(isfield(d,'z')) d.z=0;end

fontsize(isnan(fontsize))=0;
if length(s.par.plotWordcountMaxNumber)>1
    if length(s.par.plotWordcountMaxNumber)>=3
        if 1 %Select by frequency on third paramter
            zOrg(fontsize.^2<s.par.plotWordcountMaxNumber(3))=median(zOrg);
        else %Select by rank order on third paramter
            [tmp indexF]=sort(fontsize,'descend');
            zOrg(indexF(s.par.plotWordcountMaxNumber(3)+1:end))=median(zOrg);
        end
    end
    [tmp indexQ]=sort(zOrg,'descend');
    [tmp indexQ2]=sort(zOrg,'ascend');
    %indexQ=[indexQ(1:s.par.plotWordcountMaxNumber(1)) indexQ(end-s.par.plotWordcountMaxNumber(2)+1:end) indexQ(s.par.plotWordcountMaxNumber(1)+1:end-s.par.plotWordcountMaxNumber(2))];
    indexQ=[indexQ(1:min(end,s.par.plotWordcountMaxNumber(1))) indexQ2(1:min(end,s.par.plotWordcountMaxNumber(2))) indexQ(min(end,s.par.plotWordcountMaxNumber(1)+1):end-s.par.plotWordcountMaxNumber(2))];
else
    [tmp indexQ]=sort(fontsize,'descend');
    %[tmp indexQ]=sort(abs(zOrg),'descend');
end

if not(isfield(s.par,'plotScale')); s.par.plotScale=2;end
N=sum(s.par.plotWordcountMaxNumber(1:min(2,end)));
if not(isfield(s.par,'plotPosition')) 
    s.par.plotPosition=get(gcf,'Position');
    s.par.plotPosition(1)=1;
    s.par.plotPosition(2)=1;
end
if not(isfield(d,'skipLimits')) d.skipLimits=0;end
if not(d.skipLimits)
    set(gcf,'Position',[s.par.plotPosition(1) s.par.plotPosition(2) s.par.plotScale*s.par.plotPosition(3) s.par.plotScale*s.par.plotPosition(4)]);
    if isfield(d,'setLimits')
        set(gca,'Xlim',d.setLimits(1:2));
        set(gca,'Ylim',d.setLimits(3:4));
        set(gca,'Zlim',d.setLimits(5:6));
    else
        set(gca,'Xlim',getLim(x,0,length(word)));
        set(gca,'Ylim',getLim(y,dimensions<2,length(word)));
        set(gca,'Zlim',getLim(z,dimensions<3));
    end
end

p(find(isnan(p)))=1;%Set Nan to p=1;
x(find(isnan(x)))=setNan(x);%Set Nan to 'median';
y(find(isnan(y)))=setNan(y);%Set Nan to 'median';
z(find(isnan(z)))=setNan(z);%Set Nan to 'median';

if s.par.plotBonferroni==2
    for i=1:length(indexQ)
        keywordsPlotPvalue(indexQ(i))=s.par.keywordsPlotPvalue/i;
    end
    d.correctionType='Holme''s';
    if isempty(indexQ)
        selected=NaN;
    else
        selected=class(indexQ) & p(indexQ)<=keywordsPlotPvalue(indexQ);
    end
else
    if s.par.plotBonferroni==1
        if s.par.keywordsPlotPvalue==1
            selected=class(indexQ);
        elseif isfield(s.par,'plotBonferroniN')
            selected=class(indexQ) & p(indexQ)<=s.par.keywordsPlotPvalue/s.par.plotBonferroniN;
            s.par=rmfield(s.par,'plotBonferroniN');
        else
            selected=class(indexQ) & p(indexQ)<=s.par.keywordsPlotPvalue/length(indexQ);
        end
        d.correctionType='Bonferroni';
    else
        selected=class(indexQ) & p(indexQ)<=s.par.keywordsPlotPvalue;
        d.correctionType='uncorrected';
    end
end

Nselected=length(find(selected));
scale=mean(fontsize(indexQ(1:min(10,length(indexQ)))));
if not(isfield(s.par,'plotScale2')) s.par.plotScale2=1.5;end
scale2=s.par.plotScale2*s.par.plotScale*max(1,35/(Nselected+20));%Overall scaling depends on the number of words plotted

if not(isfield(s.par,'plotSignificantColors')) s.par.plotSignificantColors=2;end

if not(isempty(s.par.plotColorLimits))
    pCrit=s.par.plotColorLimits(end:-1:1);
    pCol =[.2:.6/(length(s.par.plotColorLimits)-1):0.8];
elseif length(find(p<10^-10))>20 & not(s.par.plotSignificantColors==3);
    if nargin>=12
        s.par.plotSignificantColors=7;
    else
        s.par.plotSignificantColors=4;%Random for p=0
    end
    pCrit=[.05 1/length(p) 0];
    pCol =[.2  .4   .8];
else
    %pCrit=[.05 .01 .001 .0001 .00001 .0000001 0];
    %pCol =[.2  .4  .6   .7    .8     .9        1];
    pCrit=[.05 .01 .001 .00001 0];
    pCol =[.2  .4  .6   .7    .8];
end
for i=1:length(pCol)
    if s.par.plotSignificantColors==1
        pColor(i,:) =[pCol(i) 0 0 ];
    else
        indexCol=find(pCrit(i)>=pCrit);
        tmp=rand(1,3);tmp=.8*tmp/mean(tmp);
        col=min(.7,tmp*((1-pCol(indexCol(1)))));
        pColor(i,:)=col;
    end
end

%Set colorsmaps related to plotSignificantColors
if s.par.plotSignificantColors==9
    p
    pCrit=[.95 .90 .80 .70 .60 .50 .40 .30 .20 .10 .05 0];
    pCol =[.2  .4  .6   .7    .8];
    %pColor=[1 0 0;0.9 0 0;0.8 0 0; 0.7 0 0;0.4 0 0.4;0 0 0.7;0 0 0.8; 0 0
    %0.9; 0 0 1];%Red and Blue
    %pColor=[1 0 0;0.9 0 0;0.8 0 0; 0.7 0 0; 0.6 0 0;0.5 0.5 0;0 0.6 0;0 0.7 0;0 0.8 0; 0 0.9 0; 0 1. 0];%Green and Red
    %pColor=[.6 0 0;0.7 0 0;0.8 0 0; 0.9 0 0; 1.0 0 0;0.5 0.5 0;0 1.0 0;0 0.9 0;0 0.8 0; 0 0.7 0; 0 .6 0];%Green and Red
    pColor=[1 0 0;0.9 .1 .1;0.8 .2 .2; 0.7 .3 .3; 0.6 .3 0.3;0.6 0.4 .4;0.4 0.6 .4;0.3 0.6 0.3;0.3 0.7 0.3;0.2 0.8 .2; .1 0.9 .1; 0 1. 0];%Green and Red
elseif s.par.plotSignificantColors==6 | s.par.plotSignificantColors==7 %Set data for colormap
    colorMap=colormap(s.par.plotColorMap);
    %An error will occur if you use <.6 in the row below!
    indexColor=find(mean(colorMap')<.6);
    if length(indexColor)<5
        indexColor=find(mean(colorMap')<.7);
    end
    colorMap=colorMap(indexColor,:);%Remove too white colors
    Ncol=size(colorMap);
    if Ncol(1)==0
        fprintf('This error should NOT occur\n');
        colorMap=[0:.05:1; 0:.05:1 ;0:.05:1]';
        colorMap=colorMap(find(mean(colorMap')<.6),:);%Remove too white colors
        Ncol=size(colorMap);
    end
    if s.par.plotSignificantColors==7
        tmp=sort( (abs(zOrg(p<.05))));
        if length(tmp)>200
            tmp=[tmp(1:100) tmp(end-100:end)];
        end
        if length(tmp)==0 tmp=NaN;end
        for i=1:length(pCrit)+1
            pCrit(i)=tmp(min(length(tmp),fix(1+length(tmp)*(i-1)/length(pCrit))));
        end
        for i=1:Ncol(1)
            colorMapP(i)=tmp(fix(1+length(tmp)*(i-1)/Ncol(1)));
        end
    else
        colorMap=colorMap(Ncol(1):-1:1,:);%Swap scale :)
        colorMapP=10.^(-10*(1:Ncol(1))/Ncol(1));
        colorMapP(end)=-1e-10;
    end
elseif s.par.plotSignificantColors==3 & isempty(cluster)
    fprintf('Grouping color setting (3) requires groups, changing to default color setting (2)\n');
    s.par.plotSignificantColors=2;
elseif s.par.plotSignificantColors==3
    uniCol2=unique(cluster(not(isnan(cluster))));
    resetRandomGenator(s);
    for i=1:length(uniCol2)
        pColor(i,:)=min(.5,rand(1,3));
    end
    pColor(1,:)=[0 0 1];
    pColor(2,:)=[0 1 0];
    if 1
        if isfield(s.par,'plotColor') & length(s.par.plotColor)>0
            colDef=s.par.plotColor;
        else
            colDef='krbcm';
        end
        
        for i=1:length(colDef)
            if colDef(i)=='G'
                pColor(i,:)=[.5 .5 .5];
            else
                if dimensions==3
                    h=text(0,0,0,'x','color',colDef(i));
                else
                    h=text(0,0,'x','color',colDef(i));
                end
                pColor(i,:)=get(h,'color');
            end
        end
    end
end
colRand=min(.8,rand(1,3));

%Plot wordcloud
i=1;j=1;
warning off;
% if dimensions==3;
%    set(gca,'CameraPosition',[11 17 7])
% end
while i<=length(indexQ) & j<=N
    if selected(i)
        if nargin>=7
            d.x=x(indexQ(i));
        end
        if nargin>=8
            d.y=y(indexQ(i));
        end
        if nargin>=9
            d.z=z(indexQ(i));
        end
        word{indexQ(i)}=regexprep(word{indexQ(i)},'_userreference','user');
        if length(word{indexQ(i)})>4 & strcmpi(word{indexQ(i)}(1:4),'user')
            word{indexQ(i)}='user';
        end
        if dimensions==3
            h=text(0,0,0,regexprep(index2word(s,word{indexQ(i)}),'_',''));
        else
            h=text(0,0,      regexprep(index2word(s,word{indexQ(i)}),'_',''));
        end%1=red,2=p-coded, 4=random(p=0), 5=one-random-color,
        if p(indexQ(i))<=.05 | not(isempty(s.par.plotColorCodesFor))
            indexCol=find(p(indexQ(i))>=pCrit);
            if s.par.plotSignificantColors==5 %Same random color for all words
                col=colRand;
            elseif s.par.plotSignificantColors==4 
                if p(indexQ(i))==0
                    col=min(.8,rand(1,3));
                elseif p(indexQ(i))<=.05/length(p);
                    col=[.2 .2 .2];
                else
                    col=[.5 .5 .5];
                end
            elseif s.par.plotSignificantColors==3
                %tmp=find(uniCol2==uniCol(indexQ(i)));
                %col=pColor(tmp,:);
                if isnan(cluster(indexQ(i)))
                    col=[1 1 1];
                else
                    col=pColor(cluster(indexQ(i)),:);
                end
            elseif s.par.plotSignificantColors==6
                tmp=find(p(indexQ(i))>=colorMapP);
                col=colorMap(tmp(1),:);
            elseif s.par.plotSignificantColors==7
                tmp=find( abs(zOrg(indexQ(i)))<=colorMapP);
                if isempty(tmp) tmp=length(colorMapP);end
                col=colorMap(tmp(1),:);
            elseif s.par.plotSignificantColors>0
                if isempty(indexCol)
                    indexCol=1;
                end
                col=pColor(indexCol(1),:);
            else
                col=min(.8,rand(1,3));
            end
        else
            col=[.7 0.7 0.7];%Not sigificant
        end
        fontSize2=scale2*max(s.par.fontsizeLimits(1),min(s.par.fontsizeLimits(2),fontsize(indexQ(i))/scale*parameter(s.handles.plotkeywordsFontsize)));
        set(h,'fontsize',fontSize2,'color',col,'HorizontalAlignment','center','fontname',s.par.plotFontname);
        d=findEmptySpace(d,h);
        d.word{j}=word{indexQ(i)};
        j=j+1;
    end
    i=i+1;
end
if d.skipLimits
    return
end
d.Nploted=j;
warning on;
axis off

if not(isfield(d,'Extent'))
    d.Extent=[0 0 0 0;0 0 0 0];d.h=[];
elseif size(d.Extent,1)==1
    d.Extent(2,:)=d.Extent(1,:);
end

%Print legends for p-values
if not(isfield(s.par,'plotSignificantLegend')) s.par.plotSignificantLegend=1;end
if s.par.plotSignificantColors==3 & not(strcmpi(s.par.plotNominal,'nominal'))
    Xlim=max(get(gca,'Xlim'));
    Ylim=max(get(gca,'Ylim'));
    yCol=0;
    if not(isfield(d,'pCluster')) d.pCluster=NaN(1,length(uniCol2));end
    for i=1:length(uniCol2)
        tmp=find(uniCol2(i)==cluster);
        if strcmpi(s.par.plotNominal,'nominal') %isfield(s.par,'plotNominalLabels')
            w=s.par.plotNominalLabels{i};
        else
            w='Cluster';
            try;[~,tmp2]=max(fontsize(tmp));w=word{tmp(tmp2)};end
        end
        if i<=length(d.pCluster) & not(isnan(d.pCluster(i)))
            w=['p=' sprintf('%.4f',d.pCluster(i)) ', ' w ];
        end
        h=text(Xlim*.75,Ylim*.7-yCol,w,'Color',pColor(i,:));
        yCol=yCol-h.Extent(4);
    end
    h=text(Xlim*.75,Ylim*.7-yCol,'Clusters','Color',[0 0 0]);
    yCol=yCol-h.Extent(4);
elseif s.par.plotSignificantLegend & s.par.plotSignificantColors>0 & not(dimensions==3)
    yCol=0;
    tmp=max(d.Extent);
    Xlim=tmp(1)+tmp(3);%max(get(gca,'Xlim'));
    Ylim=tmp(2)+tmp(4);%Ylim=max(get(gca,'Ylim'));
    d.Extent=[d.Extent ;[Xlim*1.1 Ylim*1.1 0 0]];
    if s.par.plotSignificantColors==7
        unit='z';
    else
        unit='p';
    end
    if strcmpi(s.par.plotColorCodesFor,'value')
        pDisplayOrder=+1;
    else
        pDisplayOrder=-1;
    end
    for i=1:length(pCrit)
        if pCrit(i)==0
            pString{i}=[unit '<1e-9'];
        elseif pCrit(i)>=.01 & pCrit(i)<=1
            pString{i}=[unit '<' sprintf('%.2f', pCrit(i))];
        else
            pString{i}=[unit '<' regexprep(num2str(pCrit(i)),'e-0','e-')];
        end
        if s.par.plotSignificantColors==6
            tmp=find(pCrit(i)>=colorMapP);
            pColor(i,:)=colorMap(tmp(1),:);
        elseif s.par.plotSignificantColors==7
            tmp=find(pCrit(i)<=colorMapP);
            if isempty(tmp) tmp=length(colorMapP);end
            pColor(i,:)=colorMap(tmp(1),:);
        elseif s.par.plotSignificantColors==4
            pString{3}='p=0 Color';pColor(3,:)=[.5 1 0];
            pColor(2,:)=[.2 .2 .2];
            pColor(1,:)=[.5 .50 .50];
        end
        h=text(Xlim*.9,Ylim*.75-yCol,pString{i},'Color',pColor(i,:));
        yCol=yCol+pDisplayOrder*h.Extent(4);
    end
    h=text(Xlim*.9,Ylim*.75-yCol,'p>.05','Color',[0.7 0.7 0.7]);%Not significant
    yCol=yCol+pDisplayOrder*h.Extent(4);
    if s.par.keywordsPlotPvalue==1
        correctionType='All words';
    else
        correctionType=d.correctionType;
    end
    h=text(Xlim*.9,Ylim*.75-yCol,correctionType,'Color',[0 0 0]);%Correction type
    yCol=yCol+pDisplayOrder*h.Extent(4);
    for i=1:max(1,dimensions)
        h=text(Xlim*.9,Ylim*.75-yCol,par{i}.plotTestType,'Color',[0 0 0]);%Correction type
        yCol=yCol+pDisplayOrder*h.Extent(4);
    end
    
    h=text(Xlim*.9,Ylim*.75-yCol,regexprep(regexprep(regexprep(s.languagefile,'space ',''),'.mat',''),'_',''),'Color',[0 0 0]);%Space name
    yCol=yCol+pDisplayOrder*h.Extent(4);
        
    if strcmpi(par{i}.plotCloudType,'category')
        tmp=['Category(' s.par.plotCategory ')'];
    else
        tmp=par{i}.plotCloudType;
    end
    h=text(Xlim*.9,Ylim*.75-yCol,tmp,'Color',[0 0 0]);%Correction type
    yCol=yCol+pDisplayOrder*h.Extent(4);
    %if not(s.par.excelServer) | 1
    h=text(Xlim*.9,Ylim*.75-yCol,regexprep(s.par.variableToCreateSemanticRepresentationFrom,'_',''),'Color',[0 0 0]);%Correction type

    %Df (i.e. N)
    yCol=yCol+pDisplayOrder*h.Extent(4);
    h=text(Xlim*.9,Ylim*.75-yCol,['df=' num2str(d.df)],'Color',[0 0 0]);%Correction type
    
    %condition_string
    yCol=yCol+pDisplayOrder*h.Extent(4);
    h=text(Xlim*.9,Ylim*.75-yCol,regexprep(s.par.condition_string,'_',' '),'Color',[0 0 0]);%Correction type

    yCol=yCol+pDisplayOrder*h.Extent(4);
    %else
    if s.par.excelServer
        if not(isfield(s.par,'userCallId'))
            s.par.userCallId='';
        end
        if length(s.par.userCallId)==0; s.par.userCallId='';end
        h=text(Xlim*.9,Ylim*.75-yCol,s.par.userCallId,'Color',[0 0 0],'fontweight','bold','fontangle','italic');%Correction type ,'Rotation',15     
        %line([h.Extent(1) h.Extent(1)+h.Extent(3)],h.Extent(4)*.2+[h.Extent(2) h.Extent(2)],'color','r')
        yCol=yCol+pDisplayOrder*h.Extent(4);
    end
end

%Plot significant lines, and arrows
if isfield(d,'plotSignificantLines') & d.plotSignificantLines 
    %if isfield(d,'df') df=d.df; else df=length(x);end
    df=length(x);%Change 2018-04-18. Is this correct?
    plotSignificantLines(s,par,df,dimensions,labels,d)
elseif s.par.plotWordcloud & not(s.par.plotCluster) & not(strcmpi(par{1}.plotNominal,'nominal')) & not(s.par.plotOnCircle)
    if isfield(s.par,'plotNominalLabels') & length(s.par.plotNominalLabels)>=2
        Low1 =s.par.plotNominalLabels{1};
        High1=s.par.plotNominalLabels{2};
    else
        Low1 =['Low '  labels{1} ];
        High1=['High ' labels{1} ];
    end
    fontSizeLabel=15;
    if dimensions==1
        yLabel=max(d.Extent(:,2))+.1;
        text(-1,yLabel,Low1 ,'HorizontalAlignment','center','fontsize',fontSizeLabel)
        text(+1,yLabel,High1,'HorizontalAlignment','center','fontsize',fontSizeLabel)
        d.Extent=[d.Extent ;[-1 yLabel -1 yLabel]];
    elseif dimensions>=2
        if isfield(s.par,'plotNominalLabels') & length(s.par.plotNominalLabels)>=4
            Low2 =s.par.plotNominalLabels{3};
            High2=s.par.plotNominalLabels{4};
        else
            Low2 =['Low '   labels{2}];
            High2=['High '  labels{2}];
        end
        if dimensions==3
            if isfield(s.par,'plotNominalLabels') & length(s.par.plotNominalLabels)>=6
                Low3 =s.par.plotNominalLabels{5};
                High3=s.par.plotNominalLabels{6};
            else
                
                Low3 =['Low'  labels{3} ];
                High3 =['High'  labels{3} ];
            end
            text(-1, 0, 0,Low1 ,'HorizontalAlignment','center','fontsize',fontSizeLabel)
            text( 1, 0, 0,High1,'HorizontalAlignment','center','fontsize',fontSizeLabel)
            text( 0,-1, 0,Low2 ,'HorizontalAlignment','center','fontsize',fontSizeLabel)
            text( 0, 1, 0,High2,'HorizontalAlignment','center','fontsize',fontSizeLabel)
            text( 0, 0,-1,Low3 ,'HorizontalAlignment','center','fontsize',fontSizeLabel)
            text( 0, 0, 1,High3,'HorizontalAlignment','center','fontsize',fontSizeLabel)
            if 1 %Make a 3d cube!
                for x=[-1 1];
                    for y=[-1 1];
                        for z=[-1 1];
                            for x2=[-1 1];
                                for y2=[-1 1];
                                    for z2=[-1 1];
                                        line([+x2  +x2],[+y2 +y2],[+z  +z2]);
                                        line([+x2  +x2],[+y  +y2],[+z2 +z2]);
                                        line([+x   +x2],[+y2 +y2],[+z2 +z2]);
                                    end
                                end
                            end
                        end
                    end
                end
            end
            if 0
                dcorners={'Benovalent','Machivellian','Narcissistic','Psychophatic','Manipulative-Narcissistic','Anti-social','Psychophatic-Narcissistic','Maleficent'};
                dcorners={'Apathetic','Bossy','Dependent','Disorganized','Organized','Absolutist','Moody','Creative'};
                text(-1,-1,-1+.4,dcorners{1},'fontsize',fontSizeLabel,'color','r','HorizontalAlignment','center')
                text(+1,-1,-1+.4,dcorners{2},'fontsize',fontSizeLabel,'color','r','HorizontalAlignment','center')
                text(-1,+1,-1+.4,dcorners{3},'fontsize',fontSizeLabel,'color','r','HorizontalAlignment','center')
                text(-1,-1,+1+.4,dcorners{4},'fontsize',fontSizeLabel,'color','r','HorizontalAlignment','center')
                text(+1,+1,-1+.4,dcorners{5},'fontsize',fontSizeLabel,'color','r','HorizontalAlignment','center')
                text(+1,-1,+1+.4,dcorners{6},'fontsize',fontSizeLabel,'color','r','HorizontalAlignment','center')
                text(-1,+1,+1+.4,dcorners{7},'fontsize',fontSizeLabel,'color','r','HorizontalAlignment','center')
                text(+1,+1,+1+.4,dcorners{8},'fontsize',fontSizeLabel,'color','r','HorizontalAlignment','center')
            end
        else
            Low1=regexprep(Low1,char(10),' ');
            Low2=regexprep(Low2,char(10),' ');
            High1=regexprep(High1,char(10),' ');
            High2=regexprep(High2,char(10),' ');
            text(-1,  -0,[Low1  ', ' char(10)  Low2 ],'HorizontalAlignment','center','fontsize',fontSizeLabel)
            text(+1,  -0,[High1 ', ' char(10) Low2 ],'HorizontalAlignment','center','fontsize',fontSizeLabel)
            text(-1,+1.7,[Low1  ', ' char(10) High2],'HorizontalAlignment','center','fontsize',fontSizeLabel)
            text(+1,+1.7,[High1 ', ' char(10) High2],'HorizontalAlignment','center','fontsize',fontSizeLabel)
            d.Extent=[d.Extent ;[0 1.7 0 0]];
        end
    end
end

%Resize figure
%This currently only works when the data is near origo, there these odd
%conditions
if not(isfield(d,'setLimits')) & isfield(d,'Extent') & mean(sign(get(gca,'Xlim')))==0 & mean(sign(get(gca,'Ylim')))==0
    Max=max(abs([d.Extent(:,1)+d.Extent(:,3); d.Extent(:,1)]));%-d.x
    if dimensions==1
        lim=max(abs([get(gca,'Xlim') ]));
    else
        Max=max([Max max(abs([d.Extent(:,2)+d.Extent(:,4); d.Extent(:,2)]))]);
        lim=max(abs([get(gca,'Xlim') get(gca,'Ylim') get(gca,'Zlim') ]));
    end
    shrink=s.par.plotWordSize*lim/Max;
    if d.Nploted<=5
        shrink=shrink*1.2;
    elseif length(word)<=10
        shrink=shrink*1.5;
    end
    if isnan(shrink) | isinf(shrink) shrink=1;end
    fprintf('Resizeing factor %.3f\n',shrink)
    set(gca,'Xlim',1/shrink*get(gca,'Xlim'));
    set(gca,'Ylim',1/shrink*get(gca,'Ylim'));
    set(gca,'Zlim',1/shrink*get(gca,'Zlim'));
    for i=1:length(d.h)
        set(d.h(i),'fontsize',d.h(i).FontSize*shrink);
    end
    if 0 %Testing - remove
        for i=1:length(d.h)
            d.Extent(i,:)=get(d.h(i),'Extent');
        end
        xMax=max(abs([d.Extent(:,1)+d.Extent(:,3); d.Extent(:,1)]));%-d.x
        yMax=max(abs([d.Extent(:,2)+d.Extent(:,4); d.Extent(:,2)]));%-d.y
        set(gca,'Xlim',[-xMax xMax])
        set(gca,'Ylim',[-yMax yMax])
    end
end

if length(s.par.plotTitle)>0
    title(s.par.plotTitle);    
end

if length(s.par.plotSaveFolder)>0
    try
        d.file=[s.par.plotSaveFolder '/Figures-' s.par.variableToCreateSemanticRepresentationFrom '-' labels{1} '-'  labels{2} '-' labels{3} num2str([s.par.plotWordcloud s.par.plotCluster ]) s.par.plotTestType s.par.plotCloudType s.par.condition_string ];
        d.file=regexprep(file,'-axis','-empty');
        fprintf('Saving plot to file: %s\n',d.file);
        warning off; mkdir(s.par.plotSaveFolder); warning on;
        h=gcf;
        hgx(h.Number,d.file);
    end
end

%Make 3d movie
if dimensions==3;
    set(gca,'CameraPosition',[11 17 7])
    %h=plot3(0,0,0,'x','color',[1 1 1]);
    try
        if isfield(s.par,'plotFilename') & length(s.par.plotFilename)>0
            N=get(gcf,'position');%Moving figure, Do not resize
            clear F;
            for i=1:36*2
                camorbit(10/2,0,'camera')
                F(i)= getframe(gcf, [0 0 N(3) N(4)]);
                drawnow
            end
            plotSaveFolder='';
            %save([plotSaveFolder 'Movie' s.par.plotFilename] ,'F');
            myVideo  = VideoWriter([plotSaveFolder 'Movie' s.par.plotFilename]);%, 'Uncompressed AVI');
            myVideo.FrameRate = 4;  % Default 30
            myVideo.Quality = 100;    % Default 75
            open(myVideo);
            writeVideo(myVideo,F);
            close(myVideo);
        end
    catch
        fprintf('Error: Could not rotate 3d figure\n')
    end
end
if not(s.par.excelServer) %Resizes the figure, otherwise it does not show correctly, follwoing Mac OS update
    refresh;
    set(gcf,'Position',get(gcf,'Position')+[0 0 0 1]);
end

function lim=getLim(x,useX,N)
tmp=(nanmax(x)-nanmin(x))/4;
lim=[nanmin(x)-tmp nanmax(x)+tmp];
if isempty(lim) | lim(1)==lim(2) | isnan(mean(lim));
    if not(isempty(lim)) & not(isnan(mean(lim)))
        lim=[-.5+lim(1) .5+lim(1)];
    elseif nargin>1 & useX
        lim=get(gca,'Xlim')-mean(get(gca,'Xlim'));
    else
        lim=[-.5 .5];
    end
end
lim=full(lim);



function plotSignificantLines(s,par,N,dimensions,labels,d)
%par{1}=par1;par{2}=par2;par{3}=par3;
hold on
if par{1}.keywordsPlotPvalue==1 par{1}.keywordsPlotPvalue=.05;end
if par{2}.keywordsPlotPvalue==1 par{2}.keywordsPlotPvalue=.05;end
if par{3}.keywordsPlotPvalue==1 par{3}.keywordsPlotPvalue=.05;end
pcrit1=unique([0.05/N .05 par{1}.keywordsPlotPvalue]);%
pcrit2=unique([0.05/N .05 par{2}.keywordsPlotPvalue]);%
pcrit3=unique([0.05/N .05 par{2}.keywordsPlotPvalue]);%
for i=1:length(labels)
    labels{i}=regexprep(labels{i},'_','');
end
Xlim=get(gca,'Xlim');
Ylim=get(gca,'Ylim');
Zlim=get(gca,'Zlim');
%XlimC=[-.1 .1]*max(abs(Xlim));
YlimC=[-.1 .1]*max(abs(Ylim));
%ZlimC=[-.1 .1]*max(abs(Zlim));

for i=1:length(pcrit1)
    [z1 axisType1]=getSigValue(par{1},N,pcrit1(i));
    [z2 axisType2]=getSigValue(par{2},N,pcrit2(i));
    [z3 axisType3]=getSigValue(par{3},N,pcrit3(i));
    z1i(i)=z1;
    z2i(i)=z2;
    z3i(i)=z3;
    
    if i==1
        ptext='Bonferroni';
    else
        ptext=num2str(pcrit1(i));
    end
    h=text(-z1,0,[index2word(s,fixchar(ptext)) char(13) char(10) axisType1 '=' sprintf('%.2f',z1)],'HorizontalAlignment','center','Color','k');
    if dimensions>=2 & not(strcmpi(axisType1,axisType2))
        h=text(0,-z2,[index2word(s,fixchar(ptext)) char(13) char(10) axisType2 '=' sprintf('%.2f',z2)],'HorizontalAlignment','center','Color','k');
    end
    if dimensions==1
        h=text(z1,0,index2word(s,fixchar(ptext)),'HorizontalAlignment','center','Color','k');
        col=.0;
        plot([-z1 -z1],YlimC,'Color', col*[1 1 1],'LineWidth',1)
        plot([+z1 +z1],YlimC,'Color', col*[1 1 1],'LineWidth',1)
        %elseif 0 %Plot oval
        %    h=ezplot(['(x)^2/' num2str(z1) '^2 +(y)^2/' num2str(z1) '^2=1'],[-z1 +z1 -z1 +z1]);
        %    set(h, 'Color', [.8 .8 .8],'LineWidth',1);
    else %Plot rectangel
        if pcrit1(i)==.05
            c1=1;
        else
            c1=1;
        end
        if dimensions==3
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
        if z1==z2
            Ylim=max(abs(Ylim),abs(Xlim));Ylim(1)=Ylim(2);Xlim=Ylim;%Make it a square
        end
        if z1==z3
            Zlim=Ylim;%Make it a square
        end
        if Xlim(2)<z1*c1
            set(gca,'Xlim',[-z1 z1])
        end
        if Ylim(2)<z2*c1
            set(gca,'Ylim',[-z2 z2])
        end
        if Zlim(2)<z3*c1
            set(gca,'Zlim',[-z3 z3])
        end
    end
end

%Plot arrows
fontsize=20;
if dimensions==3 %Red, green, blue colors for 3d plots
    c1=[1 0 0];c2=[0 1 0];c3=[0 0 1];
else %Gray colors otherwise
    c1=[.5 .5 .5];c2=[.5 .5 .5];c3=[.5 .5 .5];
end

%x-axis
Xlim=xlim;Ylim=ylim;Zlim=zlim;
a1=.2*(Xlim(2)-Xlim(1));
a2=.2*(Ylim(2)-Ylim(1));

if strcmpi(s.par.plotAxisLocation,'Origo')
    x0=0;y0=0;z0=0;%location of axis
else
    x0= min(d.Extent(:,1));
    y0=min(d.Extent(:,2));
    %x0=Xlim(1)+.05*(Xlim(2)-Xlim(1));
    %y0=Ylim(1)+.05*(Ylim(2)-Ylim(1));
    z0=Zlim(1)+.05*(Zlim(2)-Zlim(1));
end
if dimensions==3
    h=text(x0,y0-YlimC(2)/2,z0,index2word(s,[fixchar(labels{1}) ' (' axisType1 ')']),'Rotation',0,'FontSize',fontsize,'Color',c1,'HorizontalAlignment','center');
else
    h=text(x0,y0-YlimC(2)/2,index2word(s,[fixchar(labels{1}) ' (' axisType1 ')']),'Rotation',0,'FontSize',fontsize,'Color',c1*0);%'HorizontalAlignment','center',
end
plot(x0+a1*[0 0.5],y0+a2*[0 0]     ,'Color', c1,'LineWidth',1)
plot(x0+a1*[.4 .5],y0+[+a2/8 0],'Color', c1,'LineWidth',1)
plot(x0+a1*[.4 .5],y0+[-a2/8 0],'Color', c1,'LineWidth',1)

%y-axis
if not(dimensions==1)
    if dimensions==3
        h=text(x0+YlimC(2)/2,y0,z0   ,index2word(s,[fixchar(labels{2}) ' (' axisType2 ')']),'Rotation',90,'FontSize',fontsize,'Color',c2,'HorizontalAlignment','center');
    else
        h=text(x0-YlimC(2)/2,y0,index2word(s,[fixchar(labels{2}) ' (' axisType2 ')']),'Rotation',90,'FontSize',fontsize,'Color',c2*0);%'HorizontalAlignment','center',
    end
    plot(x0+[0 0]        ,y0+a2*[0 .5]    ,'Color', c2,'LineWidth',1)
    plot(x0+[+a1/8 0],y0+a2*[.4 .5],'Color', c2,'LineWidth',1)
    plot(x0+[-a1/8 0],y0+a2*[.4 .5],'Color', c2,'LineWidth',1)
end

%z-axis
if dimensions==3
    h=text(x0,y0,z0+a2*.5   ,index2word(s,[fixchar(labels{3}) ' (' axisType3 ')']),'Rotation',90,'FontSize',fontsize,'Color',c3,'HorizontalAlignment','center');
    plot3(x0+[0 0],y0+a2*[0 0]   ,z0+a2*[0 .5]    ,'Color', c3,'LineWidth',1)
    plot3(x0+[0 0],y0+a2*[+.05 0],z0+a2*[.4 .5],'Color', c3,'LineWidth',1)
    plot3(x0+[0 0],y0+a2*[-.05 0],z0+a2*[.4 .5],'Color', c3,'LineWidth',1)
    axis off
end

function [z axisType]=getSigValue(par,N,pcrit)
if strcmpi(par.plotTestType,'frequency') %par.plotwordCountCorrelation==0
    z=(chi2inv(1-pcrit,1)/N)^.5;
    axisType='phi';
elseif strcmpi(par.plotTestType,'train') | strcmpi(par.plotTestType,'semanticTest') | strcmpi(par.plotTestType,'semantic')
    z=-norminv(pcrit);
    axisType='z';
else
    if N<3 %Otherwise, fminsearch will not converge, this removes error message:
        z=.05;
    else
        banana=@(coef)abs(2*tcdf(-abs(coef.*sqrt((N-2)./(1-coef.^2))),N-2)-pcrit)+(coef>1)*coef;
        [z tmp]= fminsearch(banana,.05);
    end
    axisType='r';
end
if isfield(par,'scale')
    axisType=par.scale;
end
    
function m=setNan(x);
if nanmean(x)==0
    m=0;
elseif nanmin(x)<0 & nanmax(x)>0
    m=0;
else
    m=nanmean(x);
end

function x=removeOutliers(x,zm)
if nargin<2 zm=5;end
x(find(zTransform(x)<-zm))=nanmean(x)-zm*nanstd(x);
x(find(zTransform(x)>+zm))=nanmean(x)+zm*nanstd(x);


