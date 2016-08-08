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
        % %%Second version soma field start
        % fprintf('the start point of soma bounding box, x is : %d, y is : %d, z is : %d\n', soma.startpoint(1), soma.startpoint(2), soma.startpoint(3));
        % fprintf('the end point of soma bounding box, x is : %d, y is : %d, z is : %d\n', soma.endpoint(1), soma.endpoint(2), soma.endpoint(3));
        % fprintf('the esitmated radius is : %d\n', maxD);
        % centersoma = zeros(size(I));
        % centersoma(round(SourcePoint(1)), round(SourcePoint(2)), round(SourcePoint(3))) = 1;
        % T_soma_center = bwdist(centersoma > 0.5, 'Quasi-Euclidean');
        % soma_dist_box = T_soma_center(soma.startpoint(1):soma.endpoint(1), soma.startpoint(2):soma.endpoint(2), soma.startpoint(3):soma.endpoint(3));
        % estimated_radius = maxD;
        % scale_para = 1;
        % % % Original setting 0.9 -> 0.93 -> 1
        % expotential_coefficient = 2 / estimated_radius; 
        % gaussian_vec = exp(soma_dist_box.*expotential_coefficient);
        % gaussian_vec = gaussian_vec / min(gaussian_vec(:));
        % gaussian_vec = scale_para * gaussian_vec;
        % min_gaussian_vec = min(gaussian_vec(:));
        % if min_gaussian_vec < 1
        %     gaussian_vec = gaussian_vec + (1 - min_gaussian_vec); 
        % end
        % fprintf('Saving parameters for a new version of soma field...'); 
        % save('/home/donghao/Desktop/soma_field/soma_case1/soma_case1.mat');
        % %%Second version soma field end
        
        %%First version soma field start 
        % fprintf('bug one?\n'); 
        % centersoma = zeros(size(I));
        % centersoma(round(SourcePoint(1)), round(SourcePoint(2)), round(SourcePoint(3))) = 1;
        % T_soma_center = bwdist(centersoma > 0.5, 'Quasi-Euclidean');
        % scale_k = 2;
        % T_soma_center = T_soma_center.^(1/scale_k);
        % scale_k2 = 600000;
        % T_soma_center = T_soma_center * scale_k2;
        % T_soma_center = T_soma_center.*double((I>0.5));
        % fprintf('bug two?\n');
        %%First verison soma field end 
        
        % somaSourcepoint = [somax, somay, somaz];
        % sizesomaSourcepoint = size(somaSourcepoint); 
        % fprintf('The first dimension of source point is : %d\n', sizesomaSourcepoint(1));
        % fprintf('The second dimension of source point is : %d\n', sizesomaSourcepoint(2));
    else
        [SourcePoint, maxD] = maxDistancePoint(bdist, I, true);
        % fprintf('I want to see this line first');
        % disp(SourcePoint);
        % fprintf('The size of source point is : %d', size(SourcePoint));

    end
    disp('Make the speed image...');
    % Make sure uncomment the following line
    % SpeedImage=(bdist/maxD);
    SpeedImage=(bdist/maxD).^4;
    % !!!!!!!!

    %.^4;
    % SpeedImage=(bdist/maxD).^2;

    clear bdist;
    % %Second version soma field start
    % if somagrowthcheck
    %     fprintf('Extract speed image box...\n');
    %     speed_box = SpeedImage(soma.startpoint(1):soma.endpoint(1), soma.startpoint(2):soma.endpoint(2), soma.startpoint(3):soma.endpoint(3));
    %     fprintf('Gausssian convolution begins...\n');    
    %     speed_box = speed_box .* gaussian_vec;
    %     SpeedImage(soma.startpoint(1):soma.endpoint(1), soma.startpoint(2):soma.endpoint(2), soma.startpoint(3):soma.endpoint(3)) = speed_box;
    % end
    % % Second version soma field begin

    % Third version of soma field
    % Third version soma field begin
    fprintf('The soma field version 3 is running\n');
    somabI = soma.I > 0.5;
    % The following two lines find surface of the binary soma
    S=ones(3,3,3);
    Bsoma=xor(somabI,imdilate(somabI,S));
    dtsoma = bwdist(Bsoma);
    % dtsoma(dtsoma>10) = 1;
    % dtsoma = (dtsoma - min(dtsoma(:))) / (max(dtsoma(:)) - min(dtsoma(:))) * 5 + 1;
    % dtsoma = exp(dtsoma);
    % When distance transform values are larger than 15, we do not consider
    % them. It is beyond the scope of soma field
    dtsoma = dtsoma + 1;
    dtsoma(dtsoma>15) = 1;
    fprintf('version 3 soma field is running\n');
    [Dx, Dy, Dz] = ind2sub(size(dtsoma),find(dtsoma > 1));
    minx = min(Dx);
    maxx = max(Dx);
    miny = min(Dy);
    maxy = max(Dy);
    minz = min(Dz);
    maxz = max(Dz);
    surf_dist = dtsoma(minx:maxx, miny:maxy, minz:maxz);
    clear dtsoma; clear S; clear Bsoma; clear somabI;
    % expotential_coefficient = 2 / estimated_radius;
    % The following is a test case which might not be necessary
    surf_scale = 1;
    surf_dist = (surf_dist * surf_scale);
    if somagrowthcheck
        fprintf('Extract speed image box...\n');
        speed_box = SpeedImage(minx:maxx, miny:maxy, minz:maxz);
        fprintf('Surface distance enhancement convolution begins...\n');    
        % save('/home/donghao/Desktop/soma_field/soma_case3/speed_boxbefore.mat', 'speed_box');
        speed_box = speed_box .* surf_dist;
        % save('/home/donghao/Desktop/soma_field/soma_case3/surf_dist.mat', 'surf_dist');
        SpeedImage(minx:maxx, miny:maxy, minz:maxz) = speed_box;
        % save('/home/donghao/Desktop/soma_field/soma_case3/speed_boxafter.mat', 'speed_box');
        % xxxxxxx
    end
    % Third version soma field end

    SpeedImage(SpeedImage==0) = 1e-10;
    if plot
        axes(ax);
    end 
    disp('marching...');
    T = msfm(SpeedImage, SourcePoint, false, false);
    %%First version soma field start 
    % T = T + double(T_soma_center);
    %%First version soma field end

    
    % T = T / T_beta + T_soma_alpha * T_soma; 
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