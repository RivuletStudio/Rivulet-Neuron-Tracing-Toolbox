function u = SI(u, P)
	% img = zeros(size(u));
	% for i = 1 : 4
	% 	aux(:,:,i) = imerode(u, P{i});
	% 	img = img | aux(:,:,i); 
	% end
	% u = img;
	% size(u)
	padu = padarray(u, [1, 1]);
	for i = 1 : 4
		aux(:,:,i) = imerode(padu, P{i});
		% disp(aux(:,:,i))
		% img = img & aux(:,:,i); 
	end
	padu = max(aux, [], 3);
	u = padu(2:end-1, 2:end-1); 
end 
% function u = SI(u, P)
% 	img = zeros(size(u));
% 	for i = 1 : 4
% 		aux(:,:,i) = imerode(u, P{i});
% 		img = img | aux(:,:,i); 
% 	end
% 	u = img;
% end