clc
clear all
close all
warning off;
imgsoma = load_v3d_raw_img_file('/home/donghao/Desktop/09-2902-04R-01C-60x_merge_c1.v3dpbd.v3draw');

% maximum intensity projection to create a 2d neuron image with soma inside
somamipxy = max(imgsoma, [], 3);

% The following two lines basically make the edge of image more obvious
gI = snakegborder(somamipxy, 1, 1000);
gI = double(gI) / 255;

% parameter initialization
smoothing = 1;
threshold = 0.1;
ballon = 1;

% The initialization of snake using geodesic active contour algorithm
MorphGAC = snakeinitialise(gI, smoothing, threshold, ballon);

% Basically it creates a logical disk with true elements inside and false elements outside
shape = size(imgsoma);
scalerow = 0.75;
center = [518 438];
sqradius = 20;
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
for i = 1 : 100 
	MorphGAC = snakestep(MorphGAC);

	%Use regionprop to find largest region among all separate regions
	xyregion = regionprops(MorphGAC.u, 'all');
	[~, maxareaindex] = max([xyregion.Area]);
	xysoma = zeros(size(MorphGAC.u));
	maxxyregion = xyregion(maxareaindex);
	maxxyregionBoundingBox = maxxyregion.BoundingBox;
	
	% Estimated diameter is a practical criteria to stop the soma snake
	stopthreshold = maxxyregion.EquivDiameter;
	[xwidth, yheight] = size(xyregion(maxareaindex).FilledImage);
	xp = maxxyregionBoundingBox(2);
	yp = maxxyregionBoundingBox(1);
	
	% Fill the holes inside the soma 
	xysoma(floor(xp): floor(xp) + xwidth - 1, floor(yp) : floor(yp) + yheight - 1) = xyregion(maxareaindex).FilledImage;
	if (stopthreshold > 180) & stopthreshold ~= 0
		break;
	end
	imshow(xysoma);
	drawnow;
end