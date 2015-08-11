function tree = addbranch2tree(tree, l, radius)
	% Add a branch with 3D points to a swc tree
	assert(size(l, 1) == size(radius, 1));
	newtree = zeros(size(l, 1), 7);
	if size(tree, 1) == 0
		newtree(:, 1) = 1 : size(l, 1);
		newtree(:, 2) = 2;
		newtree(:, 3:5) = l;
		newtree(:, 6) = radius;
		newtree(1:end-1, 7) = newtree(2:end, 1);
		newtree(end, 7) = -1;
		tree = newtree;
	else
		termini = l(end, :);
		treenodes = tree(:, 3:5);
        
        % Get pairwise distance between the termini and tree nodes 
        d = pdist2(termini, treenodes);
        [~, idx] = min(d);

        % Sort internal relationship
		newtree(:, 1) = tree(end, 1) + 1 : tree(end, 1) + size(l, 1);
		newtree(:, 2) = 2;
		newtree(:, 3:5) = l;
		newtree(:, 6) = radius;
		newtree(1:end-1, 7) = newtree(2:end, 1);
		newtree(end, 7) = tree(idx, 1); % Connect to the tree parent
		tree = [tree; newtree];
	end
end