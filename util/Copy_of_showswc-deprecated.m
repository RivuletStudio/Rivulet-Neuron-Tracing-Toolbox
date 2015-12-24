function tree = showswc(varargin)
%tree is N * 7 swc matrix
%This matrix can be obtained using branch2swc function
%radiuslist is the set storing radius
tree = varargin{1};

endplot = true;
if numel(varargin) >= 2
	endplot = varargin{2};
end

[x,y,z] = sphere();
camlight('headlight')
colormap([0.7 0.7 1]);
surfl(x,y,z, 'light')  % sphere centered at origin
hold on
for i = 1 : size(tree, 1)
    surf(tree(i,6) * y + tree(i, 4), tree(i,6) * x + tree(i, 3), tree(i,6) * z + tree(i, 5),...
        'FaceColor','interp','FaceLighting','gouraud', 'EdgeColor','none');
end
%The following line  of code can adjust axis ratio
daspect([1 1 1])
if endplot
	hold off
end

end

