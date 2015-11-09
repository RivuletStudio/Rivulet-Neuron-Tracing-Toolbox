function grayimg = snakergb2gray(img)
	grayimg = 0.2989*img(:,:,1) + 0.587*img(:,:,2) + 0.114*img(:,:,3); 
	% grayimg = 0.114*img(:,:,1) + 0.587*img(:,:,2) + 0.2989*img(:,:,3); 
end