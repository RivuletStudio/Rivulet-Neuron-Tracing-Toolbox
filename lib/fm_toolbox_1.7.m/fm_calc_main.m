% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   fm_calc_main.m
%
%   Simon Robinson. 19.1.2007
%   This version 15.3.2011
%
%   For the calculation of MRI field maps, e.g. for the distortion correction of EPI.
%
%   The method is based on a Multi-echo GE scan with two or more echoes or a number of GE scans with different echo times
%
%   Requirements:
%
%   NIfTI data ('Image.nii') should be a multi-dimensional NIfTI structure (x,y,z,echo,channel,phase/mag). Echoes and/or phase/mag can also be in separate files.
%       If phase and magnitude are in different scans, set sep_files_for_pm = 'yes' and use readfile_dirs = {'$dir(M)','$dir(P)'}; or if sep_files_for_echoes = 'yes'; then readfile_dirs = {'$dir(Mag TE1)','$dir(Phase TE1)','$dir(Mag TE2)','$dir(Phase TE2)'};
%       Organising separate-channel data info a NIfTI structure like this can either be achieved with a home-written MATLAB script using the NIfTI tools from Jimmy Shen (http://www.mathworks.com/matlabcentral/fileexchange/8797-tools-for-nifti-and-analyze-image) - mainly (load_nii, make_nii and save_nii)
%       Alternatively, for Siemens DICOM data, data can be sorted and converted with dicom_sort_convert_main.m (http://www.mathworks.com/matlabcentral/fileexchange/22508-siemens-dicom-sort-and-convert-to-nifti)
%       As well as reformatting data to into a multi-dimensional NIfTI structure (x,y,z,ne,channel,p/m) dicom_sort_convert_main writes all scan parameters to a text file (which can be accessed in this program, meaning less input is needed), it also creates a summary of all scans undertaken and has some other handy features.
%
%   This program uses FSL programs, principally PRELUDE and BET, so FSL needs to be installed. This MATLAB program should either be run under Linux, or started from a cygwin shell, so that command-line programs can be run using the 'unix' function.
%       As an alternative to FSL's PRELUDE, or PHUN can be used for unwrapping, which is very fast (Stephan Witoszynskyj et al., Medical Image Analysis, 2009).
%
%   Essential parameters, to be defined in '%%Start of User-defined Parameters%%%':
%
%   n_channels
%   sep_files_for_echoes = % ('no'/'yes');
%   sep_files_for_pm = % ('no'/'yes');
%   root_dir = '/path_to_nifti/nifti';
%   readfile_dirs = {'directory_name'};
%   writefile_dir = '/path_to_fieldmap/';
%
%   Additional compulsory and optional parameters may be defined, depending on how the data were sorted/converted
%
%   Example 1: data converted/reformatted with dicom_sort_convert_main, essential parameters are only those above
%   Optional: if do_gradient_thresholding = 'yes', then the directory of the epi to be corrected should be specified, so that the receiver bandwidth and gradient direction can be determined
%             eg. epi_dir = '11';
%
%   Example 2: data NOT converted/reformatted with dicom_sort_convert_main
%   Compulsory: TEs = [5040 13040]; % echo times, in us.
%   Optional: if do_gradient_thresholding = 'yes', then the receiver bandwidth and gradient direction need to be specified
%             rbw = 1055;
%             PE_dir = 'y';
%
%   credits:
%       fsl: http://www.fmrib.ox.ac.uk/fsl/
%       Jimmy Shen's excellent NIfTI tools: http://www.mathworks.com/matlabcentral/fileexchange/8797-tools-for-nifti-and-analyze-image
%       Damien Garcia's smoothn function: http://www.biomecardio.com/matlab/smoothn.html
%       find3 is based on FINDN and FIND by Loren Shure, Mathworks Inc
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fm_calc_main(data_from_caller)
%%%%%%%%%%%%%%Start of User-defined Parameters%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Any options in fm_caller.m which are the same for all the user's analysis can be moved here
% Options specified in fm_caller.m prevail
data.multi_channel_data = 'yes' ; % available just in case this might be used for single-channel data
data.processing_option = 'all_at_once'; % 'all_at_once' or 'slice_by_slice' for creating field maps for large data sets with limited RAM
data.gradient_thresh = 0.8; % the maximum gradient allowed in voxel shift maps = 0.8 (must be below 1 for thresholding to work, and needs specification of RBW in EPI)
data.cleanup = 'no';    % removes all interim files except the final fieldmap ('fieldmap.nii')
data.extension = '.nii';     % '.nii' gives single-file NIfTI, '' gives '.img'/'.hdr' pair
data.prelude_thresholds = [8, 20]; % -t in prelude % the first value is that used for single-channel (should be low, e.g. 3-15), the second higher, for combined data. For the first, a value of something like 8 is suggested for 8-channel sep-channel, 4 for 24-32 channel
data.smoothing_kernel = [7 7 7];
data.BET_f_sep_mask = 0.3;  % BET threshold for separate channel images. Large values give small outlines - for jump correction, should be very restrictive (high value; circa 0.7)
data.BET_f_small_mask = 0.5; % BET threshold for combined images - for jump correction, should be very restrictive (high value; circa 0.5-8)
data.BET_f_large_mask = 0.4; % BET threshold for combined images - for masking fieldmap, should be quite lenient (low value; circa 0.4) - this is just the first step in denoising
data.unwrap_method = 'prelude'; %'prelude'/'phun', 'prelude' = FSL's PRELUDE, 'phun' = PHUN a.k.a unwrap-2d, which is very fast and available from Stephan Witoszynskyj by private mail (Stephan Witoszynskyj et al., Medical Image Analysis, 2009)
data.method = 'sep-channel'; %'phase-match'/'sep-channel'/'conj-diff' - these are PD,SC and HP in Robinson and Jovicich (MRM, 2011)
    %'phase-match': calls fm_phase_match : matches the phase of each channel using a reference pixel (that with the highest value in the magnitude product over channels), and creates combined phase images at each echo time, which are then unwrapped and further processed
    %'conj-diff': calls fm_conj_diff : calculates a single weighted mean phase-difference map using sum(FSbar), where F is the complex value for the first echo time, and Sbar is the complex conjugate of the complex value at the second echo time
    %'sep-channel': unwraps channels separately, creates separate phase images and separate field maps which are then combined
data.phase_cor_method = 'hammond'; %'hammond'/'schaefer' - for phase matching, this option determines how the correction region of interest is defined
    % 'hammond' = the cROI is the value in the central 3x3x3 voxels in the image
    % 'schaefer' = the cROI is the single voxel value at the position of the maximum of the magnitude product over all channels
    % if there is likely to be no/unreliable signal at the image centre, use schaefer
%%%%%%%%%%%%%%%%%End of User-defined Parameters%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

data.do_all_remaing_processing_stages = 'no';

% overwrite the standard settings above with selections in 'caller_selections' - the parameters passed by fm_calc_caller
caller_selections = fieldnames(data_from_caller);
for i=1:length(caller_selections);
    data.(caller_selections{i})=data_from_caller.(caller_selections{i});
end

writefile_dir_store = data.writefile_dir;
tic;

if ~isvar('data.epi_dir')
    data.epi_dir = -1;
end
if ~isvar('data.rbw')
    data.rbw = -1;
end
if ~isvar('data.PE_dir')
    data.PE_dir = -1;
end

% determine likely fsl_prefix (can be overridden by defining above)
if ~(exist('fsl_prefix')) || ~(exist('fsl_suffix'))
    switch ispc
        case 1
            fsl_prefix = 'avw'; %likely pre-fsl 4
            fsl_suffix = '.exe';
        case 0
            fsl_prefix = 'fsl'; %guess post fsl 4
            fsl_suffix = '';
    end
end
data.fsl_prefix = fsl_prefix;
data.fsl_suffix = fsl_suffix;

%   classify by how the data is divided between scans: file_code = SC (separate channels) SE (separate echoes) SPM (separate phase and magnitude)
data.file_code = '';
switch data.multi_channel_data
    case 'yes'
        data.file_code = [data.file_code 'SC'];
end
switch data.sep_files_for_echoes
    case 'yes'
        data.file_code = [data.file_code 'SE'];
end
switch data.sep_files_for_pm
    case 'yes'
        data.file_code = [data.file_code 'SPM'];
end

%   see if there is a reform directory (data reformed to (x,y,z,ne,p/m,channels) or similar - as created by dicom_sort_convert_main.m - http://www.mathworks.com/matlabcentral/fileexchange/22508)
reformdirtemp = fullfile(data.root_dir,char(data.readfile_dirs(1)),'reform');
if ~exist(reformdirtemp,'dir')
    reform_subdir = '';
else
    reform_subdir = 'reform';
end
data.reform_subdir = reform_subdir;

%   Make directory for results
[s,mess] = mkdir(data.writefile_dir);
if s == 0
    error('No permission to make directory %s', data.writefile_dir);
end

%   Prepare command to unzip all results
unzip_command = sprintf('for i in `find %s -name "*.gz"` ; do gunzip -d -f -q $i ; done', unix_format(fullfile(data.writefile_dir, '/')));
data.unzip_command = unzip_command;

%   Make a directory for files used in many methods (e.g. sep mag/phase)
sep_dir = sprintf('%s/sep_%s', data.writefile_dir, data.unwrap_method);
%   Make directory for results
[s,mess] = mkdir(sep_dir);
if s == 0
    error('No permission to make directory %s/m', sep_dir);
end
data.sep_dir = sep_dir;

%   make directory names
clear fm_dir
switch data.multi_channel_data
    case 'yes'
        switch data.method
            case 'phase-match'
                fm_dir = 'fm_phase-match';
                fm_dir = [fm_dir '_' phase_cor_method];
            case 'sep-channel'
                fm_dir = 'fm_sep-channel';
            case 'conj-diff'
                fm_dir = 'fm_conj-diff';
            otherwise
                error('no valid ''method'' specified in user-defined parameters in fm_calc_main ; should be ''phase-match'', ''sep-channel'' or ''conj-diff''');
        end
    case 'no'
        fm_dir = 'fm';
end

switch data.unwrap_method
    case 'prelude'
        fm_dir = [fm_dir '_prelude'];
    case 'phun'
        fm_dir = [fm_dir '_phun'];
    case 'snaphu'
        fm_dir = [fm_dir '_snaphu'];
end
data.writefile_dir = fullfile(data.writefile_dir, fm_dir);

[s,mess] = mkdir(data.writefile_dir);
if s == 0
    error('No permission to make directory %s/m', data.writefile_dir);
end

switch data.multi_channel_data
    case 'yes'
        channel_key = 'channel_';
    case 'no'
        data.n_channels = 1;
        channel_key = '';
end
data.channel_key = channel_key;

%   find out the number of echoes
data = fm_get_nes(data);

%   Find out the number of echoes present; need 2 - use 3 at the most
switch true
    case data.n_echoes > 2
        data.n_echoes_to_use = 2;
        data.echoes_to_use = [1,3];
    case data.n_echoes == 2
        data.n_echoes_to_use = 2;
        data.echoes_to_use = [1,2];
    case (data.n_echoes == 1 || data.n_echoes == -1)
        warning('!!!: At least 2 phase images are needed for field mapping; here there are only %s', num2str(n_echoes));
        warning('Will process the first echo then bail later');
        data.n_echoes_to_use = 1;
        data.echoes_to_use = [1];
    otherwise
end

%   see if there are text_headers with sequence parameters in (as created by dicom_sort_convert_main.m - http://www.mathworks.com/matlabcentral/fileexchange/22508)
switch data.file_code
    case {'SE','SESPM','SCSESPM'}
        for j=1:data.n_echoes_to_use
            header_file = fullfile(data.root_dir, char(data.readfile_dirs(j)), 'text_header.txt');
            if ~exist(header_file,'file')
                data.text_header = 'no';
                continue;
            else
                data.text_header = 'yes';
            end
        end
    otherwise
        if iscell(data.readfile_dirs) == 1
            header_file = fullfile(data.root_dir, char(data.readfile_dirs(1)), 'text_header.txt');
        else
            header_file = fullfile(data.root_dir, data.readfile_dirs, 'text_header.txt');
        end
        if ~exist(header_file,'file')
            data.text_header = 'no';
        else
            data.text_header = 'yes';
        end
end

%   find out the echo times
switch data.text_header
    case 'yes'
        data = fm_get_TEs(data);
    case 'no'
        if ~exist('TEs')
            error('TEs need to be defined in the user parameters in fm_calc_main.m: use the format ???');
        else
            data.TEs = TEs;
        end
    otherwise
        error('was not able to establish if there are text_header.txt files for each Imagedicom_sort_convert.nii');
end
%   sort the echos in the right order and the data according to the echos
[data.TEs, data.TE_sorted_indices] = sort(data.TEs);

%   Define file names
data = fm_define_filenames(data);
fnReconMag = data.fnReconMag;
fnAllMags = data.fnAllMags;

%   Get voxel dimensions
data = fm_get_voxel_dimensions(data);

%   find out the range of phase values
data = fm_get_phase_range(data);

%   Separate the magnitude and phase images into separate echoes, and rescale the phase images to 0->2PI
data = fm_split_rescale(data);

%   Reconstruct a single magnitude image and magnitude weighting images
switch data.multi_channel_data
    case 'yes'
        data = fm_recon_mags(data);
    case 'no'
        copyfile(char(data.fnCurrentMagImages(1,1)), data.fnReconMag);
end

%'phase-match'/'sep-channel'/'conj-diff'
switch data.multi_channel_data
    case 'yes'
        switch data.method
            case 'phase-match'
                %   Phase-match the data
                data = fm_phase_match(data);
            case 'conj-diff'
                %   Phase-match the data
                data = fm_conj_diff_new(data);
                %   from here on there's just one phase image (which is the phase difference)
                data.number_of_echoes_to_use = 1;
        end
    case 'no'
        disp('Single-channel data, ignoring specified phase combination method');
end

if strcmp(data.method,'phase-match') || strcmp(data.method,'conj-diff') || strcmp(data.multi_channel_data,'no')
    %   from here on there's one channel to consider, because the n_channels have been combined
    data.n_channels = 1;
    data.despeckle_method = 'EXTREMES';
else
    data.despeckle_method = 'STD';
end

%   Unwrap phase images
data = fm_unwrap(data);

%   make a generous mask
data = fm_make_mask(data);

%   Correct for n2PI jumps between slices in phase images
data = fm_jump_correct_phase(data);

if (data.n_echoes < 2)
    warning('!!!: There were not enough echoes to make fieldmaps, quitting here');
    return;
end

%   Make the fieldmaps
data = fm_make_fieldmaps(data);

%   Correct for n2PI jumps that might have occured between echoes
data = fm_jump_correct_fieldmaps(data);

if strcmp(data.multi_channel_data,'yes') && strcmp(data.method,'sep-channel')
    %  Create trimmed, weighted mean and stdev maps
    data = fm_median_mean_std(data);
end

disp(['Calculation of fieldmaps took ' secs2hms(toc)]);

%   Mask the fieldmap results using a BET mask
data = fm_mask_fm(data);

%   Despeckle fieldmaps, either with FUGUE or interpolation
data = fm_despeckle(data);

%   Smooth field maps
data = fm_smooth(data);

%   Get parameters related to the EPI.  These are used in gradient thresholding and drafting a FUGUE unwarping command (with as much information as is available)
data = fm_get_epi_pars(data);

%   Threshold shift gradients
switch data.do_gradient_thresholding
    case 'yes'
        data = fm_threshold(data);
end

disp(['Calculation of denoised fieldmaps took ' secs2hms(toc)]);

%   Pick the fieldmap to use for unwarping
fieldmap_to_use = char(data.fnCurrentFieldmaps(1));

%   get rid of everything other than the final fieldmap
switch data.cleanup
    case 'yes'
        final_fm_fn = fullfile(writefile_dir_store, ['fieldmap' data.extension]);
        copyfile(fieldmap_to_use, final_fm_fn);
        [status, message, messageid] = rmdir(data.writefile_dir, 's');
        [status, message, messageid] = rmdir(sep_dir, 's');
    case 'no'
        final_fm_fn = fullfile(data.writefile_dir, ['fieldmap' data.extension]);
        copyfile(fieldmap_to_use, final_fm_fn);
end
disp(['Took ' secs2hms(toc) ' to calculate']);
disp(['Written final fieldmap to ' final_fm_fn]);

%   just for the purposes of creating a command string for FUGUE
if data.epi_dir == -1
    epi = 'epi';
    epi_output = 'epi_output';
else
    epi = fullfile(data.root_dir, data.epi_dir, 'Image.nii'); 
    epi_output = fullfile(data.root_dir, data.epi_dir, 'Image_dc.nii');
end
if data.rbw == -1;
    dwell_time = '1/rbw';
else
    dwell_time = num2str(1.0/data.rbw);
end
if data.PE_dir == -1;
    PE_dir = '[phase-encode-direction]';
else
    PE_dir = data.PE_dir;
end

%   help out with the unwarp command for EPI distortion correction, with as much info as is available
unwarp_command = sprintf('fugue -i %s --dwell=%s --loadfmap=%s -u %s --unwarpdir=%s -v', epi, dwell_time, final_fm_fn, epi_output, PE_dir);
disp('Unwarp command is something like :');
disp(unwarp_command);
disp('');
end



