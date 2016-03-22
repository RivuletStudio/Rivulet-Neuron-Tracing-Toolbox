close all
filename = [filesep,'test',filesep,'crop1.mat'];
load(filename);
swc = branch2swc(S, []);
tree = testradius(swc, A);
binarygt = binarysphere(A, tree);
% Show the iso-surface of the vessels
figure
FV = isosurface(A,0.5)
patch(FV,'facecolor',[1 0 0],'facealpha',0.3,'edgecolor','none');
view(3)
%   camlight
% Display the skeleton
hold on;
for i=1:length(S)
	L=S{i};
    plot3(L(:,2),L(:,1),L(:,3),'-','Color',rand(1,3));
end
hold off
figure
hold on
[x y z] = ind2sub(size(A), find(A));
plot3(x, y, z, 'b.')
binarygt = permute(binarygt, [2 1 3]);
binarygt = logical(binarygt);
xorresult = xor(binarygt, A);
remain = xorresult & A;
%figure
[x y z] = ind2sub(size(remain), find(remain));
plot3(x, y, z, 'r.')
hold off
figure
[x y z] = ind2sub(size(remain), find(remain));
plot3(x, y, z, 'r.')
