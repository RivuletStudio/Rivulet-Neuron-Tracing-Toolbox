function safeshowbox(vision_box,threshold)

A = vision_box > threshold;  % synthetic data
[x y z] = ind2sub(size(A), find(A));
plot3(y, x, z, 'r.');

end