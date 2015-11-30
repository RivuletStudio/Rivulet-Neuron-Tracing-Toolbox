clc
clear all;
close all;

% function soma = somaini_v_quick(imgsoma, somathres)
	imgthres = 30;
	somathres = 70;
	imgsoma = load_v3d_raw_img_file('/home/donghao/Desktop/smallsoma.v3draw');
	% somadrthres is the threshold on the image which is perform with direntional ratio tranform
	safeshowbox(imgsoma, imgthres)
	figure
	soma = imgsoma > somathres;
	safeshowbox(soma, 0.5)
	region = regionprops(soma, 'all');
	[~, maxareaindex] = max([region.Area]);
	pasted = zeros(size(soma));
	maxxyregion = region(maxareaindex);
	maxxyregionBoundingBox = maxxyregion.BoundingBox;
	[xwidth, yheight, zdim] = size(region(maxareaindex).FilledImage);
	xp = maxxyregionBoundingBox(2);
	yp = maxxyregionBoundingBox(1);
	zp = maxxyregionBoundingBox(3); 
	pasted(floor(xp): floor(xp) + xwidth - 1, floor(yp) : floor(yp) + yheight - 1,  floor(zp) : floor(zp) + zdim - 1) = region(maxareaindex).FilledImage;
	figure
	safeshowbox(pasted, 0.5)

% end
