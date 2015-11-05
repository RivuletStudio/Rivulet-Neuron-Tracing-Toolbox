clear all; close all; clc;
% im=imread('seastar2.png');
% fim=mat2gray(im);
%draw magnitude of gradient
% figure('name','Magnitude of Gradient');
% [imx,imy]=gaussgradient(fim,0.5);
% subplot(2,2,1); imshow(abs(imx)+abs(imy)); title('sigma=0.5');
% [imx,imy]=gaussgradient(fim,1.0);
% subplot(2,2,2); imshow(abs(imx)+abs(imy)); title('sigma=1.0');
% [imx,imy]=gaussgradient(fim,1.5);
% subplot(2,2,3); imshow(abs(imx)+abs(imy)); title('sigma=1.5');
% [imx,imy]=gaussgradient(fim,2.0);
% subplot(2,2,4); imshow(abs(imx)+abs(imy)); title('sigma=2.0');
% fim = snakergb2gray(im);
% fim = rgb2gray(im);
% %draw gradeint in a small region with sigma=1.0
% [imx,imy]=gaussgradient(fim,1.0);
% figure('name','Gradient');
% imshow(fim(1:50,1:50),'InitialMagnification','fit');
% hold on;
% quiver(imx(1:50,1:50),imy(1:50,1:50));
% title('sigma=1.0');
% figure
% [imx,imy]=gaussgradient(fim,2.5);
% imshow(abs(imx)+abs(imy));
% gradnorm = imx.^2 + imy.^2;
% gradnorm = sqrt(double(gradnorm));
% alphapara = 1000;
% gI = 1./sqrt(double(1.0 + alphapara*double(gradnorm)));
% figure
% imagesc(gI)
% gI = gI / max(gI(:));
% gI = gI * 1000;
% gI = uint8(gI);
% gI = rgb2gray(gI);
% % gI = mat2gray(gI)
% figure 
% imshow(gI)
im=imread('seastar2.png');
gI = snakegborder(im, 2.5, 1000);
% figure
% imshow(gI)
smoothing = 2;
threshold = 0.33 * 255;
ballon = -1;
MorphGAC = snakeinitialise(gI, smoothing, threshold, ballon);
shape = size(im);
scalerow = 0.75;
center = [163, 137];
sqradius = 135;
u = circlelevelset(shape, center, sqradius, scalerow);
MorphGAC = snakelevelset(MorphGAC, u);
% figure
% for i = 1 : 60 
% 	MorphGAC = snakestep(MorphGAC);
% 	imshow(MorphGAC.u)
% 	drawnow;
% end

% MorphGAC = snakeupdatemask(MorphGAC);
% MorphGAC = snakeballon(MorphGAC, ballon);
% MorphGAC = snakethreshold(MorphGAC, threshold);
% MorphGAC = snakedata(MorphGAC, gI);
global P2
P2{1} = eye(3);
P2kernel = ones(3);
P2kernel(:,1) = 0;
P2kernel(:,3) = 0;
P2{2} = P2kernel;
P2{3} = flipud(P2{1});
P2{4} = P2kernel';

% figure 
% imshow(MorphGAC.u)

% figure
% imshow(MorphGAC.data)

MorphGAC = snakestep(MorphGAC);
% u = MorphGAC.u;
% u = SI(u, P2);
% figure
% imshow(u)


figure
for i = 1 : 200 
	MorphGAC = snakestep(MorphGAC);
	imshow(MorphGAC.u)
	drawnow;
end

% figure
% imshow(u)
% u = IS(u, P2);
% figure
% imshow(u)