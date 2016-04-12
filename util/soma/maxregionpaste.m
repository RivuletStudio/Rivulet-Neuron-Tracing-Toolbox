function pasted = maxregionpaste(img)
	region = regionprops(img, 'all');
	[~, maxareaindex] = max([region.Area]);
	pasted = zeros(size(img));
	maxxyregion = region(maxareaindex);
	maxxyregionBoundingBox = maxxyregion.BoundingBox;
	[xwidth, yheight] = size(region(maxareaindex).FilledImage);
	xp = maxxyregionBoundingBox(2);
	yp = maxxyregionBoundingBox(1); 
	pasted(floor(xp): floor(xp) + xwidth - 1, floor(yp) : floor(yp) + yheight - 1) = region(maxareaindex).FilledImage;
end