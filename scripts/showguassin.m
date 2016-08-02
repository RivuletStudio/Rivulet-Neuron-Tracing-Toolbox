% sigmavalue = 17;
% gaussianmat = gaussian3(sizemat, sigmavalue);
% xvec = (1:1:sizemat) - round(sizemat / 2);
% midvalue = round(sizemat / 2);
% plot(xvec, gaussianmat(1:sizemat, midvalue, midvalue)); 
counter = 1;
for i_2 = 1 : 4 
	sizemat = counter * 10;
	counter = counter + 1;
	ini_vec = 1 : sizemat;
	scale_para = 1;
	estimated_radius = 6;
	expotential_coefficient = 1.4 / estimated_radius; 
	gaussian_vec = exp(-ini_vec*expotential_coefficient);
	gaussian_vec = gaussian_vec / min(gaussian_vec(:));
	gaussian_vec = scale_para * gaussian_vec;
	min_gaussian_vec = min(gaussian_vec(:));
	if min_gaussian_vec < 1
		gaussian_vec = gaussian_vec + (1 - min_gaussian_vec); 
	end  
	% plot(ini_vec, gaussian_vec);
	% rem_one = rem(i, 2);
	subplot(2, 2, i_2);
	plot(ini_vec, gaussian_vec);
	xlabel('distance to soma center');
	ylabel('gaussian decay field');
	title('radius of this soma is 6')
end
