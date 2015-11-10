function u = IS3d(u, P)
	% img = ones(size(u));

	for i = 1 : 9
		aux(:,:,:,i) = imdilate(u, P{i});
		% img = img & aux(:,:,i); 
		% disp(aux(:,:,i))
	end
	u = min(aux, [], 4);
end