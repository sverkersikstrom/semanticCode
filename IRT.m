function out=IRT(s,index,data,variabels)
out=[];
if 0
    %Debug data
    IRT(s,wordSet.index,data,variabels)
    s=[];
    par=[];
    par.langFile='spaceEnglish2';
    [s, par]=scriptTrain(s,par);
    
    [wordSet,s] =getWord(s,'_WorkingdataFinal*');
    index=wordSet.index;

    variabels='_predgadtotcrossvalidation _gad1	_gad2	_gad3	_gad4	_gad5	_gad6	_gad7';
    %'_predgad1crossvalidation _predgad2crossvalidation _predgad3crossvalidation _predgad4crossvalidation _predgad5crossvalidation _predgad6crossvalidation _predgad7crossvalidation
    %_gadtot	_phqtot	_pswqtot	_sdstot	_liescaletot	_mcsdstot
    %'_predgadtotcrossvalidation _predphqtotcrossvalidation _predsdstotcrossvalidation _predliescaletotcrossvalidation _predmcsdstotcrossvalidation 
    data=getProperty(s,index,strread(variabels,'%s'));
    variabels=strread(regexprep(variabels,'_',''),'%s');
    %data=dlmread('example_rasch.txt',' ');
    
    %data=dataOrg;
    %data(:,10)=rand(size(data,1),1);
    %data(:,10)=dataOrg(:,10)*1.0;%*0+rand(size(data,1),1)>0.5;
    %data(:,1)=fix(data(:,3)+rand(size(data(1),1))-.5);
end

if nargin<1 %wordSet space
    s=getSpace('s');
end

if nargin<2 %Get particpants
    [wordSet, s]=getWordFromUser(s,'Choose particpants to apply IRT to');
    if wordSet.N==0; return; end
    index=wordSet.index;
end

if nargin<3 %Get IRT variables to analys
    [setV, s]=getWordFromUser(s,'Choose variabls for IRT');
    if setV.N==0; return; end
    variabels=setV.fwords;
    data=getProperty(s,index,setV.index);
end

if nargin<4 & not(exist('variabels')==1) %Get variable names
    for i=1:size(data,2)
        variabels{i}=sprintf('variable%d',i);
    end
end

if size(data,2)==1
    isNaN=isnan(data');
else
    isNaN=isnan(sum(data'));
end
if not(isempty(find(isNaN)))
    fprintf('Removing %d datapoints with NaN values\n',length(find(isNaN)))
    data=data(not(isNaN),:);
end

%Recodes continous data into categories
Ncategories=4;
dataOrg=data;
maxVariables=10;
if 0 | size(data,2)==1
    variables2=[];
    k=0;
    for j=1:size(data,2)
        udata=unique(data(:,j));
        for i=1:length(udata)
            %data(:,1)=data(:,1)==i;
            tmp=find(data(:,1)==i);
            k=k+1;
            data2(tmp,k)=1
            variables2{k}=[variabels{1} '_' num2str(i)];
        end
    end
    data=data2;
    variables=variables2;
elseif 0
    for i=1:size(data,2)
        data(:,i)=(data(:,i)-min(data(:,i)))/(max(data(:,i))-min(data(:,i)));
    end
else
    dataOrg=data;
    norm='mean';
    if not(isfield(s.par,'IRTscale')) s.par.IRTscale=1;end
    if strcmpi(norm,'item1')
        u=unique(dataOrg(:,1));
        %clear data;
        for i=1:length(u)-1
            data(:,i)=dataOrg(:,1)>u(i);
        end
    else
        for i=1:size(data,2)
            if strcmpi(norm,'r') % & length(unique(data(:,i)))>maxVariables
                fprintf('Recoding variable %s to %d categories\n',variabels{i},Ncategories);
                [~,sortD]=sort(data(:,i));
                data(sortD,i)=fix(Ncategories*[1:length(sortD)]/(length(sortD)+1));
            elseif strcmpi(norm,'0-1')
                data(:,i)=(dataOrg(:,i)-nanmin(dataOrg(:,i)))/(nanmax(dataOrg(:,i))-nanmin(dataOrg(:,i)));
            elseif strcmpi(norm,'b')
                %binary
                data(:,i)=data(:,i)>median(data(:,i));
            elseif strcmpi(norm,'mean')
                data(:,i)=dataOrg(:,i)>nanmean(dataOrg(:,i));;%nanmedian(dataOrg(:,i));%z-transform and truncate
            elseif strcmpi(norm,'median')
                data(:,i)=dataOrg(:,i)>nanmedian(dataOrg(:,i));;%nanmedian(dataOrg(:,i));%z-transform and truncate
            elseif strcmpi(norm,'medianAll')
                data(:,i)=dataOrg(:,i)>nanmean(nanmean(dataOrg));%nanmedian(dataOrg(:,i));%z-transform and truncate
                %data(:,i)=dataOrg(:,i)>nanmedian(dataOrg(:,i));%z-transform and truncate
            elseif strcmpi(norm,'z')
                data(:,i)=fix(s.par.IRTscale*(data(:,i)-nanmean(nanmean(dataOrg)))/nanmean(nanstd(dataOrg)));%z-transform and truncate
            end
            %data(:,i)=fix((data(:,i)-nanmean(data(:,i)))/nanstd(data(:,i)));%z-transform and truncate
            %data(:,i)=(data(:,i)-nanmean(data(:,i)))/nanstd(data(:,i));%z-transform
        end
    end
end
%data=max(-3,min(3,data));
%Set settings
SETTINGS = IRTmSet();
SETTINGS.input = data;
varIndex=[1:size(data,2)];
SETTINGS.I=varIndex;

%Set IRT model
MODEL = IRTmModel(length(varIndex),'2PL');

%Call IRT model
OUTPUT = IRTm(SETTINGS,MODEL);

%Print model results
sumCheck=sprintf('Optimum: %d\n%s\n%s\n',OUTPUT.optim,OUTPUT.message,OUTPUT.HEScheck);
sumModel=IRTmSummary(OUTPUT,'param',MODEL);
sumGof=IRTmSummary(OUTPUT,'gof');
sumPred=IRTmSummary(OUTPUT,'pred');

%set variables from OUTPUT
A=OUTPUT.param(1:length(varIndex));
B=OUTPUT.param(length(varIndex)+1:end);
theta = OUTPUT.ebe(OUTPUT.Index);
thetaSE = OUTPUT.ebeSE(OUTPUT.Index);
[~, order]=sort(theta);
[I,P,Q]=Information(theta,A,B);
[Id,Pd,Qd]=Information(data,A,B);

%figure 1: Histogram of theta
figure(1);hold off
plot(theta(order),thetaSE(order));
xlabel('\theta_p');
ylabel('SE(\theta_p)');

%figure 2: Information as function of theta divided into items
figure(2);
hold off;plot(theta(order),I(order,:),'linewidth',2);
xlabel('\theta_p');
ylabel('I(\theta_p)');
%hold on;plot(theta(order),mean(I(order,:)'),'k','linewidth',4);
legend([regexprep(variabels,'_','') ]);%; 'total'
title(regexprep(s.par.variableToCreateSemanticRepresentationFrom,'_',' '));
set(gcf,'color',[1 1 1]);
%hold on;plot(theta(order),(I(order,1)'),'r','linewidth',4);

%Histogram
figure(3);
hold off
for i=1:size(data,2)
    h=histogram(data(:,i),10,'Displaystyle','stairs');%,'Normalization',Normalization
    hold on
end
title('Histogram')
ylabel('N')
legend([regexprep(variabels,'_','')]);



resultTabel=sprintf('i\ttheta\t');
for i=1:size(data,2);resultTabel=[resultTabel sprintf('item%d\t',i)];end
for i=1:size(data,2);resultTabel=[resultTabel sprintf('theta%d\t',i)];end
resultTabel=[resultTabel sprintf('\n')];

for p=1:size(data,1);
    [items,thetaP(p,:),itemsThetaZero]=getBestOrder(data(p,:),A,B);
    resultTabel=[resultTabel sprintf('%d\t%.3f\t',p,theta(p))];
    resultTabel=[resultTabel sprintf('%s\t',num2str(items,'%d\t'))];
    resultTabel=[resultTabel sprintf('%s\n',num2str(thetaP(p,:),'%.2f\t'))];
end

sumThetaZero=sprintf('Item information in descreasing order (given no previous information of a participants performance):\nitemsThetaZero=\t%s\nitemsThetaZero= %s\n',cell2string(variabels(itemsThetaZero),char(9)),num2str(itemsThetaZero,'%d\t'));

%Set output variables
out.results=sprintf('\n%s\n%s\n%s\n%s\n%s\n',sumCheck,sumModel,sumGof,sumThetaZero,sumPred);

out.results=[out.results sprintf('\nr(theta-sum(fix(z-data)))=%.3f\n',corr(theta,sum(dataOrg')'))];
out.results=[out.results sprintf('r(theta-sum(      data) )=%.3f\n',corr(theta,sum(data')'))];
for i=1:size(thetaP,2)
    out.results=[out.results sprintf('r(%d)=%.3f\t',i,corr(theta,thetaP(:,i)))];
end

out.A=A;
out.B=B;
out.I=I;
out.theta=theta;
out.thetaSE=thetaSE;
out.SETTINGS=SETTINGS;
out.MODEL=MODEL;
out.OUTPUT=OUTPUT;
out.resultTabel=resultTabel;

info.A=A;
info.B=B;

fprintf('%s',resultTabel);
%fprintf('%s',out.results)
showOutput({out.results})
1;

function [items,thetaP,itemsThetaZero]=getBestOrder(data,A,B) 
items=[];
thetaP=0;
for t=1:size(data,2) 
    [Ip,P,Q]=Information(thetaP(max(t-1,1)),A,B);    
    Ip(items)=-Inf;
    [~,orderI]=sort(Ip,'descend');
    items(t)=orderI(1);
    if t==1
        itemsThetaZero=orderI;
    end
    thetaP(t) = fminsearch(@(theta) Imin(theta,A,B,items,data(items)), 0);
end

function t=Imin(theta,A,B,items,dataItems)
t=(sum(Information(theta,A(items),B(items)))-sum(Information(dataItems,A(items),B(items))))^2;

function [I,P,Q]=Information(theta,A,B)
D=1.702;
for i=1:length(A);
    P(:,i)=1./(1+exp(-D*A(i)*(theta(:,min(i,size(theta,2)))-B(i))));
    Q(:,i)=(1-P(:,i));
    I(:,i)=D^2*A(i)^2.*P(:,i).*Q(:,i);
end
