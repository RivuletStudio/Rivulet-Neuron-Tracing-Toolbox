function [tree, confidence] = addbranch2tree(tree, l, radius, I)
% Add a branch with 3D points to a swc tree
% Return the result swc tree and the confidence score of the newly added branch

    % Get the voxels on this branch and count the empty voxels 
    lint = int16(l);
    ind = sub2ind(size(I), lint(:, 1), lint(:, 2), lint(:, 3));
    vox = I(ind);
    confidence = sum(vox)/numel(vox);
    fprintf('confidence of this branch %f\n', confidence);

    % Get rid of the noise points 
   %  if confidence < 0.5
   %      s = 0;
   %      lastoneidx = numel(vox);

   %  	for i = numel(vox) : -1 : 1
			% if vox(i)
   %              lastoneidx = i;
			% end

			% s = s + vox(i);
			% p = s / i;
   %          if p < 0.9
   %              l = l(end:lastoneidx, :);
   %              break;
   %          end
   %  	end

   %  	radius = radius(end:lastoneidx);
   %  end

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
		plot3(newtree(:, 4), newtree(:, 3), newtree(:, 5), 'b-.');
		drawnow
		tree = newtree;
	else
		termini1 = l(end, :);
		termini2 = l(1, :)
		treenodes = tree(:, 3:5);
        
        % Get pairwise distance between the termini and tree nodes 
        d1 = pdist2(termini1, treenodes);
        [d1, idx1] = min(d1);

        d2 = pdist2(termini2, treenodes);
        [d2, idx2] = min(d2)

        % Sort internal relationship
		newtree(:, 1) = tree(end, 1) + 1 : tree(end, 1) + size(l, 1);
		newtree(:, 2) = 2;
		newtree(:, 3:5) = l;
		newtree(:, 6) = radius;
		newtree(1:end-1, 7) = newtree(2:end, 1);
		plot3(newtree(:, 4), newtree(:, 3), newtree(:, 5), 'b-.');

	    if d1 < tree(idx1, 6) * 4 || d1 < newtree(end, 6) * 4
			newtree(end, 7) = tree(idx1, 1); % Connect to the tree parent
			plot3([newtree(end, 4);tree(idx1, 4)], [newtree(end, 3);tree(idx1, 3)], [newtree(end, 5);tree(idx1, 5)], 'b-.');
		else
			newtree(end, 7) = -2; % Remain unconnected
		end

	    if d2 < tree(idx2, 6) * 4 || d2 < newtree(1, 6) * 4
			newtree(1, 7) = tree(idx2, 1); % Connect to the tree parent
			plot3([newtree(1, 4);tree(idx2, 4)], [newtree(1, 3);tree(idx2, 3)], [newtree(1, 5);tree(idx2, 5)], 'b-.');
		else
			newtree(end, 7) = -2; % Remain unconnected
		end

		% plot3([newtree(end, 4);tree(idx, 4)], [newtree(end, 3);tree(idx, 3)], [newtree(end, 5);tree(idx, 5)], 'b-.');
		drawnow
		tree = [tree; newtree];
	end
	% waitforbuttonpress
end

