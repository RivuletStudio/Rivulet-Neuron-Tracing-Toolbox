function data = fm_get_nes(data)

file_code = data.file_code;
root_dir = data.root_dir;
readfile_dirs = data.readfile_dirs;
reform_subdir = data.reform_subdir;

switch file_code
    case {'SE','SCSE'}
        n_echoes = size(readfile_dirs,2);
    case {'SESPM','SCSESPM'}
        n_echoes = size(readfile_dirs,2)/2;
    otherwise
        hdr = load_nii_hdr(fullfile(root_dir,char(readfile_dirs(1)), reform_subdir, 'Image.nii'));
        if hdr.dime.dim(1) == 4 % exception: single-echo, hdr.dime.dim(5) is the number of channels
            n_echoes = 1;
        else
            n_echoes = hdr.dime.dim(5);
        end
end
data.n_echoes = n_echoes;


