function MorphGAC = ACWEinitialise(data, smoothing, lambda1, lambda2)
	MorphGAC.u = [];
	MorphGAC.lambda1 = lambda1;
	MorphGAC.lambda2 = lambda2;
	MorphGAC.smoothing = smoothing;
	MorphGAC.data = data;
end
