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
% imshow(bizx)
% figure
% imshow(bizy)
xyregion = regionprops(bixy, 'all');
[~, maxareaindex] = max([xyregion.Area])
xysoma = zeros(size(bixy));
[xp, yp, xwidth, yheight] = xyregion.BoundingBox;
xysoma(xp: xp + xwidth, yp : yp + yheight) = xyregion(maxareaindex).FilledArea; 
% centroids = cat(1, s.Centroid);
% figure
% imshow(bixy)
% hold on
% plot(centroids(:,1), centroids(:,2), 'b*');
% hold off
