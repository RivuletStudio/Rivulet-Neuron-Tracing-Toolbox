function showbox(varargin)

X = varargin{1};
threshold = varargin{2};


fast = true;
if numel(varargin) >= 3
    fast = varargin{3};
end

endplot = true;
if numel(varargin) >= 4
    endplot = varargin{4};
end

hold on
whitebg(gcf, 'black')
B = X > threshold; 
camlight

if fast
	[x y z] = ind2sub(size(B), find(B));
	plot3(y, x, z, '.', 'Color', [0.7 0.7 1]);  view(3); axis equal;
else
	iso = isosurface(B);
	h = patch(iso, 'facecolor', [0.7 0.7 1], 'facealpha', 0.3, 'edgecolor', 'none');  view(3); axis equal;
end

drawnow

if endplot
	hold off
end

end