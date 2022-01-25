function [indexRand,s]=getRandomIndex(s,N)
persistent r
if not(isfield(r,'filename')) | not(strcmpi([s.languagefile s.filename],r.filename))
    r=[];
end
if isempty(r) | isempty(r.indexRand) |  max(r.indexRand)>s.N | not(isfield(r,'f')) | length(r.indexRand)<N
    r.filename=[s.languagefile s.filename];
    if 1 %Checks if the random words are in the space, if so, no need to take from database
        r.indexRand=[];
        for i=1:length(s.info)
            if isfield(s.info{i},'specialword') & s.info{i}.specialword==100
                r.indexRand=[r.indexRand i];
            end
        end
        if length(r.indexRand)>=N
            indexRand=r.indexRand(1:N);
            return
        end
    end
    if s.db
        %Get N random words from language database (seed is set to 1, so the same words will be
        %taken each time
        %Get N+40 (cached)
        randomFile=[regexprep(s.languagefile,'\.mat','') '-RandomWord.mat'];
        if exist(randomFile)
            load(randomFile);
            if istable(words)
                words=table2array(words);
            end
            if length(words)>=N; ok=1;else ok=0;end
            if length(words)>=N+20; words=words(1:N+20);end
        else
            ok=0;
        end
        if not(ok)
            query=['SELECT `id` FROM `' regexprep(s.languagefile,'\.mat','') '` WHERE `f`>0 ORDER BY RAND(1) LIMIT ' num2str(N+40) ];
            try
                words = fetch(getDb,query);
            catch
                words = fetch(getDb(1),query);
            end
            save(randomFile,'words');
        end
        if length(r.indexRand)>0
            i1=min(r.indexRand);
        else
            i1=s.N;
        end
        par=s.par;par.specialword=100;
        s=getSfromDB(s,regexprep(s.languagefile,'\.mat',''),s.filename,words,[],'merge',par);
    else
        i1=2;
    end

    r.f=NaN(1,s.N);
    agg=0;
    for i=i1:length(s.f)
        agg=nansum([agg s.f(i)]);
        r.f(i)=agg;
    end
    r.f=r.f/r.f(end);
    r.f(isnan(r.f))=0;
    r.indexRand=[];
end
if length(r.indexRand)>=N
    indexRand=r.indexRand(1:N);
    return
end
resetRandomGenator(s);
 
indexRand=ones(1,N); 
for i=1:N
    j=rand;
    [tmp1 tmp2]=find(r.f<rand);
    indexRand(i)=length(tmp1)+1;
end
r.indexRand=indexRand;