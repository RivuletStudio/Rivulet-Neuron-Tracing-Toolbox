function neighours = neighourpoints3d(x, y, z, radius)
	% Return the coordinates of neighours within a radius
	xgv = [(x - radius) : (x + radius)];
	ygv = [(y - radius) : (y + radius)];
	zgv = [(z - radius) : (z + radius)];
	[x, y, z] = meshgrid(xgv, ygv, zgv); % Rectangular grid in 2-D
	neighours = [x(:), y(:), z(:)];

end