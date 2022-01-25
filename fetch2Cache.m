function r =fetch2Cache(databaseName,sqlQuery,operationMode,clearCache)
if 1 
    %THE CAHSING IS NOW DISABLED!!!   
        
    r = fetch(databaseName,sqlQuery);
    return  
else 
    
    if(nargin<3)
        operationMode = 1;
    end 
    
    persistent sql 
    persistent results 
    persistent i
    
    if nargin==4
        sql = [];
        clear sql;
        results = [];
        clear results;
        i = 0;        
        %clear i
        %fprintf('Fetch2Cache: Database cache cleared\n');
        return
    end
     
    string=[databaseName '???' sqlQuery]; 
    if isempty(sql)
        i=0;
        sql = java.util.HashMap;
    end
    index=sql.get(string);
    if isempty(index)
        i=i+1;
        sql.put(string,i);
        i2=i;
        r = fetch2(databaseName,sqlQuery,operationMode);
        results{i2}=r;
    else
        r=results{index};
    end
end
end