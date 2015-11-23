function soma = somaini_v(imgsoma, somadrthres, thresimg, nbandsxy, nbandszy, nbandszx, msizexy, msizezy, msizezx)
	
	% somadrthres is the threshold on the image which is perform with direntional ratio tranform
	% thresimg is the 2d image threshold


	somamipxy = max(imgsoma, [], 3);
	%  - nbands: Number of bands to be generated.
	%  - msize: Size of the filter to be generated.
	% the second parameter is strongly related to the radius of the soma 
	nbands = nbandsxy;
	msize = msizexy;
	bixy = biregion(somamipxy, nbands, msize, somadrthres, thresimg);


	somamipzy = permute(imgsoma,[3 2 1]);
	somamipzy = max(somamipzy, [], 3);
	% the second parameter is strongly related to the radius of the soma 
	% m size changed because the the size of volume is anisotropic
	nbands = nbandszy; msize = msizezy;
	bizy = biregion(somamipzy, nbands, msize, somadrthres, thresimg);

	 
	somamipzx = permute(imgsoma,[3 1 2]);
	somamipzx = max(somamipzx, [], 3);
	% the second parameter is strongly related to the radius of the soma 
	nbands = nbandszx; msize = msizezx;
	bizx = biregion(somamipzx, nbands, msize, somadrthres, thresimg);
	  
	xysoma = maxregionpaste(bixy);
	zysoma = maxregionpaste(bizy);
	zxsoma = maxregionpaste(bizx);
	[xdim, ydim, zdim] = size(imgsoma);
	xysomareplicate = repmat(xysoma, 1, 1, zdim);
	zysomareplicate = repmat(zysoma, 1, 1, xdim);
	zysomareplicate = permute(zysomareplicate,[3 2 1]);
	zxsomareplicate = repmat(zxsoma, 1, 1, ydim);
	zxsomareplicate = permute(zxsomareplicate,[2 3 1]);
	soma = xysomareplicate & zysomareplicate; 
	soma = soma & zxsomareplicate;


end
