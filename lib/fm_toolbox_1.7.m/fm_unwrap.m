%   Unwrap single-channel phase images with FSL's Prelude
function data = fm_unwrap(data)

extension = data.extension;
n_channels = data.n_channels;
fnCurrentPhaseImages = data.fnCurrentPhaseImages;
fnCurrentMagImages = data.fnCurrentMagImages;
fnReconMag = data.fnReconMag;
n_echoes = data.n_echoes;
echoes_to_use = data.echoes_to_use;
unzip_command = data.unzip_command;
unwrap_method = data.unwrap_method;
writefile_dir = data.writefile_dir;
nii_pixdim = data.nii_pixdim;
prelude_thresholds = data.prelude_thresholds;
fsl_prefix = data.fsl_prefix;
fsl_suffix = data.fsl_suffix;
method = data.method;

switch method
    case {'conj-diff','phase-imaging'}
        n_phase_images_to_unwrap = 1;
        prelude_threshold = prelude_thresholds(1);
    case {'phase-match'}
        n_phase_images_to_unwrap = 2;
        prelude_threshold = prelude_thresholds(2);
    otherwise
        if data.n_echoes > 1
            n_phase_images_to_unwrap = 2;
        else
            n_phase_images_to_unwrap = 1;
        end
        prelude_threshold = prelude_thresholds(1);
end

if exist(data.fnBetMaskSubLarge) == 2
    fnBetMaskSubLarge = data.fnBetMaskSubLarge;
    mask_string = sprintf('-m %s', fnBetMaskSubLarge);
else
    mask_string = '';
end


%   Check if the data has been unwrapped already
unwrap = 'no';
for m = 1:n_channels
    for j=1:n_phase_images_to_unwrap
        fnCurrentPhaseImagesUnwrapped(m,j) = {strrep(char(fnCurrentPhaseImages(m,j)), extension, ['_unwrapped' extension])};
        if exist(char(fnCurrentPhaseImagesUnwrapped(m,j))) ~= 2 || strcmp(data.do_all_remaing_processing_stages, 'yes')
            unwrap = 'yes';
            data.do_all_remaing_processing_stages = 'yes';
        end
    end
end

switch unwrap
    case 'yes'
        disp(' * - unwrapping phase images');
        for m = 1:n_channels
            for j=1:n_phase_images_to_unwrap
                n=echoes_to_use(j);
                mag_file = char(fnCurrentMagImages(m,j));
                phase_file = char(fnCurrentPhaseImages(m,j));
                phase_file_unwrapped = char(fnCurrentPhaseImagesUnwrapped(m,j));
                %   Unwrap
                if n_channels ~= 1
                    disp(sprintf('Unwrapping phase images for channel %s, echo %s', int2str(m), int2str(n)));
                else
                    disp(sprintf('Unwrapping phase echo %s', int2str(n)));
                end
                switch unwrap_method
                    case 'prelude'
                       unwrap_command = sprintf('export LD_LIBRARY_PATH="/usr/lib/fsl:/usr/lib/fsl"; prelude -a %s -p %s -o %s -s -t %i',  unix_format(mag_file), unix_format(phase_file), unix_format(phase_file_unwrapped), prelude_threshold);
                  %      unwrap_command = sprintf('export LD_LIBRARY_PATH="/usr/lib/fsl:/usr/lib/fsl"; prelude -a %s -p %s -o %s -s %s',  unix_format(mag_file), unix_format(phase_file), unix_format(phase_file_unwrapped), mask_string);
                  switch method
                      case 'sep-channel'
                          [res, message] = unix(unwrap_command);
                          disp('');
                      otherwise
                        [res, message] = unix(unwrap_command);
                        if res ~= 0
                            error('Couldn''t unwrap: %s', message);
                        end
                        [res, message] = unix(unzip_command);
                        if res ~= 0
                            warning('Couldn''t unzip: %s', message);
                        end
                        %   centre again
                        centre_and_save_nii(load_nii(phase_file_unwrapped), phase_file_unwrapped, nii_pixdim);
                  end
                    case 'phun'
                        switch method
                            case 'sep-channel'
%                                unwrap_command = sprintf('phun -2 -n 1 --snr_min 1 --polar -o %s %s %s', unix_format(phase_file_unwrapped),  unix_format(mag_file), unix_format(phase_file));
                                unwrap_command = sprintf('phun -2 -n 1 --tq_min 0.02 --polar -o %s %s %s', unix_format(phase_file_unwrapped),  unix_format(mag_file), unix_format(phase_file));
                            otherwise
                                unwrap_command = sprintf('phun -2 -n 1 --tq_min 0.02 --polar -o %s %s %s', unix_format(phase_file_unwrapped),  unix_format(mag_file), unix_format(phase_file));
                        end
                        [res, message] = unix(unwrap_command);
                        if res ~= 0
                            error('Couldn''t unwrap: %s', message);
                        end
                    case 'snaphu'
                        unwrap_command = sprintf('sh /data/simon/scripts/snaphu_script.sh %s %s',  unix_format(mag_file), unix_format(phase_file));
                        [res, message] = unix(unwrap_command);
                        if res ~= 0
                            error('Couldn''t unwrap: %s', message);
                        end
                    otherwise
                        error('No valid unwrap option (unwrap_method) specified');
                end
            end
        end
    case 'no'
        disp(' - unwrapped data found');
end

data.fnCurrentPhaseImages = fnCurrentPhaseImagesUnwrapped;
