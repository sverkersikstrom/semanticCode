function [o, s]=getWordFromUser(s,title,wordin,default2,oneWord)
%oneWord==2: No words selected
o.N=0;
while o.N==0
    if nargin<=1
        title=' ';
    end
    if nargin<=2
        wordin='';
    end
    if nargin<=3
        default2='';
    end
    if nargin<=4
        oneWord=0;
    end
    global default
    first=1;
    o.N=-2;
    while first | (oneWord==1 & o.N>1)  
        first=0;
        if default>0
            out.word=wordin;
            out.time_period=0;
            out.single_words=0;
            out.condition=0;
            out.cancel=0;
        else
            out=inputwords(title,wordin,default2,s);
            s.par=getPar;
        end
        if out.cancel | oneWord==2;
            o.N=0;o.out=out;o.ok=0;o.index=[];o.input_clean='';o.input='';
            return;
        end
        [o s]=getWord(s,out.word,out);
        out.reportWord=0;
        
        if oneWord & o.N>1
            questdlg2('You can only select one word','Ok','Ok');
        end 
    end
    o.out=out;
    if o.N==0
        questdlg('Word not found in space, try again','Ok','Ok','Ok');
    end
end
%s=updateContext(s,o.index);
if o.condition
    s.par.condition_string=o.condition_string;
else
    s.par.condition_string='';
end
o.par=s.par;
s=getSpace('set',s);

