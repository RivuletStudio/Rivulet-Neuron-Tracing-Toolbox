clc
clear all
close all
% imgsoma = load_v3d_raw_img_file('/home/donghao/Desktop/09-2902-04R-01C-60x_merge_c1.v3dpbd.v3draw');
% imgsoma = load_v3d_raw_img_file('/home/donghao/Desktop/OP_2.v3draw');
imgsoma = load_v3d_raw_img_file('/home/donghao/Desktop/09-2902-04R-01C-60x_merge_c1.v3dpbd.v3draw');
somadrthres = 0.7;
nbands = 20;
msize = 10;
thresimg = 80;
% A low threshold is enough and this parameter should be very robust 
lowthreshold = 30;
somaloc = somalocation(imgsoma, nbands, msize, somadrthres, thresimg, lowthreshold);