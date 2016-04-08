function [paths] = setup_directories(p,resume_fb_no)
%  setup_directories  setups the hierarchy of directories needed by the
%                     learning framework to dump the results
%
%  Synopsis:
%     [p] = setup_directories(p,resume_fb_no)
%
%  Input:
%     p            = structure containing framework's configuration
%     resume_fb_no = filter bank to resume (set -1 to remove the whole
%                    previous simulation) 
%  Output:
%     paths = sub-structure of the framework's configuration with the paths
%             required to ease further coding

%  author: Roberto Rigamonti, CVLab EPFL
%  e-mail: roberto <dot> rigamonti <at> epfl <dot> ch
%  web: http://cvlab.epfl.ch/~rigamont
%  date: April 2012
%  last revision: 27 April 2012

% Setup filename format for later use
paths.fb_img_fileformat = fullfile(p.results_path,'filters_img','fb_%06d.png');
paths.fb_txt_fileformat = fullfile(p.results_path,'filters_txt','fb_%06d.txt');
paths.w_filter_filename = fullfile(p.results_path,p.wf_filename);
paths.processed_dataset = fullfile(p.results_path,'processed_dataset.mat');

if (resume_fb_no<1)
    if (resume_fb_no==-1)
        % Remove previous simulation (if present)
        if (exist(p.results_path,'dir'))
            fprintf('Removing previous simulation directory\n');
            [status,message,messageid] = rmdir(p.results_path,'s'); %#ok<*NASGU,*ASGLU>
        end
    end
    if (resume_fb_no==0)
        % Remove previous results (if present)
        if (exist(fullfile(p.results_path,'filters_img'),'dir'))
            fprintf('No resume requested, removing the previous results img directory\n');
            [status,message,messageid] = rmdir(fullfile(p.results_path,'filters_img'),'s'); %#ok<*NASGU,*ASGLU>
        end
        if (exist(fullfile(p.results_path,'filters_txt'),'dir'))
            fprintf('No resume requested, removing the previous results txt directory\n');
            [status,message,messageid] = rmdir(fullfile(p.results_path,'filters_txt'),'s'); %#ok<*NASGU,*ASGLU>
        end
    end
    % Recreate directories
    [status,message,messageid] = mkdir(p.results_path);
    [status,message,messageid] = mkdir(p.results_path,'filters_img');
    [status,message,messageid] = mkdir(p.results_path,'filters_txt');
else
    % Check that the desired filter bank and the needed directories, are present
    if (~exist(p.results_path,'dir') || ~exist(fullfile(p.results_path,'filters_txt'),'dir'))
        error('Resume requested, but needed directories are missing');
    end
    if (~exist(fullfile(p.results_path,'filters_img'),'dir'))
        [status,message,messageid] = mkdir(p.results_path,'filters_txt');
    end
    resume_fb_filename = sprintf(paths.fb_txt_fileformat,resume_fb_no);
    if (~exist(resume_fb_filename,'file'))
        error('Resume from iteration %d requested, but the filter %s, which is supposed to contain the filter bank to resume, does not exist',resume_fb_no,resume_fb_filename);
    end
end

end
