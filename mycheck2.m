function mycheck2(nr)
try
    if nargin<1
        nr=0;
    end
    f=fopen(['mytestfile.txt' num2str(nr) ],'w');
    fprintf(f,'hej %s\n',datestr(now));
    fclose(f);
end

% start
% defaultSpace='/Users/sverkersikstrom/Dropbox/ngram/spaceenglish.mat';
% if exist(defaultSpace)
%     fprintf('Loading default space: %s\n',defaultSpace);
%     s=getNewSpace(defaultSpace);
% end
%
% [a b]=getProperty(getSpace,{'i am your man'},'_space')
%
% f=fopen('mytestfile2.txt','w')
% fprintf(f,'%s %s\n',datestr(now),b{1})
% fclose(f)
%

%a=input('give a')
%a*2
