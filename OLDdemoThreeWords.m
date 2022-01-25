function [out,h,s]=demoThreeWords(s,index,numbers,par,labels,userNames)
%OLD plotCloudType,plotCluster,plotWordcloud,
%This code calls plotWordCloud, the new plotting function for 3woords and
%semanticexcel

%On the result page, add the following headings below the wordcloud:
%?Plot Theme      Scale Compare?
%Which has these subheadings, associated codes:

if 0
   %Exampel of how to call this function
    s=getSpace;
   [s newword index]=setProperty(s,{'_UserReference1','_UserReference2'},{'_text','_text'},{'zlatan car highway highway wheels','motorway finland'});
   %index2=index(end);
   %index=index(1:end-1);
   %[out,h,s]=demoThreeWords(s,index,'words',0,1,{'Text-Text', 'Text-Number', 'Text-Categories'},{[1 2],[3 1,],[3 4]},{'Text-Text', 'Text-Number', 'Text-Categories'},{'x-axis','y-axis','z-axis'}) 
end

%Where
if nargin<1
    s=getSpace;
end

if nargin<2
    [s newword index]=setProperty(s,{'_UserReference1','_UserReference2'},{'_text','_text'},{'zlatan zlatan motor engine volvo road car highway highway wheels','motorway finland'});
end


if nargin<3
    %Default: 
    numbers=[];%0 dimensions
    %numbers={[1 2]};%Exampel 1-dimensions
    %Example input for 3-dimensions: numbers{[1 2],[3 1,],[3 4]}
    %Notice that the length of numbers{i}==length(index)
end

if nargin<4
    par=[];
end


%if isempty(par)
    %For the time being, just set this variable to (later we may add input
    %to this
 %   if not(isnan(word2index(s,'_predvalencestenberg')))
 %       valenceProperty='_predvalencestenberg';
 %   else
 %       valenceProperty='_predvalence';
 %   end
 %   plotProperty={valenceProperty,valenceProperty,valenceProperty};
%end

if nargin<5
    labels=[];
end
if isempty(labels)
    %Explantory text on axis
    labels={'x-axis','y-axis','z-axis'};%labels=labels on the x and y axis used in scale (e.g.
end

if nargin<6
    userNames=[];
end



[out,h,s]=plotWordCloud(s,index,numbers,par,labels,userNames);
