function [xlist, ylist, zlist] = spherepoint(center_x, center_y, center_z, radius)
radius_int = round(radius);
xlist = [];
ylist = [];
zlist = [];
for point_x = -radius_int : 1 : radius_int
	for point_y = -radius_int : 1 : radius_int
		for point_z = -radius_int : 1 : radius_int
			if ((point_x^2 + point_y^2 + point_z^2) <  radius^2)
				xlist = [round(point_x+center_x);xlist]; 
				ylist = [round(point_y+center_y);ylist]; 
				zlist = [round(point_z+center_z);zlist];
			end
		end
	end
end
end 
