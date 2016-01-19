function swc = prunetree(swc, l)
% Prune leaf branches with #nodes  < l
    
    % Calculate the order of each node
    nnode = size(swc, 1);
    order = zeros(nnode, 1);
    parents = swc(:, 7);
    for i = 1 : nnode
        o = sum(parents == swc(i, 1));

    	if swc(i, 7) > 0 
    		o = o+1;
    	end

    	order(i) = o;
    end

    % Cluster nodes with order == 1 into branches
    ind = find(order == 1);
    leafbranchnodes = swc(ind, :);
    cluster = zeros(nnode, 1);

    % Go up from leaf until it reaches a node with order > 2
    for i = 1 : size(leafbranchnodes, 1)
        n = leafbranchnodes(i, :);
        c = max(cluster) + 1;
        cluster(i) = c;

        while(true)
            pind = find(swc(i, 1) == n(7));
            if numel(pind) > 0
                n = swc(pind, :);
                
                if cluster(pind) ~= 0
                    cluster(cluster == c) = cluster(pind);
                    break;
                else
                    cluster(pind) = c;
                end
                
                if order(pind) > 2 
                    break;
                end
            else
                break;
            end
        end
    end    

    discard = zeros(nnode, 1);

    % Discard the cluster with #nodes < l
    for i = 1 : numel(cluster)
    	if sum(cluster == cluster(i)) < l 
            discard(i) = 1;
    	end
    end

    swc = swc(discard == 0,:);
end