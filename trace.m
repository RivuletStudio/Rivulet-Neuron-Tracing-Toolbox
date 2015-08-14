function tree = trace(varargin)
% Main tracing function
% imgpath: the path to the v3draw image
% Return: swc tree
% segmentmethod: 'threshold' / 'classification'
% threshold/cl: threshold for image segmentation when method is set threshold; / cl: .mat file containing the voxel classifier; can be [] when method is set 'threshold'
% plot(optional): plot the tracing progress or not; default false
% delta_t (optional): delta_t for level-set; default 1
% percentage(optional): finish until this proportion of binary image has been covered; default 0.95
% crop(optional): crop the image with threshold > 0; default true
% rewire: whether the result tree will be rewired

	imgpath = varargin{1};
	segmentmethod = varargin{2};
	if strcmp(segmentmethod, 'threshold')
		threshold = varargin{3};
	else
	    cl = varargin{3};
	end

    if numel(varargin) > 3
		plot = varargin{4};
	else
		plot = false;
	end

    if numel(varargin) > 4
		delta_t = varargin{5};
	else
		delta_t = 0.5;
	end

	if numel(varargin) > 5
		percentage = varargin{6};
	else
		percentage = 0.95;
	end

	if numel(varargin) > 6
		crop = varargin{7};
	else
		crop = true;
	end

	if numel(varargin) > 7
		rewire = varargin{8};
	else
		rewire = false;
	end


	[pathstr, ~, ~] = fileparts(mfilename('fullpath'));
    addpath(fullfile(pathstr, '..', '..', 'v3d', 'v3d_external', 'matlab_io_basicdatatype'));
    addpath(fullfile(pathstr, 'util'));
    addpath(genpath(fullfile(pathstr, 'lib')));

	disp('Loading Image and segment foreground...');
	% I = load_v3d_raw_img_file(imgpath);

	tic;
	fprintf('Segmenting image using %s\n', segmentmethod);
	if strcmp(segmentmethod, 'threshold')
	    [I, cropregion] = binarizeimage(segmentmethod, imgpath, threshold, delta_t, crop);
	else
	    [I, cropregion] = binarizeimage(segmentmethod, imgpath, cl, delta_t, crop);
	end

    
    disp('Distance transform');
    bdist = getBoundaryDistance(I, true);
    disp('Looking for the source point...')
    [SourcePoint, maxD] = maxDistancePoint(bdist, I, true);
    disp('Make the speed image...')
    SpeedImage=(bdist/maxD).^4;
	SpeedImage(SpeedImage==0) = 1e-10;
	disp('marching...');
    oT = msfm(SpeedImage, SourcePoint, false, false);
    disp('Finish marching')

    disp('Calculating gradient...')
	% Calculate gradient of DistanceMap

    close all
    T = oT;
    tree = []; % swc tree
    prune = true;
	grad = distgradient(T);
    S = {};
    B = zeros(size(T));
    i = 1;
	figure(1)
	showbox(I, 0.5);
	drawnow

    lconfidence = [];
    if plot
	    hold on
	    [x,y,z] = sphere;
	    surf(x + SourcePoint(2), y + SourcePoint(1), z + SourcePoint(3));
	end

    while(true)

	    StartPoint = maxDistancePoint(T, I, true);
	    if plot
		    surf(x + StartPoint(2), y + StartPoint(1), z + StartPoint(3));
		end

	    if T(StartPoint(1), StartPoint(2), StartPoint(3)) == 0 || I(StartPoint(1), StartPoint(2), StartPoint(3)) == 0
	    	break;
	    end

	    disp('start tracing');
	    l = shortestpath2(T, grad, StartPoint, SourcePoint, 1, 'rk4');
	    disp('end tracing')

	    % Get radius of each point from distance transform
	    % ind = sub2ind(size(bdist), int16(l(:, 1)), int16(l(:, 2)), int16(l(:, 3)));
	    % radius = bdist(ind);
	    % radius(radius < 1) = 1;
	    % radius = ceil(radius);
	    radius = zeros(size(l, 1), 1);
	    for r = 1 : size(l, 1)
		    radius(i) = getradius(I, l(r, 1), l(r, 2), l(r, 3));
		end
	    radius(radius < 1) = 1;

	    if size(l, 1) < 4
	    	l = [StartPoint'; l];
	    	radius = zeros(size(l, 1), 1);
	    	radius(:) = 2;
	    end
		[rlistlength, useless] = size(l);
	    radiuslist = zeros(rlistlength, 1);
	    for radius_i = 1 : rlistlength
	    	curradius = getradius(I, l(radius_i, 1), l(radius_i, 2), l(radius_i, 3));
	    	radiuslist(radius_i) = curradius; 
	    end 

	    % Remove the traced path from the timemap
	    tB = binarysphere3d(size(T), l, radiuslist);
	    tB(StartPoint(1), StartPoint(2), StartPoint(3)) = 3;
	    T(tB==1) = -1;

	    % Add l to the tree
	    if prune && size(l, 1) > 4
		    [tree, confidence] = addbranch2tree(tree, l, radius, I);

		    if confidence > 0.5 % skip noise points
		    	lconfidence = [lconfidence; confidence];
			    S{i} = l;
			    i = i + 1;
		    end
		end

        B = B | tB;

        percent = sum(B(:) & I(:)) / sum(I(:))
        if percent >= percentage
        	break;
        end

    end
    hold off
    toc;

    % showswc(tree, I, true);
    % showswc(rewiredtree, I, true);
    tree(:, 6) = 1;

    % Shift the result tree back to the original space if crop was conducted
    if crop
        tree(:, 3) = tree(:, 3) + cropregion(1, 1);
        tree(:, 4) = tree(:, 4) + cropregion(2, 1);
        tree(:, 5) = tree(:, 5) + cropregion(3, 1);
    end
    
    save_v3d_swc_file(tree, [imgpath, '.trace.swc']);

    if rewire
	    rewiredtree = rewiretree(tree, S, I, lconfidence, 0.7);
	    rewiredtree(:, 6) = 1;
	    save_v3d_swc_file(rewiredtree, [imgpath, '.rewired.swc']);
	    tree = rewiredtree;
	end
end