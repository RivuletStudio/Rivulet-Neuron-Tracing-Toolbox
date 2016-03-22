function pasted = somaini_v_quick(imgsoma, somathres)
	soma = imgsoma > somathres;
	fprintf('somathres: %d4.0\n', somathres);
	region = regionprops(soma, 'all');
	[~, maxareaindex] = max([region.Area]);
	pasted = zeros(size(soma));
	maxxyregion = region(maxareaindex);
	maxxyregionBoundingBox = maxxyregion.BoundingBox;
	[xwidth, yheight, zdim] = size(region(maxareaindex).FilledImage);
	fprintf('xwidth: %4.0d, yheight: %4.0d, zdim: %4.0d\n', xwidth, yheight, zdim)
	xp = maxxyregionBoundingBox(2);
	yp = maxxyregionBoundingBox(1);
	zp = maxxyregionBoundingBox(3);
	fprintf('xp: %d, yp: %d, zp: %d\n', floor(xp), floor(yp), floor(zp))
	pasted(floor(xp): floor(xp) + xwidth - 1, floor(yp) : floor(yp) + yheight - 1,  floor(zp) : floor(zp) + zdim - 1) = region(maxareaindex).FilledImage;
end
