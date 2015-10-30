clear;close all;
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
smoothing = 3;
threshold = 1;
ballon = -1;
MorphGAC = snakeinitialise(gI, smoothing, threshold, ballon);
u = [3, -1];
MorphGAC = snakelevelset(MorphGAC, u);
MorphGAC = snakeupdatemask(MorphGAC);
MorphGAC = snakeballon(MorphGAC, 3);

