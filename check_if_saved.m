function check_if_saved(s)
if isfield(s,'saved')
    global checkIfSaved
    if isempty(checkIfSaved)
        checkIfSaved=1;
    end
    if checkIfSaved & s.par.checkIfSaved & s.saved==0 & isfield(s,'datafile')
        if strcmpi('Yes',questdlg2(['Save space ' s.datafile],'Save','Yes','No','Yes'))
            saveSpace(s);
        end
    end
end
