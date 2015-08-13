function tf=isvar(v)
%ISVAR True if Variable Exists in Workspace.
% ISVAR('V') returns True if variable identified by character string 'V'
% exists in the current workspace. Otherwise False is returned.
%
% For structures, 'V' can determine the existence of a particular field as
% well. For example, 'V.one' will return True only if the variable named
% 'V' exists AND it has a field named 'one'.
%
% Nested structures such as 'V.one.two' return False.
%
% See also EXIST, ISA, ISVARNAME.

% D.C. Hanselman, University of Maine, Orono, ME 04469
% MasteringMatlab@yahoo.com
% Mastering MATLAB 7
% 2006-11-14

if nargin~=1
   error('ISVAR:minrhs','One Input Argument is Required.')
end
if ~ischar(v)
   error('ISVAR:rhs','String Input Argument Expected.')
end

v=v(:).';                                        % make sure input is a row

if isvarname(v)            % input is a valid variable name, check existence
   
   tf=evalin('caller',sprintf('exist(''%s'',''var'')',v))==1;
   
else                       % input might be a structure name with fieldname
   
   idx=strfind(v,'.');
   if length(idx)==1 && idx>1 && idx<length(v)
      vname=v(1:idx-1);
      fname=v(idx+1:end);
      tf=isvarname(vname) && ...
         evalin('caller',sprintf('isfield(%s,''%s'')',vname,fname));
      
   else  % input is not a simple structure with field name.
      tf=false;
   end
end
