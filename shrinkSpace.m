function s=shrinkSpace(s,Ndim,N)
if nargin>1
    s.x=normalizeSpace(s.x(:,1:Ndim));
end
if nargin>2
    s=structSelect(s,1:N);
end
[s.N s.Ndim]=size(s.x);
try; s=rmfield(s,'S');end
try; s=rmfield(s,'V');end
try; s=rmfield(s,'fTime');end
try;s=rmfield(s,'wordOrg');end
try;s=rmfield(s,'upper');end
try;s=rmfield(s,'skip');end

% if 0
%     for i=1:length(s.info)
%         f=fields(s.info{i});
%         for j=1:length(f);
%             if findstr(f{j},'diffbillerud')==1
%                 s.info{i}=rmfield(s.info{i},f{j});
%             end
%         end
%     end
% end
