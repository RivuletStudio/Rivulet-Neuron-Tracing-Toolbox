function MorphGAC = snakestep(MorphGAC)
	global P2
	u = MorphGAC.u;
	gI = MorphGAC.data;
	dgI = MorphGAC.ddata;
	theta = MorphGAC.theta;
	v = MorphGAC.v;
	res = u;
	if v > 0
		aux = imdilate(u, MorphGAC.structure);
	elseif v < 0
		aux = imerode(u, MorphGAC.structure);
	end
	if v~=0
		res(MorphGAC.thresholdmaskv) = aux(MorphGAC.thresholdmaskv);
	aux = zeros(size(res));
	% disp(size(aux));
	[el1, el2] = imgradientxy(res);
	% disp(size(el1));
	aux = aux + el1.*dgI(:,:,1);
	aux = aux + el2.*dgI(:,:,2);
	res(aux > 0) = 1;
    res(aux < 0) = 0;
    res = curvop(res, P2, MorphGAC.smoothing);
	MorphGAC.u = res;

end
