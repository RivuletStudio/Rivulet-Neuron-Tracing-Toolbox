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
for i = 1 
	disp(i);
	IND = find(new_remain);
	if isempty(IND)
		break;
	end
	IND = IND(1);
	[I,J,K] = ind2sub(siz,IND);
	[xpoint, ypoint, zpoint, volume, new_remain] = simplemarching3d(new_remain, I, J, K);
end