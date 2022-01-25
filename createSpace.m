function s=createSpace(file,synonymfile,ngramfile,par);
%createSpace('File','test.txt');
s=[];
if nargin<4
    par=[];
end
par=structCopy(getPar,par);
if nargin<1
    [file,path]=uigetfile2('*.txt','Choice corpus file','');
    if file==0;
        return
    end
    par.languageCode=inputdlg3('Specifiy two digit language code, e.g. ''en'' for English ''sv'' for Swedish etc','');
    if not(length(par.languageCode)==2)
        return
    end
    par.path=path;
end
par.file=file;

if nargin>=2
    par.synonymFile=synonymfile;
else
    par.synonymFile='';
end
if nargin>=3
    par.ngramfile=ngramfile;
else
    par.ngramfile=0;
end
%par.pathResults=pwd;
par.func='createSpace';
par.multi=0;
s=ngram(par);
getSpace('set',s);

