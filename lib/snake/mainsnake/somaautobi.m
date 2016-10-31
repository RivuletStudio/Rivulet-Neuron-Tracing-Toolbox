clear all;
close all;
clc;
imgpath = '/home/donghao/Desktop/zebrafishlarveRGC/5.v3draw';
[pathstr,name,ext] = fileparts(imgpath);
file_info = dir([pathstr '/*.v3draw']);
file_num = length(file_info);
if exist(pathstr)~=7
	mkdir([pathstr '/soma_reconstruct']);
end
% The following code initialises the default values of input parameters
% This following lines will be deleted in the future
% zebrafish1 46 zebrafish2 30 zebrafish3 72 zebrafish4 70 zebrafish5 81 zebrafish6 44 zebrafish7 37 
soma_input.init_check = false; % First argument: true means that initial soma is provided  
soma_input.soma_threshold = []; % Second argument: threshold value for soma
soma_input.plotcheck = false; % Fourth argument: true: plot the process of soma region growth
soma_input.ax = []; % Fifth argument : the axis of the current figure
soma_input.sqrvalue  = 3; % Eighth argument : the lower bound of the square value of radius which will be assigned to a new value later   
soma_input.smoothvalue = 20; % Ninth argument : this term controls the smoothness 
soma_input.lambda1value = 1; % Tenth argument controls the ratio of internal energy to external energy
soma_input.lambda2value = 1.5; % Eleventh argument controls the ratio of internal energy to external energy
soma_input.stepnvalue = 100; % Twelfth argument controls the upper bound of soma growth iteration
fprintf('The file being processed named %s.\n', name);
% % load the file with the specific path 
I = load_v3d_raw_img_file([pathstr,'/',name,'.v3draw']);
maxp = max(I(:));
minp = min(I(:));
autothreshold = graythresh(I) * maxp;
autothreshold = 81;
soma_bI = I > autothreshold;
soma_bI = imfill(soma_bI,'holes');
% se = strel('sphere',3);
% soma_bI = imdilate(soma_bI, se);
soma_input.I = soma_bI * 40; % Sixth argument : the grayscale neuron image 

figure
showbox(soma_bI, 0.5)
[somaloc maxsomadt, transI] = somalocationdt(I, autothreshold);
fprintf('The maximum value of soma distance transform is %3.2f\n', maxsomadt);

% Seventh arugment : the initial centre of sphere
soma_input.somaloc(1) = somaloc.x;
soma_input.somaloc(2) = somaloc.y;
soma_input.somaloc(3) = somaloc.z;
fprintf('The initial estimation soma centroid: xloc: %i yloc: %i zloc: %i\n', soma_input.somaloc(1), soma_input.somaloc(2), soma_input.somaloc(3));
ratioxz = size(I,1)/size(I,3);
ratioyz = size(I,2)/size(I,3);
fprintf('The ratio of x to z is %3.2f; The ratio of y to z is %3.2f;\n', ratioxz, ratioyz);
replacesqrvalue = floor(sqrt(maxsomadt) * max(ratioxz, ratioyz));
replacesqrvalue = min(max(replacesqrvalue, 3),  sqrt(maxsomadt)*6);
% replacesqrvalue = 20;

% Eighth argument: The estimated square vaule of radius which is the obtained by distance transform
soma_input.sqrvalue = replacesqrvalue;
soma_input.threshold = autothreshold;
fprintf('The replacesqrvalue is %2.2f\n', replacesqrvalue);
soma = somagrowth(soma_input.init_check, soma_input.soma_threshold,...
 soma_input.threshold, soma_input.plotcheck, soma_input.ax, soma_input.I, soma_input.somaloc, soma_input.sqrvalue,...
  soma_input.smoothvalue, soma_input.lambda1value, soma_input.lambda2value, soma_input.stepnvalue);
while(isfield(soma, 'enlrspt'))
	somacube = soma.I(soma.enlrspt(1):soma.enlrept(1), soma.enlrspt(2):soma.enlrept(2), soma.enlrspt(3):soma.enlrept(3));
	soma = somagrowthcube(0.5, false, soma_input.ax, soma_input.I, soma_input.smoothvalue,...
							 soma_input.lambda1value, soma_input.lambda2value, soma_input.stepnvalue, somacube,...
							  soma.enlrspt, soma.enlrept);
end
% soma.I is the binarised soma structure
somamask = soma.I * 30;
% S = ones(3,3,3); 
% somaB=xor(soma.I > 0.5, imerode(soma.I > 0.5, S));
% figure
% showbox(somaB, 0.5)
% Blist = transI(find(somaB > 0.5));
% largeone = Blist(find(Blist > 1));
somamask = uint8(somamask);
% somacube = zeros(size(somamask));
% somacube(soma.enlrspt(1):soma.enlrept(1), soma.enlrspt(2):soma.enlrept(2), soma.enlrspt(3):soma.enlrept(3)) = 40;
% somacube = uint8(somacube);
% save the reconstructed somas as .v3draw extension 
save_v3d_raw_img_file(somamask, [pathstr, '/tmp/', name, '_bithres.v3draw']);
clear all
% save_v3d_raw_img_file(somacube, [pathstr, '/tmp/', name, '_somacube.v3draw']);
% The following code is for connect soma with automatic tracing
% set the input parameters for tracing 
% rivulet_input.threshold =  40;
% rivulet_input.bI = I > rivulet_input.threshold; % First argument binary image
% rivulet_input.plottracecheck = false; % Second argument : plot the tracing process or not
% rivulet_input.coverage = 1; % Third argument : the coverage percentage is defined as the traced binary to the total number of binary elements
% rivulet_input.rewire = false; % Fourth argument : whether the result tree will be rewired  
% rivulet_input.gap = 10; % Fifth argument : continuous steps on background
% rivulet_input.ax = []; % Sixth argument : the current axis(ax, axe) of the figure
% rivulet_input.dump = true; % Seventh argument : dump the less confident branch
% rivulet_input.connect =  1.2; % Eighth argument : connection rate which determines the longest connection gap rivulet allows.   
% rivulet_input.branchlen = 8; % Ninth argument : pruns some short branches. The length thres 
% rivulet_input.somaflagtag = true; % Tenth argument : whether the soma is detected or not 
% rivulet_input.soma = soma; % Eleventh argument : the binary image of soma. The size of soma mask is same as the original image.  
% rivulet_input.washawaytag =  false; % Twelfth argument : conduct one dilation of each trace which proves to be risky 
% rivulet_input.dtimagetag = false; % Thirteenth argument : the distance transformed image. Usually the distance transformed image is obtained from I
% rivulet_input.I = I; % Fourteenth argument : the original neuron image
% rivulet_input.ignoredradius = true; % If radius is ignored, all radii will be set to 1
% clear I autothreshold ext file_info file_num I maxp maxsomadt minp ratioxz ratioyz replacesqrvalue soma soma_bI soma_input somaloc somamask
% [tree, meanconf] = trace(rivulet_input.bI, rivulet_input.plottracecheck,...
%  rivulet_input.coverage, rivulet_input.rewire, rivulet_input.gap, rivulet_input.ax, rivulet_input.dump,...
%   rivulet_input.connect, rivulet_input.branchlen, rivulet_input.somaflagtag,...
%    rivulet_input.soma, rivulet_input.washawaytag, rivulet_input.dtimagetag, rivulet_input.I);
% if (rivulet_input.ignoredradius)
% 	tree(:,6) = 1;
% end
% saveswc(tree, [pathstr, '/soma_reconstruct/', name, '_soma.swc']);
% treetype = tree(:, 7);
% unconntree = find(treetype==-2);
% unconnectedpt = tree(unconntree,3:5);
% S=ones(3,3,3);
% Bsoma=xor(rivulet_input.soma.I > 0.5,imdilate(rivulet_input.soma.I > 0.5,S));
% somaidx = find(Bsoma == 1);
% [somax, somay, somaz] = ind2sub(size(rivulet_input.soma.I), somaidx);
% somasurf(:,1) = somax; somasurf(:,2) = somay; somasurf(:,3) = somaz;
% %strdist : the distance between unconnected tree and soma surface
% strdist = pdist2(unconnectedpt,somasurf);
% minD = min(strdist, [], 2);
% thresdist = 3;
% closetree = unconntree(minD < thresdist);
% tree(closetree, 7) = -1;
% saveswc(tree, [pathstr, '/soma_reconstruct/', name, '_soma_revised.swc']);