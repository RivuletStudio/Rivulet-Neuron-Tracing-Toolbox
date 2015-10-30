function MorphGAC = snakeinitialise(gI, smoothing, threshold, ballon)
	MorphGAC.u = [];
	MorphGAC.v = ballon;
	MorphGAC.theta = threshold;
	MorphGAC.smoothing = smoothing;
	MorphGAC.data = gI;
	[MorphGAC.ddata(:, :, 1), MorphGAC.ddata(:, :, 2)]  = imgradientxy(gI);
	% MorphGAC.structure
end 