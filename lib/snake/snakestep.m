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
	[el1, el2] = imgradientxy(res);
	aux = aux + el1.*dgI(:,:,1);
	aux = aux + el2.*dgI(:,:,2);
	res(aux > 0) = 1;
    res(aux < 0) = 0;
	
	% seastar
	% res = SI(res, P2);
	% res = IS(res, P2);    
	% res = SI(res, P2);

	% nodule
	% res = IS(res, P2);    
	
	MorphGAC.u = res;

end
