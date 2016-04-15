function [patches, gt, coord, padimgsz] = extractpatches(p)
% Extract 2D/3D patches and its ground truth distance transform from 1 I
% PARA
% p.I: 2D/3Dimage matrix 
% p.swc: swc tree 2D matrix 
% p.is2d: true / false - If the I is 3D and is2d == true, the XY max projection will be used
% p.scales: a list of scales to sample patches - the resulted region will be of size 2 * scales(i) + 1
% p.patchradius: 
    % For 2D, the rescaled patch will be of size (patchradius * 2 + 1) X (patchradius * 2 + 1); 
    % For 3D, the rescaled patch will be of size (patchradius * 2 + 1) X (patchradius * 2 + 1) X (patchradius * 2 + 1)
% p.pixelthreshold: threshold to segment the pixels
% p.nsample: number of foreground pixels to sample from image
             % p.nsample background pixels will be sampled as well
% p.dtradii: radius to generate dt
% p.bgdist: background pixels will be sampled p.bgdist away from the foreground map
% p.rotate: Randomly rotate each patch

I = p.I;
swc = p.swc;
imgdim = ndims(I);
I = double(I); % Make sure the image is double

if imgdim == 3 && p.is2d
    I = squeeze(max(I, [], 3));
    swc(:, 5) = 1;
end

dt = dtfromswc(size(I), swc, p.dtalpha, p.dtradii);

% Pad Image
margin = max(p.scales(:));
if p.is2d
    padimg = zeros(margin * 2 + size(I, 1), margin * 2 + size(I, 2));
    padimg(margin + 1:margin+size(I, 1), margin + 1:margin+size(I, 2)) = I;
    paddist = zeros(margin * 2 + size(I, 1), margin * 2 + size(I, 2));
    paddist(margin + 1:margin+size(I, 1), margin + 1:margin+size(I, 2)) = dt;
else
    % TODO
end

padimgsz = size(padimg);

se = strel('diamond', p.bgdist); % dilate foreground to sample foreground patches
fg = paddist > 0;
dilate_fg = imdilate(fg, se);
bg = dilate_fg - fg; % Background map within a distance from the neuron
fgidx = find(fg > 0);
bgidx = find(bg > 0);

% Randomly sample a subset of voxels
fgidx = fgidx(randperm(numel(fgidx)));
bgidx = bgidx(randperm(numel(bgidx)));

if p.nsample > numel(fgidx)
    p.nsample = numel(fgidx);
end

fgidx = fgidx(1 : p.nsample);
bgidx = bgidx(1 : p.nsample);

% Combine the foreground and background pixel coordinates
idx2sample = [fgidx, bgidx]; 
idx2sample = idx2sample(randperm(numel(idx2sample)));

% Initialise the extraction
patchctr = 1;  
patchsize = 2 * p.patchradius + 1;
gt = zeros(1, numel(idx2sample));
if p.is2d
    [x, y] = ind2sub(size(padimg), idx2sample);
    patches = zeros(patchsize, patchsize, 1, numel(idx2sample) * numel(p.scales));
    coord = zeros(2, numel(idx2sample));
else
    % TODO
end

for i = 1 : numel(idx2sample) % Loop to extract patches
    out = false;

    if p.is2d
        % Check if the sampling position is out of bound
        for r = p.scales
            leftx  = x(i) - r;
            rightx = x(i) + r;
            lefty  = y(i) - r;
            righty = y(i) + r;

            if leftx < 1 || lefty < 1 || rightx > padimgsz(1) || righty > padimgsz(2)
                % fprintf('%f, %f, %f,%f is outof bound in %f - %f\n', leftx, lefty, rightx, righty, padimgsz(1), padimgsz(2))
                out = true;
                break;
            end
        end

        if out == true
            continue;
        end

        % Scale image patches 
        for r = p.scales
            leftx = x(i) - r;
            rightx = x(i) + r;
            lefty = y(i) - r;
            righty = y(i) + r;

            pch = padimg(leftx:rightx, lefty:righty);
            pch = imresize(pch, [patchsize, patchsize]);

            % Randomly rotate each patch
            if p.rotate 
                pch = imrotate(pch, rand() * 360, 'bilinear', 'crop'); 
            end

            patches(:, :, 1, patchctr) = pch; % The third dimension is colour, leave for Caffe
            gt(patchctr) = paddist(idx2sample(i));
            coord(:, patchctr) = [x(i), y(i)];
            patchctr = patchctr + 1;
        end
    end
end

patches(:,:,:,patchctr:end) = []; % Release the unused memory
gt(:, patchctr:end) = []; % Release the unused memory
coord(:, patchctr:end) = [];

% Zero-Mean & STD each patch
for i = 1 : size(patches, ndims(patches)) 
    if p.is2d
        pch = patches(:, :, 1, i);
    else
        pch = patches(:, :, :, 1, i);
    end

    % Standardise the patch
    pch = pch - mean(pch(:));
    pch = pch / std(pch(:));
    pch = pch - min(pch(:));
    pch = pch / max(pch(:));

    if p.is2d
        patches(:, :, 1, i) = pch;
    else
        patches(:, :, :, 1, i) = pch;
    end
end

end