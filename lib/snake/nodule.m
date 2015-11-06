clear all; close all; clc;
im=imread('mama07ORI.bmp');
gI = snakegborder(im, 5, 1000);
gI = double(gI) / 255;
figure
imshow(gI)
smoothing = 1;
threshold = 0.3;
ballon = 1;
MorphGAC = snakeinitialise(gI, smoothing, threshold, ballon);
shape = size(im);
scalerow = 0.75;
center = [100, 126];
sqradius = 20;
u = circlelevelset(shape, center, sqradius, scalerow);
MorphGAC = snakelevelset(MorphGAC, u);
global P2
P2{1} = eye(3);
P2kernel = ones(3);
P2kernel(:,1) = 0;
P2kernel(:,3) = 0;
P2{2} = P2kernel;
P2{3} = flipud(P2{1});
P2{4} = P2kernel';
figure
for i = 1 : 200 
	MorphGAC = snakestep(MorphGAC);
	imshow(MorphGAC.u);
	drawnow;
end