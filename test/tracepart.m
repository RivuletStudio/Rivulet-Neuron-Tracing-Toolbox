    
    percentage = 0.99;
    Gap = 50;
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
	safeshowbox(I, 0.5);
	drawnow

    lconfidence = [];
    hold on
    [x,y,z] = sphere;
    surf(x + SourcePoint(2), y + SourcePoint(1), z + SourcePoint(3));

    while(true)

	    StartPoint = maxDistancePoint(T, I, true);
	    surf(x + StartPoint(2), y + StartPoint(1), z + StartPoint(3));

	    if T(StartPoint(1), StartPoint(2), StartPoint(3)) == 0 || I(StartPoint(1), StartPoint(2), StartPoint(3)) == 0
	    	continue;
	    end

	    disp('start tracing');
	    l = shortestpath2(T, grad, I, StartPoint, SourcePoint, 1, 'rk4', Gap);
	    disp('end tracing')

	    % Get radius of each point from distance transform
	    ind = sub2ind(size(bdist), int16(l(:, 1)), int16(l(:, 2)), int16(l(:, 3)));
	    radius = bdist(ind);
	    radius(radius < 1) = 2;
	    radius = ceil(radius);

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

