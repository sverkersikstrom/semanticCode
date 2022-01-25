excelServer=1;
if excelServer
    text1    = ret.get('text1');
    reftext1    = ret.get('reftext1');
    text2    = ret.get('text2');
    reftext2    = ret.get('reftext2');
    prefix    = ret.get('prefix');
    answer='';
    for j=1:text1.size
        %answer1='';
        %ref1='';
        %ref1=strcat('_ref',prefix,reftext1.get(j-1));
        %ref2='';
        %ref2=strcat('_ref',prefix,reftext2.get(j-1));
        REF1{j}=reftext1.get(j-1);%Perhaps this is not needed if you can make all call reftext1.get(0:length(text1.size-1)) ?
        REF2{j}=reftext2.get(j-1);
        %property{j}='_text';
        %Tips, for speed opimization call setProrperty with cell several cell references at the same time:
        
        %[s tmpa1 tmpb1]=setProperty(s,ref1,'_text',text1.get(j-1));
        %[s tmpa2 tmpb2]=setProperty(s,ref2,'_text',text2.get(j-1));
        %[~, answer1,s]= getProperty(s,tmpb1,tmpb2); %similarity(ref1,ref2);
        %if j==1
        %    answer = strcat(answer,answer1{1});
        %else
        %    answer = strcat(answer,';',answer1{1});
        %end
    end
else
    ref1{1}='_text11';
    ref1{2}='_text12';
    ref2{1}='_text21';
    ref2{2}='_text22';
    REF1{1}='mother';
    REF1{2}='father';
    REF2{1}='brother';
    REF2{2}='sister';
end

property='_text';

[s refNew1 index1]=setProperty(s,ref1,property,REF1);
[s refNew1 index2]=setProperty(s,ref2,property,REF2);

if length(unique(index1))==1 %This is much faster if all index1 are the same!
    [~, answer,s]= getProperty(s,index1(1),index2);
else
    for i=1:length(index1)
        [~, answer(i),s]= getProperty(s,index1(i),index2(i));
    end
end

getSpace('set',s);

m = java.util.HashMap;
m.put('results',answer);
m.put('refkey',refkey);
meexcel.setSimilarity(m);