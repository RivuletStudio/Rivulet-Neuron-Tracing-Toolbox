function [ img ] = rescale3D(img, scale)
%RESCALE Rescale image with matlab imresize
%   I : Input 3D image
if scale ~= 1
    img = imresize(img, scale);
    img = permute(img, [3, 1, 2]);
    img = imresize(img, [size(img, 1) * scale, size(img, 2)]);
    img = permute(img, [2, 3, 1]);
end

end

