function facebookIndex2Text(s)
if nargin<1
    s=getSpace;
end
%https://www.facebook.com/ads/audience_insights?_rdr=p
handles=getHandles;
d=get(handles.report,'Data');
N=size(d);
[fbindex text]=xlsread('fbindexOk.xlsx');
for column=1:N(2)
    name=[d{1,column} 'text'];
    [name nameOk]=fixpropertyname(name);
    nameCol=find(strcmpi(name,d(1,:)));
    if isempty(nameCol)
        N2=size(d);
        nameCol=N2(2)+1;
    end
    for row=2:N(1)
        if not(isnumeric(d{row,column}))
            dataStr=string2cell(d{row,column});
            data=nan(1,length(dataStr));
            for i=1:length(dataStr)
                tmp=str2double(dataStr{i});
                if not(isempty(tmp))
                    data(i)=tmp;
                end
            end
        else
            data=d{row,column};
        end
        text2='';
        indexRow=word2index(s,d{row,1});
        for i=1:length(data)
            index=find(abs(data(i)-fbindex(:,1))<.1);
            if not(isempty(index))
                if i==1 | i==length(data)
                    seperator='';
                else
                    seperator=', ';
                end
                text2=[text2 seperator text{index,3}];
                d{1,nameCol}=name;
                d{row,nameCol}=text2;
                s.info{indexRow}.(nameOk)=text2;
                info=[];
                if isnan(word2index(s,name))
                    s=addX2space(s,name,[],info,0,'Facebook labels');
                end
            elseif not(isnan(data(i))) & data(i)>1000000
                fprintf('%d %d %d\n',row,column,data(i))
            end
        end
    end
end
set(handles.report,'Data',d);
s=getSpace('set',s);
1;
