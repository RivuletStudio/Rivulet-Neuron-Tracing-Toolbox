clc;
% clear all;
close all;
imgsoma = load_v3d_raw_img_file('/home/donghao/Desktop/smallsoma.v3draw');
global P3
P2kernel = ones(3);
P2kernel(:,1) = 0;
P2kernel(:,3) = 0;
P3kernel(:,:,1) = P2kernel; 
P3kernel(:,:,2) = P2kernel; 
P3kernel(:,:,3) = P2kernel; 
P3{1} = P3kernel;
P2kernel = P2kernel';
P3kernel(:,:,1) = P2kernel; 
P3kernel(:,:,2) = P2kernel; 
P3kernel(:,:,3) = P2kernel; 
P3{2} = P3kernel;
P3kernel = zeros(3, 3, 3);
P3kernel(:,:,2) = ones(3, 3);
P3{3} = P3kernel;
P2kernel = eye(3);
P3kernel(:,:,1) = P2kernel; 
P3kernel(:,:,2) = P2kernel; 
P3kernel(:,:,3) = P2kernel; 
P3{4} = P3kernel;
P2kernel = flipud(eye(3));
P3kernel(:,:,1) = P2kernel; 
P3kernel(:,:,2) = P2kernel; 
P3kernel(:,:,3) = P2kernel; 
P3{5} = P3kernel;
P3kernel = zeros(3, 3, 3);
P3kernel(:, 1, 1) = 1;
P3kernel(:, 2, 2) = 1;
P3kernel(:, 3, 3) = 1;
P3{6} = P3kernel;
P3kernel = zeros(3, 3, 3);
P3kernel(:, 3, 1) = 1;
P3kernel(:, 2, 2) = 1;
P3kernel(:, 1, 3) = 1;
P3{7} = P3kernel;
P3kernel = zeros(3, 3, 3);
P3kernel(1, :, 1) = 1;
P3kernel(2, :, 2) = 1;
P3kernel(3, :, 3) = 1;
P3{8} = P3kernel;
P3kernel = zeros(3, 3, 3);
P3kernel(3, :, 1) = 1;
P3kernel(2, :, 2) = 1;
P3kernel(1, :, 3) = 1;
P3{9} = P3kernel;

shape = size(imgsoma);
center = [108, 137, 38];
% shape = [120, 160, 60];
sqradius = 80;
% u = circlelevelset3d(shape, center, sqradius);
u = double(soma);
smoothing = 1;
lambda1 = 1;
lambda2 = 1;
MorphGAC = ACWEinitialise(double(imgsoma), smoothing, lambda1, lambda2);
MorphGAC.u = u;
MorphGAC = ACWEstep3d(MorphGAC);
figure
% safeshowbox(MorphGAC.u, 0.5)
% figure
threshold = 0.5;
for i = 1 : 200
	MorphGAC = ACWEstep3d(MorphGAC);
	A = MorphGAC.u > threshold;  % synthetic data
	[x y z] = ind2sub(size(A), find(A));
	plot3(y, x, z, 'r.');
	axis([0 shape(1) 0 shape(2) 0 shape(3)])
	
	i
	drawnow;

end




% [snakegridz, snakegridy, snakegridx]  = meshgrid(1:shape(2), 1:shape(1),  1:shape(3));
% snakegridx = snakegridx - 1;
% snakegridy = snakegridy - 1;
% snakegridz = snakegridz - 1;
% snakegridx = snakegridx - center(1);
% snakegridy = snakegridy - center(2);
% snakegridz = snakegridz - center(3);
% snakegrid(:, :, :, 1) = snakegridx;
% snakegrid(:, :, :, 2) = snakegridy;
% snakegrid(:, :, :, 3) = snakegridz;
% size(snakegrid)
% snakegrid = permute(snakegrid, [3 4 2 1]);
% snakegrid = permute(snakegrid, [4 3 2 1]);
% snakegrid = snakegrid.^2;
% snakegrid = permute(snakegrid, [1 2 4 3]);
% snakegrid = sum(snakegrid, 4);
% snakegrid = sqrt(snakegrid);
% phi = sqradius - snakegrid;
% u =  phi > 0;
% u = double(u);

% snakegrid(:,:,1,1)
% snakegrid = permute(snakegrid, [2 4 3 1]);
% test=distgradient(imgsoma);
