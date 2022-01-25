function [xlatedString ,tTranslated]= gtranslate(s,inputString, destLanguage, sourceLanguage,maxString,cache)
%TRANSLATE Uses Google web service to translate a string
%
%  str = translate(input) converts English string to Swedish using the
%          Google language API.
%
%  str = translate(input, destinationLanguage) converts English string to
%          another language. The destinationLanguage should be a two-letter
%          language code (example: en, fr, tk, es). See the Google Language
%          API for a list of supported languages:
%
%  str = translate(input, destLanguage, sourceLanguage) converts a
%          sourceLanguage string to the destLanguage. Both source and
%          destination languages must be the two letter strings.
%
% Note that many of the supported languages will be undisplayable in the
% default character encoding on Windows.
persistent d;
global rootPath
xlatedString='';

if nargin<1
    s=getSpace;
end

if nargin < 2
    inputString = 'hello';
end

if nargin < 3
    destLanguage = 'sv';
end

if length(destLanguage)==0
    if length(s.par.translateTolanguage)==2 
        destLanguage=s.par.translateTolanguage;        
    else %if length(s.par.translateTolanguage)>0 
        destLanguage='sv';
        %fprintf('Set translateTolanguage and translateFromlanguage to correct languages codes, e.g.. ''sv'', ''en''')
    end
end

if nargin < 4
    %'en' (English) is the base languagen
    sourceLanguage = '';
end

if length(sourceLanguage)==0
    if length(s.par.translateFromlanguage)==2
        sourceLanguage=s.par.translateFromlanguage;
    else %if length(s.par.translateFromlanguage)>0 
        sourceLanguage = 'en';        
        %    fprintf('Set translateTolanguage and translateFromlanguage to correct languages codes, e.g.. ''sv'', ''en''')
    end
end

if nargin<5
    maxString=[];
end
if isempty(maxString)
    maxString=1000;
end

if nargin<6
    cache=0;
end







 
if cache
    s=getSpace;
    if iscell(inputString)
        t=inputString;
    else
        inputString2=regexprep(inputString,char(10),' newline ');
        inputString2=regexprep(inputString,char(13),' newline ');
        inputString2=regexprep(inputString2,char(9),' tabulate ');
        %inputString2=regexprep(inputString2,'(\d)+\ +\.+\ (\d)','$1.$2');
        inputString2=regexprep(inputString2,'\.',' ');
        [~, t, s]=text2index(s,inputString2);
    end
    %t=textscan( inputString2,'%s','delimiter','.');t=t{1};
    if isempty(rootPath) rootPath2=pwd; else rootPath2=rootPath;end
    table=[rootPath2 '/translate/' destLanguage '-' sourceLanguage];
    if isempty(d) | not(strcmpi(d.table,table))
        if exist([table '.mat'])
            load(table);
            d.table=table;
        else
            if not(exist('translate','dir'))
                warning off; mkdir([rootPath2 '/translate/']);warning on;
            end
            d.hash = java.util.HashMap;
            d.table=table;
        end
    end
    missing=[];
    for i=1:length(t)
        if t{i}(1)=='_' | not(isnan(str2double(t{i})))
            tTranslated{i}=t{i};
            missing(i)=0;
        else
            tTranslated{i}=d.hash.get(lower(t{i}));
            missing(i)=isempty(tTranslated{i});
        end
    end
    if not(isempty(find(missing)))
        tText=cell2string(t(find(missing))','. ');
        tText=tText(2:end);
        %tText=regexprep(tText,' ','\. ');
        tTextTranslated=gtranslate(s,[tText ''], destLanguage, sourceLanguage,maxString);
        %[~, tCellTranslated, s]=text2index(s,tTextTranslated);
        tCellTranslated=textscan( tTextTranslated,'%s','delimiter','.');tCellTranslated=tCellTranslated{1};
        %ok=length(findstr('.',tTextTranslated))==length(findstr('.',tText));
        ok= length(find(missing))==length(tCellTranslated);
        j=0;
        for i=find(missing)
            j=j+1;
            if not(ok)
                if strcmpi(t{i},char(26))
                    tCellTranslated{j}='';
                else
                    tCellTranslated{j}=gtranslate(s,t{i}, destLanguage, sourceLanguage,maxString);
                end
            end
            d.hash.put(lower(t{i}),tCellTranslated{j});
            tTranslated{i}=tCellTranslated{j};
        end
        save(d.table,'d');
    end
    tTranslated(find(strcmpi(t,'newline')))={char(13)};
    tTranslated(find(strcmpi(t,'tabulate')))={char(9)};
    xlatedString=cell2string(tTranslated);
    if not(isempty(xlatedString))
        if xlatedString(1)==' '; xlatedString=xlatedString(2:end);end
    end
    xlatedString=regexprep(xlatedString,[char(9) ' '],char(9));
    xlatedString=regexprep(xlatedString,[char(13) ' '],char(13));
    return
end


if strcmpi(sourceLanguage,destLanguage) | isempty(inputString)
    %fprintf('No translation needed\n');
    xlatedString=inputString;
    return
end

if length(inputString)>maxString
    i=findstr(inputString,' ');
    i=i(find(i<maxString));
    if isempty(i)
        i=maxString-1;
    else
        i=i(end);
    end
    %maxString=fix(maxString*.7);
    if maxString<20
        fprintf('Failed translating %s\n',inputString);
        xlatedString=inputString;
    else
        string1=gtranslate(s,inputString(1:i-1), destLanguage, sourceLanguage,maxString,cache);
        if not(length(findstr('.',inputString(1:i-1)))==length(findstr('.',string1)))
            1;
        end
        string2=gtranslate(s,inputString(i:end), destLanguage, sourceLanguage,maxString,cache);
        xlatedString = [string1 string2];
    end
    return
end

%build url and send to google
url = 'https://translation.googleapis.com/language/translate/v2';
%ok=0;i=0;
%while not(ok) & i<10
try
    response = urlread(url, 'get', {'key', 'XXX YOUR_KEY XXX','q', inputString, 'target', destLanguage, 'source', sourceLanguage});
    ok=1;
catch
    fprintf('Error in Google translate.\n')
    %pause(.1);
    response='Error';
    maxString=fix(maxString*.7);
    
    i=findstr(inputString,' ');
    if length(i)>1 & i(1)==1; i=i(2:end);end
    i=i(find(i<length(inputString)/2));
    if length(i)>1; i=i(end);end
    if isempty(i) i=length(inputString)/2;end
    
    if 1
        fprintf('. Retrying %d %d\n',i,maxString)
        if i>100
            string1=gtranslate(s,inputString(1:i-1), destLanguage, sourceLanguage,maxString,cache);
            string2=gtranslate(s,inputString(i:end), destLanguage, sourceLanguage,maxString,cache);
            xlatedString = [string1 string2];
        else
            try
                xlatedString=gtranslate(s,inputString, destLanguage, sourceLanguage,maxString,cache);
            catch
                fprintf('Failed Google translate %s\n',i,inputString)
                xlatedString=inputString;
            end
        end
    end
    return
    %        i=i+1;
    %    end
end
% TODO: change below response in a way that it returns only single translated word
% So we can implement other API if needed in future
res=loadjson(response);
xlatedString=res.data.translations{1}.translatedText;
