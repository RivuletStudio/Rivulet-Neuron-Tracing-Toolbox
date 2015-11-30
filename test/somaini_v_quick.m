function pasted = somaini_v_quick(imgsoma, somathres)
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
end
