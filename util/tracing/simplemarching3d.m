%function seedmask = simplemarching3d(I, startx, starty, startz)
%SIMPLEMARCHING Summary of this function goes here
%   Detailed explanation goes here
% startx and starty define the location of sourcepoint or you may call it starting point
% I is wall image used for marching 
% The following code shows how to use simplemarching function 
% assume you already add fish head folder to the path and test image is in the test folder  
% image = imread('binary.png');
% gray= rgb2gray(image);
% bw= im2bw(gray);
% figure
% imshow(bw)
% marchpath = simplemarching(bw, 168, 206)
% The following line is for marching process visulisation uncomment it if you need

% function [xcenter, ycenter, zcenter, volume, new_remain] = simplemarching3d(I, startx, starty, startz)
function seedmask = simplemarching3d(I, seedmask, iter)
%hold on
% The following four lines are used to create cross shape neighbouring pixels
% pixels are at boundary condition shold be considered in 3d version of simplemarching

sz = size(I);
ne =[-1  0  0;
      1  0  0;
      0 -1  0;
      0  1  0;
      0  0 -1;
      0  0  1];
% Initialise the starting process       
% hold on
% showbox(I, 0.5)
% Initialise the neighbouring points with starting point
ind = find(seedmask);
[startx, starty, startz] = ind2sub(size(I), ind);
nlist1 = [startx, starty, startz];


% Initialise the number of neighbouring points
for i = 1 : iter % Iterations
	% fprintf('iter: %d\n', i);
	nlist2 = [];

	for j = 1 : size(nlist1, 1) % Iterate boundary voxels 
		% x = nlist1(j, 1); y = nlist1(j, 2); z = nlist1(j, 3);
		K = repmat(nlist1(j, :), 6, 1) + ne;
		K(:, 1) = constrain(K(:, 1), 1, sz(1));
		K(:, 2) = constrain(K(:, 2), 1, sz(2));
		K(:, 3) = constrain(K(:, 3), 1, sz(3)); 
        kind = sub2ind(size(I), K(:, 1), K(:, 2), K(:, 3));
		add = I(kind) & ~seedmask(kind);
		nlist2 = [nlist2; K(add, :)];
        ind2add = sub2ind(size(I), K(add, 1), K(add, 2), K(add, 3));
        seedmask(ind2add) = 1;

		% for k = 1 : 6 % Iterate Kernel
		% 	kx = ne(k, 1) + x; ky = ne(k, 2) + y; kz = ne(k, 3) + z;
		% 	kx = constrain(kx, 1, sz(1));
		% 	ky = constrain(ky, 1, sz(2));
		% 	kz = constrain(kz, 1, sz(3)); 

		% 	% Check this voxel is positive in I and has not been visited
		% 	if I(kx, ky, kz) & ~seedmask(kx, ky, kz)
		% 		% Add this new position to the neighbour list in new iteration 
		% 		nlist2(nctr, 1) = x;
		% 		nlist2(nctr, 2) = y;
		% 		nlist2(nctr, 3) = z;
		% 		seedmask(kx, ky, kz) = 1;
		% 		nctr = nctr + 1;
		% 	%Uncomment these two lines if you want to view the marching process
		% 	% plot3(x, y, z, 'g.')
		% 	% pause(0.001)
		% 	end
		% end
	end

	% Make points in the neighbouring points are not redundant  
	% nlist2 = unique(nlist2, 'rows'); % Might not be nessensary
	nlist1 = nlist2; % Refresh the neighbour list to the new generation

	% There are no more new pixels, so it is the right time to stop
	if size(nlist1, 1) == 0
		break;
	end
end

% hold off 
% uncomment the above is you want to visualise the marching process 

% The following code is used to calculate centroid
% It seems that we do not need them at this moment
% new_remain = I - seedmask;
% seedmaskind = find(seedmask);
% [indx, indy, indz] = ind2sub(size(seedmask), seedmaskind);
% xcenter = sum(indx(:))/numel(indx);
% ycenter = sum(indy(:))/numel(indx);
% zcenter = sum(indz(:))/numel(indx);
% volume = sum(seedmask(:));

end