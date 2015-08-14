%   splits multi-dimensional data into echos and channels prior to unwrapping

function data = fm_split_rescale(data)

file_code = data.file_code;
root_dir = data.root_dir;
readfile_dirs = data.readfile_dirs;
n_channels = data.n_channels;
phase_range = data.phase_range;
echoes_to_use = data.echoes_to_use;
n_echoes_to_use = data.n_echoes_to_use;
fnCurrentMagImages = data.fnCurrentMagImages;
fnCurrentPhaseImages = data.fnCurrentPhaseImages;
nii_pixdim = data.nii_pixdim;
nii_dim = data.nii_dim;
reform_subdir = data.reform_subdir;

%   Check that data is there to be split
switch file_code
    case {'SESPM','SCSPM','SPM'}
        pm = 2;
    otherwise
        pm = 1;
end

for m = 1:pm
    for j=1:n_echoes_to_use
        n=echoes_to_use(j);
        switch file_code
            case {'SE','SCSE'}
                readfile_dir = char(readfile_dirs(n));
            case {'SESPM','SCSESPM'}
                readfile_dir = char(readfile_dirs(2*(n-1)+m));
            case {'SPM','SCSPM'}
                readfile_dir = char(readfile_dirs(m));
            otherwise
                readfile_dir = char(readfile_dirs);
        end
        readfile = fullfile(root_dir, readfile_dir, reform_subdir, 'Image.nii');
        if exist(readfile) ~=2
            error(['Couldn''t find ' readfile]);
        else
            disp(['Analysing ' readfile]);
        end
    end
end


disp(['Writing fieldmaps to ' data.writefile_dir]);

split = 'no';
%   See if this has been done already - if files already exist
for j=1:n_echoes_to_use
    for m=1:n_channels
        if(exist(char(fnCurrentMagImages(m,j))))~=2 || (exist(char(fnCurrentPhaseImages(m,j))))~=2 || strcmp(data.do_all_remaing_processing_stages, 'yes')
            split = 'yes';
            data.do_all_remaing_processing_stages = 'yes';
            break;
        end
    end
end

%   Separate the magnitude and phase images into separate echos, and rescale the phase images to 0->2PI
switch split
    case 'yes'
        disp(' * - separating echoes and phase and magnitude data');
        for m = 1:2     %   phase/magnitude
            for j=1:n_echoes_to_use
                n=echoes_to_use(j);
                switch file_code
                    case {'SE','SCSE'}
                        one_echo_nii = load_nii(fullfile(root_dir, char(readfile_dirs(n)), reform_subdir, 'Image.nii'), (1:1:nii_dim(5)), m);
                    case {'SPM','SCSPM'}
                        hdr = load_nii_hdr(fullfile(root_dir,char(readfile_dirs(1)), reform_subdir, 'Image.nii'));
                        switch hdr.dime.dim(1)
                            case 3
                                one_echo_nii = load_nii(fullfile(root_dir, char(readfile_dirs(m)), reform_subdir, 'Image.nii'));
                            case 4
                                one_echo_nii = load_nii(fullfile(root_dir, char(readfile_dirs(m)), reform_subdir, 'Image.nii'), (1:1:nii_dim(5)));
                                %srobi 3/3/2011                                    one_echo_nii = load_nii(fullfile(root_dir, char(readfile_dirs(m)), reform_subdir, 'Image.nii'), n);
                            case 5
                                one_echo_nii = load_nii(fullfile(root_dir, char(readfile_dirs(m)), reform_subdir, 'Image.nii'), n, (1:1:nii_dim(6)));
                        end
                    case {'SESPM','SCSESPM'}
                        one_echo_nii = load_nii(fullfile(root_dir, char(readfile_dirs(2*(n-1)+m)), reform_subdir, 'Image.nii'));
                    otherwise
                        one_echo_nii = load_nii(fullfile(root_dir, char(readfile_dirs), reform_subdir, 'Image.nii'), n, (1:1:nii_dim(6)), m);
                end
                for p=1:n_channels
                    %                 disp(sprintf('Creating magnitude and phase images for channel %s, echo %s', int2str(m), int2str(n)));
                    one_echo_one_channel_PorM_nii = make_nii(single(one_echo_nii.img(:,:,:,p)));
                    if m == 2
                        %   rescale phase to 0->2!PI
                        one_echo_one_channel_PorM_nii.img = 2*pi*(one_echo_one_channel_PorM_nii.img-phase_range(1))./(phase_range(2)-phase_range(1));
                        centre_and_save_nii(one_echo_one_channel_PorM_nii, char(fnCurrentPhaseImages(p,j)), nii_pixdim);
                    else
                        centre_and_save_nii(one_echo_one_channel_PorM_nii, char(fnCurrentMagImages(p,j)), nii_pixdim);
                    end
                end
            end
        end
    case 'no'
        disp(' - separated data found');
end

