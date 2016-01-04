function u = IS3d(u, P)
	% img = ones(size(u));
	% padu = padarray(u, [1, 1, 1], 1);
	u = u > 0.5;
	parfor i = 1 : 9
		kernel = P{i} > 0.5;
		aux(:,:,:,i) = imdilate(u, P{i});
		% img = img & aux(:,:,i); 
		% disp(aux(:,:,i))
	end
	u = min(aux, [], 4);
	u = double(u);
	% u = padu(2:end-1, 2:end-1, 2:end-1);
end