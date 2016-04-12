function swc = prunetree(swc, l)
% Prune leaf branches with #nodes  < l
    
    hold on
    
    showswc(swc, false);
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
    leafidx = find(order == 1);
    plot3(swc(leafidx, 4),...
          swc(leafidx, 3),...
          swc(leafidx, 5),...
          '.',...
          'Color',...
          [0 0 1]); axis equal;    
    
    discard = zeros(nnode, 1);

    % Go up from leaf until it reaches a node with order > 2
    for i = 1 : size(leafidx, 1)
        n = swc(leafidx(i), :);
        branch = [leafidx(i)];

        while(true)
            pidx = find(swc(:, 1) == n(7));
                  
            if numel(pidx) > 0
                n = swc(pidx, :);

                if order(pidx) ~= 2
                    if size(branch, 1) < l
                        discard(branch) = 1;

                        plot3(n(:, 4),...
                              n(:, 3),...
                              n(:, 5),...
                              '.',...
                              'Color',...
                              [1 0 1]); axis equal;
                        nodes2del = swc(branch, :);
                        plot3(nodes2del(:, 4),...
                              nodes2del(:, 3),...
                              nodes2del(:, 5),...
                              '.',...
                              'Color',...
                              [1 1 1]); axis equal;
                    end
                
                    break;
                end                

                branch = [branch; pidx]; % add parent to branch if not burification
                
            else
                break;
            end
        end
    end    

    swc = swc(discard == 0,:);
    
    hold off
end