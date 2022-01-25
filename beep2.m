function beep2(tmp)
if nargin<1
    return; 
end
try
    warning off
    sound(sin(1:10000/10));
    warning on
catch
end
