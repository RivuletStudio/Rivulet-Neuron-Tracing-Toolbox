function u = IS(u, P)
	img = zeros(size(u));
	for i = 1 : 4
		aux(:,:,i) = imerode(u, P{i});
		img = img | aux(:,:,i); 
	end
	u = img;
end
% function u = IS(u, P)
% 	img = ones(size(u));
% 	for i = 1 : 4
% 		aux(:,:,i) = imdilate(u, P{i});
% 		img = img & aux(:,:,i); 
% 	end
% 	u = img;
% end 