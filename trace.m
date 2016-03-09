function [tree, meanconf] = trace(varargin)
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

    dumpcheck = false;
    if numel(varargin) >= 7
        dumpcheck = varargin{7};
    end

    connectrate = false;
    if numel(varargin) >= 8
        connectrate = varargin{8};
    end
    
    branchlen = 4;
    if numel(varargin) >= 9
        branchlen = varargin{9};
    end

    % if numel(varargin) >= 10
    %     oriI = varargin{10};
    %     sizeI = size(oriI);
    %     fprintf('the size of original image is : %d%d%d\n', sizeI(1), sizeI(2), sizeI(3));
    % end

    % somagrowthcheck is the flag whether soma is given or not
    if numel(varargin) >= 10
        somagrowthcheck = varargin{10};
        somagrowthcheck = somagrowthcheck > 0.5;
        % fprintf('the value of somagrowthcheck is : %d\n', somagrowthcheck);
    end

    if numel(varargin) >= 11 && somagrowthcheck
        soma = varargin{11};
        % fprintf('we found soma label matrix\n');
        szsoma = size(soma.I);
        I = I | soma.I;
        % fprintf('the size of soma.I, x is : %d, y is : %d, z is : %d\n', szsoma(1), szsoma(2), szsoma(3));
    end

    cleanercheck = false;
    if numel(varargin) >= 12
        cleanercheck = varargin{12};
        if cleanercheck == 1
            fprintf('wash away is on\n');
        else
            fprintf('wash away is off\n');
        end
        cleanercheck = cleanercheck > 0.5;                    
    end
    % dtimageflag load distance transform image directly without computing distance transform
    dtimageflag = false;
    if numel(varargin) >= 13
        dtimageflag = varargin{13};
        dtimageflag = dtimageflag > 0.5;
    end
    if dtimageflag
        disp('Loading distance transformed image');
        bdist = varargin{14};
        bdist = double(bdist);
    end                        
    
	[pathstr, ~, ~] = fileparts(mfilename('fullpath'));
    addpath(fullfile(pathstr, 'util'));
    addpath(genpath(fullfile(pathstr, 'lib')));

    
    if plot
        axes(ax);
    end
    if (~dtimageflag)
        disp('Distance transform');
        notbI = not(I>0.5);
        bdist = bwdist(notbI, 'Quasi-Euclidean');
        bdist = bdist .* double(I);
        bdist = double(bdist);
    end

    disp('Looking for the source point...')
    if somagrowthcheck
        SourcePoint = [soma.x; soma.y; soma.z];
        somaidx = find(soma.I == 1);
        [somax, somay, somaz] = ind2sub(size(soma.I), somaidx);
        % Find the soma radius
        d = pdist2([somax, somay, somaz], [soma.x, soma.y, soma.z]);
        maxD = max(d);
    else
        [SourcePoint, maxD] = maxDistancePoint(bdist, I, true);
    end
    disp('Make the speed image...')
    SpeedImage=(bdist/maxD).^4;
    clear bdist;
    SpeedImage(SpeedImage==0) = 1e-10;
	if plot
        axes(ax);
	end	
	disp('marching...');
    T = msfm(SpeedImage, SourcePoint, false, false);
    szT = size(T);
    fprintf('the size of time map, x is : %d, y is : %d, z is : %d\n', szT(1), szT(2), szT(3));
    disp('Finish marching')

    if somagrowthcheck
        fprintf('Mark soma label on time-crossing map\n')
        T(soma.I==1) = -2;
    end

    if plot
    	hold on 
    end

    tree = []; % swc tree
    if somagrowthcheck
        fprintf('Initialization of swc tree.\n'); 
        tree(1, 1) = 1;
        tree(1, 2) = 1;
        tree(1, 3) = soma.x;
        tree(1, 4) = soma.y;
        tree(1, 5) = soma.z;
        % fprintf('source point x : %d, y : %d, z : %d.\n', uint8(SourcePoint(1)), uint8(SourcePoint(2)), uint8(SourcePoint(3)));         
        tree(1, 6) = 1;
        tree(1, 7) = -1;
    end

    prune = true;
	% Calculate gradient of DistanceMap
	disp('Calculating gradient...')
    grad = distgradient(T);
    if plot
        axes(ax);
    end
    S = {};
    B = zeros(size(T));
    if somagrowthcheck
        B = B | (soma.I>0.5);
    end
    lconfidence = [];
    if plot
	    [x,y,z] = sphere;
	    plot3(x + SourcePoint(2), y + SourcePoint(1), z + SourcePoint(3), 'ro');
	end

    unconnectedBranches = {};
    printcount = 0;
    printn = 0;
    while(true)

	    StartPoint = maxDistancePoint(T, I, true);
	    if plot
		    plot3(x + StartPoint(2), y + StartPoint(1), z + StartPoint(3), 'ro');
		end

	    if T(StartPoint(1), StartPoint(2), StartPoint(3)) == 0 || I(StartPoint(1), StartPoint(2), StartPoint(3)) == 0
	    	break;
	    end

	    [l, dump, merged, somamerged] = shortestpath2(T, grad, I, tree, StartPoint, SourcePoint, 1, 'rk4', gap);

        if size(l, 1) == 0
            l = StartPoint'; % Make sure the start point will be erased
        end
        
	    % Get radius of each point from distance transform
	    radius = zeros(size(l, 1), 1);
	    parfor r = 1 : size(l, 1)
		    radius(r) = getradius(I, l(r, 1), l(r, 2), l(r, 3));
		end
	    radius(radius < 1) = 1;
		assert(size(l, 1) == size(radius, 1));

        [covermask, centremask] = binarysphere3d(size(T), l, radius);
	    % Remove the traced path from the timemap
        if cleanercheck & size(l, 1) > branchlen
            covermask = augmask(covermask, I, l, radius);
        end

        % covermask(StartPoint(1), StartPoint(2), StartPoint(3)) = 3; % Why? Double check if it is nessensary - SQ

        T(covermask) = -1;
        T(centremask) = -3;

	    % if cleanercheck
     %        T(wash==1) = -1;
     %    end

	    % Add l to the tree
	    if ~((dump) && dumpcheck) 
		    [tree, newtree, conf, unconnected] = addbranch2tree(tree, l, merged, connectrate, radius, I, branchlen, plot, somamerged);
            lconfidence = [lconfidence, conf];
		end

        B = B | covermask;

        percent = sum(B(:) & I(:)) / sum(I(:));
        if plot
            axes(ax);
        end
        printn = printn + 1;
        if printn > 1
            fprintf(1, repmat('\b',1,printcount));
            printcount = fprintf('Tracing percent: %f%%\n', percent*100);
        end
        if percent >= percentage
        	disp('Coverage reached end tracing...')
        	break;
        end

    end

    meanconf = mean(lconfidence);

    if cleanercheck
        disp('Fixing topology')
        tree = fixtopology(tree);
    end 
    tree = prunetree(tree, branchlen);

	if plot
		hold off
	end

end