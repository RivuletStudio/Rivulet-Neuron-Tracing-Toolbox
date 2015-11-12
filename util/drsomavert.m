clc
clear all
close all
% imgsoma = load_v3d_raw_img_file('/home/donghao/Desktop/09-2902-04R-01C-60x_merge_c1.v3dpbd.v3draw');
% imgsoma = load_v3d_raw_img_file('/home/donghao/Desktop/OP_2.v3draw');
imgsoma = load_v3d_raw_img_file('/home/donghao/Desktop/OP_1.v3draw');
somamipxy = max(imgsoma, [], 3);
somamipxydr = directionalRatio(somamipxy, 20, 20);
somadrthres = 0.7;
figure
imagesc(somamipxydr)
somamipxydr = somamipxydr > somadrthres;
somamipxybi = somamipxy > 20; 
bixy = somamipxybi & somamipxydr;
figure
imshow(bixy)  
xyregion = regionprops(bixy, 'all');
[~, maxareaindex] = max([xyregion.Area])
xysoma = zeros(size(bixy));
maxxyregion = xyregion(maxareaindex);
maxxyregionBoundingBox = maxxyregion.BoundingBox;
[xwidth, yheight] = size(xyregion(maxareaindex).FilledImage);
xp = maxxyregionBoundingBox(2);
yp = maxxyregionBoundingBox(1); 
figure
imshow(xyregion(maxareaindex).FilledImage);
[xdim, ydim, zdim] = size(imgsoma);
for i = 1 : zdim
% for i = 40
	counter = 1;
	for j = floor(xp) : 1 : floor(xp) + xwidth -1
		for k = floor(yp) : 1 : floor(yp) + yheight -1
			counter = counter + double(imgsoma(j, k, i));
		end
    end
    %disp(i)
	zslice(i) = counter;
end
[~, maxsliceindex] = max(zslice);
boundingsomaslice = imgsoma(floor(xp) : floor(xp) + xwidth - 1, floor(yp) : 1 : floor(yp) + yheight -1, maxsliceindex);
figure
imagesc(boundingsomaslice)
threshold = 30;
boundingsomaslice = boundingsomaslice > threshold;
stat = regionprops(boundingsomaslice, 'centroid');
soma.x = stat.Centroid(1) + floor(xp);
soma.y = stat.Centroid(2) + floor(yp);
soma.z = maxsliceindex;
disp(stat);
% figure
% safeshowbox(soma, 0.5)
% axis([0 xdim 0 ydim 0 zdim])
% figure
% safeshowbox(imgsoma, 100)
% axis([0 xdim 0 ydim 0 zdim])