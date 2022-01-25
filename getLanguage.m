function [language r]=getLanguage(text)
persistent dataL
filename='getLanguage';
if isempty(dataL)
    if not(exist([filename '\.mat']))
        folder{1}='/Users/sverkersikstrom/Dropbox/ngram/';
        folder{2}='/Users/sverkersikstrom/Dropbox/ngramManylanguages/';
        j=0;
        for k=1:2
            f=dir([folder{k} '*.mat']);
            for i=1:length(f)
                clear s;
                load([folder{k} f(i).name])
                if exist('s') %& s.dataL==0
                    fprintf('Adding %s\n',f(i).name)
                    j=j+1;
                    dataL.languageOrg{j}=f(i).name;
                    dataL.language{j}=regexprep(regexprep(f(i).name,'space',''),'\.mat','');
                    dataL.s{j}.fwords=s.fwords;
                    dataL.s{j}.hash=s.hash;
                    dataL.s{j}.f=s.f;
                    dataL.s{j}.minf=min(s.f(find(s.f>0)));
                end
            end
        end
        
        %Recodes to:
        %"de"=>"German","en" =>"English", "sv"=>"Swedish", "no"=>"Norwegian", "es"=>"Spanish", "nl"=>"Dutch", "rn"=>"Romanian", "it"=>"Italian",  "fr"=>"French", "zh"=>"Chinese", "cs"=>"Czech", "fi"=>"Finnish", "he"=>"Hebrew", "pl"=>"Polish", "pt"=>"Portuguese", "ru"=>"Russian", "fa"=>"Persian"
        for i=1:length(dataL.language)
            c=lower(dataL.language{i}(1:2));
            if strcmpi(c,'ge') c='de';end
            if strcmpi(c,'sp') c='es';end
            if strcmpi(c,'sw') c='se';end
            if strcmpi(c,'du') c='nl';end
            if strcmpi(c,'ro') c='rn';end
            if strcmpi(c,'ch') c='zh';end
            if strcmpi(c,'cz') c='cs';end
            if strcmpi(dataL.language{i}(1:3),'pol') c='pl';end
            if strcmpi(c,'po') c='pt';end
            if strcmpi(c,'pe') c='fa';end
            if strcmpi(c,'ng') c='en';end
            if strcmpi(c,'cf') c='FACEBOOK';end
            dataL.languageCode{i}=c;
            fprintf('%s\t%s\n',c,dataL.language{i});
        end
        save(filename,'dataL')
    else
        load(filename)
        dataL.par=getPar;
    end
end

if nargin<1
    text='Jag g?r hem';
end

N=length(dataL.language);
ftot=NaN(1,N);
for i=1:N
    dataL.s{i}.par=dataL.par;
    index=text2index(dataL.s{i},text);
    notNan=not(isnan(index));
    r.found(i)=length(find(notNan));
    freq(find(notNan))=dataL.s{i}.f(index(notNan));
    freq(find(not(notNan)))=dataL.s{1}.minf/2;%dataL.s{i}.minf/2
    r.ftot(i)=mean(log(freq));
end

r.languageCode=dataL.languageCode;
[tmp r.index]=sort(r.ftot,'descend');
[tmp i]=max(r.ftot);
if strcmp(dataL.languageCode{r.index(1)},dataL.languageCode{r.index(2)})
    i2=3;
else
    i2=1;
end
r.confidence=r.ftot(r.index(1))-r.ftot(r.index(i2));
language=dataL.languageCode{i};



