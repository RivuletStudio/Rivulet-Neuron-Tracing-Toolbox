close all
clc
clear all
binarytest;
inputMatrix = remain;
input_x = 202;
input_y = 307;
input_z = 11;
siz = size(inputMatrix);
tic
[xpoint, ypoint, zpoint, volume, new_remain] = simplemarching3d(inputMatrix, input_x, input_y, input_z);
toc
xpointlist = zeros(10000);
ypointlist = zeros(10000);
zpointlist = zeros(10000);
volumelist = zeros(10000);

for i = 1 : 10000
	disp(i);
	IND = find(new_remain);
	if isempty(IND)
		break;
	end
	IND = IND(1);
	[I,J,K] = ind2sub(siz,IND);
	[xpoint, ypoint, zpoint, volume, new_remain] = simplemarching3d(new_remain, I, J, K);
	xpointlist(i) = xpoint;
	ypointlist(i) = ypoint;
	zpointlist(i) = zpoint;
	volumelist(i) = volume;
	counter = i;
end
xpointlist(counter+1:end) = [];
ypointlist(counter+1:end) = [];
zpointlist(counter+1:end) = [];
volumelist(counter+1:end) = [];