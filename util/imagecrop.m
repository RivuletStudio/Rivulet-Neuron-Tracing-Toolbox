function [croped, cropregion] = imagecrop(srcimg, threshold)
	srcimg = squeeze(srcimg);
    ind = find(srcimg > threshold);
    if numel(ind) == 0
        croped = [];
        cropregion = [];
        return
    end
    [M, N, Z] = ind2sub(size(srcimg), ind);
    cropregion = [min(M), max(M); min(N), max(N); min(Z), max(Z)];
    croped = srcimg(cropregion(1, 1) : cropregion(1, 2), ...
                    cropregion(2, 1) : cropregion(2, 2), ...
                    cropregion(3, 1) : cropregion(3, 2));
end