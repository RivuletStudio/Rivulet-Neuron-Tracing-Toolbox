%function Frozen = simplemarching3d(inputMatrix, input_x, input_y, input_z)
%SIMPLEMARCHING Summary of this function goes here
%   Detailed explanation goes here
% input_x and input_y define the location of sourcepoint or you may call it starting point
% inputMatrix is wall image used for marching 
% The following code shows how to use simplemarching function 
% assume you already add fish head folder to the path and test image is in the test folder  
% image = imread('binary.png');
% gray= rgb2gray(image);
% bw= im2bw(gray);
% figure
% imshow(bw)
% marchpath = simplemarching(bw, 168, 206)
% The following line is for marching process visulisation uncomment it if you need

% function [xcenter, ycenter, zcenter, volume, new_remain] = simplemarching3d(inputMatrix, input_x, input_y, input_z)
function Frozen = simplemarching3d(inputMatrix, input_x, input_y, input_z, sz)
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
I_col = input_x;
I_row = input_y;
I_stack = input_z;
curposx = I_col;
curposy = I_row;
curposz = I_stack;
counter = 1;
curvalue = 0;
% hold on
% showbox(inputMatrix, 0.5)
% Forzen is binary image which records the marched process
Frozen = zeros(size(inputMatrix));
% Initialise the neighbouring points with starting point
neg_list = [I_col, I_row, I_stack];
neg_list_old = [I_col, I_row, I_stack];
Frozen(I_col, I_row, I_stack) = 1;
% Initialise the number of neighbouring points
negnum = 1;
for i = 1 : 5  
	neg_list = [];
	% fprintf('this is marching step %d\n', uint8(i));
	for negnum_i = 1 : negnum 
	curposx = neg_list_old(negnum_i, 1);
	curposy = neg_list_old(negnum_i, 2);
	curposz = neg_list_old(negnum_i, 3);
		for ne_i = 1 : 6
			xindex = ne(ne_i, 1) + curposx;
			yindex = ne(ne_i, 2) + curposy;
			zindex = ne(ne_i, 3) + curposz;
			xindex = constrain(xindex, 1, sz(1));
			yindex = constrain(yindex, 1, sz(2));
			zindex = constrain(zindex, 1, sz(3)); 
			binaryvalue = inputMatrix(xindex, yindex, zindex);
			%Check this pixel is true value in the input binary image and we have not visited it yet
			if (binaryvalue == 1)&&(Frozen(xindex, yindex, zindex) == 0)
			neg_list(counter, 1) = xindex;
			neg_list(counter, 2) = yindex;
			neg_list(counter, 3) = zindex;
			Frozen(xindex, yindex, zindex) = 1;
			counter = counter + 1;
			%Uncomment these two lines if you want to view the marching process
			% plot3(xindex, yindex, zindex, 'g.')
			% pause(0.001)
			end
		end
	end
	% Make points in the neighbouring points are not redundant  
	neg_list = unique(neg_list,'rows');
	neg_list_old = neg_list;
	% There are no more new pixels, so it is the right time to stop
	if counter == 1
		break;
	end
	counter = 1;
	[negnum useless] = size(neg_list);
end
% hold off 
% uncomment the above is you want to visualise the marching process 

% The following code is used to calculate centroid
% It seems that we do not need them at this moment
% new_remain = inputMatrix - Frozen;
% Frozenind = find(Frozen);
% [indx, indy, indz] = ind2sub(size(Frozen), Frozenind);
% xcenter = sum(indx(:))/numel(indx);
% ycenter = sum(indy(:))/numel(indx);
% zcenter = sum(indz(:))/numel(indx);
% volume = sum(Frozen(:));

end