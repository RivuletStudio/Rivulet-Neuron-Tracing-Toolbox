function data = fm_get_phase_range(data)

root_dir = data.root_dir;
readfile_dirs = data.readfile_dirs;
nii_dim = data.nii_dim;
file_code = data.file_code;
reform_subdir = data.reform_subdir;
readfile_dirs = data.readfile_dirs;

%   Finding the phase range in the data
switch file_code
    case {'SE','SCSE'}
        one_echo_nii = load_nii(fullfile(root_dir, char(readfile_dirs(1)), reform_subdir, 'Image.nii'), (1:1:nii_dim(5)), 2);
    case {'SPM','SCSPM'}
        hdr = load_nii_hdr(fullfile(root_dir,char(readfile_dirs(1)), reform_subdir, 'Image.nii'));
        switch hdr.dime.dim(1)
            case 3
                one_echo_nii = load_nii(fullfile(root_dir, char(readfile_dirs(2)), reform_subdir, 'Image.nii'));
            case 4
                one_echo_nii = load_nii(fullfile(root_dir, char(readfile_dirs(2)), reform_subdir, 'Image.nii'), (1:1:nii_dim(5)));
            case 5
                one_echo_nii = load_nii(fullfile(root_dir, char(readfile_dirs(2)), reform_subdir, 'Image.nii'), 2, (1:1:nii_dim(6)));
        end
    case {'SESPM','SCSESPM'}
        one_echo_nii = load_nii(fullfile(root_dir, char(readfile_dirs(2)), reform_subdir, 'Image.nii'));
    otherwise
        one_echo_nii = load_nii(fullfile(root_dir, char(readfile_dirs), reform_subdir, 'Image.nii'), 1, (1:1:nii_dim(6)), 2);
end
one_echo_one_channel = one_echo_nii.img(:,:,:,1);
% assume that the smallest range possible is 2048 (usually 4096)
phase_range(1) = single(round(min(vector(one_echo_one_channel))/2048)*2048);
phase_range(2) = single(round(max(vector(one_echo_one_channel))/2048)*2048);
data.phase_range = phase_range;
disp(sprintf('   - the phase range in the data is %i -> %i', phase_range(1), phase_range(2)));

