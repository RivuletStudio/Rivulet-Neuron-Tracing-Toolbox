%function Frozen = simplemarching3d(I, startx, starty, startz)
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
function Frozen = simplemarching3d(I, startx, starty, startz, sz, iter)
%hold on
% The following four lines are used to create cross shape neighbouring pixels
% pixels are at boundary condition shold be considered in 3d version of simplemarching

ne =[-1  0  0;
      1  0  0;
      0 -1  0;
      0  1  0;
      0  0 -1;
      0  0  1];
% Initialise the starting process       
dx = startx;
dy = starty;
dz = startz;
ctr = 1;
% hold on
% showbox(I, 0.5)
% Forzen is binary image which records the marched process
Frozen = zeros(size(I));
% Initialise the neighbouring points with starting point
neg_list = [startx, starty, startz];
neg_list_old = [startx, starty, startz];
Frozen(startx, starty, startz) = 1;
% Initialise the number of neighbouring points
negnum = 1;
for i = 1 : iter
	neg_list = [];
	% fprintf('this is marching step %d\n', uint8(i));
	for negnum_i = 1 : negnum 
		dx = neg_list_old(negnum_i, 1);
		dy = neg_list_old(negnum_i, 2);
		dz = neg_list_old(negnum_i, 3);
		for ne_i = 1 : 6
			x = ne(ne_i, 1) + dx;
			y = ne(ne_i, 2) + dy;
			z = ne(ne_i, 3) + dz;
			x = constrain(x, 1, sz(1));
			y = constrain(y, 1, sz(2));
			z = constrain(z, 1, sz(3)); 
			binaryvalue = I(x, y, z);
			%Check this pixel is true value in the input binary image and we have not visited it yet
			if (binaryvalue == 1)&&(Frozen(x, y, z) == 0)
			neg_list(ctr, 1) = x;
			neg_list(ctr, 2) = y;
			neg_list(ctr, 3) = z;
			Frozen(x, y, z) = 1;
			ctr = ctr + 1;
			%Uncomment these two lines if you want to view the marching process
			% plot3(x, y, z, 'g.')
			% pause(0.001)
			end
		end
	end
	% Make points in the neighbouring points are not redundant  
	neg_list = unique(neg_list, 'rows');
	neg_list_old = neg_list;
	% There are no more new pixels, so it is the right time to stop
	if ctr == 1
		break;
	end
	ctr = 1;
	[negnum useless] = size(neg_list);
end
% hold off 
% uncomment the above is you want to visualise the marching process 

% The following code is used to calculate centroid
% It seems that we do not need them at this moment
% new_remain = I - Frozen;
% Frozenind = find(Frozen);
% [indx, indy, indz] = ind2sub(size(Frozen), Frozenind);
% xcenter = sum(indx(:))/numel(indx);
% ycenter = sum(indy(:))/numel(indx);
% zcenter = sum(indz(:))/numel(indx);
% volume = sum(Frozen(:));

end