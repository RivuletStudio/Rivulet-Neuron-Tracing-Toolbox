function MorphGAC = snakeupdatemask(MorphGAC)
	MorphGAC.thresholdmask = MorphGAC.data > MorphGAC.theta;
	MorphGAC.thresholdmaskv = MorphGAC.data > (MorphGAC.theta / abs(MorphGAC.v));
end