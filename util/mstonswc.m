function swc = mstonswc(swc, I)
	% Make graph matrix
    id = swc(:, 1);
    parent = swc(:, 7);
    maxid = max(id);
    % Caculate the weights for each edge in G, 
    % The weight is 1 if voxel at the middle point of this edge is 0; 
    % The weight is 0 if voxel at the middle point is 1
    % rest with weight inf
    G = zeros(maxid, maxid); 
    G = 0;

    for i = 1 : size(id, 1)
    	pidx = find(id == parent(i));
    	if parent(i) < 0 
    		continue
    	end

    	% disp([i, pidx, parent(i)])
        middle = (swc(i, 3:5) + swc(pidx, 3:5)) / 2;
        middle = ceil(middle);
        middlevoxel = I(middle(1), middle(2), middle(3));

        % if middlevoxel == 1
	    %     G(parent(i), id(i)) = 0.5;
	    %     G(id(i), parent(i)) = 0.5;
	    % else
        G(parent(i), id(i)) = 1;
        G(id(i), parent(i)) = 1;
	    % end
    end

    % Find circles
    findcycles(sparse(G));

    % Run MST on G
    [tree, pred] = graphminspantree(sparse(G));
    tree = full(tree);
    idx2remove = [];

    % Remove the edge in swc if this edge is not in the MST
    for i = 1 : size(id, 1)
    	if parent(i) > 0 && all(tree(id(i), :) == 0) && all(tree(:, id(i)) == 0)
    		idx2remove = [idx2remove; i];
    		fprintf('Remove %d-%d\n', parent(i), id(i));
    	end
    end

    swc(idx2remove, :) = [];
end

function findcycles(G)
	numNodes = size(G,1); 
	for n = 1:numNodes
	   [D,P]=graphtraverse(G,n);
	   for d = D
	       if G(d,n)
	           p = graphpred2path(P,d);
	       end
	   end
	   G(n,:)=0; 
	end
end