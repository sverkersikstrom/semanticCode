function s=calculate_bigram(s);
b='a'-1;
n=zeros(255-b,255-b);
fprintf('Calculating bigram frequencies, please wait...');
for i=1:length(s.fwords)
    w=lower(s.fwords{i});
    if isempty(findstr(w,'_'))
        for j=1:length(w)-1
            try;
                n(w(j)-b,w(j+1)-b)=n(w(j)-b,w(j+1)-b)+s.f(i);
            end
        end
    end
end
s.bigramN=n;
n=n/sum(sum(n));
for i=1:length(s.fwords)
    w=lower(s.fwords{i});
    clear f;
    f(1)=NaN;
    if isempty(findstr(w,'_'))
        for j=1:length(w)-1
            try;
                f(j)=n(w(j)-b,w(j+1)-b);
            end
        end
    end
    s.info{i}.bigram=mean(f)*1000;
end
fprintf('done!\n')
