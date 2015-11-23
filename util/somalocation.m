clc
clear all
close all
% imgsoma = load_v3d_raw_img_file('/home/donghao/Desktop/09-2902-04R-01C-60x_merge_c1.v3dpbd.v3draw');
% imgsoma = load_v3d_raw_img_file('/home/donghao/Desktop/OP_2.v3draw');
imgsoma = load_v3d_raw_img_file('/home/donghao/Desktop/09-2902-04R-01C-60x_merge_c1.v3dpbd.v3draw');
somamipxy = max(imgsoma, [], 3);
figure
imagesc(somamipxy)
somadrthres = 0.7;
nbands = 20;
msize = 10;
thresimg = 80;
% Use the directional ratio plus  
bixy = biregion(somamipxy, nbands, msize, somadrthres, thresimg);


xyregion = regionprops(bixy, 'all');
[~, maxareaindex] = max([xyregion.Area])
xysoma = zeros(size(bixy));
maxxyregion = xyregion(maxareaindex);
maxxyregionBoundingBox = maxxyregion.BoundingBox;
[xwidth, yheight] = size(xyregion(maxareaindex).FilledImage);
% xp and yp are the boundary of 
xp = maxxyregionBoundingBox(2);
yp = maxxyregionBoundingBox(1); 
figure
imshow(xyregion(maxareaindex).FilledImage);
[xdim, ydim, zdim] = size(imgsoma);
for i = 1 : zdim
	counter = 1;
	for j = floor(xp) : 1 : floor(xp) + xwidth -1
		for k = floor(yp) : 1 : floor(yp) + yheight -1
			counter = counter + double(imgsoma(j, k, i));
		end
    end
	zslice(i) = counter;
end
[~, maxsliceindex] = max(zslice);
boundingsomaslice = imgsoma(floor(xp) : floor(xp) + xwidth - 1, floor(yp) : 1 : floor(yp) + yheight -1, maxsliceindex);

% Create an empty mask for centroid calculation of soma
xyslice = imgsoma(:,:, maxsliceindex);
xyslicesize = size(xyslice);
xyslice = zeros(xyslicesize);
% Assign soma value inside the bounding box to the empty mask
xyslice(floor(xp) : floor(xp) + xwidth - 1, floor(yp) : 1 : floor(yp) + yheight -1) = boundingsomaslice; 

figure
imagesc(boundingsomaslice)
% A low threshold is enough and this parameter should be very robust 
lowthreshold = 30;
% Find the largest region using regionprops 
boundingsomaslice = xyslice > lowthreshold;
xyregion = regionprops(boundingsomaslice, 'all');
[~, maxareaindex] = max([xyregion.Area]);
maxxyregion = xyregion(maxareaindex);
figure
imagesc(boundingsomaslice)
maxxyregionBoundingBox = maxxyregion.BoundingBox;

% Save the soma location in a structure for fututre use
somaloc.x = maxxyregion.Centroid(1);
somaloc.y = maxxyregion.Centroid(2);
somaloc.z = maxsliceindex;
