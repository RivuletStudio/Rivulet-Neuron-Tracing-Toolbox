function [fb] = initialize_fb(p,resume_fb_no)
%  initialize_fb  initialize a filter bank, either randomly or from a file
%
%  Synopsis:
%     [fb] = initialize_fb(p,resume_fb_no)
%
%  Input:
%     p            = structure containing the parameters required by the system
%     resume_fb_no = if > 0, resume from the specified filter bank
%
%  Output:
%     fb = initialized filter bank

%  author: Roberto Rigamonti, CVLab EPFL
%  e-mail: roberto <dot> rigamonti <at> epfl <dot> ch
%  web: http://cvlab.epfl.ch/~rigamont
%  date: April 2012
%  last revision: 02 May 2012

fb = cell(p.filters_no,1);

if (resume_fb_no > 0)
    % Resume a previously-computed filter bank
    fb_file = load(sprintf(p.paths.fb_txt_fileformat,resume_fb_no));
    for i_filter = 1:p.filters_no
        fb{i_filter} = fb_file((i_filter-1)*p.filters_size+1:i_filter*p.filters_size,:);
    end
else
    % Initialize a new filter bank with random values (the first one is set
    % to a uniform value)
    fb{1} = 1/(p.filters_size^2)*ones(p.filters_size,p.filters_size);
    for i_filter = 2:p.filters_no
        fb{i_filter} = randn(p.filters_size,p.filters_size);
    end
end

%  Normalize the filter bank
for i_filter = 1:p.filters_no
    fb{i_filter} = fb{i_filter}/(norm(fb{i_filter}(:)));
end

end
