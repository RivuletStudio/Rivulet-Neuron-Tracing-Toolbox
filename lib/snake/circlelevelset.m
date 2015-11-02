function u = circlelevelset(shape, center, sqradius, scalerow)
	snakegrid = meshgrid(1:shape(1),  1:shape(2));
	snakegrid = transpose(snakegrid);
	snakegrid = snakegrid - center;
	snakegrid = transpose(snakegrid);
	snakegrid = snakegrid.^2;
	snakegrid = sum(snakegrid, 3);
end