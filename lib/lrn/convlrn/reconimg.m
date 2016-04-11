function reconstruction = reconimg(p)
    img = double(p.img);
	img = ( img - mean(img(:))) / std(img(:));
    img = gpuArray(img);

    % Load fb	
    [p, fb] = loadfb(p); 

    %% Compute the feature maps for the given sample
    feature_maps = cell(length(fb), 1);

    % Initialize the feature maps.
    for i_fm = 1 : length(fb)
    	fprintf('Extracting feature %d/%d\n', i_fm, length(fb));
        feature_maps{i_fm} = imfilter(img, fb{i_fm}, 'symmetric', 'same', 'corr');
    end

    % Reconstruct the image with the fb
	for i_step = 1 : p.ISTA_steps_no
		fprintf('ISTA iter %d\n', i_step);

        % Compute the reconstruction
        reconstruction = imfilter(img, fb{1}, 'symmetric', 'same', 'corr');

        for i_fm = 2:length(feature_maps)
            reconstruction = reconstruction + imfilter(feature_maps{i_fm}, fb{i_fm}, 'symmetric', 'same', 'corr');
        end

        % Normalize the reconstruction.
        % Empirically, we have found that dividing by filter's area+2 gives good
        % results.
        reconstruction = reconstruction / (size(fb{1},1) + 2) ^ 2;

        % Compute the residual
        residual = img - reconstruction;

        for i_fm = 1 : p.filters_no
            % Gradient: -2(residual*filter)
            grad_fm = -2 * imfilter(residual, fb{i_fm}, 'symmetric', 'same', 'conv');

            % Apply gradient
            fm = feature_maps{i_fm} - p.gd_step_size_fm*grad_fm;

            % Soft-thresholding
            feature_maps{i_fm} = max(abs(fm) - p.lambda_l1, 0) .* sign(fm);
        end
    end 

    reconstruction = gather(reconstruction);

end