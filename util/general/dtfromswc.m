function dt = dtfromswc(sz, swc, alpha, is2D)
% Generate distance transform from the SWC file
% The SWC nodes will be upsampled to make sure almost every voxel along the path has a value
% sz: The input image size in 3D
% swc: the SWC node list
% is2D: boolean for whether the output is expected to be the XY projection

	% Up sample swc nodes
	[~, pts] = binarycilinder3D(sz, swc, true);

	if is2D
		dt = zeros(sz(1:2));
	else
		dt = zeros(sz);
	end

	dt(:) = -1;


	% Fill in the distances between the nodes and the voxel it stays in
	for i = 1 : size(pts, 1)
		if is2D
			dt(ceil(pts(i, 1)), ceil(pts(i, 2))) = norm(pts(i, 1:2) - ceil(pts(i, 1:2)), 2);
		else
			dt(ceil(pts(i, 1)), ceil(pts(i, 2)), ceil(pts(i, 3))) = norm(pts(i, 1:3) - ceil(pts(i, 1:3)), 2);
		end
    end
    
    newdt = dt; 
    
	for i = 1 : 5 
        if is2D
			ind = findneighbours(dt, is2D); % Return the linear index of all neighbours in the outer boundary
			[x, y] = ind2sub(sz(1:2), ind);

	        for j = 1 : numel(ind)
			 	[xgrid, ygrid] = meshgrid(x(j)-1:x(j)+1, y(j)-1:y(j)+1);
				xgrid = constrain(xgrid(:), 1, size(dt, 1));
				ygrid = constrain(ygrid(:), 1, size(dt, 2));
	            gridind = sub2ind(sz(1:2), xgrid, ygrid);
	            neighbourval = dt(gridind);
	            
	            if ~all(neighbourval == -1)
	            	neighbourval(neighbourval == -1) = 10000; % To find the minimum value except -1
	            	[minD, minDidx] = min(neighbourval);
	            	[minx, miny] = ind2sub(sz(1:2), gridind(minDidx));
	            	nd = norm([x(j), y(j)] - [minx, miny], 2) + minD;
	                newdt(ind(j)) = nd;
	            end
	        end
        else
			ind = findneighbours(dt, is2D); % Return the linear index of all neighbours in the outer boundary
			[x, y, z] = ind2sub(sz, ind);
	        for j = 1 : numel(ind)
			 	[xgrid, ygrid, zgrid] = meshgrid(x(j)-1:x(j)+1,...
			 	                                 y(j)-1:y(j)+1,...
			 	                                 z(j)-1:z(j)+1);
				xgrid = constrain(xgrid(:), 1, size(dt, 1));
				ygrid = constrain(ygrid(:), 1, size(dt, 2));
				zgrid = constrain(zgrid(:), 1, size(dt, 3));
	            gridind = sub2ind(sz, xgrid, ygrid, zgrid);
	            neighbourval = dt(gridind);
	            
	            if ~all(neighbourval == -1)
	            	neighbourval(neighbourval == -1) = 10000; % To find the minimum value except -1
	            	[minD, minDidx] = min(neighbourval);
	            	[minx, miny, minz] = ind2sub(sz, gridind(minDidx));
	            	nd = norm([x(j), y(j), z(j)] - [minx, miny, minz], 2) + minD;
	                newdt(ind(j)) = nd;
	            end
	        end
	    end

		dt = newdt;
    end
    
    bgmask = dt == -1;
	dt(:) = alpha * (1 - dt(:) ./ max(dt(:)));
	dt(:) = exp(dt(:)) - 1;
	dt = dt ./ max(dt(:));
    % dt(bgmask) = -1;
    dt(bgmask) = 0;
end

			 	                                
function ind = findneighbours(dt, is2D)
	binarydt = dt >= 0;

	if is2D
	    se = strel(ones(3, 3));
	else
	    se = strel(ones(3, 3, 3));
	end

    binarydt = imdilate(binarydt, se) - binarydt;
    ind = find(binarydt ~= 0);
end


function [bcilinder, pts] = binarycilinder3D(sz, swc, ignore_radius)
% Generate binary image by the swc skelonton
% Draw cilinder shape between each pair of adjacent nodes.

bcilinder = logical(zeros(sz));

pts = [];
for i = 1 : size(swc, 1)
    node = swc(i, :);

    if swc(i, 7) > 0
        pid = swc(i, 7);
        pnode = swc(swc(:,1) == pid, :);

        if ~any(swc(:,1) == pid) || ...
                any(pnode(3:5) < 0) || ...
                any(pnode(3:5) > sz) || ...
                any(node(3:5) < 0) || ...
                any(node(3:5) > sz)
            continue
        end

        direction = pnode(3:5) - node(3:5);
        D = sqrt(sum((pnode(3:5) - node(3:5)) .^ 2 ));
        nstep = floor(D);
        step = direction / nstep;        
        dr = (pnode(:, 6) - node(:, 6)) / (nstep - 1);
        r = node(6);

        for j = 0 : nstep - 1
            node(3:5) = node(3:5) + step;
            if ignore_radius
                x = node(3); y = node(4); z = node(5);
                if x > 0 && x <= sz(1) && y > 0 && y <= sz(2) && z > 0 && z <= sz(3)
                    % bcilinder(x, y, z) = 1;
                else
                    fprintf('Got node at %d, %d, %d. Skipped\n', x, y, z);
                end
            else
                neighbours = neighourpoints3d(x, y, z, floor(r + j * dr));
                neighbours(:, 1) = constrain(neighbours(:, 1), 1, sz(1));
                neighbours(:, 2) = constrain(neighbours(:, 2), 1, sz(2));
                neighbours(:, 3) = constrain(neighbours(:, 3), 1, sz(3));
                ind = sub2ind(sz, int16(neighbours(:, 1)), int16(neighbours(:, 2)), int16(neighbours(:, 3)));
                bcilinder(ind) = 1;
            end

            pts = [pts; x, y, z, floor(r + j * dr)];
        end
    end
end
end