function [s info]=db2space(s,target,maxTarget2Retrieve,date,contextSize)
info=[];
p=getdb_parametersNew;
if not(isempty(p.conn_a.Message)) & s.par.db2space==0
    fprintf('Error connecting to database: %s\n')
    return
end
if nargin<1
    s=getSpace('s');
end
if nargin<2
    target=inputdlg3('Input target words to extract contexts from (random articles)','');
    if isempty(target); return; end
end
if nargin<3
    maxTarget2Retrieve=str2double(inputdlg3('Maximum number of contexts to retreive (0=all):','0'));
end
if nargin<4
    date{1}=inputdlg3('Start date','2000');
    date{2}=inputdlg3('Stop date','2020');
end
if not(iscell(date))
    condition=date;
elseif not(isempty(date))
    condition=[' `published`>''' date{1} ''' AND  `published`<''' date{2} ''''];
else
    condition='1';
end

orderBy='autoId';    

if nargin<5
    contextSize=str2double(inputdlg3('Context size','30'));
end

lim=1000;
maxLim=lim;

targetCell=string2cell(target);

i=1;j=1;k=0;
ldate6='';
include=[];
Nadded=0;
if not(isfield(s,'timeFrequency'))
    s.extraData.timeFrequency(fix(now*10))=sparse(0);
end
results=' ';
autoId=0;
Nr=0;
tic;

s.par.fastAdd2Space=1;
for i=1:length(targetCell)
    while not(isempty(results)) & (Nadded<maxTarget2Retrieve | maxTarget2Retrieve<=0)
        Nr=Nr+1;
        limitN=[' limit 0,' num2str(lim)];
        file=['tmp/' targetCell{i} num2str(Nr)];
        condAutoId=[ ' AND `autoId`>' num2str(autoId) ];
        if strcmpi(targetCell{i},'random')
            if maxTarget2Retrieve==0
                fprintf('Setting maximum number of random articles to 1000\n');
                maxTarget2Retrieve=1000;
            end
            limitN=[' limit 0,' num2str(min(lim,maxTarget2Retrieve))];
            SQL=['SELECT  `header`,`preamble`,`body`,  `published`, `autoId`,`resourceId`  FROM  `archive_latin1` WHERE `published`>''1'' AND ' condition condAutoId ' ORDER BY RAND() '  limitN ];
        else
            SQL=['SELECT  `header`,`preamble`,`body`,  `published`, `autoId`,`resourceId`  FROM  `archive_latin1` WHERE `published`>''1'' AND ' condition condAutoId ' AND `body` REGEXP ''' targetCell{i} '''  order by ' orderBy  limitN ];
        end
        if s.par.db2space==2
            ok=1;
            load(file);
        else
            ok=0;
            %while not(ok) %Fixes odd unusla db bugg...
            try
                results = table2cell(fetch(p.conn_a,SQL));
                ok=1;
                lim=fix(min(maxLim,lim*2));
            catch
                p=getdb_parameters(0);
                fprintf('Problem %s %d\n', targetCell{i},autoId)
                Nr=Nr-1;
                lim=fix(max(1,lim/2+1));
            end
            %end
        end
        if not(ok)
            if lim<10
                autoId=autoId+1;
            end
        elseif not(isempty(results))
            try
                autoId=max(cell2mat(results(:,5)));
            catch
                fprintf('Problem Id %s %d\n', targetCell{i},autoId)
                ok=0;
                N=size(results);
                autoId=autoId+N(1);
            end
        end
        if not(ok)
        elseif s.par.db2space==1
            save(file,'results')
        else            
            N=size(results);
            for j=1:N(1)
                context=[results{j,1} results{j,2} results{j,3}];
                dates=results{j,4};
                info.article=results{j,5};
                info.newspaperid=results{j,6};
                info.time=datenum(dates);                
                info.par=setInfoPar(s.par);
                s.extraData.timeFrequency(fix(info.time))=s.extraData.timeFrequency(fix(info.time))+1;
                if not(isnan(info.time))
                    info.target=targetCell{i};
                    context2=getContexts(s,context,targetCell{i},contextSize);
                    for l=1:length(context2)
                        info.context=context2{l};
                        if length(info.context)>0
                            x=text2space(s,info.context);
                            if strcmpi(orderBy,'autoId')
                                date6=num2str(info.article);
                            else
                                date6=[dates(1:4) dates(6:7) dates(9:10)];
                            end
                            if strcmpi(ldate6,date6) k=k+1; else k=1; end
                            ldate6=date6;
                            word=['_'  targetCell{i} date6 'n' num2str(k) ];
                            t=toc;
                            s=addX2space(s,word,x,info);
                            %s.par.handles.regression_extension
                            Nadded=Nadded+1;
                            fprintf('articles/s=%.2f, %s, %s\n',t/Nadded,word,dates);
                        end
                    end
                end
            end
        end
    end
end
if Nadded>0
    s.par.fastAdd2Space=2;
    s=addX2space(s,word,x,info);
end

