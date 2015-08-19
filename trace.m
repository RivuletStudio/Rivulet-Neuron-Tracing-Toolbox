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
		percentage = varargin{3};
	end

	rewire = false;
	if numel(varargin) >= 4
		rewire = varargin{4};
    end
    
	gap = 10;
    if numel(varargin) >= 5
		gap = varargin{5};
	end

	msg = false;
    if numel(varargin) >= 6
		msg = varargin{6};
	end

	[pathstr, ~, ~] = fileparts(mfilename('fullpath'));
    addpath(fullfile(pathstr, 'util'));
    addpath(genpath(fullfile(pathstr, 'lib')));

    
    if msg
    	h1 = msgbox('Distance transform...')
    end
    disp('Distance transform');
    bdist = getBoundaryDistance(I, true);
    if msg
    	delete(h1);
    end
    disp('Looking for the source point...')
    [SourcePoint, maxD] = maxDistancePoint(bdist, I, true);
    disp('Make the speed image...')
    SpeedImage=(bdist/maxD).^4;
	SpeedImage(SpeedImage==0) = 1e-10;
	if msg
		h2 = msgbox('Marching...');
	end	
	disp('marching...');
    oT = msfm(SpeedImage, SourcePoint, false, false);
    if msg
    	delete(h2);
    end
    disp('Finish marching')

    disp('Calculating gradient...')
	% Calculate gradient of DistanceMap

    % close all
    if plot
    	hold on 
    	% showbox(I, 0.5);
    end
    T = oT;
    tree = []; % swc tree
    prune = true;
	grad = distgradient(T);
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

	    l = shortestpath2(T, grad, I, StartPoint, SourcePoint, 1, 'rk4', gap);
	    % if size(l, 1) < 4
	    % 	disp('Branch too short: abandoned');
	    %     continue	
	    % end

	    % Get radius of each point from distance transform
	    radius = zeros(size(l, 1), 1);
	    for r = 1 : size(l, 1)
		    radius(r) = getradius(I, l(r, 1), l(r, 2), l(r, 3));
		end
	    radius(radius < 1) = 1;
	    disp([size(l, 1), size(radius, 1)]);
		assert(size(l, 1) == size(radius, 1));

	    % Remove the traced path from the timemap
	    tB = binarysphere3d(size(T), l, radius);
	    tB(StartPoint(1), StartPoint(2), StartPoint(3)) = 3;
	    T(tB==1) = -1;

	    % Add l to the tree
	    [tree, confidence] = addbranch2tree(tree, l, radius, I, plot);

	    if confidence > 0.5 % skip noise points
	    	lconfidence = [lconfidence; confidence];
		    S{i} = l;
		    i = i + 1;
	    end

        B = B | tB;

        percent = sum(B(:) & I(:)) / sum(I(:));
        fprintf('Percent: %.2f/%.2f\n', percent * 100, percentage * 100);
        if percent >= percentage
        	disp('Coverage reached end tracing...')
        	break;
        end

    end

    % Remove the unconnected branches
    

    % showswc(tree, I, true);
    % showswc(rewiredtree, I, true);
    tree(:, 6) = 1;

    % % Shift the result tree back to the original space if crop was conducted
    % if crop
    %     tree(:, 3) = tree(:, 3) + cropregion(1, 1);
    %     tree(:, 4) = tree(:, 4) + cropregion(2, 1);
    %     tree(:, 5) = tree(:, 5) + cropregion(3, 1);
    % end
    
    % save_v3d_swc_file(tree, [imgpath, '.trace.swc']);

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