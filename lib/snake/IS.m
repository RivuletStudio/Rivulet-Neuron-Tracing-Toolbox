function u = IS(u, P)
	% img = ones(size(u));
	for i = 1 : 4
		aux(:,:,i) = imdilate(u, P{i});
		% img = img & aux(:,:,i); 
		% disp(aux(:,:,i))
	end
	u = min(aux, [], 3);
end
% function u = IS(u, P)
% 	img = ones(size(u));
% 	for i = 1 : 4
% 		aux(:,:,i) = imdilate(u, P{i});
% 		img = img & aux(:,:,i); 
% 	end
% 	u = img;
% end 