function swc = fixtopology(swc)
	nnode = size(swc, 1);
	G = sparse(logical(zeros(nnode, nnode)));

	for i = 1 : nnode
		pind = find(swc(:, 1) == swc(i, 7));

		if numel(pind) > 0
	        G(i, pind) = 1;
	        G(pind, i) = 1;
	    end
	end
	
    rootind = find(swc(:, 7) == -1);
	[~, p] = graphminspantree(G, rootind);
    
    for i = 1 : numel(p)
    	if p(i) == 0 
    		swc(i, 7) = -1;
		elseif ~isnan(p(i))
	    	swc(i, 7) = swc(p(i), 1);
	    else
    		swc(i, 7) = -2;
	    end
    end

    swc = swc(swc(:, 7) ~= -2, :);

end