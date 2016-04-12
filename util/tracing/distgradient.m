function GradientVolume = distgradient(DistanceMap)
	% Calculate gradient of DistanceMap
	if(ndims(DistanceMap)==2) % Select 2D or 3D
	    [Fy,Fx] = pointmin(DistanceMap);
	    GradientVolume(:,:,1)=-Fx;
	    GradientVolume(:,:,2)=-Fy;
	else
	    [Fy,Fx,Fz] = pointmin(DistanceMap);
	    GradientVolume(:,:,:,1)=-Fx;
	    GradientVolume(:,:,:,2)=-Fy;
	    GradientVolume(:,:,:,3)=-Fz;
	end
end