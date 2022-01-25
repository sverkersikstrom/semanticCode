% function testFunctions(s,word)
% if nargin<1
%     s=getSpace;
% end
% if nargin<2
%     word='My mother is nice.';
% end
% [id, categories, index,user]=getIndexCategory('functions',s);
% %[id, categories, index,user]=getIndexCategory('wordclasses',s);
% [~,out,s]=getProperty(s,word,index);
% for i=1:length(out)
%    if isfield(s.info{index(i)},'comment')
%        comment=s.info{index(i)}.comment;
%    else
%        comment='';
%    end
%    fprintf('%d\t%s\t%s\t%s\t%s\n',i,word,s.fwords{index(i)},out{i},comment)
% end
