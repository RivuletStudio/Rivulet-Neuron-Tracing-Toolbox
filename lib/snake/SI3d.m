function u = SI3d(u, P)
	padu = padarray(u, [1, 1, 1]);
	for i = 1 : 4
		aux(:,:,:,i) = imerode(padu, P{i});
		% disp(aux(:,:,i))
		% img = img & aux(:,:,i); 
	end
	padu = max(aux, [], 4);
	u = padu(2:end-1, 2:end-1, 2:end-1); 
end