load('/home/donghao/Desktop/soma_field/soma_case1/soma_case1.mat')
somabI = soma.I > 0.5;
% The following two lines find surface of the binary soma
S=ones(3,3,3);
Bsoma=xor(somabI,imdilate(somabI,S));
dtsoma = bwdist(Bsoma);
% When distance transform values are larger than 15, we do not consider
% them. It is beyond the scope of soma field
dtsoma(dtsoma>15) = 1;
[Dx, Dy, Dz] = ind2sub(size(dtsoma),find(dtsoma > 1));
minx = min(Dx);
maxx = max(Dx);
miny = min(Dy);
maxy = max(Dy);
minz = min(Dz);
maxz = max(Dz);
surf_dist = D(minx:maxx, miny:maxy, minz:maxz);
expotential_coefficient = 2 / estimated_radius;
% The following is a test case which might not be necessary
surf_scale = 1;
surf_dist = (surf_dist * surf_scale);
%Third version soma field start
if somagrowthcheck
    fprintf('Extract speed image box...\n');
    speed_box = SpeedImage(minx:maxx, miny:maxy, minz:maxz);
    fprintf('Surface distance enhancement convolution begins...\n');    
    speed_box = speed_box .* surf_dist;
    SpeedImage() = speed_box;
end
% Second version soma field end