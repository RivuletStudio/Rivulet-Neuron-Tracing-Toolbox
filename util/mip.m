clc
clear all
close all
imgsoma = load_v3d_raw_img_file('/home/donghao/Desktop/09-2902-04R-01C-60x_merge_c1.v3dpbd.v3draw');
somamipxy = max(imgsoma, [], 3);
somamipzy = permute(imgsoma,[3 2 1]);
somamipzy = max(somamipzy, [], 3);
somamipzx = permute(imgsoma,[3 1 2]);
somamipzx = max(somamipzx, [], 3);
% figure
% imshow(somamipxy, []); colormap('jet');
bixy = somamipxy > 100;
bizx = somamipzx > 100;
bizy = somamipzy > 100;
% figure
% imshow(bixy)
% figure
% imshow(bizy)
% figure
% imshow(bizx)
xyregion = regionprops(bixy, 'all');
[~, maxareaindex] = max([xyregion.Area])
xysoma = zeros(size(bixy));
maxxyregion = xyregion(maxareaindex);
maxxyregionBoundingBox = maxxyregion.BoundingBox;
[xwidth, yheight] = size(xyregion(maxareaindex).FilledImage);
xp = maxxyregionBoundingBox(2);
yp = maxxyregionBoundingBox(1); 
xysoma(floor(xp): floor(xp) + xwidth - 1, floor(yp) : floor(yp) + yheight - 1) = xyregion(maxareaindex).FilledImage;

zyregion = regionprops(bizy, 'all');
[~, maxareaindex] = max([zyregion.Area])
zysoma = zeros(size(bizy));
maxzyregion = zyregion(maxareaindex);
maxzyregionBoundingBox = maxzyregion.BoundingBox;
[xwidth, yheight] = size(zyregion(maxareaindex).FilledImage);
xp = maxzyregionBoundingBox(2);
yp = maxzyregionBoundingBox(1); 
zysoma(floor(xp): floor(xp) + xwidth - 1, floor(yp) : floor(yp) + yheight - 1) = zyregion(maxareaindex).FilledImage;

zxregion = regionprops(bizx, 'all');
[~, maxareaindex] = max([zxregion.Area])
zxsoma = zeros(size(bizx));
maxzxregion = zxregion(maxareaindex);
maxzxregionBoundingBox = maxzxregion.BoundingBox;
[xwidth, yheight] = size(zxregion(maxareaindex).FilledImage);
xp = maxzxregionBoundingBox(2);
yp = maxzxregionBoundingBox(1); 
zxsoma(floor(xp): floor(xp) + xwidth - 1, floor(yp) : floor(yp) + yheight - 1) = zxregion(maxareaindex).FilledImage;

[xdim, ydim, zdim] = size(imgsoma);
xysomareplicate = repmat(xysoma, 1, 1, zdim);
zysomareplicate = repmat(zysoma, 1, 1, xdim);
zysomareplicate = permute(zysomareplicate,[3 2 1]);
zxsomareplicate = repmat(zxsoma, 1, 1, ydim);
zxsomareplicate = permute(zxsomareplicate,[2 3 1]);
soma = xysomareplicate & zysomareplicate; 
soma = soma & zxsomareplicate;
% figure
% safeshowbox(zysomareplicate, 0.5)
% figure
% safeshowbox(xysomareplicate, 0.5)
% figure
% safeshowbox(zxsomareplicate, 0.5)

figure
safeshowbox(soma, 0.5)
axis([0 xdim 0 ydim 0 zdim])
figure
safeshowbox(imgsoma, 100)
axis([0 xdim 0 ydim 0 zdim])
% safeshowbox(zysomareplicate, 0.5)
% safeshowbox(xysomareplicate, 0.5)
% figure
% imshow(xysoma)
% figure
% imshow(zysoma)
% figure
% imshow(zxsoma) 
% centroids = cat(1, s.Centroid);
% figure
% imshow(bixy)
% hold on
% plot(centroids(:,1), centroids(:,2), 'b*');
% hold off
