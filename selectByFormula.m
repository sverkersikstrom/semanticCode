function selection=selectByFormula(x,formula)
%Returns the indices where the selection criterion from the web page is true, for example 'x>2 & x<5'.
%The criterion is evaluated as MATLAB code, and it comes from the user, so only x, numbers,
%comparisons, logic, arithmetic and parentheses are accepted. Anything else could run commands on the server.
formula=char(formula);
if isempty(regexp(formula,'^[x0-9.eE+\-*/<>=~&|() ]*$','once'))
    error('The selection criterion "%s" may contain only x, numbers, comparisons such as > and ==, & and |, and parentheses',formula);
end
selection=find(eval(formula));
end
