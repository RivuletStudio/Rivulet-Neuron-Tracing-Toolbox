function [] = convolutional_filter_learning(resume_fb_no, p)
%  convolutional_filter_learning  learns a convolutional filter bank using
%                                 the algorithm presented in [1]
%
%  Synopsis:
%     convolutional_filter_learning
%     convolutional_filter_learning(resume_fb_no)
%
%  Input:
%     resume_fb_no = when resuming a previous simulation, start from the
%                    given filter bank number (default=0, set to -1 to
%                    remove the previous simulation entirely (with 0 only
%                    img/txt dumps of the filters are removed))
%
% [1] R. Rigamonti, M. Brown, V. Lepetit "Are Sparse Representations Really
%     Relevant for Image Classification?", IEEE Conf. on Comput. Vis. and
%     Pattern Recogn., 2011

%  author: Roberto Rigamonti, CVLab EPFL
%  e-mail: roberto <dot> rigamonti <at> epfl <dot> ch
%  web: http://cvlab.epfl.ch/~rigamont
%  date: April 2012
%  last revision: 27 April 2012

addpath(genpath('helper_functions'));
if (nargin==0)
    resume_fb_no = 0;
else
    if (nargin>1 || ~isnumeric(resume_fb_no))
        error('Wrong parameters');
    end
end

% p = get_convlrn_config(); % <--- MODIFY HERE the algorithm's parameters

% Setup directories according to the parameters set in the configuration
% file and the iteration number that has to be resumed
[p.paths] = setup_directories(p,resume_fb_no);

% Load the CIFAR-10 dataset, performing the whitening if requested to do so
[dataset] = load_2d_neuron_patches(p);

% Initialize the filter bank
[fb] = initialize_fb(p,resume_fb_no);

% Get current iteration number as the product of the number of iterations
% required for a single dump of the filter bank and the resumed filter bank
% number
it_count = resume_fb_no*p.iterations_no+1;

% Optimize filter bank
while(true)
    if (rem(it_count,p.iterations_no)==0)
        fprintf('## Iteration %d ##\n',it_count);
    end

    %% Extract a sample from the dataset
    sample = dataset{randi(length(dataset))};

    %% Compute the feature maps for the given sample
    feature_maps = cell(p.filters_no,1);

    % Initialize the feature maps.
    for i_fm = 1:p.filters_no
        feature_maps{i_fm} = imfilter(sample,fb{i_fm},'symmetric','same','corr');
    end

    % Perform ISTA for the given number of steps.
    % This basically accounts to a step in the direction opposite to the
    % gradient of the reconstruction error, followed by a soft-thresholding of
    % the values in the feature maps.
    % We are not interested in having a good reconstruction, that's why the
    % number of steps is small.
    for i_step = 1:p.ISTA_steps_no
        % Compute the reconstruction
        reconstruction = imfilter(feature_maps{1},fb{1},'symmetric','same','corr');
        for i_fm = 2:length(feature_maps)
            reconstruction = reconstruction+imfilter(feature_maps{i_fm},fb{i_fm},'symmetric','same','corr');
        end
        % Normalize the reconstruction.
        % Empirically, we have found that dividing by filter's area+2 gives good
        % results.
        reconstruction = reconstruction/(size(fb{1},1)+2)^2;

        % Compute the residual
        residual = sample-reconstruction;

        for i_fm = 1:p.filters_no
            % Gradient: -2(residual*filter)
            grad_fm = -2*imfilter(residual,fb{i_fm},'symmetric','same','conv');
            % Apply gradient
            fm = feature_maps{i_fm}-p.gd_step_size_fm*grad_fm;
            % Soft-thresholding
            feature_maps{i_fm} = max(abs(fm)-p.lambda_l1,0).*sign(fm);
        end
    end

    %% Optimize the filters
    % Compute the reconstruction
    reconstruction = imfilter(feature_maps{1},fb{1},'symmetric','same','corr');
    for i_fm = 2:length(feature_maps)
        reconstruction = reconstruction+imfilter(feature_maps{i_fm},fb{i_fm},'symmetric','same','corr');
    end
    % Normalize the reconstruction.
    % Empirically, we have found that dividing by filter's area+2 gives good
    % results.
    reconstruction = reconstruction/(size(fb{1},1)+2)^2;
    residual = sample-reconstruction;

    residual = residual(floor(p.filters_size/2)+1:end-floor(p.filters_size/2),floor(p.filters_size/2)+1:end-floor(p.filters_size/2));
    for i_fm = 1:p.filters_no
        fm = feature_maps{i_fm};

        % Compute filter's gradient as the valid correlation of the feature
        % maps with the residual
        grad_filter = -2*filter2(residual,fm,'valid');

        % Update the filter
        fb{i_fm} = fb{i_fm}-p.gd_step_size_filters*grad_filter;
    end

    % Re-normalize the filter bank
    for i_filter = 1:p.filters_no
        fb{i_filter} = fb{i_filter}/(norm(fb{i_filter}(:)));
    end

    %% Eventually, dump the filter bank to a file
    if(rem(it_count,p.iterations_no)==0)
        save_filter_bank(p,fb,it_count);
    end

    it_count = it_count+1;
end

end
