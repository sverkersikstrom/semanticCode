%Example Code from paper
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%_________________________________________________________________________%
%
%IRTm Toolbox version0.0 2008 | code written by: Johan Braeken |
%Using this file implies that you agree with the license (see License.pdf)| 
%email: j.braeken@uvt.nl|j.braeken@flavus.org
%_________________________________________________________________________%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
%First Go to file->import and locate and open the file "recode.txt" (which is in your IRTm directory);
%Click next and finish to be able to try out the recoding example.
%Y=zeros(size(textdata)); 
%Y(find(ismember(textdata, 'A')==1))=1;
%Z=zeros(size(data,1),2); 
%Z(data==2,1)=1; 
%Z(data==3,2)=1;
%DataSet = [Y Z] 
%dlmwrite('filename.txt',DataSet,' ') 
%save('filename.mat', 'DataSet')
%%
%%%%START EXAMPLE I: a simple Rasch model%%%%%
SETTINGS = IRTmSet();
SETTINGS.input = 'example_rasch.txt'; 
SETTINGS.I=[2:7];
MODEL = IRTmModel(6,'Rasch'); 
OUTPUT = IRTm(SETTINGS,MODEL); 
OUTPUT.optim
OUTPUT.message
OUTPUT.HEScheck 
IRTmSummary(OUTPUT,'pred') 
IRTmSummary(OUTPUT,'param',MODEL) 
IRTmSummary(OUTPUT,'gof') 
%%
theta = OUTPUT.ebe(OUTPUT.Index);
figure('color','white')
hist(theta);
xlabel('\theta_p');
ylabel('freq(\theta_p)');
thetaSE = OUTPUT.ebeSE(OUTPUT.Index);
[s order]=sort(theta);
figure('color','white')
plot(theta(order),thetaSE(order));
xlabel('\theta_p');
ylabel('SE(\theta_p)');
%%
MODEL.TS.R=logical(0);
MODEL.TS.O=1;
OUTPUT(2) = IRTm(SETTINGS,MODEL);
IRTmSummary(OUTPUT,'gof') 
LR=1-chi2cdf(2*(OUTPUT(2).LL-OUTPUT(1).LL),1) 
%%
MODEL.TS.R=logical(1);
MODEL.TS.O=0;
MODEL.B.D=logical([1 0 0 0;0 1 0 0;1 1 1 0;
         1 0 0 1;0 1 0 1;1 1 1 1]);
MODEL.B.R=true(4,1);
MODEL.B.O=zeros(4,1);
OUTPUT(2)=IRTm(SETTINGS,MODEL);
IRTmSummary(OUTPUT(2),'param',MODEL)
%%
[ignore randomorder] = sort(rand(500,1)); 
SETTINGS.Sel=[randomorder(1:250)]; 
MODEL = IRTmModel(6, '2PL');
OUTPUT =IRTm(SETTINGS,MODEL); 
SETTINGS.Sel=[randomorder(251:500)];
MODEL.A.R=logical(zeros(6,1));
MODEL.A.O=OUTPUT.param(1:6);
MODEL.B.R=logical(zeros(6,1)); 
MODEL.B.O=OUTPUT.param(7:12);
OUTPUT(2)=IRTm(SETTINGS,MODEL);
CVI = OUTPUT(2).LL/OUTPUT(1).LL  
%%
SETTINGS = IRTmSet();
load('covtest.mat')
dataset(:,12)=dataset(:,12)-mean(dataset(:,12));
SETTINGS.input=dataset;
SETTINGS.I=[1:10];
SETTINGS.J=[11:12];
MODEL = IRTmModel(10,'Rasch',2);
MODEL.LM.I=[0.5;-0.5];
OUTPUT=IRTm(SETTINGS,MODEL);
dataset(:,12)=dataset(:,12)./100;
SETTINGS.input=dataset;
MODEL.LM.I=[];
OUTPUT(2)=IRTm(SETTINGS,MODEL);
display('Time in seconds for both models')
[OUTPUT.time] 
display('Parameter comparison')
[OUTPUT.param]
%%
MODEL.BD.D=logical([[zeros(6,1);1;zeros(3,1)] [zeros(4,1);ones(2,1);zeros(4,1)]]);
MODEL.BD.P=[1;1];
MODEL.BD.R=logical(ones(2,1));
MODEL.BD.O=zeros(2,1);
OUTPUT(3)=IRTm(SETTINGS,MODEL);
IRTmSummary(OUTPUT(3),'param',MODEL) 
%%
Z = dataset(:,11); 
dataset(:,11)=[]; 
SETTINGS.input=dataset;
SETTINGS.J=[11];
MODEL=IRTmModel(10,'Rasch',1);
OUTPUT=IRTm(SETTINGS,MODEL);
SETTINGS.alg=1;
SETTINGS.iter=50;
SETTINGS.crit=0.005;
SETTINGS.display='on';
MODEL.TM.D=logical(eye(2));
MODEL.TM.R=logical([0;1]);
MODEL.TM.O=zeros(2,1);
MODEL.TS.D=logical(ones(2,1));
MODEL.TW.D=logical(eye(2));
MODEL.TW.R=logical(ones(2,1));
MODEL.TW.O=zeros(2,1);
OUTPUT(2)=IRTm(SETTINGS,MODEL);
[OUTPUT.LL;OUTPUT. BIC]
[a postG]=max(OUTPUT(2).l(OUTPUT(2).Index,:),[],2);
Z1=sum(Z(Z==1));
Z0=OUTPUT(2).lN-Z1;
C1=sum(postG(postG==1));
C2=sum(postG(postG==2))./2;
Z1C1=sum(Z(postG==1));
Z1C2=sum(Z(postG==2));
Z0C1=C1-Z1C1;
Z0C2=C2-Z1C2;
M=[Z0C1 Z0C2 Z0;Z1C1 Z1C2 Z1;C1 C2 OUTPUT(2).lN]./OUTPUT(2).lN
%%
SETTINGS=IRTmSet;
SETTINGS.input='example_lid.txt';
SETTINGS.I=[1:10];
MODEL=IRTmModel(10,'Rasch');
OUTPUT=IRTm(SETTINGS,MODEL);
IRTmLIDscan(OUTPUT.Y(OUTPUT.Index,:),OUTPUT.S(OUTPUT.Index));
MODEL(2)=MODEL;
MODEL(2).Copula.D=[3 2 4 5 0 1;2 3 6 7 8 2];
MODEL(2).Copula.R=logical([1 0;1 0]);
MODEL(2).Copula.O=[1 1;0 1];
OUTPUT(2) =IRTm(SETTINGS,MODEL(2));
IRTmSummary(OUTPUT(2),'param',MODEL(2)) 
IRTmSummary(OUTPUT,'gof') 
MODEL(3)=MODEL(2);
MODEL(3).Copula.D=[0 2 4 5 0 1;
                6 2 4 5 0 1;
                2 3 6 7 8 2];
MODEL(3).Copula.R=logical([0 1;0 1;1 0]);
MODEL(3).Copula.O=[0 0;0 0;0 1];
SETTINGS.con=1;
MODEL(3).B.I=OUTPUT(1).param(1:10);
OUTPUT(3)=IRTm(SETTINGS,MODEL(3));
IRTmSummary(OUTPUT,'gof')
sum([OUTPUT.time])/60 
%%
%MODEL=IRTmModel(10,'Rasch');
%		MODEL.B.O=randn(10,1);
%		MODEL.TS.O=1.5;
%[Y th] = IRTmSim(MODEL,500);
%save('nameoffile.mat');
%save('nameoffile.mat','nameofMATLABvariable');
%dlmwrite('nameoffile.txt',Y,' ');





