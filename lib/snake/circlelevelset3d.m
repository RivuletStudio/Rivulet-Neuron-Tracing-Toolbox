function u = circlelevelset3d(shape, center, sqradius)
	[snakegridz, snakegridy, snakegridx]  = meshgrid(1:shape(2), 1:shape(1),  1:shape(3));
	
	% snakegridx = snakegridx - 1;
	% snakegridy = snakegridy - 1;
	% snakegridz = snakegridz - 1;
	% snakegridx = snakegridx - center(1);
	% snakegridy = snakegridy - center(2);
	% snakegridz = snakegridz - center(3);
	% snakegrid(:, :, :, 1) = snakegridx;
	% snakegrid(:, :, :, 2) = snakegridy;
	% snakegrid(:, :, :, 3) = snakegridz;
	% % size(snakegrid)
	% snakegrid = permute(snakegrid, [3 4 2 1]);
	% snakegrid = permute(snakegrid, [4 3 2 1]);
	% snakegrid = snakegrid.^2;
	% snakegrid = permute(snakegrid, [1 2 4 3]);
	% snakegrid = sum(snakegrid, 4);
	% snakegrid = sqrt(snakegrid);
	% phi = sqradius - snakegrid;
	% u =  phi > 0;
	% u = double(u);

	testsnakegrid(1, :, :, :) = snakegridy  - center(1);
	testsnakegrid(2, :, :, :) = snakegridz  - center(2);
	testsnakegrid(3, :, :, :) = snakegridx  - center(3);
	testsnakegrid = permute(testsnakegrid, [4 3 2 1]);
	testsnakegrid = testsnakegrid.^2;
	testsnakegrid = sum(testsnakegrid, 4);
	testsnakegrid = sqrt(testsnakegrid);
	phi = sqradius - testsnakegrid;
	u =  phi > 0;
	u = double(u);
	u = permute(u, [3 2 1]);
end