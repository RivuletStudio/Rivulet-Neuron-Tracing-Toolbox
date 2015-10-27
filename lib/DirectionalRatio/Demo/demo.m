load('demo.mat');

% dirRatio = directionalRatio(image, nbands,msize)
% nbands = number of bands  %msize = filter length
% output is going to change if we change the nbands and msize

dirRatio = directionalRatio(demo,20,20);

subplot(1,2,1);
imshow(demo, []); colormap('jet');

subplot(1,2,2);
imshow(dirRatio, []); colormap('jet');

