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

	I = varargin{1};

	plot = false;
    if numel(varargin) >= 2
		plot = varargin{2};
	end

	percentage = 0.95;
    if numel(varargin) >= 3
		percentage = double(varargin{3});
	end

	rewire = false;
	if numel(varargin) >= 4
		rewire = varargin{4};
    end
    
	gap = 10;
    if numel(varargin) >= 5
		gap = varargin{5};
	end

	ax = false;
    if numel(varargin) >= 6
		ax = varargin{6};
	end

	[pathstr, ~, ~] = fileparts(mfilename('fullpath'));
    addpath(fullfile(pathstr, 'util'));
    addpath(genpath(fullfile(pathstr, 'lib')));

    
    if plot
        h = waitbar(0.2, 'Preprocessing: Distance Tr...');
        set(h, 'windowstyle', 'modal');
        axes(ax);
    end
    disp('Distance transform');
    bdist = getBoundaryDistance(I, true);
    
    disp('Looking for the source point...')
    [SourcePoint, maxD] = maxDistancePoint(bdist, I, true);
    disp('Make the speed image...')
    SpeedImage=(bdist/maxD).^4;
	SpeedImage(SpeedImage==0) = 1e-10;
	if plot
        set(0, 'CurrentFigure', h);
		h = waitbar(0.5, h, 'Preprocessing: Marching...');
        set(h, 'windowstyle', 'modal');
        axes(ax);
	end	
	disp('marching...');
    oT = msfm(SpeedImage, SourcePoint, false, false);
    
    disp('Finish marching')

    

    % close all
    if plot
    	hold on 
    	% showbox(I, 0.5);
    end
    T = oT;
    tree = []; % swc tree
    prune = true;
	% Calculate gradient of DistanceMap
	disp('Calculating gradient...')
    grad = distgradient(T);
    if plot
        set(0, 'CurrentFigure', h);
		h = waitbar(0.8, h, 'Preprocessing: Calculate Distance Gradients...');
        set(h, 'windowstyle', 'modal');
        axes(ax);
    end
    S = {};
    B = zeros(size(T));
    i = 1;

    lconfidence = [];
    if plot
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

	    [l, dump] = shortestpath2(T, grad, I, StartPoint, SourcePoint, 1, 'rk4', gap);

	    % Get radius of each point from distance transform
	    radius = zeros(size(l, 1), 1);
	    for r = 1 : size(l, 1)
		    radius(r) = getradius(I, l(r, 1), l(r, 2), l(r, 3));
		end
	    radius(radius < 1) = 1;
	    % disp([size(l, 1), size(radius, 1)]);
		assert(size(l, 1) == size(radius, 1));

	    % Remove the traced path from the timemap
	    tB = binarysphere3d(size(T), l, radius);
	    tB(StartPoint(1), StartPoint(2), StartPoint(3)) = 3;
	    T(tB==1) = -1;

	    % Add l to the tree
	    if ~dump
		    [tree, confidence] = addbranch2tree(tree, l, radius, I, plot);
		end

        B = B | tB;

        percent = sum(B(:) & I(:)) / sum(I(:));
%         fprintf('Percent: %.2f/%.2f\n', percent * 100, percentage * 100);
        if plot
%             disp(percent)
            set(0, 'CurrentFigure', h);
%             h = waitbar(percent, h, sprintf('Tracing %.2f%%', percent*100 / percentage));
            h = waitbar(percent, h);
            set(h, 'windowstyle', 'modal');
%             set(0, 'CurrentFigure', gcf);
            axes(ax);
        end
        if percent >= percentage
            if plot
                close(h)
            end
        	disp('Coverage reached end tracing...')
        	break;
        end

    end

    % % Shift the result tree back to the original space if crop was conducted
    % if crop
    %     tree(:, 3) = tree(:, 3) + cropregion(1, 1);
    %     tree(:, 4) = tree(:, 4) + cropregion(2, 1);
    %     tree(:, 5) = tree(:, 5) + cropregion(3, 1);
    % end

    if rewire
	    rewiredtree = rewiretree(tree, S, I, lconfidence, 0.7);
	    rewiredtree(:, 6) = 1;
	    save_v3d_swc_file(rewiredtree, [imgpath, '.rewired.swc']);
	    tree = rewiredtree;
	end

	if plot
		hold off
	end

end