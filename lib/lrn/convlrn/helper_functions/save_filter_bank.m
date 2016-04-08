function [] = save_filter_bank(p,fb,it_count)
%  save_filter_bank  saves the filter bank both as a text file and as an
%                    image
%
%  Synopsis:
%     save_filter_bank(p,fb,it_count)
%
%  Input:
%     p        = structure containing the parameters required by the system
%     fb       = cell array containing the filters
%     it_count = iteration counter

%  author: Roberto Rigamonti, CVLab EPFL
%  e-mail: roberto <dot> rigamonti <at> epfl <dot> ch
%  web: http://cvlab.epfl.ch/~rigamont
%  date: April 2012
%  last revision: 30 April 2012

% Save the filter bank in a text file
fd = fopen(sprintf(p.paths.fb_txt_fileformat,it_count/p.iterations_no),'wt');
for i_filter = 1:p.filters_no
    % Dump the filters a row at a time
    for r = 1:p.filters_size
        fprintf(fd,'%f ',fb{i_filter}(r,:));
        fprintf(fd,'\n');
    end
end
fclose(fd);
 
% Save the filter bank as an image
imwrite(reshape_fb_as_img(p,fb)/255,sprintf(p.paths.fb_img_fileformat,it_count/p.iterations_no),'png');
figure(1);
imagesc(reshape_fb_as_img(p,fb)/255);

end
