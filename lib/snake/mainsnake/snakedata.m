function MorphGAC = snakedata(MorphGAC, data)
	MorphGAC.data = data;
	size(data)
	
	[MorphGAC.ddata(:,:,1), MorphGAC.ddata(:,:,2)] = imgradientxy(data);
	MorphGAC = snakeupdatemask(MorphGAC);
	snakedimension = ndims(data);
	if snakedimension == 2
		MorphGAC.structure = ones(3, 3);
	else
		MorphGAC.structure = ones(3, 3, 3);
	end
end