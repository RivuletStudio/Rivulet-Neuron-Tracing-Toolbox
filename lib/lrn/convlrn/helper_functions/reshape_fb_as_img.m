function [fb_img] = reshape_fb_as_img(p,fb)
%  reshape_fb_as_img  reshape a filter bank as an image where each filter
%                     constitutes a block in a matrix
%
%  Synopsis:
%     [fb_img] = reshape_fb_as_img(p,fb)
%
%  Input:
%     p  = structure containing the parameters required by the system
%     fb = cell array containing the filters
%  Output:
%     fb_img = filter bank reshaped as image

%  author: Roberto Rigamonti, CVLab EPFL
%  e-mail: roberto <dot> rigamonti <at> epfl <dot> ch
%  web: http://cvlab.epfl.ch/~rigamont
%  date: April 2012
%  last revision: 30 April 2012

% Total number of blocks
blocks_no = p.filters_no;
% Number of rows in the block matrix
blocks_rows_no = ceil(sqrt(blocks_no));
% Number of cols in the block matrix
blocks_cols_no = ceil(sqrt(blocks_no));

% Allocate the image with white background and the proper size
fb_img = 255*ones(blocks_rows_no*p.filters_size*p.pixel_size+(blocks_rows_no-1)*p.v_space,blocks_cols_no*p.filters_size*p.pixel_size+(blocks_cols_no-1)*p.h_space);

i_row = 0;
i_col = 0;
for i_filter = 1:p.filters_no
    if(i_col==blocks_cols_no)
        i_row = i_row+1;
        i_col = 0;
    end
    
    % Magnify the filter and convert it to image
    filter_img = convert_img_visualization(magnify_matrix(fb{i_filter},p.pixel_size));
    % Set the filter in the image
    fb_img(i_row*(p.filters_size*p.pixel_size+p.v_space)+1:(i_row+1)*p.filters_size*p.pixel_size+i_row*p.v_space,i_col*(p.filters_size*p.pixel_size+p.h_space)+1:(i_col+1)*p.filters_size*p.pixel_size+i_col*p.h_space) = filter_img;
    
    i_col = i_col+1;
end

end
