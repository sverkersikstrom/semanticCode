function s=initSpace(command);
%global savedHandles2
s=[];
s.fwords={};
s.info={};
s.Ndim=0;
s=mkHash(s,1);
s.par=getPar;
s.N=0;
s.x=[];
s.f=[];
%if not(isempty(savedHandles2))
%    s.handles=savedHandles2;
%else
s.handles=getHandles;
%end
s.languagefile='';
s.filename='';
s.datafile='';
s.languagefilePath='';
s.wordclass=[];
s.data=1;
s.rand=rand;
s.classlabel={    'temporal'    'adjective'    'conjunction etc'    'determinerare'    'countingwords'    'nouns'    'proper name'    'pronouns'    'adverb'    'verb'    'prepositions'    'other'    'errors'};
disp('----');

disp(nargin);
disp('----');
if nargin>0
    if isempty(s.par.languageCode)
        s.par.languageCode=command.get('languagecode');
    end
    weightTargetWord = command.get('weightTargetWord');
    weightWordClass = command.get('weightWordClass');
    semanticDistance = command.get('semanticDistance');
    parameters = command.get('parameters');
    if isempty(parameters) == false
        parameters=loadjson(parameters);
        s=advancedOption(s,parameters,weightTargetWord,weightWordClass,semanticDistance);
    end
end
