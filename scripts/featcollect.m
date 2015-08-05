function [X, Y] = featcollect(path2feat, skip)
% Collect each .mat feature file of 1 subject and normalize the feature fields
% To be run after featextract
    [pathstr, ~, ~] = fileparts(mfilename('fullpath'));
    addpath(fullfile(pathstr, '..', 'util'));
    addpath(fullfile(pathstr, '..', 'lib', 'dir2'));
    addpath(fullfile(pathstr, '..', '..', '..', 'v3d', 'v3d_external', 'matlab_io_basicdatatype'));
    
    X = [];
    Y = [];
    disp(['Searching path...', path2feat])
    fnames = dir2(path2feat, '*.mat', '-r');
    fields = {};

    for i = 1 : numel(fnames)   
    	f = fnames(i);
    	xrows = [];
    	yrows = [];

        if any(abs(skip-i)<1e-10)
        	fprintf('skipping %s\n', f.name);
        	continue
        end
        
    	% if numel(f) > 4 && strcmp(f(end-3:end), '.mat')
		fprintf('Collecting %s\n', f.name);
		feats = load(fullfile(path2feat, f.name));
		fields = fieldnames(feats);

        for j = 1:numel(fields)
        	if strcmp(fields{j}, 'gt')
        	    yrows = feats.(fields{j});	
        	    yrows = yrows(:, end:-1:1, :);
			else
	            x = feats.(fields{j});
	            x = normalise(x(:));
	            xrows = [xrows, x];
	        end
        end

        X = [X; xrows];
        Y = [Y; yrows(:)];
        clear rows, feats;
    end

	path2save = fullfile(path2feat, '..', 'allfeat.mat')
	fprintf('saving to %s\n', path2save);
    save(path2save, 'X', 'Y', 'fields', '-v7.3');
end

function x = normalise(x)
    x = (x - mean(x)) / std(x);
	x = (x - min(x)) / (max(x) - min(x));
end