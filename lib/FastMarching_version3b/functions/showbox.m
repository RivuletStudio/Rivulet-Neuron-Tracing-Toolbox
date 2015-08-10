function showbox(vision_box,threshold)
figure
hold on
A = vision_box > threshold;  % synthetic data
[x y z] = ind2sub(size(A), find(A));
plot3(y, x, z, 'b.');
end