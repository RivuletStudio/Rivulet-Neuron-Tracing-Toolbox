% load('/home/donghao/Desktop/somadata/converged/slider_diff.mat')
% load('/home/donghao/Desktop/somadata/converged/foreground_num.mat')
% load('/home/donghao/Desktop/somadata/converged/forward_diff_store.mat')
% figure
% subplot(2, 2, 1)
% plot(1:numel(foreground_num), foreground_num, 'o')
% title('The number of foreground voxels')
% subplot(2, 2, 2)
% plot(1:numel(forward_diff_store), forward_diff_store, 'o')
% title('The first order difference of foreground voxels')
% subplot(2, 2, 3)
% plot(1:numel(slider_diff), slider_diff, 'o')
% title('The sliding window of the sum of first order difference') 
clear all;
close all;
clc;
imgpath = '/home/donghao/Desktop/somadata/converged/case1.v3draw';
[pathstr,name,ext] = fileparts(imgpath);
file_info = dir([pathstr '/*.v3draw']);
file_num = length(file_info);
mkdir([pathstr '/soma_reconstruct']);

% The following code initialises the default values of input parameters
soma_input.init_check = false; % First argument: true means that initial soma is provided  
soma_input.soma_threshold = []; % Second argument: threshold value for soma
soma_input.plotcheck = false; % Fourth argument: true: plot the process of soma region growth
soma_input.ax = []; % Fifth argument : the axis of the current figure
soma_input.sqrvalue  = 3; % Eighth argument : the lower bound of the square value of radius which will be assigned to a new value later   
soma_input.smoothvalue = 20; % Ninth argument : this term controls the smoothness 
soma_input.lambda1value = 1; % Tenth argument controls the ratio of internal energy to external energy
soma_input.lambda2value = 1.5; % Eleventh argument controls the ratio of internal energy to external energy
soma_input.stepnvalue = 100; % Twelfth argument controls the upper bound of soma growth iteration

% The following code is for connect soma with automatic tracing
% set the input parameters for tracing 
rivulet_input.plottracecheck = false; % Second argument : plot the tracing process or not
rivulet_input.coverage = 0.98; % Third argument : the coverage percentage is defined as the traced binary to the total number of binary elements
rivulet_input.rewire = false; % Fourth argument : whether the result tree will be rewired  
rivulet_input.gap = 10; % Fifth argument : continuous steps on background
rivulet_input.ax = []; % Sixth argument : the current axis(ax, axe) of the figure
rivulet_input.dump = true; % Seventh argument : dump the less confident branch
rivulet_input.connect =  1.2; % Eighth argument : connection rate which determines the longest connection gap rivulet allows.   
rivulet_input.branchlen = 8; % Ninth argument : pruns some short branches. The length thres 
rivulet_input.somaflagtag = true; % Tenth argument : whether the soma is detected or not 
rivulet_input.washawaytag =  false; % Twelfth argument : conduct one dilation of each trace which proves to be risky 
rivulet_input.dtimagetag = false; % Thirteenth argument : the distance transformed image. Usually the distance transformed image is obtained from I

rivulet_input.ignoredradius = true; % If radius is ignored, all radii will be set to 1
thresholdarray = [23,     40,    13,     44,    84,   80,   22,   28,   18,    87,    16]; % threshold array of 11 cases for testing purposes only
%                case1  case10 case11  case2  case3  case4 case5 case6 case7  case8  case9
for i = 1 : file_num
	cur_name = file_info(i).name;
	[~,casename,~] = fileparts(cur_name);
	fprintf('The file being processed named %s.\n', cur_name);
	% % load the file with the specific path 
	I = load_v3d_raw_img_file([pathstr,'/',cur_name]);
	soma_input.I = I; % Sixth argument : the grayscale neuron image 
	maxp = max(I(:));
	minp = min(I(:));
	autothreshold = graythresh(I) * maxp;
	soma_bI = I > autothreshold;
	% figure
	% showbox(soma_bI, 0.5)
	[somaloc maxsomadt] = somalocationdt(I, autothreshold);
	% fprintf('The maximum value of soma distance transform is %3.2f\n', maxsomadt);
	% Seventh arugment : the initial centre of sphere
	soma_input.somaloc(1) = somaloc.x;
	soma_input.somaloc(2) = somaloc.y;
	soma_input.somaloc(3) = somaloc.z;
	% fprintf('The initial estimation soma centroid: xloc: %i yloc: %i zloc: %i\n', soma_input.somaloc(1), soma_input.somaloc(2), soma_input.somaloc(3));
	ratioxz = size(I,1)/size(I,3);
	ratioyz = size(I,2)/size(I,3);
	% fprintf('The ratio of x to z is %3.2f; The ratio of y to z is %3.2f;\n', ratioxz, ratioyz);
	replacesqrvalue = floor(sqrt(maxsomadt) * max(ratioxz, ratioyz));
	replacesqrvalue = min(max(replacesqrvalue, 3),  sqrt(maxsomadt)*6);
	% Eighth argument: The estimated square vaule of radius which is the obtained by distance transform
	soma_input.sqrvalue = replacesqrvalue;
	soma_input.threshold = autothreshold;
	% fprintf('The replacesqrvalue is %d\n', replacesqrvalue);
	soma = somagrowth(soma_input.init_check, soma_input.soma_threshold,...
	 soma_input.threshold, soma_input.plotcheck, soma_input.ax, soma_input.I, soma_input.somaloc, soma_input.sqrvalue,...
	  soma_input.smoothvalue, soma_input.lambda1value, soma_input.lambda2value, soma_input.stepnvalue);
	% soma.I is the binarised soma structure
	somamask = soma.I * 30;
	somamask = uint8(somamask);
	% save the reconstructed somas as .v3draw extension 
	save_v3d_raw_img_file(somamask, [pathstr, '/soma_reconstruct/', cur_name, '_soma.v3draw']);
	rivulet_input.threshold =  thresholdarray(i);
	rivulet_input.bI = I > rivulet_input.threshold; % First argument binary image
	rivulet_input.soma = soma; % Eleventh argument : the binary image of soma. The size of soma mask is same as the original image. 
	rivulet_input.I = I; % Fourteenth argument : the original neuron image
	clear I autothreshold ext file_num I maxp maxsomadt minp ratioxz ratioyz replacesqrvalue soma_bI somaloc somamask	
	soma.I = [];
    soma_input.I = [];
    [tree, meanconf] = trace(rivulet_input.bI, rivulet_input.plottracecheck,...
	 rivulet_input.coverage, rivulet_input.rewire, rivulet_input.gap, rivulet_input.ax, rivulet_input.dump,...
	  rivulet_input.connect, rivulet_input.branchlen, rivulet_input.somaflagtag,...
	   rivulet_input.soma, rivulet_input.washawaytag, rivulet_input.dtimagetag, rivulet_input.I);
	if (rivulet_input.ignoredradius)
		tree(:,6) = 1;
	end
	saveswc(tree, [pathstr, '/soma_reconstruct/', casename, '_soma.swc']);
	close all;
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
end
