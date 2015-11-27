function somaloc = somalocation(imgsoma, nbands, msize, somadrthres, thresimg, lowthreshold)
	somamipxy = max(imgsoma, [], 3);
	% Use the directional ratio plus  
	bixy = biregion(somamipxy, nbands, msize, somadrthres, thresimg);


	xyregion = regionprops(bixy, 'all');
	[~, maxareaindex] = max([xyregion.Area]);
	xysoma = zeros(size(bixy));
	maxxyregion = xyregion(maxareaindex);
	maxxyregionBoundingBox = maxxyregion.BoundingBox;
	[xwidth, yheight] = size(xyregion(maxareaindex).FilledImage);
	% xp and yp are the boundary of soma 
	xp = maxxyregionBoundingBox(2);
	yp = maxxyregionBoundingBox(1); 
	figure
	imshow(xyregion(maxareaindex).FilledImage);
	pause(0.2)
	close
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
	pause(0.1)
	close
	% Find the largest region using regionprops 
	boundingsomaslice = xyslice > lowthreshold;
	xyregion = regionprops(boundingsomaslice, 'all');
	[~, maxareaindex] = max([xyregion.Area]);
	maxxyregion = xyregion(maxareaindex);
	figure
	imagesc(boundingsomaslice)
	pause(0.1)
	close
	maxxyregionBoundingBox = maxxyregion.BoundingBox;

	% Save the soma location in a structure for fututre use
	somaloc.x = maxxyregion.Centroid(1);
	somaloc.y = maxxyregion.Centroid(2);
	somaloc.z = maxsliceindex;
end