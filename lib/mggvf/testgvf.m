clc
clear all
close all
im = imread('test.jpg');
figure
imshow(im)
hold on
im = double(rgb2gray(im));
% im = im2bw(im);
[nr,nc]=size(im);
% 2D gvf
% [u,v] = gradient(double(im));
v1 = 5; v2 = 5; threshold = 0.1; mu =0.1; f = im;
[u,v] = mggvf(f, mu, v1, v2, threshold);
[x, y] = meshgrid(1:nc,1:nr);
quiver(x,y,u,v)

% 3D gvf
im = imread('test.jpg'); iterations = 5;
[u,v,w] = GVF3D(double(im), mu, iterations);