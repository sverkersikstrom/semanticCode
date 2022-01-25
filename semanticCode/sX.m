% function x=sX(s,index,data)
% persistent sSave;
% if 1 %old moode
%     if nargin<3 | strcmpi(data,'x')
%         x=s.x(index,:);
%     elseif strcmpi(data,'info')
%         x=s.info(index);
%     elseif strcmpi(data,'f')
%         x=s.f(index);
%     else
%         'error'
%     end
% else
%     if not(isfield(sSave,'index'))
%         sSave.index(100,1000)=sparse(0);
%         sSave.language=[];
%     end
%     if not(isfield(s,'spaceId'))
%         k=findstr(s.filename,'/');
%         language=s.filename;
%         if length(k)>0
%             language=language(k(end)+1:end);
%         end
%         k=find(strcmpi(language,sSave.language));
%         if isempty(k)
%             sSave.language=[sSave.language {language}];
%         end
%         s.spaceId=find(strcmpi(language,sSave.language));
%     end
%     k=full(sSave.index(s.spaceId,index));
%     kmissing=find(not(k));
%     if not(isempty(kmissing))
%         [s,x,index]=struct2Db(s,'get',kmissing,kmissing)
%     end
%     
% end