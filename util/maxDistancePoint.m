function [posD,maxD]=maxDistancePoint(BoundaryDistance,I,IS3D)
	% Mask the result by the binary input image
	BoundaryDistance(~I)=0;

	% Find the maximum distance voxel
	[maxD,ind] = max(BoundaryDistance(:));
	if(~isfinite(maxD))
	    error('Skeleton:Maximum','Maximum from MSFM is infinite !');
	end

	if(IS3D)
	    [x,y,z]=ind2sub(size(I),ind); posD=[x;y;z];
	else
	    [x,y]=ind2sub(size(I),ind); posD=[x;y];
	end

end	
