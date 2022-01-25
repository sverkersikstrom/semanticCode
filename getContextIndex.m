function index=getContextIndex(s,i)
index=text2index(s,getText(s,i));
index=index(index>0);
% if not(isfield(s,'info'))
%     index=i;    
% elseif not(isfield(s.info{i},'index'))
%     index=i;
% else
%     index=s.info{i}.index;
%     index=index(find(index>0));
% end