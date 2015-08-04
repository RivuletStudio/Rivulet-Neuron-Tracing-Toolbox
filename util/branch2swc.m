function [tree] = branch2swc(S, filename)
% Convert branchpoints cellarrays to swc tree
% S: cell array of branch points, each cell with size N * 3
% filename: the filename to save the swc file, if empty, the file will not be saved

    % Take the first node of the first branch as the root
    nbranch = numel(S);
    B = {};

    id = 1;
    % Assign an ID to each node
    for i = 1 : nbranch
        b = S{i};
        idb = zeros(size(b, 1), size(b, 2) + 1);
        idb(:, 1:3) = b;

        for j = 1 : size(b, 1) 
	        idb(j, 4) = id;
	        id = id + 1;
	    end

	    B{i} = idb;
    end

    Bcopy = B;
    trees = {};
    subtreeterminis = {};
	branchidx = find(~cellfun(@isempty,B));

    subtreectr = 1;
    while numel(branchidx) > 0
	    subtrees = {};
	    % disp('Looking for subtree in ');
	    % disp(branchidx);
	    parent = B{branchidx(1)};
	    parent = parent(1, :);
	    terminis = [];
 	    terminis = [terminis;parent];
	    [subtree, B, terminis] = addchirldren(B, parent, 0, terminis);
	    subtrees = [subtrees, subtree];
        subtreeterminis = [subtreeterminis, terminis];
		branchidx = find(~cellfun(@isempty,B));

		%tree = [parent(4), 2, parent(1), parent(2), parent(3), 1, -1];
        tree = [];
		% Combine the subtrees
		for i = 1 : numel(subtrees)
            tree = [tree; subtrees{i}];
        end
        
        tree = [parent(4), 2, parent(2), parent(1), parent(3), 1, -1; tree];

		trees = [trees, tree];
		disp(size(tree, 1))
        % showtree(subtreectr, A, Bcopy(find(~cellfun(@isempty,B))));
        subtreectr = subtreectr + 1;
    end

	% Connect each branch tree
	subtreeidx = find(~cellfun(@isempty,trees));
	parenttree = trees{subtreeidx(1)};
	rt = subtreeterminis{1};
	while numel(subtreeidx) > 1
        minst = Inf;
		for i = 2 : numel(subtreeidx)
			% Calculate pairwise distances and find the tree with a termini of the smallest distance TODO
			st = subtreeterminis{subtreeidx(i)};
			nexttree = trees{i};
            d = pdist2(parenttree(:, 3:5), nexttree(:, 3:5));
            [mind, I1] = min(d);
            [mt, I2] = min(mind);
            I1 = I1(I2);
            if mt < minst
                minst = mt;	
            end

            minidx = i;
            minI1 = I1;
            minI2 = I2;
		end

		% Pick the smallest distance with any of the termini of the first tree and connect them
		mintree = trees{minidx};
		mintree(minI2, 7) = parenttree(minI1, 1);
	    parenttree = [parenttree; mintree(2:end, :)];
	    % rt(minI1, :) = []; % Remove the connected terminis from the termnis of the first tree
		subtreeidx(minidx) = []; % Remove the tree being connected from the subtreeidx
	end

    tree = parenttree;
    if numel(filename) == 0
        return
    end

    fprintf('Saving to %s\n', [filename, '.swc']);
    save_v3d_swc_file(tree, [filename, '.swc']);
end


function [subtree, B, terminis] = addchirldren(B, parent, parentidx, terminis)
	subtree = {};
	subtreeidx = 1;
    
    % Look for the direct chirldren branchs
    for i = 1 : numel(B)
    	b = B{i};
    	if numel(b) == 0
    		continue
    	end

    	if b(1, 1:3) == parent(1:3) % Normal order
    		% fprintf('parent %d found child at: %d\n', parentidx, i);
		    % Add each chirldren branch to swc
            t = zeros(size(b, 1) - 1, 7);
            t(:, 1) = b(2:end, 4);
            t(:, 2) = 2;
            t(:, 3) = b(2:end, 2);
            t(:, 4) = b(2:end, 1);
            t(:, 5) = b(2:end, 3);
            t(:, 6) = 1;
            t(2:end, 7) = b(2:end-1, 4);
            t(1, 7) = parent(4);

            B{:,i} = [];
		    % Recursively add the descendents branches to swc tree
            [childrentree, B, terminis] = addchirldren(B, b(end, :), i, terminis);
            subtree = [subtree, t, childrentree];
	        if numel(childrentree) == 0
	        	terminis = [terminis; b(end, : )];
	        	% disp('termnis update')
	        	% disp(terminis)
	        end

        elseif b(end, 1:3) == parent(1:3) % Reversed order
    		% fprintf('parent %d found child at: %d Reversed\n', parentidx, i);
            % reverse permute b 
            reverseidx = size(b, 1) : -1 : 1;
            b = b(reverseidx, :);

		    % Add each chirldren branch to swc
            t = zeros(size(b, 1) - 1, 7);
            t(:, 1) = b(2:end, 4);
            t(:, 2) = 2;
            t(:, 3) = b(2:end, 2);
            t(:, 4) = b(2:end, 1);
            t(:, 5) = b(2:end, 3);
            t(:, 6) = 1;
            t(2:end, 7) = b(2:end-1, 4);
            t(1, 7) = parent(4);

            B{:,i} = [];
		    % Recursively add the descendents branches to swc tree
            [childrentree, B, terminis] = addchirldren(B, b(end, :), i, terminis);
            subtree = [subtree, t, childrentree];
	        if numel(childrentree) == 0
	        	terminis = [terminis; b(end, : )];
	        	% disp('termnis update')
	        	% disp(terminis)
	        end
    	end

    end

end
