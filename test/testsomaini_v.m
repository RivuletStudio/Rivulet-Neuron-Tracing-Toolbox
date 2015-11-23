clc
clear all
close all
% imgsoma = load_v3d_raw_img_file('/home/donghao/Desktop/09-2902-04R-01C-60x_merge_c1.v3dpbd.v3draw');
% imgsoma = load_v3d_raw_img_file('/home/donghao/Desktop/OP_2.v3draw');
imgsoma = load_v3d_raw_img_file('/home/donghao/Desktop/smallsoma.v3draw');
nbandsxy = 20; nbandszy = 20; nbandszx = 20;
msizexy  = 20; msizezy  = 10; msizezx  = 10;
somadrthres = 0.8;
thresimg = 30;
soma = somaini_v(imgsoma, somadrthres, thresimg, nbandsxy, nbandszy, nbandszx, msizexy, msizezy, msizezx);
[xdim, ydim, zdim] = size(imgsoma);
figure
safeshowbox(soma, 0.5)
axis([0 xdim 0 ydim 0 zdim])
figure
safeshowbox(imgsoma, 100)
axis([0 xdim 0 ydim 0 zdim])