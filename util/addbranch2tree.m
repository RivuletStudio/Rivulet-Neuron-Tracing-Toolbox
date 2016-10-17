function [tree, newtree, confidence, unconnected] = addbranch2tree(tree, l, merged, connectrate, radius, I, branchlen, plot, somamerged)
% Add a branch with 3D points to a swc tree
% Return the result swc tree and the confidence score of the newly added branch
    % Get the voxels on this branch and count the empty voxels 
    unconnected = false;
    newtree = [];
    lint = int16(l);
    ind = sub2ind(size(I), lint(:, 1), lint(:, 2), lint(:, 3));
    vox = I(ind);
    confidence = sum(vox)/numel(vox);
    if confidence < 0.5 || size(l, 1) < branchlen
    	return
    end

	assert(size(l, 1) == size(radius, 1));
	newtree = zeros(size(l, 1), 7);
	if size(tree, 1) == 0 || size(tree, 1) == 1 % 1 When soma location is used 
		newtree(:, 1) = 2 : size(l, 1)+1;
		newtree(:, 2) = 3;
		newtree(:, 3:5) = l;
		newtree(:, 6) = radius;
		newtree(1:end-1, 7) = newtree(2:end, 1);

		if somamerged
			newtree(end, 7) = 1;  % Soma ID
		else
			newtree(end, 7) = -1; % Make it the root
		end

		if plot
			plot3(newtree(:, 4), newtree(:, 3), newtree(:, 5), 'b-.');
			drawnow
		end
				% Try to visualise the soma merged point
		if somamerged
			newtree(:, 2) = 200; % Use different colors to show whether soma merged is successful or not
			fprintf('This is just a debug type one\n');
		end 
		tree = [tree;newtree];
	else
		termini1 = l(end, :);
		termini2 = l(1, :);
		treenodes = tree(:, 3:5);
        
        % Get pairwise distance between the termini and tree nodes 
        d1 = pdist2(termini1, treenodes);
        [d1, idx1] = min(d1);

        d2 = pdist2(termini2, treenodes);
        [d2, idx2] = min(d2);

        % Sort internal relationship
		newtree(:, 1) = tree(end, 1) + 1 : tree(end, 1) + size(l, 1);
		newtree(:, 2) = 3;
		newtree(:, 3:5) = l;
		newtree(:, 6) = radius;
		newtree(1:end-1, 7) = newtree(2:end, 1);
		if plot
			plot3(newtree(:, 4), newtree(:, 3), newtree(:, 5), 'b-.');
			drawnow
		end

		if somamerged
			newtree(end, 7) = 1; % Soma ID
		else
		    if (d1 < (tree(idx1, 6) + 3) * connectrate || d1 < (newtree(end, 6) + 3) * connectrate) && merged
				newtree(end, 7) = tree(idx1, 1); % Connect to the tree parent
				if plot
					plot3([newtree(end, 4);tree(idx1, 4)], [newtree(end, 3);tree(idx1, 3)], [newtree(end, 5);tree(idx1, 5)], 'b-.');
					drawnow
                end
                newtree(end, 2) = 5;
			else
				newtree(end, 7) = -2; % Remain unconnected
                newtree(end, 2) = 6;
			end
		end

	    if (d2 < (tree(idx2, 6) + 3) * connectrate || d2 < (newtree(1, 6) + 3)* connectrate) && merged
			newtree(1, 7) = tree(idx2, 1); % Connect to the tree parent
			if plot
				plot3([newtree(1, 4);tree(idx2, 4)], [newtree(1, 3);tree(idx2, 3)], [newtree(1, 5);tree(idx2, 5)], 'b-.');
				drawnow
            end
            newtree(1, 2) = 3;
		else
% 			newtree(1, 7) = -2; % Remain unconnected
            newtree(1, 2) = 6;
		end

		% plot3([newtree(end, 4);tree(idx, 4)], [newtree(end, 3);tree(idx, 3)], [newtree(end, 5);tree(idx, 5)], 'b-.');

		if newtree(end, 7) == -2 && newtree(1, 7) == -2
			unconnected = true;
			% return
		end

		% Try to visualise the soma merged point
		if somamerged
			newtree(:, 2) = 200; % Use different colors to show whether soma merged is successful or not
			fprintf('This is just a debug type two\n');
		end 
		tree = [tree; newtree];
	end

end
