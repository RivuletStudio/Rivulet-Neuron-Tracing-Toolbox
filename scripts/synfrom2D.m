function I3D = synfrom2D(impath, radius, sm)
    I2D = imread(impath);
    I3D = zeros(size(I2D, 1), size(I2D, 2), 30);
    I3D(:,:,10:radius+9) = repmat(I2D, 1, 1, radius);
    I3D = smooth3(I3D, 'box', sm);
end