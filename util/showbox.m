function showboI(varargin)

I = varargin{1};
threshold = varargin{2};

fast = true;
if numel(varargin) >= 3
    fast = varargin{3};
end

endplot = true;
if numel(varargin) >= 4
    endplot = varargin{4};
end

black = 1;
if numel(varargin) >= 5
    black = varargin{5};
end

hold on

if black
    whitebg(gcf, 'black');
else
    whitebg(gcf, 'white');
end

set(gcf,'Color',[0.3137 0.3137 0.3137])
B = I > threshold;


if fast
	[x y z] = ind2sub(size(B), find(B));
	plot3(y, x, z, '.', 'Color', [0.7 0.7 1]);  view(3); axis equal;
else
% 	iso = isosurface(B);
% 	h = patch(iso, 'facecolor', [0.7 0.7 1], 'facealpha', 0.3, 'edgecolor', 'none');  view(3); aIis equal;
    camlight(camlight('headlight'),'headlight')
    I = double(I);
    [f,v] = isosurface(B);
    intv = round(v);
    indeIv = sub2ind(size(I), intv(:,2), intv(:,1), intv(:,3));
    colors = I(indeIv);
%     colors = colors ./ max(colors);
%     green = zeros(numel(colors), 3);
%     green(:,3)=colors;
    patch('Faces',f, 'Vertices', v,...
          'FaceVertexCData', colors,...
          'EdgeColor', 'none',...
          'AmbientStrength', 0.5);
%     colorbar
    axis equal
    alpha color
    alpha scaled
end

drawnow

if endplot
	hold off
end

end