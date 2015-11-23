function bifinal = biregion(biimage, nbands, msize, somadrthres, thresimg)
	somamipdr = directionalRatio(biimage, nbands, msize);
	somamipdr = somamipdr > somadrthres;
	somamipbi = biimage > thresimg; 
	bifinal = somamipbi & somamipdr; 
end