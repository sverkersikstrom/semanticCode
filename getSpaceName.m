function [space,languageId,languageNames]=getSpaceName(documentlanguage);
languageId=[];
space=[];

languageNames={'sv','spaceSwedish';
    'sv2','spaceSwedish2';
    'sv3','spaceSwedish3';
    'svC1','spaceStudiesAllSwedishLink';
    'en2','spaceEnglish2';
    'en','spaceEnglish';
    'no','spaceNorwegian';
    'es','spaceSpanish';
    'nl','spacedutch';
    'rn','spaceRomanian';%SHOULD BE 'ro' !!!!
    'it','spaceItalian';
    'de','spaceGerman';
    'fr','spaceFrench';
    'zh','spaceChinese';
    'cs','spaceczech';
    'fi','spacefinnish';
    'he','spaceHebrew';
    'pl','spacepolish';
    'pt','spaceportuguese';
    'ru','spaceRussian';
    'fa','spacepersianDone';
    'da','spacedanishDone'
    'fb','spaceFacebookWWW';
    'ft','spaceFacebookIndexTest';
    };
if nargin==0
   documentlanguage=''; 
end
documentlanguage=regexprep(documentlanguage,'\.mat','');
i=find(strcmpi(languageNames(:,1),documentlanguage));
if not(isempty(i))
    space=languageNames{i,2};
else
    space=documentlanguage;
end
if nargin>0
    i=find(strcmpi(languageNames(:,2),documentlanguage));
    if not(isempty(i))
        languageId=languageNames{i,1};
    else
        for i=1:size(languageNames,1)
            if not(isempty(strfind(upper(languageNames{i,2}),upper(documentlanguage))))
                languageId=languageNames{i,1};
            end
        end
    end
    if length(languageId)>2; languageId=languageId(1:2);end
end    