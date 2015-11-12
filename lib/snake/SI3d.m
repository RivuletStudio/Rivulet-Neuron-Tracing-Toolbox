function u = SI3d(u, P)
	% padu = padarray(u, [1, 1, 1], 1);
	u = u > 0.5;
	for i = 1 : 9
		kernel = P{i} > 0.5;
		aux(:,:,:,i) = imerode(u, P{i});
		% disp(aux(:,:,i))
		% img = img & aux(:,:,i); 
	end
	u = max(aux, [], 4);
	u = double(u);
	% u = padu(2:end-1, 2:end-1, 2:end-1);
	% u =  max(aux, [], 4);
end