function LDA(s,o,modelTypeLDA,T)
if nargin<1
    s=getSpace;
end
if nargin<2
    [o s]=getWordFromUser(s,'Choice words to create LDA from');
    if o.N==0
        return
    end
end
A=zeros(1,o.N);

if nargin<3
    modelTypeLDA=strcmp('LDA',questdlg2('Model type','Type','LDA','Topic','LDA'));
    if modelTypeLDA==0
        [group s]=getWordFromUser(s,'Choice word to group topics from','','',1);
        if group.N==0; return;end
        A=getProperty(s,group.index,o.index);
        if strcmp('Yes',questdlg2('Median split on the group data','Median Split','Yes','No','No'));
            A=A>nanmedian(A);
        end
        Aunique=unique(A(not(isnan(A))));
        i2=0;
        for i=1:o.N
            if isfield(s.info{(o.index(i))},'index') & not(isnan(A(i)))
                i2=i2+1;
                for j=1:length(Aunique)
                    if A(i)==Aunique(j)
                        AD(j,i2)=1;
                    end
                end
            end
        end
        AD(sum(AD)==0,length(Aunique)+1)=1;
        AD=sparse(AD);
    end
end
if nargin<4
    T=str2num(inputdlg3('Number of topics','50'));
end

WS=[];
DS=[];
i2=0;
for i=1:o.N
    if isfield(s.info{(o.index(i))},'index') & not(isnan(A(i)))
        i2=i2+1;
        index=s.info{(o.index(i))}.index;
        index=index(find(index>0));
        if modelTypeLDA==0
            %DS=[DS (AD(i2,j)+1)*ones(1,length(index))];
            DS=[DS i2*ones(1,length(index))];
        else
            DS=[DS o.index(i)*ones(1,length(index))];
        end
        WS=[WS index];
    end
end

dataset = 1; % 1 = psych review abstracts 2 = NIPS papers
% Set the hyperparameters
BETA=0.01;
ALPHA=50/T;
% The number of iterations
N = 300; 
% The random seed
SEED = 3;
% What output to show (0=no output; 1=iterations; 2=all output)
OUTPUT = 1;
% This function might need a few minutes to finish
filename='topics.txt';

tic
WO=s.fwords;
if modelTypeLDA
    [ WP,DP,Z ] = GibbsSamplerLDA( WS , DS , T , N , ALPHA , BETA , SEED , OUTPUT );
    % Put the most 7 likely words per topic in cell structure S
    [S] = WriteTopics( WP , BETA , WO , 7 , 0.7 );
    uDS=unique(DS);
    fprintf( '\n\nMost likely words in divided into topics:\n' );
    fprintf( '\ntopics\tN\twords\t\n' );
    
    %%
    % Show the most likely words in the topics
    %S%( 1:10 )
    for i=1:T
        fprintf('%d\t%d\t%s\n',i,length(find(Z==i)),S{i})
    end

    
    %%
    % Write the topics to a text file
    WriteTopics( WP , BETA , WO , 10 , 0.7 , 4 , filename );
    
    fprintf( '\n\nInspect the file ''topics.txt'' for a text-based summary of the topics\n' );

else
    [ WP, AT , Z , X ] = GibbsSamplerAT( WS , DS , AD , T , N , ALPHA , BETA , SEED , OUTPUT );
    for i=1:T %length(unique(DS))
        index=find(i==DS);
        Dtopic(i)=median(Z(index));
        Daurthor(i)=median(X(index));
    end
    WPM{1} = WP; WPM{2} = AT;
    BETAM(1)=BETA; BETAM(2) = ALPHA;
    for i=1:length(Aunique)
        AN{i}=num2str(Aunique(i));
    end
    Nword=length(Aunique);
    AN{Nword+1}='Missing data';
    WOM{1}=WO; WOM{2}=AN;
    % Write the word topic and author topic distributions to a text file
    [ SM ] = WriteTopicsMult( WPM , BETAM , WOM , Nword , 0.7 , 4 , filename );
    fprintf('Topic\tKeywords\tCategorization')
    NAT=size(AT);
    for j=1:NAT(1)
        fprintf('\t%d',Aunique(j))
    end
    fprintf('\n')
    for i=1:T
        fprintf('%d\t%s\t%s\t',i,fixStringLength(SM{1}{i}),SM{2}{i})
        for j=1:NAT(1)
            fprintf('%d\t',full(AT(j,i)))
        end
        fprintf('\n')
    end
end
toc


function example

%% Example 1 of running basic topic model (LDA)
%
% This example shows how to run the LDA Gibbs sampler on a small dataset to
% extract a set of topics and shows the most likely words per topic. It
% also writes the results to a file

%%
% Choose the dataset
dataset = 1; % 1 = psych review abstracts 2 = NIPS papers

if (dataset == 1)
    % load the psych review data in bag of words format
    load 'bagofwords_psychreview'; 
    % Load the psych review vocabulary
    load 'words_psychreview'; 
elseif (dataset == 2)
    % load the nips dataset
    load 'bagofwords_nips'; 
    % load the nips vocabulary
    load 'words_nips'; 
end

%%
% Set the number of topics
T=50; 

%%
% Set the hyperparameters
BETA=0.01;
ALPHA=50/T;

%%
% The number of iterations
N = 300; 

%%
% The random seed
SEED = 3;

%%
% What output to show (0=no output; 1=iterations; 2=all output)
OUTPUT = 1;

%%
% This function might need a few minutes to finish
tic
[ WP,DP,Z ] = GibbsSamplerLDA( WS , DS , T , N , ALPHA , BETA , SEED , OUTPUT );
toc

%%
% Just in case, save the resulting information from this sample 
if (dataset==1)
    save 'ldasingle_psychreview' WP DP Z ALPHA BETA SEED N;
end

if (dataset==2)
    save 'ldasingle_nips' WP DP Z ALPHA BETA SEED N;
end
%%
% Put the most 7 likely words per topic in cell structure S
[S] = WriteTopics( WP , BETA , WO , 7 , 0.7 );

fprintf( '\n\nMost likely words in the first ten topics:\n' );

%%
% Show the most likely words in the first ten topics
S( 1:10 )  

%%
% Write the topics to a text file
WriteTopics( WP , BETA , WO , 10 , 0.7 , 4 , 'topics.txt' );

fprintf( '\n\nInspect the file ''topics.txt'' for a text-based summary of the topics\n' ); 
