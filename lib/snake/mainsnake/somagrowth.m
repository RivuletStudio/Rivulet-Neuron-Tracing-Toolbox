function soma = somagrowth(inivcheck, somathres, showthres, plotcheck, ax, imgsoma, center, sqradius, smoothing, lambda1, lambda2, stepnum)
	% The following kernel is used for the SI and IS operation 
	global P3
	P2kernel = ones(3);
	P2kernel(:,1) = 0;
	P2kernel(:,3) = 0;
	P3kernel(:,:,1) = P2kernel; 
	P3kernel(:,:,2) = P2kernel; 
	P3kernel(:,:,3) = P2kernel; 
	P3{1} = P3kernel;
	P2kernel = P2kernel';
	P3kernel(:,:,1) = P2kernel; 
	P3kernel(:,:,2) = P2kernel; 
	P3kernel(:,:,3) = P2kernel; 
	P3{2} = P3kernel;
	P3kernel = zeros(3, 3, 3);
	P3kernel(:,:,2) = ones(3, 3);
	P3{3} = P3kernel;
	P2kernel = eye(3);
	P3kernel(:,:,1) = P2kernel; 
	P3kernel(:,:,2) = P2kernel; 
	P3kernel(:,:,3) = P2kernel; 
	P3{4} = P3kernel;
	P2kernel = flipud(eye(3));
	P3kernel(:,:,1) = P2kernel; 
	P3kernel(:,:,2) = P2kernel; 
	P3kernel(:,:,3) = P2kernel; 
	P3{5} = P3kernel;
	P3kernel = zeros(3, 3, 3);
	P3kernel(:, 1, 1) = 1;
	P3kernel(:, 2, 2) = 1;
	P3kernel(:, 3, 3) = 1;
	P3{6} = P3kernel;
	P3kernel = zeros(3, 3, 3);
	P3kernel(:, 3, 1) = 1;
	P3kernel(:, 2, 2) = 1;
	P3kernel(:, 1, 3) = 1;
	P3{7} = P3kernel;
	P3kernel = zeros(3, 3, 3);
	P3kernel(1, :, 1) = 1;
	P3kernel(2, :, 2) = 1;
	P3kernel(3, :, 3) = 1;
	P3{8} = P3kernel;
	P3kernel = zeros(3, 3, 3);
	P3kernel(3, :, 1) = 1;
	P3kernel(2, :, 2) = 1;
	P3kernel(1, :, 3) = 1;
	P3{9} = P3kernel;
	startpoint = zeros(1, 3);
	startpoint = center - 3 * sqradius;
	disp(startpoint)
    endpoint = zeros(1, 3);
	endpoint = center + 3 * sqradius;
	disp(endpoint);
	shape = size(imgsoma);
	startpoint(1) = constrain(startpoint(1), 1, shape(1));
	startpoint(2) = constrain(startpoint(2), 1, shape(2));
	startpoint(3) = constrain(startpoint(3), 1, shape(3));
	endpoint(1) = constrain(endpoint(1), 1, shape(1));
	endpoint(2) = constrain(endpoint(2), 1, shape(2));
	endpoint(3) = constrain(endpoint(3), 1, shape(3));
	oriI = imgsoma;
	imgsoma = imgsoma(startpoint(1):endpoint(1), startpoint(2):endpoint(2), startpoint(3):endpoint(3));
	shape = size(imgsoma);
	oldcenter = center;
	center = shape/2;
	center = floor(center);
	% Basically it creates a logical disk with true elements inside and false elements outside
	u = circlelevelset3d(shape, center, sqradius);
	threshold = 0.5;
	MorphGAC = ACWEinitialise(double(imgsoma), smoothing, lambda1, lambda2);
	% the threshold is just for visulisation
	% u is the snake mask which will evolve according to level set equation
    if inivcheck
        iniu = somaini_v_quick(double(imgsoma), somathres);
        MorphGAC.u = iniu > 0.5;
    else
        MorphGAC.u = u;
    end
	% disp(stepnum)
	% figure
	if plotcheck
		axes(ax);
		% hold on;
	end
	for i = 1 : stepnum
		if plotcheck
			cla(ax);
			hold on
            safeshowbox(oriI, showthres);
		end
		
		MorphGAC = ACWEstep3d(MorphGAC, i);
		A = MorphGAC.u > threshold;  % synthetic data
		[x y z] = ind2sub(size(A), find(A));
		x = x - center(1) + oldcenter(1);
		y = y - center(2) + oldcenter(2);
		z = z - center(3) + oldcenter(3);
		fprintf('this is the %d step of the snake\n', i);
		if plotcheck
			plot3(y, x, z, 'b.');
            axis equal
			hold off
            
			% axis([0 shape(2) 0 shape(1) 0 shape(3)])
			drawnow
		end
	end
	% close
	disp(class(MorphGAC.u));
	backsoma = zeros(size(oriI));
	backsoma(startpoint(1):endpoint(1), startpoint(2):endpoint(2), startpoint(3):endpoint(3)) = MorphGAC.u;
	soma.I = double(backsoma);
	% Recalculate soma centre
	somaidx = find(soma.I == 1);
	[x, y, z] = ind2sub(size(soma.I), somaidx);
	soma.x = mean(x);
	soma.y = mean(y);
	soma.z = mean(z);
	fprintf('The soma centre is recalculated as (%f, %f, %f)', soma.x, soma.y, soma.z);
end
