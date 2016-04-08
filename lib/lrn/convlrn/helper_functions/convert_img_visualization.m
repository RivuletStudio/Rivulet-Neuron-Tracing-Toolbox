function [filter_img] = convert_img_visualization(filter)
%  convert_img_visualization  converts a filter in a numerical format
%                             suitable for visualization
%
%  Synopsis:
%     [filter_img] = convert_img_visualization(filter)
%
%  Input:
%     filter = filter to visualize
%  Output:
%     filter_img = filter converted to a numerical range that enables
%                  visualization

%  author: Roberto Rigamonti, CVLab EPFL
%  e-mail: roberto <dot> rigamonti <at> epfl <dot> ch
%  web: http://cvlab.epfl.ch/~rigamont
%  date: April 2012
%  last revision: 30 April 2012

filter_img = zeros(size(filter));

min_val = min(filter(:));
max_val = max(filter(:));
extremum = max(abs(min_val),abs(max_val));

if(max_val-min_val<1e-5 || extremum<1e-5)
    filter_img = 127.5;
else
    % Put filter in [0,2], with 0 centered in 1, then put in the [0,255]
    % range
    filter_img = (filter./extremum+1)*127.5;
end

end
