function binarygt = binarysphere2d(sz, pts, radius)
% Generate a mask with 2d spheres to cover a list of 2d points 
% sz: the size of the original image
% pts: a list of 2d point coordinates < N * D>
% radius: a list of radius corresponding to the pts

%Initialize the 2d binary matrix with zeros 
binarygt = logical(zeros(sz));
for i = 1 : size(pts, 1) 
	neighbours = neighourpoints2d(pts(i, 1), pts(i, 2), radius(i));
	neighbours(:, 1) = constrain(neighbours(:, 1), 1, sz(1));
	neighbours(:, 2) = constrain(neighbours(:, 2), 1, sz(2));
	ind = sub2ind(sz, int16(neighbours(:, 1)), int16(neighbours(:, 2)));
	binarygt(ind) = 1;
end

end

function neighours = neighourpoints2d(x, y, radius)
% Return the coordinates of neighours within a radius
xgv = [(x - radius) : (x + radius)];
ygv = [(y - radius) : (y + radius)];
[x, y] = meshgrid(xgv, ygv); % Rectangular grid in 2-D
neighours = [x(:), y(:)];
end