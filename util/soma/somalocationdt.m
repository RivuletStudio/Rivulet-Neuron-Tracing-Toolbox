function somaloc = somalocationdt(imgsoma, imgthres)
	bI = imgsoma > imgthres;
	% safeshowbox(bI, 0.5)
	notbI = imgsoma < imgthres;
	transI = bwdist(notbI, 'Quasi-Euclidean');
	transI = transI .* double(bI);
	[maxmiumvaule maxindex] = max(transI(:));
	[x, y, z] = ind2sub(size(transI), maxindex);
	somaloc.x = x;
	somaloc.y = y;
	somaloc.z = z;
	transI = double(transI)/ max(double(transI(:)));
	% implay(transI)
end