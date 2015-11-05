function u = SI(u, P)
	img = zeros(size(u));
	for i = 1 : 4
		aux(:,:,i) = imerode(u, P{i});
		img = img | aux(:,:,i); 
	end
	u = img;
end 
% function u = SI(u, P)
% 	img = zeros(size(u));
% 	for i = 1 : 4
% 		aux(:,:,i) = imerode(u, P{i});
% 		img = img | aux(:,:,i); 
% 	end
% 	u = img;
% end