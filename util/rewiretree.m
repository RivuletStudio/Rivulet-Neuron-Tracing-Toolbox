function newtree = rewiretree(tree, S, I, lconfidence, threshold)
% Rewire the branches when there is a confidence score lower than the threshold, eg. 0.7
	newtree = [];
	assert(numel(S) == numel(lconfidence));

    nodectr = 1; % The tree node should be in the same order with that the branch nodes are traversed
    branchstart = 1; % The start index of the branch in the original tree
    lrewirenodeidx = [];

    newS = {};
	for i = 1 : numel(S)
        l = S{i};
		if lconfidence(i) < threshold 
            % Walk from the outside end and accumulate the confidence
		    lint = int16(l);
		    ind = sub2ind(size(I), lint(:, 1), lint(:, 2), lint(:, 3));
		    vox = I(ind);
	        s = 0;
	        lastoneidx = 1;

	        % Find the largest chunk of zero voxels
	        largestzerostart = 0; % will definitely be replaced by a later voxel since the start point is always nonzero 
	        largestzeroctr = 0;
	        chunkstart = 0;
	        nonzeroctr = 0;
	        for j = 1 : size(l, 1)
	        	if ~vox(j)
	        		if nonzeroctr == 0 
	        			chunkstart = j;
	        		end
                    nonzeroctr = nonzeroctr + 1;
                else
                	if nonzeroctr > largestzeroctr
                		largestzeroctr = nonzeroctr;
                		largestzerostart = chunkstart;
                	end
                	nonzeroctr = 0;
	        	end
	        end

	        l = l(1:largestzerostart, :);
	        newS{i} = l;

            % Delete the rest nodes from the tree
            newtree = [newtree; tree(branchstart : branchstart + size(l, 1) - 1, :), repmat(i, size(l, 1), 1)]; % Additional column to track the branch

            % Change the parent of the last node to the nearest neighbour of the tree
        	lrewirenodeidx = [lrewirenodeidx, size(newtree, 1)];
        else
        	newS{i} = l;
        	newtree = [newtree; tree(branchstart : branchstart + size(l, 1) - 1, :), repmat(i, size(l, 1), 1)]; % Additional column to track the branch
		end
        branchstart = branchstart + size(S{i}, 1);
	end

    % For nodes lost their parents 
    % Find the nesrest neighbour in other branches to connect
    lid = newtree(:, 1);
    lbranch = newtree(:, 8);
    lbrokenbranch = [];
    % Find out the branches with lost parents
    for i = 1 : size(newtree, 1) 
		if ~any(abs(newtree(i, 7)-lid)<1e-10) && newtree(i, 7) ~= -1 % Faster way to see if a number is in array
            lbrokenbranch = [lbrokenbranch, newtree(i, 8)];
		end
    end

    lbrokenbranch = unique(lbrokenbranch);

    for i = 1 : size(newtree, 1) 
		if ~any(abs(newtree(i, 7)-lid)<1e-10) && newtree(i, 7) ~= -1 % Faster way to see if a number is in array
			% Slice tree to obtain nodes in other branches
	    	node2rewire = newtree(i, :);
			ctree = newtree(~ismember(lbranch, lbrokenbranch), :);
	    	d = pdist2(node2rewire(:, 3:5), ctree(:, 3:5));
	    	[~, pidx] = min(d);
	        newtree(i, 7) = ctree(pidx, 1);
		end
	end

    newtree = newtree(:, 1:7);
end