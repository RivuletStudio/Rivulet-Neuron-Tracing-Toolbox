%   Modify maps to chart the maximum remapping gradient possible without
%   causing conflict

function data = fm_get_epi_pars(data)

extension = data.extension;
echoes_to_use = data.echoes_to_use;
fnCurrentFieldmaps = data.fnCurrentFieldmaps;
root_dir = data.root_dir;
readfile_dirs = data.readfile_dirs;
nii_pixdim = data.nii_pixdim;
gradient_thresh = data.gradient_thresh;

%   get the receiver bandwidth/pix, even if no gradient threshold is being done
if data.epi_dir ~= -1
    epi_dir = data.epi_dir;
    epi_header_file = fullfile(root_dir, epi_dir, 'text_header.txt');
    if exist(epi_header_file)==2
        rbw = str2double(search_all_header_func(epi_header_file, sprintf('PixelBandwidth')));
    else
        rbw = -1;
    end
elseif data.rbw ~=-1
    rbw = data.rbw;
end
%   determine the phase-encode direction and phase-encode direction (PE_dir)
%   change direction labelling to something more intuitive
if data.epi_dir ~= -1
    PE_dir = search_all_header_func(epi_header_file, 'InPlanePhaseEncodingDirection');
    switch PE_dir
        case 'COL'
            data.readout_dimension = 2;
            APPA = search_all_header_func(epi_header_file, 'dInPlaneRot');
            switch APPA
                case '-1'
                    PE_dir = 'y-';
                otherwise
                    PE_dir = 'y';
            end
            PE_dir = PE_dir;
        case 'ROW' % could do with a bit more checking
            readout_dimension = 3;
            LRRL = search_all_header_func(epi_header_file, 'dInPlaneRot');
            switch LRRL
                case '-1'
                    PE_dir = 'x-';
                otherwise
                    PE_dir = 'x';
            end
            PE_dir = PE_dir;
        otherwise
            PE_dir = -1;
    end
    data.PE_dir = PE_dir;
end
PE_dir = data.PE_dir;
switch PE_dir
    case {'-y'}
        PE_dir='y-';
        readout_dimension = 2;
    case {'y','y-'}
        readout_dimension = 2;
    case {'-x'}
        PE_dir='x-';
        readout_dimension = 3;
    case {'x','x-'}
        readout_dimension = 3;
    otherwise
        readout_dimension = -1;
end
data.readout_dimension = readout_dimension;
data.PE_dir = PE_dir;

