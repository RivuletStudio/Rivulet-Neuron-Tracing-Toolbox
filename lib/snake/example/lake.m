clear all; close all; clc;
im=imread('lakes3.jpg');

% The smoothing parameter basically controls the smoothness of object boundary
smoothing = 3;

% The following two lines basically make the edge of image more obvious
gI = rgb2gray(im);
gI = double(gI) / 255;
smoothing = 3;

% lambda one controls the internal energy and lambda two controls the external energy 
lambda1 = 1;
lambda2 = 1;

% The initialization of snake using active contour without edge algorithm
MorphGAC = ACWEinitialise(gI, smoothing, lambda1, lambda2);

% Basically it creates a logical disk with true elements inside and false elements outside
shape = size(im);
scalerow = 0.75;
center = [80, 170];
sqradius = 25;
u = circlelevelset(shape, center, sqradius, scalerow);


MorphGAC = snakelevelset(MorphGAC, u);

% The following kernel is used for the SI and IS operation 
global P2
P2{1} = eye(3);
P2kernel = ones(3);
P2kernel(:,1) = 0;
P2kernel(:,3) = 0;
P2{2} = P2kernel;
P2{3} = flipud(P2{1});
P2{4} = P2kernel';

% Each move the snake will evolue one step 
figure
for i = 1 : 200
	MorphGAC = ACWEstep(MorphGAC);
	imshow(MorphGAC.u);
	drawnow;
end
