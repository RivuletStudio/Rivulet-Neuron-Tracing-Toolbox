function tree = trace(imgpath, clsf, method, para, percentage)
tic;
	warning off;
	%addpath(genpath('/project/RDS-FEI-NRMMCI-RW/DH-Workspace/fishhead'));
	
	disp('Loading Image and classifying...');
	[pathstr, ~, ~] = fileparts(mfilename('fullpath'));
    addpath(fullfile(pathstr, '..', '..', 'v3d', 'v3d_external', 'matlab_io_basicdatatype'));
    addpath(genpath(fullfile(pathstr, '..', '..')));
	I = load_v3d_raw_img_file(imgpath);
	switch(lower(method))
        case 'threshold'
            I = I > para;
        otherwise
		    cl = clsf.obj;
    		[I, ~] = binarizeimage(imgpath, cl, para);
			I = I > 0.5;
    end
	% I = load_v3d_raw_img_file('/home/siqi/hpc-data1/Data/OP/OP_V3Draw/OP_2.v3draw');
	% I = squeeze(I>30);
	% clsf = load('/project/RDS-FEI-NRMMCI-RW/Data/OP/quad.mat');
	%[I, ~] = binarizeimage('/project/RDS-FEI-NRMMCI-RW/Data/OP/OP_V3Draw/OP_4.v3draw', cl, 2);

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

	% figure(2)
	% showbox(I, 0.5);
	% drawnow

    while(true)

	    StartPoint = maxDistancePoint(T, I, true);
	    % disp('SourcePoint')
	    % disp(SourcePoint)
	    % disp('StartPoint')
	    % disp(StartPoint)
	    % disp('T:')
	    % disp(T(StartPoint(1), StartPoint(2), StartPoint(3)))
	    % disp('B:')
	    % disp(B(StartPoint(1), StartPoint(2) ,StartPoint(3)))
	    % disp('I:')
	    % disp(I(StartPoint(1), StartPoint(2) ,StartPoint(3)))

	    if T(StartPoint(1), StartPoint(2), StartPoint(3)) == 0 || I(StartPoint(1), StartPoint(2), StartPoint(3)) == 0
	    	break;
	    end

	    % disp('start tracing');
	     figure(1)
	     hold on
	    l = shortestpath2(T, grad, StartPoint, SourcePoint, 2, 'rk4');
	    [rlistlength, useless] = size(l);
	    radiuslist = zeros(rlistlength,1);
        radiuslist = radiuslist + 2;
	    for radius_i = 1 : rlistlength
	    	curradius = getradius(I, l(radius_i, 1), l(radius_i, 2), l(radius_i, 3));
	    	radiuslist(radius_i) = curradius; 
        end
        radiuslist = radiuslist + 2;
        
	     hold off
	    % disp('end tracing')


	    % Get radius of each point from distance transform
	    ind = sub2ind(size(bdist), int16(l(:, 1)), int16(l(:, 2)), int16(l(:, 3)));
	    radius = bdist(ind);
	    radius(radius < 1) = 2;
	    radius = ceil(radius);

    	% disp('found shorline with length')
    	% disp(size(l, 1))
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
	    S{i} = l;

	    % Add l to the tree
	    if prune && size(l, 1) > 4
		    tree = addbranch2tree(tree, l, radius);
		end

        B = B | tB;

        percent = sum(B(:) & I(:)) / sum(I(:))
        if percent > percentage
        	break;
        end

         figure(2)
        % % scatter3(B(:, 1), B(:, 2), B(:, 3));
         showbox(B, 0.5);
         drawnow

	    i = i + 1;
    end

    showswc(tree, I);
    % save_v3d_swc_file('shit.swc', tree);
    %save('/project/RDS-FEI-NRMMCI-RW/DH-Workspace/fishhead/test/simple.mat');
toc
end