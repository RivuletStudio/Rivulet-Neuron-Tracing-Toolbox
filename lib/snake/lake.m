clear all; close all; clc;
im=imread('lakes3.jpg');
smoothing = 3;
% gI = snakergb2gray(im);
gI = rgb2gray(im);
gI = double(gI) / 255;
smoothing = 3;
lambda1 = 1;
lambda2 = 1;
% figure
% imshow(gI*255)
MorphGAC = ACWEinitialise(gI, smoothing, lambda1, lambda2);
shape = size(im);
scalerow = 0.75;
center = [80, 170];
sqradius = 25;
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
MorphGAC = ACWEstep(MorphGAC);
figure
for i = 1 : 200
	MorphGAC = ACWEstep(MorphGAC);
	imshow(MorphGAC.u);
	drawnow;
end
