function [X, feats] = binarizeimage(path2img, cl, delta_t)
	parpool
	% Use the trained classifier to enhance and binarize the foreground neuron from v3draw
    [pathstr, ~, ~] = fileparts(mfilename('fullpath'));
    addpath(fullfile(pathstr, '..', 'scripts'));
    addpath(fullfile(pathstr, '..', 'lib', 'AOSLevelsetSegmentationToolboxM','AOSLevelsetSegmentationToolboxM'));
    addpath(fullfile(pathstr, '..', '..', '..', 'v3d', 'v3d_external', 'matlab_io_basicdatatype'));

    [imgdir, ~, ~] = fileparts(path2img);
    featdir = fullfile(imgdir, 'tmp');

	if ~exist(featdir, 'dir')
	  mkdir(featdir);
	end

    featextract(path2img, [], featdir, 3);
    [X, ~, feats] = featcollect(featdir, []);
    pred = predict(cl, X);
    X = reshape(pred, size(feats.I));
    X = ac_linear_diffusion_AOS(X, delta_t);
    fprintf('Removing %s\n', featdir);
    rmdir(featdir, 's');
end

