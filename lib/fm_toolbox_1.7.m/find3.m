function [x,y,z,v]=find3(arr);

%   FIND3   Find x,y,z locations and values of nonzero elements.
%   Syntax: [x,y,z,v] = find3(arr);
%   Based on FINDN and FIND by Loren Shure, Mathworks Inc
%   Simon Robinson. 9.11.2007
if nargout==4
    ind = find(arr);
    [x,y,z] = ind2sub(size(arr), ind);
    v=double(arr(ind));
else
    disp('!Syntax Wrong!'); 
    help find3; error('');
end
