function scriptMARGRET(dataSet,code)
%ver=0 Ngram, dataSet='twitter', ver=2 twitter results
%scp -r /Users/sverkersikstrom/Dropbox/ngram/* sverker@aurora.lunarc.lu.se:/lunarc/nobackup/users/sverker/Margret
%scp -r /Users/sverkersikstrom/Dropbox/semantic/semanticCode/* sverker@aurora.lunarc.lu.se:/home/sverker/semantic/semanticCode
%scp -r /Users/sverkersikstrom/Dropbox/semantic/semanticCode/scriptMARGRET.m sverker@aurora.lunarc.lu.se:/home/sverker/semantic/semanticCode
%scp -r /Users/sverkersikstrom/Dropbox/semantic/semanticCode/getProperty2file.m sverker@aurora.lunarc.lu.se:/home/sverker/semantic/semanticCode
%scp -r sverker@aurora.lunarc.lu.se:/lunarc/nobackup/users/sverker/Margret/Englishtwitter/*teetsdata.mat /Users/sverkersikstrom/Documents/Dokuments/Artiklar_in_progress/Semantic_spaces/ngram/Margret/Englishtwitter
%scp -r sverker@aurora.lunarc.lu.se:/lunarc/nobackup/users/sverker/Margret/*teetsdata.mat /Users/sverkersikstrom/Documents/Dokuments/Artiklar_in_progress/Semantic_spaces/ngram/Margret
%scp -r sverker@aurora.lunarc.lu.se:/lunarc/nobackup/users/sverker/Margret/plotPronouns.mat /Users/sverkersikstrom/Documents/Dokuments/Artiklar_in_progress/Semantic_spaces/ngram/Margret
%scp -r sverker@aurora.lunarc.lu.se:/lunarc/nobackup/users/sverker/Margret/Englishtwitter/twitter* /Users/sverkersikstrom/Documents/Dokuments/Artiklar_in_progress/Semantic_spaces/ngram/Margret/Englishtwitter
%scp -r sverker@aurora.lunarc.lu.se:/lunarc/nobackup/users/sverker/Margret/Englishtwitter/nonustweets/log-non-us-tw-2018-07-01T05-00-00Z.txt.sift /Users/sverkersikstrom/Documents/Dokuments/Artiklar_in_progress/Semantic_spaces/ngram/Margret

% curl -O http://www.sift.net/sites/default/files/margaret/us-tweets-2018-jan-oct.tar.gz

%REMOVE norm-tx-tweetstxtdata.mat norm-ak-tweetsResults.mat norm-ny-tweetsResults.mat
%regexprep('Hi how are <HT> you?','<\w+>','')

%ssh sverker@aurora.lunarc.lu.se
%2018-09-26 Sverker  RKReGcvgr7uX
%pocket pass 8517
%cd /lunarc/nobackup/users/sverker/Margret
%sbatch job1.scr
%scancel 7101
%squeue
%tar xvzf  us-tweets-2018-jan-oct.tar.gz


%http://storage.googleapis.com/books/ngrams/books/datasetsv2.html

%[space,filename,languageNames]=getSpaceName;

%d.path='';
%d.language='English';
%d.corpus1='googlebooks-eng-all-';
%d.corpus3='-20120701-';
%d.name='countEnglish';
%d.lexicon='spaceEnglish';
%d.synonymFile2=[d.path 'qualitysandberg.txt'];
%d.gram1='a b c d e f g h i j k l m n o other p pos punctuation q r s t u v w x y z';
%filename=[d.path d.corpus d.fileExtOne '.txt'];
if nargin<1 | isempty(dataSet)
    %dataSet='twitter';
    dataSet='noustwitter';
end
if nargin<2 | isempty(dataSet)
    %code='summarize';
    code='';
end

if 0 %Print maps?
    load('plotPronouns')
    %dAll.fileExt='norm-ak-tweets.txt norm-dc-tweets.txt  norm-ma-tweets.txt  norm-nj-tweets.txt  norm-tx-tweets.txt norm-ak-tweetsResults.txt  norm-de-tweets.txt  norm-md-tweets.txt  norm-nm-tweets.txt  norm-ut-tweets.txt norm-al-tweets.txt         norm-fl-tweets.txt  norm-me-tweets.txt  norm-nv-tweets.txt  norm-va-tweets.txt norm-al-tweetsResults.txt  norm-ga-tweets.txt  norm-mi-tweets.txt  norm-ny-tweets.txt  norm-vt-tweets.txt norm-ar-tweets.txt         norm-hi-tweets.txt  norm-mn-tweets.txt  norm-oh-tweets.txt  norm-wa-tweets.txt norm-ar-tweetsResults.txt  norm-ia-tweets.txt  norm-mo-tweets.txt  norm-ok-tweets.txt  norm-wi-tweets.txt norm-az-tweets.txt         norm-id-tweets.txt  norm-ms-tweets.txt  norm-or-tweets.txt  norm-wv-tweets.txt norm-az-tweetsResults.txt  norm-il-tweets.txt  norm-mt-tweets.txt  norm-pa-tweets.txt  norm-wy-tweets.txt norm-ca-tweets.txt         norm-in-tweets.txt  norm-nc-tweets.txt  norm-ri-tweets.txt  norm-ks-tweets.txt  norm-nd-tweets.txt  norm-sc-tweets.txt norm-co-tweets.txt         norm-ky-tweets.txt  norm-ne-tweets.txt  norm-sd-tweets.txt norm-ct-tweets.txt         norm-la-tweets.txt  norm-nh-tweets.txt  norm-tn-tweets.txt';%norm-ca-tweetsResults.txt 
    dAll.fileExt='norm-dc-tweets.txt  norm-ak-tweets.txt norm-ma-tweets.txt  norm-nj-tweets.txt  norm-tx-tweets.txt norm-de-tweets.txt  norm-md-tweets.txt  norm-nm-tweets.txt  norm-ut-tweets.txt norm-al-tweets.txt         norm-fl-tweets.txt  norm-me-tweets.txt  norm-nv-tweets.txt  norm-va-tweets.txt norm-ga-tweets.txt  norm-mi-tweets.txt  norm-ny-tweets.txt  norm-vt-tweets.txt norm-ar-tweets.txt         norm-hi-tweets.txt  norm-mn-tweets.txt  norm-oh-tweets.txt  norm-wa-tweets.txt norm-ia-tweets.txt  norm-mo-tweets.txt  norm-ok-tweets.txt  norm-wi-tweets.txt norm-az-tweets.txt         norm-id-tweets.txt  norm-ms-tweets.txt  norm-or-tweets.txt  norm-wv-tweets.txt norm-il-tweets.txt  norm-mt-tweets.txt  norm-pa-tweets.txt  norm-wy-tweets.txt norm-ca-tweets.txt         norm-in-tweets.txt  norm-nc-tweets.txt  norm-ri-tweets.txt norm-ks-tweets.txt  norm-nd-tweets.txt  norm-sc-tweets.txt norm-co-tweets.txt         norm-ky-tweets.txt  norm-ne-tweets.txt  norm-sd-tweets.txt norm-ct-tweets.txt         norm-la-tweets.txt  norm-nh-tweets.txt  norm-tn-tweets.txt';%norm-ca-tweetsResults.txt  norm-ak-tweetsResults.txt  norm-ar-tweetsResults.txt  norm-al-tweetsResults.txt  norm-az-tweetsResults.txt  

    dAll.fileExt=regexprep(dAll.fileExt,'norm-','');
    dAll.fileExt=regexprep(dAll.fileExt,'-tweets.txt','')
    dAll.fileExt=regexprep(dAll.fileExt,'-tweetsResults.txt','')
    dAll.states=strread(upper(dAll.fileExt),'%s');
    states=textread2('StatesCordinates.xlsx');
    dAll.x=nan(1,length(dAll.states));
    dAll.y=nan(1,length(dAll.states));
    for i=1:size(states,1)
        j=find(strcmpi(dAll.states,states(i,1)));
        if length(j)>0
            j=j(1);
            dAll.states2{j}=states{i,1};
            dAll.x(j)=states{i,3};
            dAll.y(j)=states{i,2};
        end
    end
    
    for k=1:10
        try;close(k);end
        figure(k);
        set(gca,'Xlim',[-140 -65])
        set(gca,'Ylim',[30 50])
        d.keywords={'he','she','I','you','we','they', 'she-he','we-they','we+they - she+he','he+she+I+you+we+they'};
        keyword=d.keywords{k};
        title(keyword,'fontsize',20)
        if k==7
            k1=2;k2=1;
            v=dAll.tabel(:,1,2)-dAll.tabel(:,1,1);
        elseif k==8
            k1=5;k2=6;
            v=dAll.tabel(:,1,5)-dAll.tabel(:,1,6);
        elseif k==9
            k1=[5 6];k2=[1 2];
            v=dAll.tabel(:,1,5)+dAll.tabel(:,1,6)-dAll.tabel(:,1,1)-dAll.tabel(:,1,2);
        elseif k==10
            k1=[1 2 3 4 5 6];k2=[];
            v=dAll.tabel(:,1,1)+dAll.tabel(:,1,2)+dAll.tabel(:,1,3)+dAll.tabel(:,1,4)+dAll.tabel(:,1,5)+dAll.tabel(:,1,6);
        else
            k1=find(    k==1:6);
            k2=find(not(k==1:6));
            v=dAll.tabel(:,1,k);
        end
        v=(v-nanmean(v))/nanstd(v);
        col=min(1,[max(0,v/3) zeros(length(v),1) -min(0,v/3) ]);
        for i=1:size(states,1)
            t(i)=(mean(dAll.tabel(i,1,k1))-mean(dAll.tabel(i,1,k2)))/sum(dAll.tabel(i,2,[k1 k2]).^2)^.5;
            p(i)=1-cdf('norm',abs(t(i)),0,1);
            if p(i)>.05/length(states) | abs(v(i))<.5
                col(i,:)=[.8 .8 .8];
            end
            if not(isnan(v(i)))
                text(dAll.x(i),dAll.y(i),dAll.states{i},'color',col(i,:));
            end
        end
        axis off
        saveas(k,['map-' keyword],'fig');
        saveas(k,['map-' keyword],'pdf');
    end
end


if findstr(dataSet,'twitter')>0 %strcmpi(dataSet,'twitter') %
    language={'twitter'};
else
    language={'czech','dutch','polish','romanian'};
    language=[{'English','French','German','Spanish','Italian'} language] ;%,'Hebrew','Russian','Chinese'};%'Hebrew',
    %No LIWC in 'portuguese',,'Swedish' and 'finnish', different numbers of LIWC
end
fprintf('%s\n',language{1});

dlang=getDparameters(language,dataSet);

if strcmpi(code,'summarize')
    getProperty2filePlots(dlang);
    return
end



for i=1:60 %Loop over files for languages
    for l=1:length(language) %Loop over languages
        d=dlang{l};
        if i<=length(d.file)
            if isfield(d,'path')
                warning off; mkdir(d.path); warning on;
                cd(d.path)
            end
            d.done=0;
            if isfield(d,'corpus')
                %fileGoogle=[d.language '-' d.file{i} '-sumdata.mat'];
                fprintf('%s\t%s\n',d.fileSave{i},pwd);
                if exist(d.fileSave{i})
                    try
                        load(d.fileSave{i});
                    catch
                        fprintf('Error during loading\n')
                    end
                    d.done=1;
                    %if not(d.done); restart=1;end
                else
                    save(d.fileSave{i},'d','-V7.3');
                end
            else
                fprintf('%s\t%s\n',d.fileSave{i},pwd);
                if exist(d.fileSave{i})
                    try
                        load(d.fileSave{i});
                    catch
                        fprintf('Error during loading\n')
                    end
                end
            end
            if not(isfield(d,'fileSave'))
                d.fileSave=dlang{l}.fileSave;
            end
            if not(d.done)
                d.done=0;
                if isfield(d,'corpus')
                    file=[d.language '-' d.fileExt{i}];
                    if not(exist(file))
                        save(file,'d','-V7.3');
                        fprintf('Downloading %s\n',file);
                        urlwrite(['http://storage.googleapis.com/books/ngrams/books/' d.corpus d.fileExt{i} '.gz'],[file '.gz']);
                        fprintf('Unzippig %s\n',file);
                        gunzip([file '.gz']);
                        delete([file '.gz']);
                        fprintf('Done %s\n',file);
                    end
                else
                    file= d.file{i};
                end
                if not(ismac)
                    s=getNewSpace(['/lunarc/nobackup/users/sverker/Margret/' d.spaceName]);
                else
                    s=getNewSpace(d.spaceName);
                end
                if isfield(d,'norms')
                    for i=1:length(d.norms)
                        [s,N,identifier] =addNorm(s,d.normsLabels{i},d.normsLabels{i});
                        d.property=[d.property identifier];
                    end
                end
                index=word2index(s,d.property);
                
                
                fprintf('%s\t%s\t%s\n',d.spaceName,file,datestr(now));
                d.iFile=i;
                dout{i}=getProperty2file(s,index,file,d);
                if d.sumTime &  exist(file)
                    delete(file);
                end
            end
        end
    end
end
%f=fopen(file,'r','n','UTF-8');'
%for i=1:500000; fgets(f);end
%fgets(f)
%if 0
    %problem 13 chinese can not print associates in training - working
    %16 hebrew translation produces NaNs - not working
    %[space,filename,languageNames]=getSpaceName;
    %for i=21:21 %size(languageNames,1)
    %    getNewSpace(languageNames{i,2});
    %end
%end

function dlang=getDparameters(language,dataSet);
%if nargin<2
%    ver=1;
%end
for l=1:length(language)
    d=[];
    d.label='';
    d.language=language{l};
    d.folder='';
    d.sumTime=0;
    d.property={'_predvalence'};
    d.contextSize=0;
    if strcmpi(dataSet,'twitter') | strcmpi(dataSet,'noustwitter')
        d.language='English';
        d.spaceName=['space' d.language];
        d.filePrefix='';
        d.removeBrackets=1;
        if strcmpi(dataSet,'noustwitter')
            d.folder='noustwitter';
            d.fileExt=ls('*.sift');
        else
            d.folder='twitter';
            %d.fileExt='norm-ak-tweets.txt  norm-ar-tweets.txt  norm-ca-tweets.txt norm-al-tweets.txt  norm-az-tweets.txt';
            d.fileExt='norm-dc-tweets.txt  norm-ak-tweets.txt norm-ma-tweets.txt  norm-nj-tweets.txt  norm-tx-tweets.txt norm-de-tweets.txt  norm-md-tweets.txt  norm-nm-tweets.txt  norm-ut-tweets.txt norm-al-tweets.txt         norm-fl-tweets.txt  norm-me-tweets.txt  norm-nv-tweets.txt  norm-va-tweets.txt norm-ga-tweets.txt  norm-mi-tweets.txt  norm-ny-tweets.txt  norm-vt-tweets.txt norm-ar-tweets.txt         norm-hi-tweets.txt  norm-mn-tweets.txt  norm-oh-tweets.txt  norm-wa-tweets.txt norm-ia-tweets.txt  norm-mo-tweets.txt  norm-ok-tweets.txt  norm-wi-tweets.txt norm-az-tweets.txt         norm-id-tweets.txt  norm-ms-tweets.txt  norm-or-tweets.txt  norm-wv-tweets.txt norm-il-tweets.txt  norm-mt-tweets.txt  norm-pa-tweets.txt  norm-wy-tweets.txt norm-ca-tweets.txt         norm-in-tweets.txt  norm-nc-tweets.txt  norm-ri-tweets.txt norm-ks-tweets.txt  norm-nd-tweets.txt  norm-sc-tweets.txt norm-co-tweets.txt         norm-ky-tweets.txt  norm-ne-tweets.txt  norm-sd-tweets.txt norm-ct-tweets.txt         norm-la-tweets.txt  norm-nh-tweets.txt  norm-tn-tweets.txt';%norm-ca-tweetsResults.txt  norm-ak-tweetsResults.txt  norm-al-tweetsResults.txt  norm-ar-tweetsResults.txt  norm-az-tweetsResults.txt
        end
        d.sumTime=0;
        d.contextSize=3;
        if strcmpi(dataSet,'scott')
            d.label='scottsWordList';
            d.keywords={'pain', 'hygiene','blood',{'he','son','his','him','father','man','boy','himself','male','brother','sons','fathers','men','boys','males','brothers','uncle','uncles','nephew','nephews'},{'she','daughter','hers','her','mother','woman','girl','herself','female','sister','daughters','mothers','women','girls','femen','sisters','aunt','aunts','niece','nieces'}};
            d.norms{1}='janitor, statistician, midwife, bailiff, auctioneer, photographer, geologist, shoemaker, athlete, cashier, dancer, housekeeper, accountant, physicist, gardener, dentist, weaver, blacksmith, psychologist, supervisor, math- ematician, surveyor, tailor, designer, economist, mechanic, laborer, postmaster, broker, chemist, librarian, atten- dant, clerical, musician, porter, scientist, carpenter, sailor, instructor, sheriff, pilot, inspector, mason, baker, administrator, architect, collector, operator, surgeon, driver, painter, conductor, nurse, cook, engineer, retired, sales, lawyer, clergy, physician, farmer, clerk, manager, guard, artist, smith, official, police, doctor, professor, student, judge, teacher, author, secretary, soldier';
            d.norms{2}='statistician, auctioneer, photographer, geologist, accountant, physicist, dentist, psychol- ogist, supervisor, mathematician, designer, economist, postmaster, broker, chemist, librarian, scientist, instruc- tor, pilot, administrator, architect, surgeon, nurse, engineer, lawyer, physician, manager, official, doctor, profes- sor, student, judge, teacher, author';
            d.normsLabels={'Occupations','Professional'};
        else
            d.keywords={'he','she','I','you','we','they'};
        end
        
    elseif strcmpi(language{l},'English')
        d.corpus='googlebooks-eng-all-5gram-20120701-';
        d.fileExt='a_ aa ab ac ad ae af ag ah ai aj ak al am an ao ap aq ar as at au av aw ax ay az b_ ba bb bc bd be bf bg bh bi bj bk bl bm bn bo bp bq br bs bt bu bv bw bx by bz c_ ca cb cc cd ce cf cg ch ci cj ck cl cm cn co cp cq cr cs ct cu cv cw cx cy cz d_ da db dc dd de df dg dh di dj dk dl dm dn do dp dq dr ds dt du dv dw dx dy dz e_ ea eb ec ed ee ef eg eh ei ej ek el em en eo ep eq er es et eu ev ew ex ey ez f_ fa fb fc fd fe ff fg fh fi fj fk fl fm fn fo fp fq fr fs ft fu fv fw fx fy fz g_ ga gb gc gd ge gf gg gh gi gj gk gl gm gn go gp gq gr gs gt gu gv gw gx gy gz h_ ha hb hc hd he hf hg hh hi hj hk hl hm hn ho hp hq hr hs ht hu hv hw hx hy hz i_ ia ib ic id ie if ig ih ii ij ik il im in io ip iq ir is it iu iv iw ix iy iz j_ ja jb jc jd je jf jg jh ji jj jk jl jm jn jo jp jq jr js jt ju jv jw jx jy jz k_ ka kb kc kd ke kf kg kh ki kj kk kl km kn ko kp kq kr ks kt ku kv kw kx ky kz l_ la lb lc ld le lf lg lh li lj lk ll lm ln lo lp lq lr ls lt lu lv lw lx ly lz m_ ma mb mc md me mf mg mh mi mj mk ml mm mn mo mp mq mr ms mt mu mv mw mx my mz n_ na nb nc nd ne nf ng nh ni nj nk nl nm nn no np nq nr ns nt nu nv nw nx ny nz o_ oa ob oc od oe of og oh oi oj ok ol om on oo op oq or os ot other ou ov ow ox oy oz p_ pa pb pc pd pe pf pg ph pi pj pk pl pm pn po pp pq pr ps pt pu punctuation pv pw px py pz q_ qa qb qc qd qe qf qg qh qi qj ql qm qn qo qp qq qr qs qt qu qv qw qx qy qz r_ ra rb rc rd re rf rg rh ri rj rk rl rm rn ro rp rq rr rs rt ru rv rw rx ry rz s_ sa sb sc sd se sf sg sh si sj sk sl sm sn so sp sq sr ss st su sv sw sx sy sz t_ ta tb tc td te tf tg th ti tj tk tl tm tn to tp tq tr ts tt tu tv tw tx ty tz u_ ua ub uc ud ue uf ug uh ui uj uk ul um un uo up uq ur us ut uu uv uw ux uy uz v_ va vb vc vd ve vf vg vh vi vj vk vl vm vn vo vp vq vr vs vt vu vv vw vx vy vz w_ wa wb wc wd we wf wg wh wi wj wk wl wm wn wo wp wq wr ws wt wu wv ww wx wy wz x_ xa xb xc xd xe xf xg xh xi xj xk xl xm xn xo xp xq xr xs xt xu xv xw xx xy xz y_ ya yb yc yd ye yf yg yh yi yj yk yl ym yn yo yp yq yr ys yt yu yv yw yx yy yz z_ za zb zc zd ze zf zg zh zi zj zk zl zm zn zo zp zq zr zs zt zu zv zw zx zy zz';
        %d.fileExt='aa ab ac ad ae af ag ah ai aj ak al am an ao ap aq ar as at au av aw ax ay az';
        d.sumTime=1;
        d.keywords={'he','she','I','you','we','they'};
    elseif strcmpi(d.language,'French')
        d.corpus='googlebooks-fre-all-5gram-20120701-';
        d.fileExt='a_ aa ab ac ad ae af ag ah ai aj ak al am an ao ap aq ar as at au av aw ax ay az b_ ba bb bc bd be bf bg bh bi bj bk bl bm bn bo bp bq br bs bt bu bv bw bx by c_ ca cb cc cd ce cf cg ch ci cj ck cl cm cn co cp cq cr cs ct cu cv cx cy cz d_ da db dc dd de df dg dh di dj dk dl dm dn do dp dq dr ds dt du dv dw dx dy dz e_ ea eb ec ed ee ef eg eh ei ej ek el em en eo ep eq er es et eu ev ew ex ey ez f_ fa fb fc fd fe ff fg fh fi fj fl fm fn fo fp fr fs ft fu fw fx fy g_ ga gb gc gd ge gf gg gh gi gj gk gl gm gn go gp gr gs gt gu gv gw gx gy h_ ha hb hc hd he hf hg hh hi hj hl hm hn ho hp hq hr hs ht hu hv hw hx hy hz i_ ia ib ic id ie if ig ih ii ij ik il im in io ip iq ir is it iu iv iw ix iy iz j_ ja jb jc jd je jf jg jh ji jj jk jl jm jn jo jp jr js jt ju jv jw jx jy k_ ka kb kc kd ke kf kg kh ki kj kk kl km kn ko kp kr ks kt ku kv kw kx ky l_ la lb lc ld le lf lg lh li lj lk ll lm ln lo lp lq lr ls lt lu lv lw lx ly m_ ma mb mc md me mf mg mh mi mj mk ml mm mn mo mp mq mr ms mt mu mv mw mx my mz n_ na nb nc nd ne nf ng nh ni nj nk nl nm nn no np nr ns nt nu nv nw nx ny nz o_ oa ob oc od oe of og oh oi oj ok ol om on oo op oq or os ot other ou ov ow ox oy oz p_ pa pb pc pd pe pf pg ph pi pj pk pl pm pn po pp pq pr ps pt pu punctuation pv pw px py q_ qa qb qc qd qe qg qi ql qn qo qp qs qu qv qw qx r_ ra rb rc rd re rf rg rh ri rj rk rl rm rn ro rp rq rr rs rt ru rv rw rx ry rz s_ sa sb sc sd se sf sg sh si sj sk sl sm sn so sp sq sr ss st su sv sw sx sy sz t_ ta tb tc td te tf tg th ti tj tk tl tm tn to tp tq tr ts tt tu tv tw tx ty tz u_ ua ub uc ud ue uf ug uh ui uj uk ul um un uo up uq ur us ut uu uv ux uy uz v_ va vb vc vd ve vf vg vh vi vj vk vl vm vn vo vp vr vs vt vu vv vw vx vy w_ wa wb wc wd we wf wh wi wj wl wm wn wo wp wr ws wt wu wv ww wx wy x_ xa xc xd xe xf xg xh xi xj xk xl xm xn xo xp xq xr xs xt xu xv xw xx xy xz y_ ya yb yd ye yg yh yi yl ym yn yo yp yq yr ys yt yu yv yx yz z_ za zb zd ze zg zh zi zk zl zm zn zo zp zr zs zu zv zw zx zy zz';
        d.keywords=strread('il elle je vous nous ils','%s');
        d.sumTime=1;
        d.gram1='a b c d e f g h i j k l m n o other p pos punctuation q r s t u v w x y z';
    elseif strcmpi(d.language,'German')
        d.corpus='googlebooks-ger-all-5gram-20120701-';
        d.fileExt='a_ aa ab ac ad ae af ag ah ai aj ak al am an ao ap aq ar as at au av aw ax ay az b_ ba bb bc bd be bf bg bh bi bj bk bl bm bn bo bp bq br bs bt bu bv bw bx by bz c_ ca cb cc cd ce cf cg ch ci cj ck cl cm cn co cp cr cs ct cu cv cw cx cy cz d_ da db dc dd de df dg dh di dj dk dl dm dn do dp dr ds dt du dv dw dx dy dz e_ ea eb ec ed ee ef eg eh ei ej ek el em en eo ep eq er es et eu ev ew ex ey ez f_ fa fb fc fd fe ff fg fh fi fj fk fl fm fn fo fp fr fs ft fu fv fw fx fy fz g_ ga gb gc gd ge gf gg gh gi gj gk gl gm gn go gp gr gs gt gu gv gw gx gy h_ ha hb hc hd he hf hg hh hi hj hk hl hm hn ho hp hq hr hs ht hu hv hw hx hy hz i_ ia ib ic id ie if ig ih ii ij ik il im in io ip iq ir is it iu iv iw ix iy iz j_ ja jb jc jd je jf jg jh ji jj jk jl jm jn jo jp jr js jt ju jv jw jx jy jz k_ ka kb kc kd ke kf kg kh ki kj kk kl km kn ko kp kq kr ks kt ku kv kw kx ky kz l_ la lb lc ld le lf lg lh li lj lk ll lm ln lo lp lr ls lt lu lv lw lx ly lz m_ ma mb mc md me mf mg mh mi mj mk ml mm mn mo mp mr ms mt mu mv mw mx my mz n_ na nb nc nd ne nf ng nh ni nj nk nl nm nn no np nr ns nt nu nv nw nx ny nz o_ oa ob oc od oe of og oh oi oj ok ol om on oo op or os ot other ou ov ow ox oy oz p_ pa pb pc pd pe pf pg ph pi pj pk pl pm pn po pp pr ps pt pu punctuation pv pw px py pz q_ qa qf qi qk qm qn qo qr qu qw qx r_ ra rb rc rd re rf rg rh ri rj rk rl rm rn ro rp rr rs rt ru rv rw rx ry rz s_ sa sb sc sd se sf sg sh si sj sk sl sm sn so sp sq sr ss st su sv sw sx sy sz t_ ta tb tc td te tf th ti tj tk tl tm tn to tp tq tr ts tt tu tv tw tx ty tz u_ ua ub uc ud ue uf ug uh ui uj uk ul um un uo up uq ur us ut uu uv uw ux uz v_ va vb vc vd ve vf vg vh vi vk vl vm vn vo vp vr vs vt vu vv vw vx vy vz w_ wa wb wc wd we wf wg wh wi wj wk wl wm wn wo wp wr ws wt wu wv ww wx wy wz x_ xa xc xe xh xi xj xl xm xn xp xs xt xu xv xw xx xy xz y_ ya yb yc yd ye yi ym yn yo yp ys yt yu yv yx yy yz z_ za zb zc zd ze zf zg zh zi zj zk zl zm zn zo zp zr zs zt zu zv zw zx zy zz';
        d.keywords=strread('er sie ich du wir sie','%s');
        d.sumTime=1;
        d.gram1='a b c d e f g h i j k l m n o other p pos punctuation q r s t u v w x y z';
    elseif strcmpi(d.language,'Spanish')
        d.corpus='googlebooks-spa-all-5gram-20120701-';
        d.fileExt='a_ aa ab ac ad ae af ag ah ai aj ak al am an ao ap aq ar as at au av aw ax ay az b_ ba bb bc bd be bf bg bh bi bj bl bm bn bo bp br bs bt bu bv bw by c_ ca cb cc cd ce cf cg ch ci cj ck cl cm cn co cp cr cs ct cu cv cw cx cy cz d_ da db dc dd de df dg dh di dj dk dl dm dn do dp dq dr ds dt du dv dw dx dy dz e_ ea eb ec ed ee ef eg eh ei ej ek el em en eo ep eq er es et eu ev ew ex ey ez f_ fa fb fc fd fe ff fg fh fi fj fl fm fn fo fp fr fs ft fu fv g_ ga gb gc gd ge gf gg gh gi gj gk gl gm gn go gp gr gs gt gu gv gw gy h_ ha hb hc hd he hf hg hh hi hj hk hl hm hn ho hp hr hs ht hu hv hw hy hz i_ ia ib ic id ie if ig ih ii ij ik il im in io ip iq ir is it iu iv iw ix iy iz j_ ja jb jc jd je jf jg jh ji jj jk jl jm jn jo jp jr js jt ju jv jw jx jy k_ ka kb kc kd ke kg kh ki kj kk kl km kn ko kp kr ks kt ku kv kw kx ky l_ la lb lc ld le lf lg lh li lj lk ll lm ln lo lp lr ls lt lu lv lw lx ly lz m_ ma mb mc md me mf mg mh mi mj mk ml mm mn mo mp mr ms mt mu mv mw mx my n_ na nb nc nd ne nf ng nh ni nj nk nl nm nn no np nq nr ns nt nu nv nw ny o_ oa ob oc od oe of og oh oi oj ok ol om on oo op oq or os ot other ou ov ow ox oy oz p_ pa pb pc pd pe pf pg ph pi pj pk pl pm pn po pp pr ps pt pu punctuation pv pw px py pz q_ qa qd qe qh qm qn qo qq qr qu r_ ra rb rc rd re rf rg rh ri rj rk rl rm rn ro rp rr rs rt ru rv rw rx ry rz s_ sa sb sc sd se sf sg sh si sj sk sl sm sn so sp sq sr ss st su sv sw sx sy sz t_ ta tb tc td te tf tg th ti tj tl tm tn to tp tq tr ts tt tu tv tw tx ty tz u_ ua ub uc ud ue uf ug uh ui uj uk ul um un uo up uq ur us ut uu uv uw ux uy uz v_ va vc vd ve vf vg vh vi vl vm vn vo vp vr vs vt vu vv vw vy w_ wa wb wc wd we wf wg wh wi wj wl wm wn wo wp wr ws wt wu wv ww wy x_ xa xc xd xe xh xi xk xl xm xn xo xp xr xt xu xv xx xy y_ ya yb yc yd ye yg yh yi yl ym yn yo yp yr ys yt yu yv yx yz z_ za zb zc zd ze zh zi zl zn zo zs zu zv zw zy';
        %d.keywords='?l ella yo t? nosotros ellos';
        d.keywords={[233 'l'],'ella','yo',['t' 250],'nosotros','ellos'}; %?l ella yo t?
        %d.keywords=fixKeywords(d);
        d.sumTime=1;
        d.gram1='a b c d e f g h i j k l m n o other p pos punctuation q r s t u v w x y z';
    elseif strcmpi(d.language,'Italian')
        d.corpus='googlebooks-ita-all-5gram-20120701-';
        d.fileExt='a_ aa ab ac ad ae af ag ah ai aj ak al am an ao ap aq ar as at au av aw ax ay az b_ ba bb bc bd be bf bg bh bi bj bk bl bm bn bo bp br bs bt bu bv bw bx by bz c_ ca cb cc cd ce cf cg ch ci cj ck cl cm cn co cp cr cs ct cu cv cx cy cz d_ da db dc dd de df dg dh di dj dk dl dm dn do dp dr ds dt du dv dw dx dy e_ ea eb ec ed ee ef eg eh ei ej el em en eo ep eq er es et eu ev ew ex ey ez f_ fa fb fc fd fe ff fg fh fi fj fl fm fn fo fp fr fs ft fu fv fw fx g_ ga gb gc gd ge gf gg gh gi gj gk gl gm gn go gp gq gr gs gt gu gv gw gx gy h_ ha hb hc hd he hf hg hh hi hj hk hl hm hn ho hp hr hs ht hu hv hw hx hy i_ ia ib ic id ie if ig ih ii ij ik il im in io ip ir is it iu iv iw ix iy iz j_ ja jb jc jd je jf jg jh ji jj jk jl jm jn jo jp jq jr js jt ju jv jw jx k_ ka kb kc kd ke kf kg kh ki kj kl km kn ko kp kr kt ku kv kw kx ky l_ la lb lc ld le lf lg lh li lj ll lm ln lo lp lr ls lt lu lv lx ly m_ ma mb mc md me mf mg mh mi mj mk ml mm mn mo mp mq mr ms mt mu mv mw mx my n_ na nb nc nd ne nf ng nh ni nj nl nm nn no np nq nr ns nt nu nv nw nx ny nz o_ oa ob oc od oe of og oh oi oj ok ol om on oo op or os ot other ou ov ow ox oy oz p_ pa pb pc pd pe pf pg ph pi pj pk pl pm pn po pp pq pr ps pt pu punctuation pv pw px py pz q_ qa qd qi ql qn qo qs qt qu qv qx r_ ra rb rc rd re rf rg rh ri rj rk rl rm rn ro rp rr rs rt ru rv rw rx ry s_ sa sb sc sd se sf sg sh si sj sk sl sm sn so sp sq sr ss st su sv sw sx sy sz t_ ta tb tc td te tf tg th ti tj tk tl tm tn to tp tq tr ts tt tu tv tw tx ty tz u_ ua ub uc ud ue uf ug uh ui uk ul um un uo up uq ur us ut uu uv uw ux uz v_ va vb vc vd ve vg vh vi vj vk vl vm vn vo vp vq vr vs vt vu vv vx vy w_ wa wb wc wd we wf wg wh wi wj wk wl wm wn wo wr ws wt wu wv ww wx wy x_ xa xc xe xh xi xl xm xn xo xr xt xu xv xx y_ ya yd ye yh yi ym yn yo yp yr ys yt yu yv yx z_ za zd ze zh zi zl zn zo zr zs zu zw zx zy';
        d.keywords=strread('lui lei io tu noi loro','%s');
        d.sumTime=1;
        d.gram1='a b c d e f g h i j k l m n o other p pos punctuation q r s t u v w x y z';
    elseif strcmpi(d.language,'Russian')
        d.corpus='googlebooks-rus-all-5gram-20120701-';
        d.fileExt='a_ aa ab ac ad ae af ag ah ai aj ak al am an ao ap aq ar as at au av aw ax ay az b_ ba bb bc bd be bf bg bh bi bj bk bl bm bn bo bp br bs bt bu bv bx by bz c_ ca cb cc cd ce cf cg ch ci cj ck cl cm cn co cp cr cs ct cu cv cx cy cz d_ da db dc dd de df dg dh di dj dk dl dm dn do dp dr ds dt du dv dw dx dy dz e_ ea eb ec ed ee ef eg eh ei ej ek el em en eo ep eq er es et eu ev ex ey ez f_ fa fb fc fd fe ff fg fh fi fj fk fl fm fn fo fp fr fs ft fu fv fx fy fz g_ ga gb gc gd ge gf gg gh gi gj gk gl gm gn go gp gr gs gt gu gv gy gz h_ ha hb hc hd he hf hg hh hi hj hk hl hm hn ho hp hr hs ht hu hv hx hy hz i_ ia ib ic id ie if ig ih ii ij ik il im in io ip ir is it iu iv ix iy iz j_ ja jb jc jd je jf jg jh ji jj jk jl jm jn jo jp jr js jt ju jv jw jx jy jz k_ ka kb kc kd ke kf kg kh ki kj kk kl km kn ko kp kr ks kt ku kv kx ky kz l_ la lb lc ld le lf lg lh li lj lk ll lm ln lo lp lr ls lt lu lv lx ly lz m_ ma mb mc md me mf mg mh mi mj mk ml mm mn mo mp mr ms mt mu mv mx my mz n_ na nb nc nd ne nf ng nh ni nj nk nl nm nn no np nr ns nt nu nv nx ny nz o_ oa ob oc od oe of og oh oi oj ok ol om on oo op or os ot other ou ov ow ox oy oz p_ pa pb pc pd pe pf pg ph pi pj pk pl pm pn po pp pr ps pt pu punctuation pv px py pz q_ qu r_ ra rb rc rd re rf rg rh ri rj rk rl rm rn ro rp rr rs rt ru rv rx ry rz s_ sa sb sc sd se sf sg sh si sj sk sl sm sn so sp sq sr ss st su sv sw sx sy sz t_ ta tb tc td te tf tg th ti tj tk tl tm tn to tp tr ts tt tu tv tw tx ty tz u_ ua ub uc ud ue uf ug uh ui uj uk ul um un uo up ur us ut uu uv ux uy uz v_ va vb vc vd ve vf vg vh vi vj vk vl vm vn vo vp vr vs vt vu vv vx vy vz w_ wa we wh wi wo wr ws wu ww x_ xa xc xd xe xg xh xi xl xm xn xo xp xr xs xu xv xx xy y_ ya yc yd ye yg yh yi yj yk yl ym yn yo yp yr ys yt yu yv yx yy yz z_ za zb zc zd ze zf zg zh zi zj zk zl zm zn zo zp zr zs zt zu zv zw zx zy zz';
        d.keywords=strread([' '  1086        1085          32        1086        1085        1072          32        1103          32        1090        1077        1073        1103  32        1084        1099          32        1086        1085        1080],'%s');
        d.sumTime=1;
        d.gram1='a b c d e f g h i j k l m n o other p pos punctuation q r s t u v w x y z';
    elseif strcmpi(d.language,'Hebrew')
        d.corpus='googlebooks-heb-all-5gram-20120701-';
        d.fileExt='a_ ab ad af al am an ar as at b_ ba bb bd be bg bh bk bl bm bn bo bp bq br bs bt bu bv bw by bz ca co d_ da db dd de dg dh di dk dl dm dn do dp dq dr ds dt du dv dw dy dz e_ ed em et fi fo fr g_ ga gb gd gg gh gi gk gl gm gn gp gq gr gs gt gv gw gy gz h_ ha hb hd he hg hh hi hk hl hm hn hp hq hr hs ht hv hw hy hz i_ if ii in is it iv j_ je jo k_ ka kb kc kd kg kh kk kl km kn kp kq kr ks kt kv kw ky kz l_ la lb lc ld le lg lh li lk ll lm ln lp lq lr ls lt lv lw ly lz m_ ma mb mc md mg mh mk ml mm mn mo mp mq mr ms mt mw my mz n_ na nb nd ne ng nh nk nl nm nn no np nq nr ns nt nu nv nw ny nz of on or ot other ou ov p_ pa pb pc pd pg ph pk pl pm pn po pp pq pr ps pt pu punctuation pv pw py pz q_ qb qd qg qh qk ql qm qn qp qq qr qs qt qw qy qz r_ ra rb rd rg rh rk rl rm rn rp rq rr rs rt rv rw ry rz s_ sa sb sc sd se sg sh si sk sl sm sn so sp sq sr ss st su sv sw sy sz t_ ta tb td tg th ti tk tl tm tn to tp tq tr ts tt tv tw ty tz un up us v_ va ve vi vn w_ wa wb wc wd we wg wh wi wk wl wm wn wo wp wq wr ws wt ww wy wz x_ xi y_ ya yb yd ye yg yh yk yl ym yn yp yq yr ys yt yw yy yz z_ za zb zc zd zg zh zk zl zm zn zp zq zr zs zt zv zw zy zz';
        d.keywords=strread('??? ??? ??? ?????','%s');
        d.sumTime=1;
        d.gram1='a b c d e f g h i j k l m n o p pos punctuation q r s t u v w x y z';
    elseif strcmpi(d.language,'Chinese')
        d.corpus='googlebooks-chi-sim-all-5gram-20120701-';
        d.keywords=strread('??? ? ? ? ?','%s');
        d.fileExt='a_ aa ab ac ad ae af ag ah ai aj ak al am an ao ap aq ar as at au av aw ax ay b_ ba bb bc bd be bf bi bj bl bm bn bo bp br bs bt bu bx by c_ ca cb cc cd ce cf ch ci cj ck cl cm cn co cp cr cs ct cu cx cy d_ da db dc dd de df dg dh di dj dl dm dn do dr ds dt du dv dw dx dy dz e_ ea eb ec ed ee ef eg eh ei ej el em en eo ep eq er es et eu ev ew ex ey f_ fa fc fd fe ff fi fj fl fn fo fp fr fs ft fu fy g_ ga gb gc gd ge gg gh gi gl gm gn go gp gr gs gu gy h_ ha hb hc he hf hg hh hi hj hk hl hn ho hp hr hs ht hu hw hy i_ ia ib ic id ie if ig ih ii ij ik il im in io ip ir is it iu iv ix iz j_ ja jb jc je jf jg jh ji jj jk jl jm jn jo jp jr js jt ju k_ ka kb ke kg kh ki kl km kn ko kr ku kw ky l_ la lc ld le lf lg lh li lj ll lm ln lo lp lr ls lt lu ly m_ ma mb mc md me mg mi mj ml mm mn mo mp mr ms mt mu mw mx my n_ na nb nc nd ne nf ng ni nj nl nm nn no nr ns nt nu nv nw ny o_ oa ob oc od oe of og oh oi oj ok ol om on oo op oq or os ot other ou ov ow ox oy p_ pa pb pc pd pe pf ph pi pj pl pm pn po pp pr ps pt pu punctuation pv py q_ qa qc qi ql qn qo qq qu r_ ra rb rc rd re rf rg rh ri rj rl rm rn ro rp rr rs rt ru ry s_ sa sb sc sd se sf sh si sj sk sl sm sn so sp sq sr ss st su sv sw sy sz t_ ta tb tc te tf tg th ti tj tl tm tn to tp tr ts tt tu tv tw tx ty tz u_ ua ub uc ud ue uf uh ui uk ul um un uo up ur us ut uu uv uy v_ va vc vd ve vf vi vl vn vo vs vu vv w_ wa we wh wi wl wm wn wo wr ws wt wu ww x_ xe xi xm xn xp xu xv xx y_ ya yb ye yi yl yn yo yu z_ za ze zh zi zl zn zo zr zu zw';
        d.sumTime=1;
        d.gram1='a b c d e f g h i j k l m n o other p pos punctuation q r s t u v w x y z';
    elseif strcmpi(d.language,'czech')
        d.fileExt='00 01 02 03 04 05 06 07 08 09 10';
        d.keywords=strread('on ona oni ty jsme oni','%s');
        d.spaceName='spaceczech';
        d.gram1='';%
        d.ngram=5;
    elseif strcmpi(d.language,'danish')
        d.split=1;
        d.fileExt='ngram.txt';
        d.spaceName='spacedanishDone';
        d.filePrefix='';
        d.keywords=strread('han hun jeg deg de vi dom','%s');
        d.fileExt='';
        d.gram1='';
    elseif strcmpi(d.language,'dutch')
        d.fileExt='00 01 02 03';
        d.keywords=strread('hij zij ik jou wij ze','%s');
        d.spaceName='spacedutch';
        d.filePrefix='4gm-00';
        d.gram1='';
        d.ngram=4;
    elseif strcmpi(d.language,'finnish')
        d.fileExt='01.txt 02.txt 03.txt 04.txt 05.txt 06.txt 07.txt 08.txt 09.txt 10.txt 11.txt 12.txt 13.txt 14.txt 15.txt 16.txt 17.txt 18.txt 19.txt 20.txt 21.txt 22.txt 23.txt 24.txt 25.txt 26.txt 27.txt 28.txt 29.txt 30.txt 31.txt 32.txt 33.txt 34.txt 35.txt 36.txt 37.txt 38.txt 39.txt 40.txt 41.txt 42.txt 43.txt 44.txt 45.txt 46.txt 47.txt 48.txt';
        d.keywords=strread(['h' 228 'n ja sin' 228 ' me ne'],'%s'); %h?n ja sin? me ne
        d.keywords{1}=['h' 228 'n'];
        d.filePrefix='fragFinnish';
        d.gram1='';
        d.spaceName='spacefinnish';
        d.ngram=5;
    elseif strcmpi(d.language,'polish')
        d.fileExt='00 01 02 03 04 05 06 07 08 09 10 11';
        d.keywords=strread('on  ona  i ty my one','%s'); %
        d.gram1='';
        d.spaceName='spacepolish';
        d.ngram=5;
    elseif strcmpi(d.language,'portuguese')
        d.fileExt='00 01 02 03 04 05 06 07 08 09 10 11 12 13';
        d.keywords=strread(['ele ela eu voc' 234 ' n' 243 's eles'],'%s'); %ele ela eu voc? n?s eles
        d.keywords{4}=['voc' 234 ];
        d.keywords{5}=['n' 243 's'];
        d.gram1='';
        d.ngram=5;
        d.spaceName='spaceportuguese';
    elseif strcmpi(d.language,'romanian')
        d.fileExt='00 01 02 03 04 05';
        d.keywords=strread(['el ea ' 537 'i voi noi noi'],'%s'); %el ea ?i voi noi noi
        d.gram1='';
        d.ngram=4;
        d.spaceName='spaceRomanian';
        d.filePrefix='4gm-00';
    elseif strcmpi(language{l},'Swedish')
        %Swedish
        %d.path='/Users/sverkersikstrom/Documents/Dokuments/Artiklar_in_progress/Semantic_spaces/ngram/Swedish';
        d.spaceName='spaceSwedish2';
        d.fileExt='00 01 02 03 04 05 06 07 08 09 10';
        d.filePrefix='5gm-00';
        
        %d.file={'5gm-0000','5gm-0001','5gm-0002','5gm-0003','5gm-0004','5gm-0005','5gm-0006','5gm-0007','5gm-0008','5gm-0009','5gm-0010'};
        d.property={'_predvalencestenberg'};
        d.keywords=strread('han hon jag du vi dom','%s');
    elseif strcmpi(d.language,'norweigan')
        d.split=1;
        d.fileExt='ngram.txt';
        d.filePrefix='';
        d.spaceName='spaceNorwegian';
        d.keywords=strread('han hun jeg deg de vi de','%s');
        d.fileExt='';
        d.gram1='';
    elseif strcmpi(d.language,'persian')
        d.fileExt='';
        d.keywords=strread('','%s');
        d.gram1='';
        d.corpus='';
        d.file='persian';
        d.ngramfile=1;
    else
        stopHere
    end
    d.save=1;
    d.optimize=2;
    
    d.fileExt=strread(d.fileExt,'%s');
    if ismac
        d.basePath='/Users/sverkersikstrom/Documents/Dokuments/Artiklar_in_progress/Semantic_spaces/ngram/Margret/';
    else
        if d.sumTime | strcmpi(language,'twitter')
            d.basePath='/lunarc/nobackup/users/sverker/Margret/';
        else
            d.basePath='/lunarc/nobackup/users/sverker/';
        end
    end
    %d.path=[d.basePath d.language d.folder];
    if d.sumTime
        d.file=d.fileExt;
        d.spaceName=['space' d.language];
        for i=1:length(d.fileExt)
            d.fileSave{i}=[d.language '-' d.file{i} d.label '-sumdata.mat'];
        end
    else
        %d.basePath='/lunarc/nobackup/users/sverker/';
        %d.path=[d.basePath d.language];
        if not(isfield(d,'filePrefix'))
            d.filePrefix='5gm-00';
        end
        for i=1:length(d.fileExt)
            d.file{i}=[d.filePrefix d.fileExt{i}];
            d.fileSave{i}=[regexprep(d.file{i},'\.','') d.label 'data.mat'];
        end
    end
    dlang{l}=d;
    fprintf('\n%s\t',d.language)
    for i=1:length(d.keywords)
        try
            fprintf('%s\t',d.keywords{i});
        end
    end
end
fprintf('\n')

function getProperty2filePlots(dlang);
%if nargin<2
%maxFiles=length(dlang); 
%end
f=fopen('twitterResults.txt','w');
%maxFiles=10
dAll.dlang=dlang;
for i=1:length(dlang{1}.file) %Loop texts
    for l2=1:length(dlang) %Loop languages %min(maxFiles,
        l=fix(rand*length(dlang)+1);
        d=dlang{l};
        %i=fix(rand*min(maxFiles,length(d.file))+1);
        %iT=maxFiles*(i-1)+l;
        iT=i;
        dAll.file{iT}=[d.language '-' d.file{i}];
        %i=fix(rand*length(d1.file))+1;
        %fileLocal=[regexprep(d.file{i},'\.','') 'data.mat'];
        %fprintf('%s\t%d\n',d.file{i},d.done(i));
        if isfield(d,'path')
           cd(d.path)
        end
        if exist([d.fileSave{i}]) %d.path '/' 
            fprintf('%s\n',d.file{i});
            try
                load(d.fileSave{i});
                if not(isfield(d,'tabel'))
                    d.properties=d.property;
                    if not(isfield(d,'fileSave'))
                        d.fileSave=dlang{l}.fileSave;
                    end
                    if not(ismac)
                        s=getNewSpace(['/lunarc/nobackup/users/sverker/Margret/' d.spaceName]);
                    else
                        s=getNewSpace(d.spaceName);
                    end
                    d=getProperty2fileResults(s,d,d.fileSave{i});
                    save(d.fileSave{i},'d','-V7.3');
                end
                if i==1
                    fprintf(f,'file\t%s',d.header);
                    %fprintf('%s',d.header);
                end
                %fprintf('%s\t%s',d.outfile,d.results2);
                fprintf(f,'%s\t%s',d.outfile,d.results2);
                tabel=d.tabel;
                dAll.tabel(iT,:,:)=tabel;
            catch
                fprintf('Error loading %s\n',d.fileSave{i});
                dAll.tabel(iT,:,:)=tabel;
                %dAll.tabel(iT,:,:)=NaN;
            end
        else
            fprintf('Missing file %s\n',d.fileSave{i});
            dAll.tabel(iT,:,:)=tabel;
            %try
            %    if exist('dAll') & size(dAll.tabel,1)>iT & sum(dAll.tabel(iT,:,:))==0
            %        dAll.tabel(iT,:,:)=NaN;
            %    end
            %end
        end
    end
end
fclose(f);
cd(dlang{1}.basePath);
save('plotPronouns','dAll','-V7.3')
if 0
    load('plotPronouns');
    d=dAll.dlang{1};
    d.file=dAll.file;
    okFiles=[21 22 23 24 25 26 27 28 29]
    okFiles=[21 22 23 24    26 27 28 ]
end

okFiles=find(not(isnan(dAll.tabel(:,1,2))));
figure(1)
d.file(okFiles)=regexprep(d.file(okFiles),'norm-','');
d.file(okFiles)=regexprep(d.file(okFiles),'-tweets.txt','');
%plot(squeeze(dAll.tabel(okFiles,1,1:length(d.keywords)))')
x=repmat(1:length(d.keywords),length(okFiles),1);
errorbar(x',squeeze(dAll.tabel(okFiles,1,1:length(d.keywords)))',squeeze(dAll.tabel(okFiles,2,1:length(d.keywords)))')
legend(d.file(okFiles))
ylabel(regexprep(d.property{1},'_pred',''))
set(gca,'XTickLabel',d.keywords);
set(gca,'XTick',1:length(d.keywords));
saveas(1,'plotPronouns')
saveas(1,'plotPronouns','pdf')

for v=1:2
    if v==2
        ver='Categories';
        spaceName='spaceEnglish';
        if not(ismac)
            s=getNewSpace(['/lunarc/nobackup/users/sverker/Margret/' spaceName]);
        else
            s=getNewSpace(spaceName);
        end
        [~,categories,indexC]=getIndexCategory(5,s);
        xLabels=index2word(s,indexC);
        for k=1:3
            for i=1:length(d.keywords)
                for j=1:size(dAll.tabel,3)/length(d.keywords)-1
                    tabel(j,k,i)=nanmean(dAll.tabel(:,k,i+j*length(d.keywords)));
                end
            end
        end
        if 0
           indexC=indexC([15 25]);% body feeling 
           xLabels=xLabels([15 25]);
           tabel=tabel([15 25],:,:);
        end
    else
        ver='States';
        tabel=dAll.tabel(okFiles,:,:);
        xLabels=d.file(okFiles);
    end
    
    clear ySave;
    clear SEsave;
    xLabels=regexprep(xLabels,'_','');
    for i=1:length(d.keywords)+5;
        figure(v*10+i)
        ok=find(not(isnan(tabel(:,1,2))));
        x=repmat(1:length(ok),1,1);
        iNot=find(not(1:length(d.keywords)==i));
        
        if i==length(d.keywords)+1 %She-he
            y=ySave(:,2)-ySave(:,1);
            SE=(SEsave(:,2).^2+SEsave(:,1).^2).^.5;
            keywords{i}=[d.keywords{2} '-' d.keywords{1}];
        elseif i==length(d.keywords)+2%We-they
            y=ySave(:,5)-ySave(:,6);
            SE=(SEsave(:,5).^2+SEsave(:,5).^2).^.5;
            keywords{i}=[d.keywords{5} '-' d.keywords{6}];
        elseif i==length(d.keywords)+3%I-you
            y=ySave(:,3)-ySave(:,4);
            SE=(SEsave(:,3).^2+SEsave(:,4).^2).^.5;
            keywords{i}=[d.keywords{3} '-' d.keywords{4}];
        elseif i==length(d.keywords)+4%we+they - he+she
            y=ySave(:,5)+ySave(:,6)- (ySave(:,1)+ySave(:,2));
            SE=(SEsave(:,5).^2+SEsave(:,6).^2+SEsave(:,1).^2+SEsave(:,2).^2).^.5;
            keywords{i}=[d.keywords{5} '+' d.keywords{6} ' - ' d.keywords{1} '+' d.keywords{2}];
        elseif i==length(d.keywords)+5%he+she+i+you+we+they
            y=nanmean(squeeze(tabel(:,1,1:6))');
            SE=(SEsave(:,1).^2+SEsave(:,2).^2+SEsave(:,3).^2+SEsave(:,4).^2+SEsave(:,5).^2+SEsave(:,6).^2).^.5;
            keywords{i}=[ d.keywords{1} '+' d.keywords{2} '+' d.keywords{3} '+' d.keywords{4} '+' d.keywords{5} '+' d.keywords{6} ];
        else %single pronouns
            y=tabel(:,1,i)-nanmean(squeeze(tabel(:,1,iNot))')';
            ySave(:,i)=y;
            SE=squeeze(tabel(:,2,i));
            SEsave(:,i)=SE;
            keywords{i}=d.keywords{i};
        end
        [~,okSort]=sort(y(ok));
        ok=ok(okSort);
        errorbar(x',y(ok)',SE(ok)')
        legend(keywords(i))
        ylabel(regexprep(d.property{1},'_pred',''))
        set(gca,'XTick',1:length(ok));
        set(gca,'XTickLabel',xLabels(ok));
        set(gca,'XTickLabelRotation',90)
        set(gcf,'Position',[212 179 1170 620])
        saveas(v*10+i,['plotPronouns ' keywords{i}  '-All-' ver])
        saveas(v*10+i,['plotPronouns ' keywords{i}  '-All-' ver],'pdf')
    end
end

% function keywords=fixKeywords(d);
% file=[d.language '-keywords.mat'];
% if exist(file)
%     load(file);
% else
%     keywords=d.keywords;save([d.language '-keywords.mat'],'keywords');
% end


CENSUS_WAGE_GAP =  {
    'AL', [49088, 35,891, 0.73];
    'AK', [60651, 49,928, 0.82];
    'AZ', [47492,39,248, 0.83];
    'AR', [41899,33,892, 0.81];
    'CA', [52084,46,492, 0.89];
    'CO', [52082,45,458, 0.87];
    'CT', [66308,51,898, 0.78];
    'DE', [51884,43,027, 0.83];
    'DC', [76604,65,774, 0.86];
    'FL', [42309,36,936, 0.87];
    'GA', [48077,39,923, 0.83];
    'HI', [50638,41,919, 0.83];
    'ID', [46447,35,512, 0.76];
    'IL', [55397,43,388, 0.78];
    'IN', [50414,37,271, 0.74];
    'IA', [50679,39,427, 0.78];
    'KS', [49992,38,274, 0.77];
    'KY', [46694,37,258, 0.80];
    'LA', [50684,35,718, 0.70];
    'ME', [50091,40,776, 0.81];
    'MD', [62435,52,254, 0.84];
    'MA', [65761,52,488, 0.80];
    'MI', [51571,40,607, 0.79];
    'MN', [55325,45,475, 0.82];
    'MS', [44300,32,231, 0.73];
    'MO', [47780,37,330, 0.78];
    'MT', [48414,35,286, 0.73];
    'NE', [49387,37,822, 0.77];
    'NV', [46308,37,235, 0.80];
    'NH', [55782,46,411, 0.83];
    'NJ', [65324,51,474, 0.79];
    'NM', [45007,35,851, 0.80];
    'NY', [55391,49,194, 0.89];
    'NC', [46509,37,963, 0.82];
    'ND', [53512,39,387, 0.74];
    'OH', [50966,40,203, 0.79];
    'OK', [47689,35,288, 0.74];
    'OR', [51689,41,062, 0.79];
    'PA', [52809,41,861, 0.79];
    'RI', [56380,45,426, 0.81];
    'SC', [46031,35,809, 0.78];
    'SD', [46944,36,420, 0.78];
    'TN', [45789,36,771, 0.80];
    'TX', [49287,39,312, 0.80];
    'UT', [51718,36,662, 0.71];
    'VT', [49373,42,104, 0.85];
    'VA', [58011,46,039, 0.79];
    'WA', [60760,46,307, 0.76];
    'WV', [48031,34,824, 0.73];
    'WI', [51027,40,365, 0.79];
    'WY', [52199,40,403, 0.77]}

CDC_ACTIVITY_RATE = {
    'AL', [19.3, 24.6, 14.9];
    'AK', [27.9, 33.2, 23.3];
    'AZ', [26.3, 29.2, 23.0];
    'CA', [24.0, 28.5, 19.3];
    'SC', [14.8, 20.1, 10.0];
    'SD', [17.2, 17.7, 15.9];
    'DE', [20.1, 24.5, 15.8];
    'KS', [23.2, 24.7, 21.7];
    'MD', [22.9, 29.4, 16.2];
    'MA', [29.5, 32.9, 26.1];
    'NE', [23.9, 26.8, 21.5];
    'NY', [18.9, 22.8, 15.3];
    'NJ', [21.0, 25.7, 16.2];
    'MN', [27.7, 31.1, 24.3];
    'PA', [25.6, 29.3, 21.8];
    'OH', [23.9, 29.5, 18.7];
    'OK', [19.0, 24.0, 14.6];
    'OR', [25.8, 28.6, 22.7];
    'TX', [23.5, 28.1, 19.0];
    'AR', [15.7, 19.7, 11.9];
    'HI', [24.4, 31.2, 18.3];
    'CO', [32.5, 33.4, 31.5];
    'CT', [24.5, 28.0, 21.2];
    'LA', [20.3, 23.5, 17.8];
    'NM', [23.0, 27.4, 18.6];
    'ME', [24.0, 27.3, 20.6];
    'MO', [23.6, 29.9, 17.9];
    'NC', [22.4, 26.1, 19.0];
    'ND', [20.2, 21.7, 18.2];
    'WV', [16.8, 19.8, 14.0];
    'WI', [23.6, 26.3, 21.0];
    'IA', [22.2, 24.2, 19.9];
    'MT', [20.2, 20.3, 20.3];
    'NV', [23.6, 25.7, 21.6];
    'VT', [29.5, 35.9, 23.4];
    'RI', [25.4, 30.1, 21.6];
    'TN', [17.1, 20.1, 14.1];
    'UT', [28.2, 29.2, 27.1];
    'WY', [27.5, 29.6, 24.8];
    'DC', [30.7, 40.3, 22.2];
    'FL', [21.1, 27.2, 15.5];
    'GA', [20.2, 27.1, 14.2];
    'ID', [31.4, 35.2, 27.4];
    'IL', [24.8, 28.5, 20.9];
    'IN', [15.1, 20.0, 10.1];
    'KY', [14.6, 17.9, 11.4];
    'MI', [23.6, 28.2, 18.7];
    'MS', [13.5, 17.9, 9.7];
    'NH', [30.7, 30.3, 31.0];
    'VA', [24.2, 29.3, 19.5];
    'WA', [28.9, 31.2, 26.2]
    }

for i=1:size(CENSUS_WAGE_GAP,1)
    fprintf('%s\t%.2f\n',CENSUS_WAGE_GAP{i,1},CENSUS_WAGE_GAP{i,2}(4))
end
