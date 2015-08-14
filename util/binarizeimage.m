function [X, cropregion] = binarizeimage(varargin)
    % Segment the 3D v3draw uint image to binary image with a classifier or threshold
    % The segmentation will be enhanced with levelset
    % example:
    % binarizeimage(path2img, classifier, deleta_t)
    % binarizeimage(path2img, threshold)
    nVarargs = length(varargin);
    % Use the trained classifier to enhance and binarize the foreground neuron from v3draw
    [pathstr, ~, ~] = fileparts(mfilename('fullpath'));
    addpath(fullfile(pathstr, '..', 'scripts'));
    addpath(fullfile(pathstr, '..', 'lib', 'AOSLevelsetSegmentationToolboxM','AOSLevelsetSegmentationToolboxM'));
    addpath(fullfile(pathstr, '..', '..', '..', 'v3d', 'v3d_external', 'matlab_io_basicdatatype'));

    method = varargin{1};
    path2img = varargin{2};
    [imgdir, ~, ~] = fileparts(path2img);
    delta_t = varargin{4};

    crop = false;
    if numel(varargin) >= 5
        crop = varargin{5};
    end

    if strcmp(method, 'threshold')
        X = load_v3d_raw_img_file(path2img);
        threshold = varargin{3};
        X = double(X > threshold); 
    else
        cl = varargin{3}
        featdir = fullfile(imgdir, 'tmp');
        if ~exist(featdir, 'dir')
          mkdir(featdir);
        end
        featextract(path2img, [], featdir, 3);
        [X, ~, feats] = featcollect(featdir, []);
        pred = predict(cl, X);
        X = reshape(pred, size(feats.I));
        fprintf('Removing %s\n', featdir);
        rmdir(featdir, 's');
    end

    X = ac_linear_diffusion_AOS(X, delta_t);

    if crop
        [X, cropregion] = imagecrop(X, 0.5);
        disp('Image Size After Crop: ')
        disp(size(X));
    end

    X = X > 0.5;
end

