function showbox(vision_box,threshold)
% figure
hold on
whitebg(gcf, 'black')
biA = vision_box > threshold; 
% [x y z] = ind2sub(size(biA), find(biA));
% plot3(y, x, z, 'b.');
%scatter3(x(i),y(i),z(i),15,A(x(i),y(i),z(i)),'filled');
camlight;
iso = isosurface(biA);
h = patch(iso, 'facecolor',[1 1 1],'facealpha',0.3,'edgecolor','none');  view(3); axis equal;
drawnow
hold off
end