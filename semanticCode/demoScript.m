function demoScript(s,db);
if nargin<2
    db=0;
end
db=1;

%This file shows how to use scripts in semantics

%lang='space_allmansum3';
lang='spaceenglish';
text={'Volvo is a good car','Saab is a car. He is great','Fruit is good','Dinner will be served'};
ref={'_reference1','_reference2','_reference3','_reference4'};
if db
    document='test';%This is the name of the document/or question.
    %type='clear';%Clear all data, and load them from again from dB. 
    %type='';%Default. reads word vectors in the the s-stucture, do not update. 
    type='update';%Change the texts. 
    s=[];%Startinga a new strucutre here, but you can also add data from and exisint s-structure
    par=getPar; %Here we set parameters.
    par.db2space=db;
    [s, index]=getSfromDB(s,lang,document,ref,text,type,par);%Adds documents referenced with "ref" consiting of text in "text" to the s2-structure, using the langugae in "lang" and we call this document "document"
else
    
    %Load new space from harddrive
    %s=getNewSpace('/Users/sverkersikstrom/Dropbox/ngram/spaceSwedish2.mat')
    if nargin<1
        s=getNewSpace(lang)
        
        %Load space from memory
        s=getSpace;%Get current space, if no space loaded opens ask for a filename
        s=getSpace('',[],lang)  %Get space named 'space_allmansum3'
        
        %s=getSpace('keepData',[],'spaceDemoScript');%Keep current data in the dataspace while adding a new space data
        
        %Save space in internal memory (not to harddrive).
    end
    getSpace('set',s);
    
    
    s.par.updateReportAutomatic=2;%Deactivates reports...
    
    %Define four texts!
    s.par.documentId=2;%Texts belonging to document 2.
    %NOTICE THAT THE SPACE FILE IS DOCUMENT=1 - DO NOT USE THIS AS A DOCUMENT
    
    [s tmp index(1)]=setProperty(s,ref{1},'_text',text{1});
    [s tmp index(2)]=setProperty(s,ref{2},'_text',text{2});
    [s tmp index(3)]=setProperty(s,ref{3},'_text',text{3});
    s.par.documentId=3;%%Texts belonging to document 3.
    [s tmp index(4)]=setProperty(s,ref{4},'_text',text{4});
    
    %Save space to harddrive
    saveSpace(s,'spaceDemoScript');%Save all data
    remove=0;%If 1, removes data from s, otherwise keep it in s
    s=saveSpace(s,'spaceDemoScript',[],2,remove);%Save data from document 2 in file spaceDemoSript2!
    s=saveSpace(s,'spaceDemoScript',[],3,remove);%Save data from document 3 in file spaceDemoSript2!
    
    remove=1;%Removes and save document 3
    s=saveSpace(s,'spaceDemoScript',[],3,remove);%Save data from document 3 in file spaceDemoSript2!
    %Restore document 3
    %s=getSpace('keepData',s,'spaceDemoScript3');%Keep data in the dataspace
    
    %Three ways of saveing the data in semanticexcel
    %1 When leaving a page, save and remove
    s=saveSpace(s,'spaceDemoScript',[],3,1);%Save data from document 3 in file spaceDemoSript2!
    %2 When more then 30 minuts have passed since laste change
    iLoop=find(s.par.documentNumber>0);
    for i=1:iLoop
        if s.par.documentTime(i)>0 & abs(s.par.documentTime(i)-now)>.5/24
            s=saveSpace(s,'spaceDemoScript',[],i,1);%Save data from document 3 in file spaceDemoSript2!
        end
    end
    %3 When the number of identifiers in s exceeds 250k!
    if s.N>250000
        tmp=s.par.documentTime;tmp(tmp==0)=now;[~,i]=max(now-tmp);
        s=saveSpace(s,'spaceDemoScript',[],i,1);%Save data from document 3 in file spaceDemoSript2!
    end
    
    
    %Tips, for speed opimization call setProrperty with cell several cell references at the same time:
    [s newword index]=setProperty(s,ref,{'_text','_text','_text','_text'},text);
end


%Set property '_mydata' in word '_reference1'/index(1) to 3
s=setProperty(s,index(1),'_mydata',3);

%Optionally you can get the index of _reference1 by....
index(1)=word2index(s,'_reference1')

%Semantic similiarity
[~,~,s]=getProperty(s,index(1),index(2))

%Frequency property of _reference1
[~,~,s]=getProperty(s,index(1),'_frequency')
%For most proporties the order does not mather, the same results is given for
[~,~,s]=getProperty(s,'_frequency',index(1))

%However, for LIWC scures, you need to have the _liwc* identifier as the second (not third) argument
[~,~,s]=getProperty(s,'_liwcpersonalpron',index(1))
%This does NOT work getProperty(s,index(1),'_liwcpersonalpron')

%Get property _mdataa from _reference1
[~,~,s]=getProperty(s,index(1),'_mydata')

%Get property can be used without storing a text, with the following syntex.
%Note that tbe text is automatically stored in identifier _temp1, temp2... etc
[Numeric CellString s]=getProperty(s,'_predvalence',ref)

%Association list property of mamma (%For other association, see getProperty)
[Numeric CellString s]=getProperty(s,index(1),'_associates');fprintf('%s\n',CellString{1})

%Semantic test between two wordsets
[out,s]=semanticTest(s,index(1:2),index(3:4))
out.results %Print results

%Keyword frequency test between two wordsets
[out s]=keywordsTest(s,index(1:2),index(3:4))
out.results %Print results

%Keyword frequency test between one wordset and numericalData
numericalData=rand(1,length(index));
[out s]=keywordsTest(s,index,NaN,0,'','',2,numericalData)

%Semantic test between property1 in identifier 1-2 and property2 in identifier 3-4
out=semanticTestProperty(s,index(1:2),index(3:4),'mamma','pappa')
out.results %Print results

%Multiple semantic test between property1 in identifier 1-2 and property2 in identifier 1-2
property=[];
indexCell{1}=index(1:2);property{1}='mamma';label{1}='Set 1';%Defines rows! Here we only define one row {(1}, but one can define multiple rows {2:N}
indexCell2{1}=indexCell{1};
property2=property;label2{2}='Set 2';;%Defines columns (optial)! However, int this example rows and columns are identical so matrix is squared!
[results out]=semanticTestPropertyMany(s,indexCell,property,label,indexCell2,property2,label2)

%Prediction predictProperity in Wordset, and storing results in setPropery
trainProp='_predfreq';%Name of identifier to the prediction model
YtrainData=[2 3 2 5];%Data to be predicted, input from user
group=[1 1 2 2];%Opitional user input which groups the data during cross-validation
XnumericalData=rand(length(index),2)%Optionally input add numerical predictors as input. In this case there are two columns of random data
Ycovariates=[1 0 1 0];%Optional input, add numerical data as input. If no input set Ycovariates=[];
indexSubtract=[];%Subtracted identifiers
[s info]=train(s,YtrainData, trainProp,index,group,XnumericalData,Ycovariates,indexSubtract);
info.results %Print results

%After training, a prediction can be made:
[~,~,s]=getProperty(s,index(1),trainProp)

%Cluster index in N clusters and store result in _clustercategory
N=2;clustercategory='_clustercategory';
[s info]=clusterSpace(s,index,N,clustercategory)

%Cluster a 'selection' of the indexes using a formula
x=(1:length(index));
formula='x>1';%Choice formula to select
eval(['selection=find(' formula ')']) %
[s info]=clusterSpace(s,index(selection),N,clustercategory)

%Plotting functions

%Plot in 1-3 dimensions, and output handles
indexCell{1}=index;%Texts plotted in one color/legend
indexCell{2}=index;%Texts plotted in another color/legend
[h1 s]=plotSpace(s,indexCell,index(1))%saveas(h1,'FigurName.eps')%Saves the figure to an .eps file!
[h2 s]=plotSpace(s,indexCell,index(1),index(2))
[h3 s]=plotSpace(s,indexCell,index(1),index(2),index(3))

%Keywords plot
%index=a set of identifiers to plot, index1=one propery defining median split of texts on x-axel, index2=one propery defining median split on texts on y-axel,
%out1 is the output for keywordsTest for set 1, out2 simliar for set 2.Print out1.results

s.par.figureType=1:15; %where the labels of 1 to 15 corresponds to:
figureTitels={'keywords','Cluster of keywords','Cluster of semantic associates','Cluster of all words','wordcloud (base word frequency','wordcloud (high-low), 7=wordcloud (low-high)','semantic LIWC','frequency LIWC', 'predictions','=variables','wordclasses','functions','clusters', 'userdefined'};
%s.par.figureType:1=keywords,2=Cluster of keywords, 3=Cluster of semantic
%associates,4=Cluster of all words, 5=wordcloud (base word frequency),
%6=wordcloud (high-low), 7=wordcloud (low-high),8=semantic LIWC,
%9=frequency LIWC, 10=predictions,11=variables, 12=wordclasses,
%13=functions, 14=clusters, 15=userdefined
[s h out1]=plotWordcount(s,index,index(1)) %One dimensional plot
[s h out1 out2]=plotWordcount(s,index,index(1),index(2),'x-axel','y-axel',[1:15]) %Two dimensional plot

%plotWordCount can also be called with the xdata and ydata as input (given
%that either one of them has a lenght longer than 1)
xdata=[2 3 4];%Input from the user in the spreadsheet
ydata=[1 2 6];%Input from the user in the spreadsheet
[s h]=plotWordcount(s,index(1:length(xdata)),xdata,ydata)


stop %The remaning functions are not needed now

[text, data, dim, labels]=textread2(file)%Reads text file

if 0 %Make space file
    d.debug=0;
    d.contextSize=5000000;
    sF=createSpace('flashback.txt',[],[],d);
end


%Plot 2d map with wordd1-wordd2 on x-axis, and wordd3-wordd4 on y-axis, and
%save axis result in propertyX and propertyY

%Defines axes to plot for dimension 1-3
%This wordset can be selected without a user interface
[wordset1 s]=getWord(s,'*bad')
[wordset2 s]=getWord(s,'*abb')
manywordset{1}=wordset1;
manywordset{2}=wordset2;
[wordd1 s]=getWord(s,'mamma');
[wordd2 s]=getWord(s,'pappa');
[wordd3 s]=getWord(s,'barn');
[wordd4 s]=getWord(s,'flicka');

propertyX='_plotsavex';
propertyY='_plotsavey';
normalDist=0;
addLabels=0;
plotDifference(s,manywordset,wordd1,wordd2,propertyY,wordd3,wordd4,propertyY,normalDist,addLabels);

%Plot an animation aross the property _time, matching words with the
%property _subjects, using 5 time periods.
plotSpace(s,manywordset,wordd1,wordd2,[],1)


%Retrieve contexts from database
contextSize=30;target='facebook';maxContext=10;
dates{1}='2012-01-01';dates{2}='2013-02-01';contextSize=30;
s=db2space(s,target,maxContext,dates,contextSize)

%Selecting a set of words, from user interface
[wordset s]=getWordFromUser(s,'Select a set of words')


fil='space_allmansum3_farhan';
s=getNewSpace(fil)
clear manywordset;
[manywordset{1} s]=getWord(s,'_fpa*')
[manywordset{2} s]=getWord(s,'_fpb*')
[wordd1 s]=getWord(s,'_time25vtime1');
[wordd2 s]=getWord(s,'_disvreh');

[time1 s]=getWord(s,'_fp*','_time==1');
[time25 s]=getWord(s,'_fp*','_time>1 && _time<=5');

[reh s]=getWord(s,'_fp*','_dicussion==1');
[dis s]=getWord(s,'_fp*','_dicussion==0');

reh.input_clean='discussion - rehearsal';
time25.input_clean='time 2-5 - time 1';
manywordset{1}.input_clean='discussion';
manywordset{2}.input_clean='rehearsal';

s.par.text_all2=0;
%plotSpace(s,manywordset,wordd1,wordd2,[],1)
plotSpace(s,manywordset,time25,reh,[],1,time1,dis)

legend({'discussion','rehearsal'})
xlabel('time 2-5 - time 1')
ylabel('discussion - rehearsal')

%Other functions
results=std([1 2 3 4])%Calculation of standard deviation in Matlab
tail='both';d1=[1 2 3];d2=[4 5 6 7];[h p]=ttest2(d1,d2,.05,tail);%ttest between d1 & d2. tail may be either 'left','right', or 'both' (default)
[r p]=nancorr(d1',d2')%Correlation d1 och d2
