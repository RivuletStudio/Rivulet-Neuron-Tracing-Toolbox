function MorphGAC = snakelevelset(MorphGAC, u)
	MorphGAC.u = double(u);
	MorphGAC.u(u > 0) = 1;
	MorphGAC.u(u <= 0) = 0;
end