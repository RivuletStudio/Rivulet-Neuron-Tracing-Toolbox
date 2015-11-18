clc;
clear all;
close all;
imgsoma = load_v3d_raw_img_file('/home/donghao/Desktop/smallsomatwo.v3draw');
% imgsomaindex = imgsoma > 30;
% imgsoma(imgsomaindex) = imgsoma(imgsomaindex) * 3;
% somamipxy = max(imgsoma, [], 3);
% somamipxydr = directionalRatio(somamipxy, 20, 20);
% somadrthres = 0.8;
% figure
% imagesc(somamipxydr)
% somamipxydr = somamipxydr > somadrthres;
% somamipxybi = somamipxy > 20; 
% bixy = somamipxybi & somamipxydr;  
% % figure
% % imagesc(somamipxydr)
% % figure 
% % imshow(somamipxybi)
% % figure
% % imshow(somamipxy)
% % fig_counter = 1;
% % for i = 1 : 2 : 40
% % 	somamipxy = max(imgsoma, [], 3);
% % 	somamipxy = directionalRatio(somamipxy,i,20);
% % 	somamipxy = somamipxy * 255;
% % 	subplot(4, 5, fig_counter);
% % 	imagesc(somamipxy);
% % 	fig_counter = fig_counter + 1; 
% % end
% % fig_counter = 1;
% % figure
% % for i = 1 : 2 : 40
% % 	somamipxy = max(imgsoma, [], 3);
% % 	somamipxy = directionalRatio(somamipxy,20,i);
% % 	somamipxy = somamipxy * 255;
% % 	subplot(4, 5, fig_counter);
% % 	imagesc(somamipxy);
% % 	fig_counter = fig_counter + 1; 
% % end
% somamipzy = permute(imgsoma,[3 2 1]);
% somamipzy = max(somamipzy, [], 3);
% somamipzydr = directionalRatio(somamipzy, 20, 10);
% figure
% imagesc(somamipzydr)
% somadrthres = 0.8;
% somamipzydr = somamipzydr > somadrthres;
% somamipzybi = somamipzy > 30; 
% bizy = somamipzybi & somamipzydr;  
% figure
% imshow(bizy)


% somamipzx = permute(imgsoma,[3 1 2]);
% somamipzx = max(somamipzx, [], 3);
% somamipzxdr = directionalRatio(somamipzx, 20, 10);
% somadrthres = 0.8;
% somamipzxdr = somamipzxdr > somadrthres;
% somamipzxbi = somamipzx > 30; 
% bizx = somamipzxbi & somamipzxdr;  
% figure
% imshow(bizx)

% % figure
% % imshow(somamipzx)

% % figure
% % imshow(somamipxy, []); colormap('jet');
% % somathreshold = 0.5;
% % bixy = somamipxy < somathreshold;
% % bizx = somamipzx < somathreshold;
% % bizy = somamipzy < somathreshold;
% % figure
% % imshow(bixy)
% % figure
% % imshow(bizy)
% % figure
% % imshow(bizx)
% xyregion = regionprops(bixy, 'all');
% [~, maxareaindex] = max([xyregion.Area])
% xysoma = zeros(size(bixy));
% maxxyregion = xyregion(maxareaindex);
% maxxyregionBoundingBox = maxxyregion.BoundingBox;
% [xwidth, yheight] = size(xyregion(maxareaindex).FilledImage);
% xp = maxxyregionBoundingBox(2);
% yp = maxxyregionBoundingBox(1); 
% xysoma(floor(xp): floor(xp) + xwidth - 1, floor(yp) : floor(yp) + yheight - 1) = xyregion(maxareaindex).FilledImage;

% zyregion = regionprops(bizy, 'all');
% [~, maxareaindex] = max([zyregion.Area])
% zysoma = zeros(size(bizy));
% maxzyregion = zyregion(maxareaindex);
% maxzyregionBoundingBox = maxzyregion.BoundingBox;
% [xwidth, yheight] = size(zyregion(maxareaindex).FilledImage);
% xp = maxzyregionBoundingBox(2);
% yp = maxzyregionBoundingBox(1); 
% zysoma(floor(xp): floor(xp) + xwidth - 1, floor(yp) : floor(yp) + yheight - 1) = zyregion(maxareaindex).FilledImage;

% zxregion = regionprops(bizx, 'all');
% [~, maxareaindex] = max([zxregion.Area])
% zxsoma = zeros(size(bizx));
% maxzxregion = zxregion(maxareaindex);
% maxzxregionBoundingBox = maxzxregion.BoundingBox;
% [xwidth, yheight] = size(zxregion(maxareaindex).FilledImage);
% xp = maxzxregionBoundingBox(2);
% yp = maxzxregionBoundingBox(1); 
% zxsoma(floor(xp): floor(xp) + xwidth - 1, floor(yp) : floor(yp) + yheight - 1) = zxregion(maxareaindex).FilledImage;

% [xdim, ydim, zdim] = size(imgsoma);
% xysomareplicate = repmat(xysoma, 1, 1, zdim);
% zysomareplicate = repmat(zysoma, 1, 1, xdim);
% zysomareplicate = permute(zysomareplicate,[3 2 1]);
% zxsomareplicate = repmat(zxsoma, 1, 1, ydim);
% zxsomareplicate = permute(zxsomareplicate,[2 3 1]);
% soma = xysomareplicate & zysomareplicate; 
% soma = soma & zxsomareplicate;
% imgsoma = load('np.mat');
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
center = [280/2, 296/2, 70];
sqradius = 4;
u = circlelevelset3d(shape, center, sqradius);
% soma = double(soma);
% u = soma;
smoothing = 1;
lambda1 = 1;
lambda2 = 1.5;
MorphGAC = ACWEinitialise(double(imgsoma), smoothing, lambda1, lambda2);
MorphGAC.u = u;
threshold = 0.5;
figure
for i = 1 : 80
	MorphGAC = ACWEstep3d(MorphGAC, i);
	A = MorphGAC.u > threshold;  % synthetic data
	[x y z] = ind2sub(size(A), find(A));
	plot3(y, x, z, 'r.');
	axis([0 shape(1) 0 shape(2) 0 shape(3)])
	i
	drawnow;
end

%% The following code is imnplementation of level set 3d in the library 
% V = double(load_v3d_raw_img_file('/home/donghao/Desktop/smallsoma.v3draw'));
% margin = 5;
% phi = zeros(size(V)); 
% phi(margin:end-margin, margin:end-margin, margin:end-margin) = 1; 
% phi = ac_reinit(phi-.5); 
% smooth_weight = 0.1; 
% image_weight = 0.001; 
% delta_t = 1; 
% for i = 1 : 50
%     phi = ac_ChanVese_model(V, phi, smooth_weight, image_weight, delta_t, 1); 
%     if exist('h','var') && all(ishandle(h)), delete(h); end
% 	iso = isosurface(phi);	
% 	h = patch(iso,'facecolor','w');  axis equal;  view(3); 
% 	set(gcf,'name', sprintf('#iters = %d',i));
% 	drawnow; 
% end


