function swcradiusplot(tree)
[lengthtree useless] = size(tree); 
%sphere creates the base sphere
[x,y,z] = sphere();
%figure
surf(x,y,z)  % sphere centered at origin
hold on
for i=1 : lengthtree
surf( ((tree(i, 6) + 3) * x + tree(i, 3)), ((tree(i, 6)+3) * y + tree(i, 4)), ((tree(i, 6)+3) * z + tree(i, 5)) );  
end
%The following line  of code can adjust axis ratio of each other
daspect([1 1 1])
hold off
end