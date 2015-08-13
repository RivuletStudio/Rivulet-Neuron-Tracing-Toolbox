[pathstr, ~, ~] = fileparts(mfilename('fullpath'));
addpath(fullfile(pathstr, 'lib', 'fm_toolbox_1.7.m'));
addpath(fullfile(pathstr, '..', '..', 'v3d', 'v3d_external', 'matlab_io_basicdatatype'));
I = load_v3d_raw_img_file('/home/siqi/hpc-data1/Data/Gold166/gold166_trainingsubset79/SQSelected/Image10/Image10.v3dpbd.v3draw');
initpsf = ones(7,7,7);
[J, PSF] = deconvblind(I, initpsf);
save_v3d_raw_img_file(J, 'deconv.v3draw');
denoiseI = medfilt3(I, [5,5,5]);
save_v3d_raw_img_file(denoiseI, 'denoise.v3draw');
