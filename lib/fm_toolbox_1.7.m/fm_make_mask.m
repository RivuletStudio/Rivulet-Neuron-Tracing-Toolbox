function data = fm_make_mask(data)

fnReconMag = data.fnReconMag;
fnCurrentMagImages = data.fnCurrentMagImages;
fnBetImSmall = data.fnBetImSmall;
fnBetImLarge = data.fnBetImLarge;
fnBetMaskSmall = data.fnBetMaskSmall;
fnBetMaskLarge = data.fnBetMaskLarge;
fnBetMaskSubSmall = data.fnBetMaskSubSmall;
fnBetMaskSubLarge = data.fnBetMaskSubLarge;
fnBetMaskSep = data.fnBetMaskSep;
method = data.method;
n_channels = data.n_channels;
n_echoes_to_use = data.n_echoes_to_use;
echoes_to_use = data.echoes_to_use;
BET_f_small_mask = data.BET_f_small_mask;
BET_f_large_mask = data.BET_f_large_mask;
BET_f_sep_mask = data.BET_f_sep_mask;
root_dir = data.root_dir;
unzip_command = data.unzip_command;
nii_pixdim = data.nii_pixdim;

%   Assume that if this is a linux machine, it is using FSL3+ (where tool
%   names begin 'fsl...', if it is a PC it is using FSL2 in cygwin (where
%   tools begin 'avw...'

switch ispc
    case 0  %   Linux
        fsl_version = 4;
        root_dir = unix_format(root_dir);
        bet_call = 'bet';
        maths_call_dil = 'fslmaths';
        maths_call_smooth = maths_call_dil;
    case 1  %   PC
        fsl_version = 3;
        bet_call = 'bet_32R';
        maths_call_dil = 'avwmaths_32R';
        maths_call_smooth = 'avwmaths++';
end

%   Check if anything needs doing
bet = 'no';

if exist(fnBetMaskSubSmall) ~=2 || exist(fnBetMaskSubLarge) ~=2 || strcmp(data.do_all_remaing_processing_stages, 'yes')
    bet = 'yes';
end

switch bet
    case 'yes'
        for i=1:2
            switch i
                case 1
                    disp(' * - creating a small brain mask with BET from the first echo magnitude image');
                    fnBetIm = fnBetImSmall;
                    BET_f = BET_f_small_mask;
                    fnBetMask = fnBetMaskSmall;
                    fnBetMaskSub = fnBetMaskSubSmall;
                case 2
                    disp(' * - creating a large brain mask with BET from the first echo magnitude image');
                    fnBetIm = fnBetImLarge;
                    BET_f = BET_f_large_mask;
                    fnBetMask = fnBetMaskLarge;
                    fnBetMaskSub = fnBetMaskSubLarge;
            end
            %   Create BET mask
            try
                %   my computer
                %                bet_command = sprintf('export LD_LIBRARY_PATH="/usr/lib/fsl:/usr/lib/fsl"; %s %s %s -f %f -m', bet_call, char(fnReconMag(1,1)), fnBetIm, BET_f);
                % bet_command = sprintf('export LD_LIBRARY_PATH="/usr/lib/fsl:/usr/lib/fsl"; %s %s %s -f %f -m', bet_call, fnReconMag, fnBetIm, BET_f);
                %   sacher
                   bet_command = sprintf('%s %s %s -f %f -m', '/usr/local/fsl/bin/bet', unix_format(char(fnReconMag)), fnBetIm, BET_f);
            catch
                disp('');
            end
            unix(bet_command);
            unix(unzip_command);
            centre_header_file(fnBetIm);
            set_nii_voxel_size(fnBetIm, nii_pixdim);
            %   Move mask to the more sensible filename
                        unix(unzip_command);
            unix(sprintf('mv %s %s', unix_format(fnBetMask), unix_format(fnBetMaskSub)));
            centre_header_file(fnBetMaskSub);
            set_nii_voxel_size(fnBetMaskSub, nii_pixdim);
        end
    case 'no'
        ('- mask found');
end

bet='no';

switch method
    case {'sep-channel','phase-imaging'}
        for m = 1:n_channels
            for j=1:n_echoes_to_use
                n=echoes_to_use(j);
                if exist(char(fnBetMaskSep(m,j))) ~= 2 || strcmp(data.do_all_remaing_processing_stages, 'yes')
                    bet = 'yes';
                    data.do_all_remaing_processing_stages = 'yes';
                    break
                end
            end
        end
end

switch bet
    case 'yes'
        %   create sep-channel masks
        switch method
            case {'sep-channel','phase-imaging'}
                disp(' * - creating separate BET masks for each channel');
                global_masked_image_nii = load_nii(fnBetMaskSubLarge);
                for m = 1:n_channels
                    for j=1:n_echoes_to_use
                        n=echoes_to_use(j);
                        mag_file = char(fnCurrentMagImages(m,j));
                        mag_file_temp = strrep(mag_file, '.nii', '_temp.nii');
                        mag_file_bet = strrep(mag_file, '.nii', '_bet.nii');
                        mag_file_bet_mask = strrep(mag_file, '.nii', '_bet_mask.nii');
                        %   Mask with the global mask first
                        one_channel_one_echo_nii = load_nii(mag_file);
                        try
                            one_channel_one_echo_nii.img(global_masked_image_nii.img == 0) = 0;
                        catch
                            disp('');
                        end
                        save_nii(one_channel_one_echo_nii, mag_file_temp);
                        %   Create BET mask
                        bet_command = sprintf('export LD_LIBRARY_PATH="/usr/lib/fsl:/usr/lib/fsl"; %s %s %s -f %f -m', bet_call, mag_file_temp, mag_file_bet, BET_f_sep_mask);
                        unix(bet_command);
                        [res, message] = unix(unzip_command);
                        delete(mag_file_bet);
                        delete(mag_file_temp);
                        set_nii_voxel_size(mag_file_bet_mask, nii_pixdim);
                        %   Move mask to the more sensible filename
                        [res, message] = unix(unzip_command);
                        unix(sprintf('mv %s %s', mag_file_bet_mask, char(fnBetMaskSep(m,j))));
                        centre_header_file(char(fnBetMaskSep(m,j)));
                        set_nii_voxel_size(char(fnBetMaskSep(m,j)), nii_pixdim);
                    end
                end
        end
    case 'no'
        ('- mask found');
end
