function s=printSpaceInfo(s);
if ispc
    seperator='\';
else
    seperator='/';
end

if isfield(s,'languagefile')
    datafile='';
    try
        datafile=s.datafile;
        a=findstr(datafile,seperator);
        datafile=datafile(a(end)+1:end);
    end
    
    global reportFilename
    report=reportFilename;
    a=findstr(report,seperator);
    try
        report=report(a(end)+1:end);
    end
    try
        parent=get(s.handles.commandOrData,'Parent');
        langeName=regexprep(s.languagefile,'\.mat','');
        a=findstr(langeName,seperator);
        try
            langeName=langeName(a(end)+1:end);
        end
        set(parent,'name',['Semantic: Langauge=' langeName ' , Data=' datafile ' Report=' report ', Text=' s.par.variableToCreateSemanticRepresentationFrom])
    end
end