function [tree, confidence] = addbranch2tree(tree, l, radius, I)
% Add a branch with 3D points to a swc tree
% Return the result swc tree and the confidence score of the newly added branch

    % Get the voxels on this branch and count the empty voxels 
    lint = int16(l);
    ind = sub2ind(size(I), lint(:, 1), lint(:, 2), lint(:, 3));
    vox = I(ind);
    confidence = sum(vox)/numel(vox);

    % Get rid of the noise points 
    if confidence < 0.5
        s = 0;
        lastoneidx = numel(vox);

    	for i = numel(vox) : -1 : 1
			if vox(i)
                lastoneidx = i;
			end

			s = s + vox(i);
			p = s / i;
            if p < 0.9
                l = l(end:lastoneidx, :);
                break;
            end
    	end

    	radius = radius(end:lastoneidx);
    end

    if size(l, 1) < 4
    	return;
    end

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