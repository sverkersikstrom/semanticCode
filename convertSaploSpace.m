file='space_swe_anders_20110119.mat';
load(file);
%if not(isfield(s,'skip'))
%    s.skip(s.N)=0;
%end
s.filename=file;
s.fwords=s.fwords(1:s.N);
s.f=s.wordFreq(1:s.N);
save(s.filename,'s');
clear 
