function somastruc = somagrowth(showthres, plotcheck, ax, imgsoma, center, sqradius, smoothing, lambda1, lambda2, stepnum)
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
	shape = size(imgsoma);

	% Basically it creates a logical disk with true elements inside and false elements outside
	u = circlelevelset3d(shape, center, sqradius);
	threshold = 0.5;
	MorphGAC = ACWEinitialise(double(imgsoma), smoothing, lambda1, lambda2);
	% the threshold is just for visulisation
	% u is the snake mask which will evolve according to level set equation 
	MorphGAC.u = u;
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
		end
		safeshowbox(imgsoma, showthres);
		MorphGAC = ACWEstep3d(MorphGAC, i);
		A = MorphGAC.u > threshold;  % synthetic data
		[x y z] = ind2sub(size(A), find(A));
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
	hold off
	somastruc.I = MorphGAC.u;
	somastruc.x = center(1);
	somastruc.y = center(2);
	somastruc.z = center(3);
end
