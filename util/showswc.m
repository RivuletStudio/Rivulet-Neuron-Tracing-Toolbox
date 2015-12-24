function tree = showswc(varargin)
%tree is N * 7 swc matrix
%This matrix can be obtained using branch2swc function
%radiuslist is the set storing radius
tree = varargin{1};

endplot = true;
if numel(varargin) >= 2
	endplot = varargin{2};
end
whitebg(gcf, 'black')
colormap([0.7 0.7 1]);

hold on
for i = 1 : size(tree, 1)
    % Draw a line between the current node and its parent
    cnode = tree(i, 3:5);
    parent = tree(i, 7);
    [pidx] = find(tree(:, 1) == parent);
    if numel(pidx) == 1
        pnode = tree(pidx, 3:5);
        plot3([cnode(1);pnode(1)], [cnode(2);pnode(2)], [cnode(3); pnode(3)],...
              'Color', [0.8 0 0]);
    end
end
%The following line  of code can adjust axis ratio
daspect([1 1 1])
if endplot
	hold off
end

end

