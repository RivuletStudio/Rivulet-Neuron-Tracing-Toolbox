function [p] = get_config()
%  get_config  setup the configuration for the convolutional filter
%              learning framework
%
%  Synopsis:
%     [p] = get_config()
%
%  Ouput:
%     p = structure containing the parameters required by the system

%  author: Roberto Rigamonti, CVLab EPFL
%  e-mail: roberto <dot> rigamonti <at> epfl <dot> ch
%  web: http://cvlab.epfl.ch/~rigamont
%  date: April 2012
%  last revision: 27 April 2012

%% Dataset's parameters
% File containing the path for the CIFAR-10's training batches
p.dataset_filelist = '/home/siqi/Desktop/err_GMR_57C10_AD_01-1xLwt_attp40_4stop1-f-A01-20110325_3_A3-left_optic_lobe.v3draw.extract_4/neuron2d_filelist.txt';

% Number of images per block
p.imgs_per_block = 168024 * 4;

%% Whitening filter's parameters
% Flag for activating image whitening
p.whiten_images = false;

% Whitening filter's size
p.wf_size = 11;

% Number of samples collected for the computation of the whitening filter
p.wf_samples_no = 300000;

% Minimum standard deviation for the samples used in the computation of the
% whitening filter
p.wf_samples_std = 1e-1;

% Whitening filter's filename
p.wf_filename = 'w_filter.mat';

%% Filter bank's parameters
% Number of filters in the filter bank
p.filters_no = 100;

% Filter's size
p.filters_size = 11;

%% Optimization algorithm's parameters
% Number of ISTA steps on the coefficients
p.ISTA_steps_no = 10;

% Gradient step size for the feature maps
p.gd_step_size_fm = 1e-1;

% Gradient step size for the filters
p.gd_step_size_filters = 5e-5;

% Regularization's parameter
p.lambda_l1 = 2e-2;

%% Results' parameters
% Results' path
p.results_path = 'results';

% Number of iterations before dumping the results
p.iterations_no = 100;

% Vertical/horizontal spacing between filters in filter bank's
% representation
p.v_space = 4;
p.h_space = 4;

% Pixel size for the filters in filter bank's representation
p.pixel_size = 2;

end
