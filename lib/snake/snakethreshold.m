function MorphGAC = snakethreshold(MorphGAC, theta)
	MorphGAC.theta = theta;
	MorphGAC = snakeupdatemask(MorphGAC);
end