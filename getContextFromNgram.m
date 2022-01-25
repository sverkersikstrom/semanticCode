function getContextFromNgram(contextWords)
d.func='mkOcurrence';
d.pathResults=[pwd '/'];%
if nargin<1
    d.contextWords={'happiness','harmony'};
end
d.ocurrenceFromNgram=0;
if 1
    d.restart=1;
    d.path=[ '/Users/sverkersikstrom/Dropbox/ngram/'];%pwd
    ngram(0,d);
else
    ngram(1,d);
end
