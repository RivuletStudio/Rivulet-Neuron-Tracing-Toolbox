function [el_list,el_no] = get_list(list_filename)
%  get_list  reads a list of elements from a file
%
%  Synopsis:
%     [el_list,el_no] = get_list(list_filename)
%
%  Input:
%     list_filename = name of the file containing the list
%  Output:
%     el_list = list read from file
%     el_no   = number of elements read from file

%  author: Roberto Rigamonti, CVLab EPFL
%  e-mail: roberto <dot> rigamonti <at> epfl <dot> ch
%  web: http://cvlab.epfl.ch/~rigamont
%  date: April 2012
%  last revision: 27 April 2012

if (~exist(list_filename,'file'))
    warning(fprintf('The requested list (%s) is empty',list_filename));
    el_list = [];
    el_no = 0;
else
    fid = fopen(list_filename);
    el_list = textscan(fid,'%s','commentStyle','#');
    fclose(fid);
    el_list = el_list{1};
    el_no = length(el_list);
end

end
