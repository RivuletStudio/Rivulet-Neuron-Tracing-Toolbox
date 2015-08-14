function data = fm_get_voxel_dimensions(data);

root_dir = data.root_dir;
readfile_dirs = data.readfile_dirs;
reform_subdir = data.reform_subdir;

if iscell(readfile_dirs) == 1
    hdr = load_nii_hdr(fullfile(root_dir, char(readfile_dirs(1)), reform_subdir, 'Image.nii'));
else
    hdr = load_nii_hdr(fullfile(root_dir, readfile_dirs, reform_subdir, 'Image.nii'));
end
data.nii_dim = hdr.dime.dim;
data.nii_pixdim = hdr.dime.pixdim;
