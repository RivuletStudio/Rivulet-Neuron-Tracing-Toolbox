clc;
clear all;
close all;
% read image
imgsoma = load_v3d_raw_img_file('/home/donghao/Desktop/smallsomafive.v3draw');
% The following parameters are tested for smallsomafive
center = [77, 125, 38];
sqradius = 4;
% lambda one controls the internal energy and lambda two controls the external energy 
smoothing = 1;
lambda1 = 1;
lambda2 = 1.5;
stepnum = 30;
soma = somagrowth(imgsoma, center, sqradius, smoothing, lambda1, lambda2, stepnum);