function soma = somasmooth(showthres, plotcheck, ax, imgbi, smoothing, lambda1, lambda2, stepnum, iniu, enlrspt, enlrept)
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
	oriI = imgbi;
	imgbicube = imgbi(enlrspt(1):enlrept(1), enlrspt(2):enlrept(2), enlrspt(3):enlrept(3));
	clear imgbi
	% the threshold is just for visulisation
	threshold = 0.5;
	MorphGAC = ACWEinitialise(double(imgbicube), smoothing, lambda1, lambda2);
	
	% u is the snake mask which will evolve according to level set equation
    MorphGAC.u = iniu;
	% figure
	if plotcheck
		if(~isempty(ax))
			axes(ax);
			% hold on;
		end
	end

	ini_vol = sum(MorphGAC.u(:));
	for i = 1 : MorphGAC.smoothing
		A = curvop3d(MorphGAC.u, P3, 1);
		% vol_pct is the percent compared to the initial volume compared to  
		vol_pct = sum(A(:)) / ini_vol;
		if vol_pct < 0.85
			break;
		end 
		% fprintf('The current soma volume is %4.1f\n', foreground_num(end));
		MorphGAC.u = A;
	end

	backsoma = zeros(size(oriI));
	backsoma(enlrspt(1):enlrept(1), enlrspt(2):enlrept(2), enlrspt(3):enlrept(3)) = MorphGAC.u;
	soma.I = double(backsoma);
	
	% Recalculate soma centre
	somaidx = find(soma.I == 1);
	[x, y, z] = ind2sub(size(soma.I), somaidx);
	soma.x = mean(x);
	soma.y = mean(y);
	soma.z = mean(z);
    soma.startpoint = enlrspt;
    soma.endpoint = enlrept;
	% fprintf('The soma centre is recalculated as (%f, %f, %f)', soma.x, soma.y, soma.z);
end