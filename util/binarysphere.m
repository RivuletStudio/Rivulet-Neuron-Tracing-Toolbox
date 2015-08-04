function binarygt = binarysphere(originalimg, tree)
%tree is the  swc matrix and the dimension of this matrix is N * 7
%originalimg is the original 3D image stack
figure
[M, N, Z] = size(originalimg);
%Initialize the 3d binary matrix with zeros 
binarygt = (zeros(M, N, Z));
[lengthtree useless] = size(tree); 
for i = 1 : lengthtree
    xlist = [];
	ylist = [];
	zlist = [];
	[xlist, ylist, zlist] = spherepoint(tree(i, 3), tree(i, 4), tree(i, 5), (tree(i, 6)));
	for j = 1 : numel(xlist)
		%Test point is within valid range assign fore ground voxel to true
		if ((xlist(j)<M) && (xlist(j)>0) && (ylist(j)<N) && (ylist(j)>0)...
		 && (zlist(j)<Z) && (zlist(j)>0))  
			binarygt(xlist(j), ylist(j), zlist(j)) = 1;
		end
	end
end
[x y z] = ind2sub(size(binarygt), find(binarygt));
plot3(x, y, z, 'b.')
end