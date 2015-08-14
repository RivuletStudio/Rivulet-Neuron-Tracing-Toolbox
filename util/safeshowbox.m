function safeshowbox(vision_box,threshold)
figure
A = vision_box > threshold;  % synthetic data
[x y z] = ind2sub(size(A), find(A));
plot3(x, y, z, 'b.');

end