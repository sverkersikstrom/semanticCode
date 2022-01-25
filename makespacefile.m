function s=makespacefile(filename)
s=[];
if isempty(findstr(filename,'space_'))
    filename=['space_' filename];
end
spaceFile=[filename '.txt'];
if not(exist(spaceFile))
    fprintf('Critical Error: cannot find spacefil %s, please locate!\n',spaceFile)
    return
end
fprintf('Making matlab %s file, please wait...',filename)
dicfile=['dictionary_' filename '.txt'];
if not(exist(dicfile));
    copyfile('dictionary.txt',dicfile);
end
s.fwords=textread(dicfile,'%s');
diana = fopen2([filename '.txt'], 'r');
if diana==-1
    fprintf('Semantic space file is missing %s\n',[ filename '.txt'])
else
    N= length(shiftdim(sscanf(fgets(diana),'%f')));
    fclose(diana);
    s.x=textread([ filename '.txt'],'%f');
    s.x=reshape(s.x,N,int32(length(s.x)/N));
    s.x=shiftdim(s.x,1);
    if not(length(s.x)==length(s.fwords))
        fprintf('\nCRITICAL ERROR: Length of dictionary.txt (%d) does not mach lenght if space-file (%d)!\n',length(s.fwords),length(s.x));
        stop%CHANGE
        if 1
            i=0;s.x=1;;N=150;
            diana = fopen2([ filename '.txt'], 'r');
            while not(feof(diana))
                i=i+1;
                tmp=sscanf(fgets(diana),'%f');
                if length(tmp)>1
                    s.x(i,:)=shiftdim(tmp,1);
                else
                    s.x(i,1)=-9;
                    s.x(i,N)=-9;
                end
            end
            fclose(diana);
            [~, N]=size(s.x);
            if not(length(s.x)==length(s.fwords))
                stop
            end
        end
    end
    s.info{length(s.fwords)}='';
    s.f(length(s.fwords))=NaN;
    ffile=['freq_' filename '.txt'];
    if exist(ffile);
        i=0;
        f=fopen(ffile);
        while not(feof(f))
            i=i+1;
            tmp=sscanf(fgets(f),'%d');
            if isnumeric(tmp)
                s.f(i)=tmp;
                s.info{i}.frequency=tmp;
            else
                s.f(i)=0;
            end
        end
        fclose(f);
        %s.f=textread(ffile);%CHANGE
        if not(length(s.f)==length(s.fwords))
            fprintf('\nCRITICAL ERROR: Length of frequency-file (%d) does not match lenght if dictionary-file (%d)!\n',length(s.f),length(s.fwords));
            stop
        end
    else
        fprintf('Could not find frequency file %s\n',ffile);
    end
    select=find(s.x(:,1)==-9);
    s.x(select,:)=zeros(length(select),N)*NaN;
    %s.skip(select)=1;
    %s.skip=zeros(1,length(s.fwords));
    
    for i=1:length(s.fwords)
        if length(find(strcmpi(s.fwords,s.fwords{i})))>1
            s.fwords{i}=[s.fwords{i} num2str(i)];
            fprintf('Duplicate %s found...removed by renameing with a number\n',s.fwords{i});
        end
    end
    s=calculate_bigram(s);
    fprintf('done.\nSaving %s file...\n',filename)
    save([ filename '.mat'],'s');
    beep2;
end
s.filename=[ filename '.mat'];
