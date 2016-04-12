function extract2dfeat()
	I = handles.selectfilebtn.UserData.I;
    maxI = squeeze(max(I, [], 3));

%     figure()
%     imshow(maxI);
    if isfield(handles.selectfilebtn.UserData, 'inputpath')
        [~, fn, ~] = fileparts(handles.selectfilebtn.UserData.inputpath);
    else
        fn = 'maxI';
    end
    
    if isfield(handles.selectfilebtn.UserData, 'swc')
        swcxy = handles.selectfilebtn.UserData.swc;
        swcxy(:, 5) = 1;
    else
    end
    
    path2save = sprintf('%s-XY.tif', fn);    
    fprintf('Saving tif image to %s\n', path2save);
    imwrite(maxI, path2save);
        
    % Calculate real valued DT from the skeleton
    disp('Extracing 2D Distance transform')
    dt2d = dtfromswc(size(I), handles.selectfilebtn.UserData.swc, str2double(handles.alpha.String), true);
    disp('Extracing 3D Distance transform')
    dt3d = dtfromswc(size(I), handles.selectfilebtn.UserData.swc, str2double(handles.alpha.String), false);
    
    % Reload workspace
    vlist = evalin('base', 'who');
    set(handles.workspacelist, 'String', vlist, 'Value', 1);
    
    disp('DT generated!');

    bg = maxI <= handles.thresholdslider.Value;
    % bdist = bwdist(bg, 'Quasi-Euclidean');
    % bdist(bg) = 0;
    % maxd = ceil(max(bdist(:)));
    % meanbdist = bdist(bdist > 0);
    % meanbdist = mean(meanbdist(:));
    % meanradius = ceil(meanbdist);
    maxd = 120;

    % Pad image
    pad2Dimg = zeros(maxd * 4 + size(maxI, 1), maxd * 4 + size(maxI, 2));
    pad2Dimg(2*maxd + 1:2*maxd+size(maxI,1), 2*maxd + 1:2*maxd+size(maxI,2)) = maxI;
    
    pad2Ddist = zeros(maxd * 4 + size(maxI, 1), maxd * 4 + size(maxI, 2));
    pad2Ddist(2*maxd + 1:2*maxd+size(maxI,1), 2*maxd + 1:2*maxd+size(maxI,2)) = dt2d;
    fg = pad2Dimg > handles.thresholdslider.Value;
    
    % Normalise maxI
    pad2Dimg = double(pad2Dimg);
    pad2Dimg = pad2Dimg - mean(pad2Dimg(:));
    pad2Dimg = pad2Dimg / std(pad2Dimg(:));
    pad2Dimg = pad2Dimg - min(pad2Dimg(:));
    pad2Dimg = pad2Dimg / max(pad2Dimg(:)); 

    se = strel('diamond', str2double(handles.kernelsize.String)); % dilate foreground to sample foreground patches
    fg = imdilate(fg, se);
    fgidx = find(fg > 0);
    [x, y] = ind2sub(size(pad2Dimg), fgidx);
    patchsize = 19;
    patchctr = 1;
    scale = [60:20:120];
    nscale = numel(scale);
    patches = zeros(patchsize, patchsize, nscale, numel(fgidx));
    gt = zeros(1, numel(fgidx));
    coord = zeros(2, numel(fgidx));

    disp('Extracting patches...')
    for i = 1 : numel(fgidx)
        fprintf('Extracting %f%%\n', 100*i/numel(fgidx));
        % radius = ceil(pad2Dbdist(fgidx(i)));
        radiusidx = 1;
        out = false;

        for radius = scale
            leftx = x(i) - radius;
            rightx = x(i) + radius;
            lefty = y(i) - radius;
            righty = y(i) + radius;
            if leftx < 1 || lefty < 1 || rightx > size(pad2Dimg, 1) || righty > size(pad2Dimg, 2)
                out = true;
                break;
            end
        end

        if out == true
            continue;
        end
        
        % Randomly rotate image patches 
        randangle = randi([0, 359]);
        
        for radius = scale 
            leftx = x(i) - radius;
            rightx = x(i) + radius;
            lefty = y(i) - radius;
            righty = y(i) + radius;
            p = pad2Dimg(leftx:rightx, lefty:righty);
            p = imresize(p, [patchsize, patchsize]);
            
            if handles.rotatecheck.Value
                p = imrotate(p, randangle, 'bilinear', 'crop');
            end
            
            patches(:, :, radiusidx , patchctr) = p;
            gt(patchctr) = pad2Ddist(fgidx(i));
            coord(:, patchctr) = [x(i), y(i)];
            radiusidx = radiusidx + 1;
        end

        patchctr = patchctr + 1;
    end

    patches(:,:,:,patchctr:end) = []; % Release the unused memory
    gt(:, patchctr:end) = []; % Release the unused memory

    % Sample foreground and background instances
%     bgidx = find(gt == 0);
%     fgidx = find(gt > 0);
%     randbgidx = randperm(numel(bgidx));
%     randbgidx = bgidx(randbgidx);
%     fgpatches = patches(:,:,:,fgidx);
%     bgpatches = patches(:,:,:,randbgidx(1:numel(fgidx)));
%     patches = zeros(size(patches, 1), size(patches, 2), size(patches, 3), 2*numel(fgidx));
%     patches(:,:,:,1:numel(fgidx)) = fgpatches;
%     patches(:,:,:,numel(fgidx)+1:end) = bgpatches;
%     gt = [gt(fgidx), gt(randbgidx(1:numel(fgidx)))];
%     coord = [coord(:, fgidx), coord(:, randbgidx(1:numel(fgidx)))];
    
%     eval(sprintf('assignin (''base'', ''%s'', %s);', 'maxI', 'maxI')); 
%     eval(sprintf('assignin (''base'', ''%s'', %s);', 'swcxy', 'swcxy')); 
%     eval(sprintf('assignin (''base'', ''%s'', %s);', 'dt2d', 'dt2d'));
%     eval(sprintf('assignin (''base'', ''%s'', %s);', 'dt3d', 'dt3d'));
%     eval(sprintf('assignin (''base'', ''%s'', %s);', 'gt', 'gt'));
%     eval(sprintf('assignin (''base'', ''%s'', %s);', 'patches', 'patches'));

    disp('Writting H5...')
    fh5 = '/home/siqi/ncidata/Neuveal-Caffe/expt/2d/data/data-8.h5';
    if exist(fh5, 'file')==2
      delete(fh5);
    end

    h5create(fh5, '/data' , [patchsize, patchsize, numel(scale), Inf], 'ChunkSize', [patchsize, patchsize, numel(scale), 64], 'DataType', 'single');
    h5create(fh5, '/label' , [1, Inf], 'ChunkSize', [1, 64], 'DataType', 'single');
    h5create(fh5, '/coord' , [3, Inf], 'ChunkSize', [3, 64], 'DataType', 'single');
    h5create(fh5, '/imagesize' , [1, 3], 'ChunkSize', [1, 3], 'DataType', 'uint16');
    h5write(fh5, '/data', single(patches), [1, 1, 1, 1], size(patches));
    h5write(fh5, '/label', single(gt), [1, 1], size(gt));
    h5write(fh5, '/coord', single(coord), [1, 1], size(coord));
    sz = size(pad2Dimg);
    h5write(fh5, '/imagesize', uint16(sz), [1, 1], size(sz));
end