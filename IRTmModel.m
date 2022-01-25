function MODEL = IRTmModel(lI,type,varargin);
%Acquire default MODEL structure
% MODEL = IRTmModel(lI,type,varargin) takes two parameters
% indicating the number of items lI, and the type of model you want to estimate.
% An optional third argument indicates the number of person covariates lJ.
% At this moment standard model settings are provided for the 'Rasch' and
% '2PL' model, with in case of covariates a latent regression on the mean.
% A switch statement is present in which extra userdefined standard models
% can be specified.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%_________________________________________________________________________%
%
%IRTm Toolbox version0.0 2008 | code written by: Johan Braeken |
%Using this file implies that you agree with the license (see License.pdf)| 
%email: j.braeken@uvt.nl|j.braeken@flavus.org
%_________________________________________________________________________%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin==3; lJ=varargin{1}; else lJ=0; end
switch(type);
    case 'Rasch';
        MODEL.A=struct('D',true(lI,1),'R',false(1),'O',1,'I',[],'lb',[],'ub',[]);
        MODEL.AD=struct('D',[],'R',logical([]),'O',[],'I',[],'lb',[],'ub',[],'P',0);
        MODEL.B=struct('D',logical(eye(lI)),'R',true(lI,1),'O',zeros(lI,1),'I',[],'lb',[],'ub',[]);
        MODEL.BD=struct('D',[],'R',logical([]),'O',[],'I',[],'lb',[],'ub',[],'P',0);
        MODEL.C=struct('D',true(lI,1),'R',false(1),'O',0,'I',[],'lb',[],'ub',[]);
        MODEL.LM=struct('D',logical(eye(lJ)),'R',true(lJ,1),'O',zeros(lJ,1),'I',[],'lb',[],'ub',[]);
        MODEL.LS=struct('D',true(lJ,1),'R',false(1),'O',0,'I',[],'lb',[],'ub',[]);
        MODEL.TM=struct('D',true(1),'R',false(1),'O',0,'I',[],'lb',[],'ub',[]);
        MODEL.TS=struct('D',true(1),'R',true(1),'O',0,'I',[],'lb',[],'ub',[]);
        MODEL.TW=struct('D',true(1),'R',false(1),'O',1,'I',[],'lb',[],'ub',[]);
        MODEL.Copula=struct('D',[],'R',logical([]),'O',[],'I',[],'lb',[],'ub',[]);
        %Rasch (latent regression on the mean in case of covariates)

    case '2PL';
        MODEL.A=struct('D',logical(eye(lI)),'R',true(lI,1),'O',zeros(lI,1),'I',[],'lb',[],'ub',[]);
        MODEL.AD=struct('D',[],'R',logical([]),'O',[],'I',[],'lb',[],'ub',[],'P',0);
        MODEL.B=struct('D',logical(eye(lI)),'R',true(lI,1),'O',zeros(lI,1),'I',[],'lb',[],'ub',[]);
        MODEL.BD=struct('D',[],'R',logical([]),'O',[],'I',[],'lb',[],'ub',[],'P',0);
        MODEL.C=struct('D',true(lI,1),'R',false(1),'O',0,'I',[],'lb',[],'ub',[]);
        MODEL.LM=struct('D',logical(eye(lJ)),'R',true(lJ,1),'O',zeros(lJ,1),'I',[],'lb',[],'ub',[]);
        MODEL.LS=struct('D',true(lJ,1),'R',false(1),'O',0,'I',[],'lb',[],'ub',[]);
        MODEL.TM=struct('D',true(1),'R',false(1),'O',0,'I',[],'lb',[],'ub',[]);
        MODEL.TS=struct('D',true(1),'R',false(1),'O',1,'I',[],'lb',[],'ub',[]);
        MODEL.TW=struct('D',true(1),'R',false(1),'O',1,'I',[],'lb',[],'ub',[]);
        MODEL.Copula=struct('D',[],'R',logical([]),'O',[],'I',[],'lb',[],'ub',[]);
        %2PL (latent regression on the mean in case of covariates)

        %case 'modelname'; add standard settings here
end