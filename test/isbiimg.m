%     load binaryOP.mat;
%     I = A;
%     clear A
    bdist = getBoundaryDistance(I, true);
    disp('Looking for the source point...')
    [SourcePoint, maxD] = maxDistancePoint(bdist, I, true);
    disp('Make the speed image...')
    SpeedImage=(bdist/maxD).^4;
	SpeedImage(SpeedImage==0) = 1e-10;
	disp('marching...');
    oT = msfm(SpeedImage, SourcePoint, false, false);
    disp('Finish marching')
    % close all
    T = oT;
    tree = []; % swc tree
    prune = true;
	% Calculate gradient of DistanceMap
	disp('Calculating gradient...')
    grad = distgradient(T);
    S = {};
    B = zeros(size(T));
    i = 1;
    lconfidence = [];
    unconnectedBranches = {};
    gap = 3;
    percentage = 0.19;
    dumpbranch = false;
    connectrate = 4;
    plotpara = true;
    showbox(I, 0.5);
    hold on
    while(true)
	    StartPoint = maxDistancePoint(T, I, true);
	    if T(StartPoint(1), StartPoint(2), StartPoint(3)) == 0 || I(StartPoint(1), StartPoint(2), StartPoint(3)) == 0
	    	break;
	    end
	    [l, dump, merged] = shortestpath2(T, grad, I, StartPoint, SourcePoint, 1, 'rk4', gap);
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
	    if ~(dump && dumpbranch) 
		    [tree, newtree, conf, unconnected] = addbranch2tree(tree, l, merged, connectrate, radius, I, plotpara);
            if unconnected
                unconnectedBranches = {unconnectedBranches, newtree};
            end
            lconfidence = [lconfidence, conf];
		end
        B = B | tB;
        percent = sum(B(:) & I(:)) / sum(I(:));
%         fprintf('Percent: %.2f/%.2f\n', percent * 100, percentage * 100);
        fprintf('Tracing percent: %d\n', percent);
        if percent >= percentage
        	disp('Coverage reached end tracing...')
        	break;
        end

    end
    meanconf = mean(lconfidence);

