function [Frozen, Label]= simplemarching(I, startx, starty)
%SIMPLEMARCHING Summary of this function goes here
%   Detailed explanation goes here
% ne =[-1  0  0;
%       1  0  0;
%       0 -1  0;
%       0  1  0;
%       0  0 -1
%       0  0  1];
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
% hold on
% The following four lines are used to create cross shape neighbouring pixels
% pixels are at boundary condition shold be considered in 3d version of simplemarching
ne = [-1  0;
       1  0;
       0 -1;
       0  1;];
% Initialise the starting process       
% I_col = startx;
% I_row = starty;
% dx = I_col;
% dy = I_row;
counter = 1;
curvalue = 0;

% Forzen is binary image which records the marched process
Frozen = zeros(size(I));
Label = zeros(size(I));
% Initialise the neighbouring points with starting point
neg_list = zeros(1000,2);
neg_list(1,1) = startx;
neg_list(2,1) = starty;
neg_list_old = [startx, starty];


% Initialise the number of neighbouring points
negnum = 1;
while(true)  
%	neg_list = [];
	for negnum_i = 1 : negnum 
		dx = neg_list_old(negnum_i, 1);
		dy = neg_list_old(negnum_i, 2);
		for ne_i = 1 : 4
			x = ne(ne_i, 1) + dx;
			y = ne(ne_i, 2) + dy;

			%Check this pixel is true value in I and we have not visited it yet
			if I(x, y) && ~Frozen(x, y)
				neg_list(counter, 1) = x;
				neg_list(counter, 2) = y;
				Frozen(x, y) = 1;
				Label(x, y) = i;
				counter = counter + 1;
				%Uncomment these two lines if you want to view the marching process
				%plot(y, x, 'r.')
				%pause(0.01);
	            %drawnow
			end
		end
	end
	% Make points in the neighbouring points are not redundant  
	neg_list_old = neg_list(1:counter-1, :);
	neg_list_old = unique(neg_list_old,'rows');

	% Stop when no more new pixels to discover
	if counter == 1
		break;
	end
	
	counter = 1;
	[negnum useless] = size(neg_list_old);
end
% hold off 
% uncomment the above is you want to visualise the marching process 