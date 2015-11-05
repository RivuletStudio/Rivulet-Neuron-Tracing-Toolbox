function u = curvop(u, P, iter)
	for i = 1 : iter
		u = SIoIS(u, P);
		% u = ISoSI(u, P);
	end
end