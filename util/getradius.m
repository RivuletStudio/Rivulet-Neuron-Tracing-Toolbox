function radius = getradius(inputMatrix, input_x, input_y, input_z)
%Calculate the radius of M * N * Z binary matrix at specific location 
%The specific location is defined by corresponding  input_x, input_y, input_z
[M, N, Z] = size(inputMatrix);
%sz vector stores the dimensional information 
sz(1) = M;
sz(2) = N;
sz(3) = Z;
%max_r is max radius radius which each neuron can have
max_r = max([M/2, N/2, Z/2]);

% mx, my, mz are eight neighbouring points of center points
mx = input_x + 0.5;
my = input_y + 0.5;
mz = input_z + 0.5;

%tol_num is the total number of foreground voxels
%bak_num is the total number of background voxels
tol_num = 0;
bak_num = 0;

%neighpot represent eight choosing ways. 
%It either choose the first element or the second element.
neighpot = [2, 1, 1;
			1, 2, 1;
			1, 1, 2;
			2, 1, 2;
			2, 2, 1;
			1, 2, 2;
			2, 2, 2;
			2, 1, 1;];
for(r = 1 : max_r)
	r1 = r - 0.5;
	r2 = r + 0.5;
	r1_r1 =  r1 * r1;
	r2_r2 =  r2 * r2;
	z_min = 0;
	z_max = r2;
	for(dz = z_min : 1 : z_max) 
		dz_dz = dz * dz;
		y_min = 0;
		y_max =  sqrt(r2_r2 - dz_dz);
		for (dy = y_min : y_max)
			dy_dy = dy * dy;
			x_min = r1_r1 - dz_dz - dy_dy;
			if (x_min > 0)
				x_min = sqrt(x_min) + 1;
			else
				x_min = 0;
			end
            x_max = sqrt(r2_r2 - dz_dz - dy_dy);
			for (dx = x_min : 1 : x_max)
				x(1) = mx - dx;
				x(2) = mx + dx;
				y(1) = my - dy;
				y(2) = my + dy;
				z(1) = mz - dz;
				z(2) = mz + dz;
				for (b = 1 : 8)
					neighindex = neighpot(b, :, :);
					ii = neighindex(1);
					jj = neighindex(2);
					kk = neighindex(3);
					%Make sure that center point is still in the 3D binary matrix
					if (x(ii)<0 || x(ii)>sz(1) || y(jj)<0 || y(jj)>sz(2) || z(kk)<0 || z(kk)>sz(3))
						%radius is final return value 
						radius = r;
						return;
					else
						tol_num = tol_num + 1;
						point = inputMatrix(round(x(ii)), round(y(jj)), round(z(kk)));
						%fprintf('bak_num : %6.2f  tol_num: %12.8f\n',bak_num, tol_num);
                        if(point == 0)
							bak_num = bak_num + 1;
                        end
                        %This is the criterion to calculate the radius, I have to say it is a harsh criterion which might be adjusted in the future 
                        judge = (bak_num / tol_num) > 0.0001;
                        %disp(judge)
						if (judge)
							radius = r;
                            %disp(bak_num/tol_num)
							return;
						end
					end
				end
			end
		end
	end
end
radius = r;
return

