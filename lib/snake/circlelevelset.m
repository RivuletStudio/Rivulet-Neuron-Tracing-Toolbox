function u = circlelevelset(shape, center, sqradius, scalerow)
	[snakegridy, snakegridx]  = meshgrid(1:shape(2),  1:shape(1));
	snakegridx = snakegridx - 1;
	snakegridy = snakegridy - 1;
	snakegridx = snakegridx - center(1);
	snakegridy = snakegridy - center(2);
	snakegrid(:,:,1) = snakegridx;
	snakegrid(:,:,2) = snakegridy;
	snakegrid = permute(snakegrid, [1, 3, 2]);
	snakegrid = permute(snakegrid, [1, 3, 2]);
	snakegrid = snakegrid.^2;
	snakegrid = sum(snakegrid, 3);
	snakegrid = sqrt(snakegrid);
	phi = sqradius - snakegrid;
	u =  phi > 0;
	u = double(u);
end