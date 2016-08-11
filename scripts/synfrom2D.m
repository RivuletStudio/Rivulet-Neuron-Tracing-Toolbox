function I3D = synfrom2D(impath, radius, sm, noisedensity)
% SYNFROM2D Synthesize 3D tube from a 2D image for testing neuron tracing algorithms
%    synfrom2D(imgpath, radius_of_2d_tube, smooth_ratio, noise_density)

    
    I2D = imread(impath);
    I3D = zeros(size(I2D, 1), size(I2D, 2), 30);
    I3D(:,:,10:radius+9) = repmat(I2D, 1, 1, radius);
    I3D = smooth3(I3D, 'box', sm);
    I3D(I3D < 0.5) = 0;
    C = reshape(I3D, [], size(I3D, 2), 1);
    [IDX,sep] = otsu(C,2);
    I3D = reshape(IDX, size(I3D)) - 1;
    I3D = imnoise(I3D, 'salt & pepper', noisedensity);
end