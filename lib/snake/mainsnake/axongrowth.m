function axonvol = axongrowth(imgsoma, smoothing, lambda1, lambda2, stepnum, iniu)
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



	MorphGAC = ACWEinitialise(double(imgsoma), smoothing, lambda1, lambda2);
	% u is the snake mask which will evolve according to level set equation
    MorphGAC.u = iniu > 0.5;

	% disp(stepnum)
	% figure
	for i = 1 : stepnum
		MorphGAC = ACWEstep3d(MorphGAC, i);
		fprintf('this is the %d step of the snake\n', i);
	end
	% close	
	axonvol = MorphGAC.u;
end