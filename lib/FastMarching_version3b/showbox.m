function biA = showbox(vision_box,threshold)
figure
hold on
biA = vision_box > threshold;  % synthetic data
[x y z] = ind2sub(size(biA), find(biA));
plot3(y, x, z, 'b.');
%scatter3(x(i),y(i),z(i),15,A(x(i),y(i),z(i)),'filled');
end