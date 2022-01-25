function handles=getHandles(handles) 
%global saveGlobalHandels

persistent savedHandles 
if nargin>0 
     savedHandles=handles; 
%elseif not(isempty(savedHandles) )
%    savedHandles=saveGlobalHandels;
elseif isempty(savedHandles)
    semantic;
end 
handles=savedHandles;
 