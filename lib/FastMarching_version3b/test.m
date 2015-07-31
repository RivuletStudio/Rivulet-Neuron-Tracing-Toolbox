clc
clear all
close all
cd golden
fname = 'enhancedcrop8.tif';
info = imfinfo(fname);
num_images = numel(info);
for k = 1:num_images
   vision_box(:,:,k) = imread(fname, k);
end
threshold = 0.2
A = vision_box > threshold;  % synthetic data
[x y z] = ind2sub(size(A), find(A));
plot3(x, y, z, 'b.')
% Use fastmarching to find the skeleton
  S=skeleton(A);


% Show the iso-surface of the vessels
figure,
  FV = isosurface(A,0.5)
  patch(FV,'facecolor',[1 0 0],'facealpha',0.3,'edgecolor','none');
  view(3)
%   camlight
% Display the skeleton
  hold on;
  for i=1:length(S)
    L=S{i};
    plot3(L(:,2),L(:,1),L(:,3),'-','Color',rand(1,3));
  end