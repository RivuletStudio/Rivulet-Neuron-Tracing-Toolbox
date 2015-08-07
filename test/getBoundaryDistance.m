function BoundaryDistance=getBoundaryDistance(I,IS3D)
% Calculate Distance to vessel boundary

% Set all boundary pixels as fastmarching source-points (distance = 0)
if(IS3D),S=ones(3,3,3); else S=ones(3,3); end
B=xor(I,imdilate(I,S));
ind=find(B(:));
if(IS3D)
    [x,y,z]=ind2sub(size(B),ind);
    SourcePoint=[x(:) y(:) z(:)]';
else
    [x,y]=ind2sub(size(B),ind);
    SourcePoint=[x(:) y(:)]';
end

% Calculate Distance to boundarypixels for every voxel in the volume
SpeedImage=ones(size(I));
BoundaryDistance = msfm(SpeedImage, SourcePoint, false, true);

% Mask the result by the binary input image
BoundaryDistance(~I)=0;
