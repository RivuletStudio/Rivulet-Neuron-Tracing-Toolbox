function tree = showswc(tree, A, ignoreradius)
%tree is N * 7 swc matrix
%This matrix can be obtained using branch2swc function
%radiuslist is the set storing radius
%xlist is the set storing value at x axis
%ylist is the set storing value at y axis
%zlist is the set storing value at z axis
	radiuslist = [];
	xlist =[];
	ylist =[];
	zlist =[];
	[lengthtree useless] = size(tree); 
	for i=1 : lengthtree
	    L=tree(i, :);
        if ignoreradius
            tree(i, 6) = 0.2;
            radiuslist = [1;radiuslist];
        else
			radiuslist = [getradius(A, L(3), L(4), L(5)); radiuslist];
		    tree(i, 6) = getradius(A, L(3), L(4), L(5)) + 3;
		end

	    xlist = [L(3);xlist];
	    ylist = [L(4);ylist];
	    zlist = [L(5);zlist];
	end
	%sphere creates the base sphere
	[x,y,z] = sphere();
	figure
	camlight
	surfl(x,y,z, 'light')  % sphere centered at origin
	hold on
	for i = 1 : numel(xlist)
	surf((radiuslist(i)+3) * y + ylist(i), (radiuslist(i)+3) * x + xlist(i), (radiuslist(i)+3) * z + zlist(i));  
	end
	%The following line  of code can adjust axis ratio of each other
	daspect([1 1 1])
	hold off
end
