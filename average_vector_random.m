function [x, ok,tot,xRandom,wordlist_out,ok_index]=average_vector_random(s,wordlist1,wordlist2)
'do not use this code'
%Returns the average x from words in wordlist1.
%If called by wordlist2, then a random sampling is made from list 1 and 2.
x=[];ok=[];,tot=[];xRandom=[];wordlist_out=[];ok_index=[];
wordlist_out{1}='';
%If set average x in valence space rather than Semantic space...
ok=0;tot=0;
[~, N]=size(s.x);
Ndoc1 =length(wordlist1);
try
    x=ones(Ndoc1,N)*NaN;%Optimezes speed...
catch
    fprintf('Failed using optimzation, may be slow...\n');
    x=ones(min(5000,Ndoc1),N)*NaN;%Optimezes speed...
end
if nargin>3 %Random
    wordlist12=[wordlist1;wordlist2];
    [Ndoc12 N]=size(wordlist12);
    [tmp index]=sort(rand(1,Ndoc12));
end
for i=1:Ndoc1 %length(wordlist1)
    if isa(wordlist1,'numeric')
        ok2=1;
        if nargin>3 %Random
            xOne=wordlist12(index(i));
        else %Not random
            xOne=wordlist1(i,:);
        end
    else
        if nargin>3 %Random
            w=wordlist12{index(i)};
        else %Not random
            w=wordlist1{i};
        end
        [xOne ok2 tmp]=getXword(s,w);
    end

    tot=tot+1;
    if ok2
        ok=ok+1;
        ok_index(ok)=tmp(1);
        x(ok,:)=xOne;
        wordlist_out(ok)=wordlist1(tot);
    end
end
xRandom=x(1:ok,:);
x=average_vector(s,xRandom,ok_index);
tot=length(wordlist1);
if ok<tot
    myprint(sprintf('found %d of %d words',ok,tot));
end
if ok>0
    ok=1;
end

