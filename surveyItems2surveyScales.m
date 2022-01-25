file='results-survey165884.xlsx';
file='Psykiatrin.xlsx';
seperator='[';

%Read file
[words, data, dim, labels,labelsFixe,numeric]=textread2(file);

%Find groups
for i=1:length(labels)
    j=findstr(labels{i},seperator);
    if isempty(j); j=length(labels{i})+1; end
    labels2{i}=labels{i}(1:j-1);
    while  not(isnan(str2double(labels2{i}(end)))) labels2{i}=labels2{i}(1:end-1); end
    if i==1
        group=1;groupId=group;
    elseif not(strcmpi(labels2{i},labels2{i-1})) | findstr(labels{i},'[Ord 1]')>0;
        group=group+1;
    else
        groupId(i-1)=group;
    end
    groupId(i)=group;
end

%Print variabels
for i=1:length(labels)
    fprintf('%d\t%d\t%d\t%s\t%s\n',i,numeric(i),groupId(i),labels{i},labels2{i})
end
1;

%Merge columns
labelsNew=labels;
wordsNew=words;
u=unique(groupId);
include=ones(1,length(labelsNew));
for i=u
    index=find(i==groupId);
    if length(index)>1
        %labelsNew=[labelsNew; {cell2string(labels(index)')}];
        labelsNew=[labelsNew; labels2{index(1)}];
        if numeric(index(1))
            for j=1:size(wordsNew,1)
                wordsNew{j,length(labelsNew)}=regexprep(num2str(sum(data(j,index))),'NaN','');
            end            
        else
            for j=1:size(wordsNew,1)
                wordsNew{j,length(labelsNew)}=cell2string(words(j,index));
            end
        end
        include(length(labelsNew))=1;
        include(index)=0;
    end
end

%Remove empty columns
for j=1:size(wordsNew,2)
    if isempty(cell2string(wordsNew(:,j)',''))
        include(j)=0;
    end
end


%Print results
fileOut=['Merged' regexprep(file,'.xlsx','.txt')];
cell2file(wordsNew(:,include>0),fileOut,labelsNew(include>0));
1;



%Read codes
% [code, codedata]=textread2('code.xlsx');
% r2=codedata(:,2)';
% r=code(:,1)';


% for i=1:length(labels)
%     missing='';uString='';
%     try
%         if numeric(i)
%             u=unique(cell2mat(words(:,i)));
%         else
%             u=unique(words(:,i));
%             uString=cell2string(u');
%             if length(u)>1 & length(u)<10
%                 missingJ=[];
%                 for j=1:length(u)
%                     if isempty(u{j})
%                     elseif isempty(find(strcmp(r,u{j})))
%                         missingJ(j)=isempty(find(strcmp(r,u{j})));
%                         missing=cell2string(u');
%                     end
%                 end
%             end
% ;
%         end
%     catch
%         u=-1;
%     end
%     fprintf('%d\t%d\t%d\t%s\t%d\t%s\n',i,ord(i),groupId(i),labels{i},length(u),uString)
%     if length(missing)>0
%         labels{i}
%         u
%         1;
%     end
% end

    %ord(i)=not(isempty(findstr(labels{i},seperator)>0));

% i=0;
% i=i+1;r2(i)=1;r{i}='Inte alls';
% i=i+1;r2(i)=2;r{i}='Flera dagar';
% i=i+1;r2(i)=3;r{i}='Mer än hälften  av dagarna';
% i=i+1;r2(i)=4;r{i}='Flertalet dagar';
% i=i+1;r2(i)=5;r{i}='Nästan varje dag';
% i=i+1;r2(i)=6;r{i}='Så gott som dagligen';
% 
% i=i+1;r2(i)=1;r{i}='Aldrig';
% i=i+1;r2(i)=2;r{i}='Nästan aldrig';
% i=i+1;r2(i)=3;r{i}='Ibland'       ;
% i=i+1;r2(i)=4;r{i}='Ganska ofta'  ;
% i=i+1;r2(i)=5;r{i}='Väldigt ofta' ;
% 
% i=i+1;r2(i)=1;r{i}='Instämmer absolut inte';
% i=i+1;r2(i)=2;r{i}='Instämmer inte'           ;
% i=i+1;r2(i)=3;r{i}='Instämmer inte riktigt'   ;
% i=i+1;r2(i)=4;r{i}='√Ñr varken för eller emot';
% i=i+1;r2(i)=5;r{i}='Instämmer delvis'         ;
% i=i+1;r2(i)=6;r{i}='Instämmer'                ;
% i=i+1;r2(i)=7;r{i}= 'Instämmer helt'           ;
% 
% i=i+1;r2(i)=1;r{i}= '1 gång i månaden eller mer sällan';
% i=i+1;r2(i)=2;r{i}=     '2-3 gånger i veckan'              ;
% i=i+1;r2(i)=3;r{i}=     '2-4 gånger i månaden'             ;
% i=i+1;r2(i)=4;r{i}=     'Aldrig'                           ;
%{0×0 char                         }
%    {'Aldrig'                         }
%    {'Mer sällan än en gång i månaden'}
%    {'Varje månad'                    }
%    {'Varje vecka'                    }
