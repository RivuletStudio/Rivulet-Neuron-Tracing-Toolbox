function [shortline, T, Y, maxD] = trytip2d()
	I = imread('/home/siqi/Downloads/vessels2d.png');
	I=im2double(rgb2gray(I));
	% Convert double image to logical
	I=I<0.5;
    bdist = getBoundaryDistance(I, false);
    [SourcePoint, maxD] = maxDistancePoint(bdist, I, false);
    SpeedImage=(bdist/maxD).^4;
	SpeedImage(SpeedImage==0)=1e-10;

    figure(2),
    imagesc(SpeedImage)

    % SourcePoint = [154; 214];
    % StartPoint = [64; 371];
    T = msfm(SpeedImage, SourcePoint, false, false);

    S = {};

    B = zeros(size(T));
    i = 1;
    while(true)

	    StartPoint = maxDistancePoint(T, I, false);

		% StartPoint=maxDistancePoint(Y,I,false);
	    disp('SourcePoint')
	    disp(SourcePoint)
	    disp('StartPoint')
	    disp(StartPoint)
	    disp('T:')
	    disp(T(StartPoint(1), StartPoint(2)))
	    disp('B:')
	    disp(B(StartPoint(1), StartPoint(2)))

	    if T(StartPoint(1), StartPoint(2)) == 0 || I(StartPoint(1), StartPoint(2)) == 0
	    	break;
	    end

	    disp('start tracing');
	    tic
	    figure(4)
	    imagesc(T)
	    hold on
	    shortline = shortestpath2(T, StartPoint, SourcePoint, 2, 'rk4');
	    toc
	    disp('end tracing')


	    % Get radius of each point from distance transform
	    ind = sub2ind(size(bdist), int16(shortline(:, 1)), int16(shortline(:, 2)));
	    radius = bdist(ind);
	    radius = ceil(radius);

    	disp('found shorline with length')
    	disp(size(shortline, 1))
	    if size(shortline, 1) < 2
	    	shortline = StartPoint';
	    	radius = 1;
	    end
	    % Remove the traced path from the timemap
	    tB = binarysphere2d(size(T), shortline, radius);

	    T(tB==1) = 0;
	    S{i} = shortline;

        B = B | tB;
	    figure(6)
	    imagesc(B)
	    i = i + 1;
	end

	for i = 1 : numel(S) - 1
		l = S{i};
	    line(l(:, 2), l(:,1), 'Color', 'r');
	end

end

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
end

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