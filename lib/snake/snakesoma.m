clc
clear all
close all
warning off;
imgsoma = load_v3d_raw_img_file('/home/donghao/Desktop/09-2902-04R-01C-60x_merge_c1.v3dpbd.v3draw');

somamipxy = max(imgsoma, [], 3);
gI = snakegborder(somamipxy, 1, 1000);
gI = double(gI) / 255;
% gI = directionalRatio(somamipxy, 15, 20);
figure
imagesc(gI)
smoothing = 1;
threshold = 0.1;
ballon = 1;
MorphGAC = snakeinitialise(gI, smoothing, threshold, ballon);
shape = size(imgsoma);
scalerow = 0.75;
center = [518 438];
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
for i = 1 : 100 
	MorphGAC = snakestep(MorphGAC);
	xyregion = regionprops(MorphGAC.u, 'all');
	[~, maxareaindex] = max([xyregion.Area]);
	xysoma = zeros(size(MorphGAC.u));
	maxxyregion = xyregion(maxareaindex);
	maxxyregionBoundingBox = maxxyregion.BoundingBox;
	% stopthreshold = maxxyregion.Perimeter / maxxyregion.FilledArea
	stopthreshold = maxxyregion.EquivDiameter;
	[xwidth, yheight] = size(xyregion(maxareaindex).FilledImage);
	xp = maxxyregionBoundingBox(2);
	yp = maxxyregionBoundingBox(1); 
	xysoma(floor(xp): floor(xp) + xwidth - 1, floor(yp) : floor(yp) + yheight - 1) = xyregion(maxareaindex).FilledImage;
	% MorphGAC.u = xysoma;
	if (stopthreshold > 180) & stopthreshold ~= 0
		break;
	end
	% disp(i);
	imshow(xysoma);
	drawnow;
end