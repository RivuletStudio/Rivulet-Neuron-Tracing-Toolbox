function showbox(vision_box,threshold)
figure
hold on
A = vision_box > threshold;  % synthetic data
[x y z] = ind2sub(size(A), find(A));
%plot3(y, x, z, 'b.');
for i = 1 : 1000
disp(numel(x)-i)
scatter3(x(i),y(i),z(i),15,A(x(i),y(i),z(i)),'filled');
end
end