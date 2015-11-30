% function soma = somaini_v_quick(imgsoma, somathres)
	imgsoma = load_v3d_raw_img_file('/home/donghao/Desktop/smallsoma.v3draw');
	% somadrthres is the threshold on the image which is perform with direntional ratio tranform
	safeshowbox(imgsoma, 30)
	figure
	soma = imgsoma > somathres;
	safeshowbox(soma, somathres)


% end
