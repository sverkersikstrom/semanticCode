function textTrans=index2word(s,text,language1,language2)
if isnumeric(text)
    if isnan(mean(text))
        text2{1}='';
        for i=1:length(text);
            if not(isnan(text(i)))
                text2{i}=s.fwords{text(i)};
            else
                text2{i}='';
            end
        end
        text=text2;
    else
        index=text<=length(s.fwords);
        tmp(index)=s.fwords(text(index));
        tmp(not(index))={''};
        text=tmp;
    end
end
textTrans=text;


if not(s.par.translate==1) | (nargin==3 & isnumeric(language1) & language1==0)
    return %Do not translate!
end
%[~,languageId,~]=getSpaceName(regexprep(s.languagefile,'\.mat',''));
%if isempty(languageId)
%    languageId='sv';
%end
textTrans = gtranslate(s,text, '', '',[],1);


%Replace words
if length(s.par.plotReplaceWords)>0
    plotReplaceWords=textscan(s.par.plotReplaceWords,'%s','delimiter',',');plotReplaceWords=plotReplaceWords{1};
    for i=1:length(plotReplaceWords)
       ReplaceWords=textscan(plotReplaceWords{i},'%s');ReplaceWords=ReplaceWords{1};
       if length(ReplaceWords)==2
           textTrans=regexprep(textTrans,ReplaceWords{1},ReplaceWords{2});
       end
    end
end


