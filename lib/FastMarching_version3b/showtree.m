function showtree(figid, img, branches)
% Show the iso-surface of the vessels
figure(figid),

if numel(img) ~= 0
    FV = isosurface(img,0.5)
    patch(FV,'facecolor',[1 0 0],'facealpha',0.3,'edgecolor','none');
    
end
view(3)

%   camlight

% Display the skeleton
hold on;
for i= 1:length(branches)
	L=branches{i};
	if numel(L) == 0
		continue
	end
	plot3(L(:,2),L(:,1),L(:,3),'-','Color',rand(1,3));
end
  
end