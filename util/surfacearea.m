clc
clear all
close all
imgsoma = load_v3d_raw_img_file('/home/donghao/Desktop/OP_2.v3draw');
threshold = 60;
biA = imgsoma > threshold; 
camlight;
iso = isosurface(biA);
h = patch(iso, 'facecolor',[0.7 0.7 1],'facealpha',0.3,'edgecolor','none');  view(3); axis equal;
verts = get(h, 'Vertices');
faces = get(h, 'Faces');
a = verts(faces(:, 2), :) - verts(faces(:, 1), :);
b = verts(faces(:, 3), :) - verts(faces(:, 1), :);
c = cross(a, b, 2);
sarea = 1/2 * sum(sqrt(sum(c.^2, 2)))