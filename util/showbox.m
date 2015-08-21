function showbox(varargin)
X = varargin{1};
threshold = varargin{2};
endplot = true;
if numel(varargin) >= 3
    endplot = varargin{3};
end
hold on
whitebg(gcf, 'black')
biA = X > threshold; 
camlight;
iso = isosurface(biA);
h = patch(iso, 'facecolor',[0.7 0.7 1],'facealpha',0.3,'edgecolor','none');  view(3); axis equal;
drawnow
if endplot
	hold off
end
end