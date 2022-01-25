function procent = print_mem(print)
    % how to change heap space size:
    % http://www.mathworks.com/support/solutions/data/1-18I2C.html
    procent = NaN;
    try
        max = java.lang.Runtime.getRuntime.maxMemory/1000000;
        tot = java.lang.Runtime.getRuntime.totalMemory/1000000;
        free = java.lang.Runtime.getRuntime.freeMemory/1000000;
        procent = (free+(max-tot))/max*1.;
        if(nargin < 1)
            fprintf('MEMORY: max=%.0f mb, tot=%.0f mb, free=%.0f mb pro=%.4f mb\n',max,tot,free,procent);
        end
    catch ME
        printException(ME);
        fprintf('Failed to print java memory information.\n')
    end
    
    % Optimize memory usage
    max = [];
    tot = [];
    free = [];
end
