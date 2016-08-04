load('/home/donghao/Desktop/soma_field/soma_case3/somafieldtest.mat');
subplot(2, 2, 1)
imagesc(SpeedImage(:,:,round(size(SpeedImage, 3)/4)));
subplot(2, 2, 2)
imagesc(SpeedImage(:,:,round(size(SpeedImage, 3)/2)));
subplot(2, 2, 3)
imagesc(SpeedImage(:,:,round(size(SpeedImage, 3)/4*2)));
subplot(2, 2, 4)
imagesc(SpeedImage(:,:,round(size(SpeedImage, 3)/4*3)));
bfspbox = load('/home/donghao/Desktop/soma_field/soma_case3/speed_boxbefore.mat');
afspbox = load('/home/donghao/Desktop/soma_field/soma_case3/speed_boxafter.mat');
surf_dist = load('/home/donghao/Desktop/soma_field/soma_case3/surf_dist.mat');
figure
for i = 1 : size(SpeedImage, 3)
    imagesc(SpeedImage(:,:,i));
    pause(0.5)
end
figure
for i = 1 : size(surf_dist.surf_dist, 3)
    imagesc(surf_dist.surf_dist(:,:,i));
    pause(0.5)
end

close all
figure
for i = 20
    imagesc(bfspbox.speed_box(:,:,i));
    pause(0.5)
end

figure
for i = 20
    imagesc(afspbox.speed_box(:,:,i));
    pause(0.5)
end

figure
for i = 20
    imagesc(surf_dist.surf_dist(:,:,i));
    pause(0.5)
end