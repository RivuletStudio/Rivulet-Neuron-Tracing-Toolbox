function swc = gvf_adjust_swc(I, swc, mu)
	I = double(I);
	nvox = numel(I);
	% niter = floor(sqrt(nvox));
	stepsize = 0.01;

	[u, v, w] = GVF3D(I, mu, 60);
	vsum = u + v + w;
    u = u ./ vsum;
    v = v ./ vsum;
    w = w ./ vsum;

	% TODO : May do interpolation here
	for i = 1 : 10
        disp(i)
		nodeidx = sub2ind(size(I), ceil(swc(:, 3)), ceil(swc(:, 4)), ceil(swc(:, 5))); 
		swc(:, 3) = constrain(swc(:, 3) + stepsize * u(nodeidx), 1, size(I, 1));
		swc(:, 4) = constrain(swc(:, 4) + stepsize * v(nodeidx), 1, size(I, 2));
		swc(:, 5) = constrain(swc(:, 5) + stepsize * w(nodeidx), 1, size(I, 3));
	end

end