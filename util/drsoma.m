clc
clear all
close all
imgsoma = load_v3d_raw_img_file('/home/donghao/Desktop/09-2902-04R-01C-60x_merge_c1.v3dpbd.v3draw');

somamipxy = max(imgsoma, [], 3);
somamipxydr = directionalRatio(somamipxy, 40, 40);
somadrthres = 0.8;
somamipxydr = somamipxydr > somadrthres;
somamipxybi = somamipxy > 30; 
bixy = somamipxybi & somamipxydr;  
% figure
% imagesc(somamipxydr)
% figure 
% imshow(somamipxybi)
% figure
% imshow(somamipxy)
% fig_counter = 1;
% for i = 1 : 2 : 40
% 	somamipxy = max(imgsoma, [], 3);
% 	somamipxy = directionalRatio(somamipxy,i,20);
% 	somamipxy = somamipxy * 255;
% 	subplot(4, 5, fig_counter);
% 	imagesc(somamipxy);
% 	fig_counter = fig_counter + 1; 
% end
% fig_counter = 1;
% figure
% for i = 1 : 2 : 40
% 	somamipxy = max(imgsoma, [], 3);
% 	somamipxy = directionalRatio(somamipxy,20,i);
% 	somamipxy = somamipxy * 255;
% 	subplot(4, 5, fig_counter);
% 	imagesc(somamipxy);
% 	fig_counter = fig_counter + 1; 
% end
somamipzy = permute(imgsoma,[3 2 1]);
somamipzy = max(somamipzy, [], 3);
somamipzydr = directionalRatio(somamipzy, 20, 20);
somadrthres = 0.8;
somamipzydr = somamipzydr > somadrthres;
somamipzybi = somamipzy > 30; 
bizy = somamipzybi & somamipzydr;  
% figure
% imshow(somamipzy)


somamipzx = permute(imgsoma,[3 1 2]);
somamipzx = max(somamipzx, [], 3);
somamipzxdr = directionalRatio(somamipzx, 20, 20);
somadrthres = 0.8;
somamipzxdr = somamipzxdr > somadrthres;
somamipzxbi = somamipzx > 30; 
bizx = somamipzxbi & somamipzxdr;  
% figure
% imshow(somamipzx)

% figure
% imshow(somamipxy, []); colormap('jet');
% somathreshold = 0.5;
% bixy = somamipxy < somathreshold;
% bizx = somamipzx < somathreshold;
% bizy = somamipzy < somathreshold;
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

figure
safeshowbox(soma, 0.5)
axis([0 xdim 0 ydim 0 zdim])
figure
safeshowbox(imgsoma, 100)
axis([0 xdim 0 ydim 0 zdim])


