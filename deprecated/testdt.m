clc
clear all
close all
imgsoma = load_v3d_raw_img_file('/home/donghao/Desktop/OP_1.v3draw');
bI = imgsoma > 30;
safeshowbox(bI, 0.5)
notbI = imgsoma < 30;
% [x y z] = ind2sub(size(notbI), find(notbI));
% transI = bwdistsc(bI, [1 1 1]);
transI = bwdist(notbI, 'Quasi-Euclidean');
% transI(x, y, z) = 0;
transI = transI .* double(bI);
[maxmiumvaule maxindex] = max(transI(:));
[x, y, z] = ind2sub(size(transI), maxindex)
% transI = transI / max(transI(:)) * 3;
% transI = im2uint8(transI);
% transI = uint8(transI);
figure
safeshowbox(transI, 0)
% save_v3d_raw_img_file(transI, 'trans.v3draw');
transI = double(transI)/ max(double(transI(:)));
implay(transI)