clc;
clear all;
close all;
% imgsoma = load_v3d_raw_img_file('/home/donghao/Desktop/OP_1.v3draw');
imgsoma = load('np.mat');
imgsoma = imgsoma.array;
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
pythonu = load('pythonu.mat');
pythonu = pythonu.pythonu;
shape = size(imgsoma);
% center = [38, 137, 108];
center = [30, 50, 80];
% shape = [120, 160, 60];
sqradius = 25;



pythonmapslice = load('pythonmapslice.mat');
pythonmapslice = pythonmapslice.pythonmapslice;
firstpythonmapslice = pythonmapslice(1,:,:,:);
firstpythonmapslice = permute(firstpythonmapslice, [4 3 2 1]);
firstpythonmapslice = sum(firstpythonmapslice, 4);
firstpythonmapslice = permute(firstpythonmapslice, [3 2 1]);


secondpythonmapslice = pythonmapslice(2,:,:,:);
secondpythonmapslice = permute(secondpythonmapslice, [4 3 2 1]);
secondpythonmapslice = sum(secondpythonmapslice, 4);
secondpythonmapslice = permute(secondpythonmapslice, [3 2 1]);
[snakegridz, snakegridy, snakegridx]  = meshgrid(1:shape(2), 1:shape(1),  1:shape(3));
snakegridx = snakegridx - 1;
snakegridy = snakegridy - 1;
snakegridz = snakegridz - 1;

samefirstpart = double(firstpythonmapslice) == snakegridy;
samefirstvalue = sum(samefirstpart(:));
samesecondpart = double(secondpythonmapslice) == snakegridz;
samesecondvalue = sum(samesecondpart(:));

testsnakegrid(1, :, :, :) = snakegridy  - center(1);
testsnakegrid(2, :, :, :) = snakegridz  - center(2);
testsnakegrid(3, :, :, :) = snakegridx  - center(3);
% testsnakegrid = testsnakegrid - 1;
testsnakegrid = permute(testsnakegrid, [4 3 2 1]);
% testsnakegrid(:, :, :, 1) = testsnakegrid(:, :, :, 1) - center(1);
% testsnakegrid(:, :, :, 2) = testsnakegrid(:, :, :, 2) - center(2);
% testsnakegrid(:, :, :, 3) = testsnakegrid(:, :, :, 3) - center(3);
% testsnakegrid = testsnakegrid - center;
pythongrid = load('pythongrid.mat');
pythongrid = pythongrid.pythonhrid;
pythongrid = double(pythongrid);
samegrid = pythongrid == testsnakegrid;
samegridvalue = sum(samegrid(:));





u = circlelevelset3d(shape, center, sqradius);
% % u = double(soma);
smoothing = 1;
lambda1 = 1;
lambda2 = 2;
MorphGAC = ACWEinitialise(double(imgsoma), smoothing, lambda1, lambda2);
MorphGAC.u = u;


 %    u = MorphGAC.u;
 %    data = MorphGAC.data;
 %    data = double(data);

 %    inside = u > 0;
 %    outside = u<=0;
 %    doubleoutside = double(outside);
 %    doubleinside = double(inside);
    
 %    dataoutside = data(outside);
 %    datainside = data(inside);

 %    c0 = sum(dataoutside(:)) / sum(doubleoutside(:));
 %    disp(c0);
 %    c1 = sum(datainside(:)) / sum(doubleinside(:));
 %    disp(c1);
 %    % dres = distgradient(u);
 %    % Fx = dres(:,:,:,1);
 %    % Fy = dres(:,:,:,2);
 %    % Fz = dres(:,:,:,3);
 %    [Fx, Fy, Fz] = gradient(u);
 %    pythondres = load('pythondres.mat');
	% pythondres = pythondres.pythondres;
	% Fxpythondres = pythondres(2,:,:,:);
	% Fxpythondres = permute(Fxpythondres, [4 3 2 1]);
	% Fxpythondres = sum(Fxpythondres, 4);
	% Fxpythondres = permute(Fxpythondres, [3 2 1]);
	% samedresx = Fxpythondres == Fx;
	% samedresxvaule = sum(samedresx(:));
	% % figure 
	% % safeshowbox(Fx, 0);
	% % figure
	% % safeshowbox(Fxpythondres, 0);



	% Fypythondres = pythondres(1,:,:,:);
	% Fypythondres = permute(Fypythondres, [4 3 2 1]);
	% Fypythondres = sum(Fypythondres, 4);
	% Fypythondres = permute(Fypythondres, [3 2 1]);
	% samedresy = Fypythondres == Fy;
	% samedresyvaule = sum(samedresy(:));
	% % figure 
	% % safeshowbox(Fy, 0);
	% % figure
	% % safeshowbox(Fypythondres, 0);


	% Fzpythondres = pythondres(3,:,:,:);
	% Fzpythondres = permute(Fzpythondres, [4 3 2 1]);
	% Fzpythondres = sum(Fzpythondres, 4);
	% Fzpythondres = permute(Fzpythondres, [3 2 1]);
	% samedresz = Fzpythondres == Fz;
	% samedreszvaule = sum(samedresz(:));
	% % figure 
	% % safeshowbox(Fz, 0);
	% % figure
	% % safeshowbox(Fzpythondres, 0);

 %    % abs_dres = abs(dres(:,:,:,1)) + abs(dres(:,:,:,2)) + abs(dres(:,:,:,3));
 %    abs_dres = abs(Fx) + abs(Fy) + abs(Fz);
 %    pythonabsdres = load('pythonabsdrse.mat');
 %    pythonabsdres = pythonabsdres.pythonabsdres;
 %    sameabs_dres = abs_dres == pythonabsdres;
 %    sameabsdresvaule = sum(sameabs_dres(:));
 %    firstpart = (data - c1).^2;
 %    firstpart = MorphGAC.lambda1 * firstpart;
 %    secondpart = (data - c0).^2;
 %    secondpart = MorphGAC.lambda2 * secondpart;
 %    aux = double(abs_dres).* (firstpart - secondpart); 
    
 %    pythonaux = load('pythonaux.mat');
 %    pythonaux = pythonaux.pythonaux;
 %    sameaux = abs_dres == pythonabsdres;
 %    sameauxvaule = sum(sameaux(:));
    


 %    res = u;
 %    res(aux < 0) = 1;
 %    res(aux > 0) = 0;
 %    pythonres = load('pythonres.mat');
 %    pythonres = pythonres.pythonres;
 %    sameres = res == pythonres;
 %    sameresvaule = sum(sameres(:));


%%The following code make snake step
% MorphGAC = ACWEstep3d(MorphGAC);

threshold = 0.5;
figure
for i = 1 : 200
	MorphGAC = ACWEstep3d(MorphGAC, i);
	A = MorphGAC.u > threshold;  % synthetic data
	[x y z] = ind2sub(size(A), find(A));
	plot3(y, x, z, 'r.');
	axis([0 shape(3) 0 shape(3) 0 shape(3)])
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


