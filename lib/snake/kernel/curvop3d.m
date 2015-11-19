function u = curvop3d(u, P, iter)
	for i = 1 : iter
		u = SIoIS3d(u, P);
		u = ISoSI3d(u, P);
	end
end