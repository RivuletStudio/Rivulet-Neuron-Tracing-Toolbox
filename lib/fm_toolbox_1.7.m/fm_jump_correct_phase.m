function data = fm_jump_correct_phase(data)

extension = data.extension;
n_channels = data.n_channels;
fnCurrentPhaseImages = data.fnCurrentPhaseImages;
fnCurrentMagImages = data.fnCurrentMagImages;
fnBetMaskSubSmall = data.fnBetMaskSubSmall;
fnBetMaskSep = data.fnBetMaskSep;
nii_pixdim = data.nii_pixdim;
nii_dim = data.nii_dim;
echoes_to_use = data.echoes_to_use;
method = data.method;

switch method
    case {'conj-diff','phase-imaging'}
        n_phase_images_to_jc = 1;
    otherwise
        if data.n_echoes > 1
            n_phase_images_to_jc = 2;
        else
            n_phase_images_to_jc = 1;
        end
end

correct_jumps = 'no';

for m = 1:n_channels
    for j=1:n_phase_images_to_jc
        n=echoes_to_use(j);
        fnCurrentPhaseImagesJC(m,j) = {strrep(char(fnCurrentPhaseImages(m,j)), extension, ['_jc' extension])};
        if exist(char(fnCurrentPhaseImagesJC(m,j))) ~= 2 || strcmp(data.do_all_remaing_processing_stages, 'yes')
            correct_jumps = 'yes';
            data.do_all_remaing_processing_stages = 'yes';
        end
    end
end

switch correct_jumps
    case 'yes'
        disp(' * - correcting for 2PI jumps in between slices');
        any_jumps_corrected = 'no';
        %   Load the phase images into one matrix
        for j=1:n_phase_images_to_jc
            for m = 1:n_channels 
                phase_nii = load_nii(char(fnCurrentPhaseImages(m,j)));
                mag_nii = load_nii(char(fnCurrentMagImages(m,j)));
                one_phase_jump_rads = (2*pi);
                %   load the mask (using in-mask voxels only to make sure jump-corrected not prejudiced by unwrapped OOB/noise value)
                %   Start at the middle slice then work way up, then start from the middle, and work way down
                slice_check_order = [ceil(nii_dim(4)/2):1:nii_dim(4) ceil(nii_dim(4)/2):-1:1];
                switch method
                    case 'sep-channel' % the global mask is no good for sep channels - use voxels > median of non-zero voxels
                        mask_nii = load_nii(char(fnBetMaskSep(m,j)));
                    otherwise
                        mask_nii = load_nii(fnBetMaskSubSmall);
                end
                z = nii_dim(4);
                for i = 1:z
                    if (slice_check_order(i) ~= z) %don't compare the top slice to the bottom
                        this_slice = squeeze(phase_nii.img(:,:,slice_check_order(i)));
                        next_slice = squeeze(phase_nii.img(:,:,slice_check_order(i+1)));
                        nz_inds_this_slice = find(mask_nii.img(:,:,slice_check_order(i)));
                        nz_inds_next_slice = find(mask_nii.img(:,:,slice_check_order(i+1)));
                        mean_this_slice = nanmedian(vector(this_slice(nz_inds_this_slice)));
                        mean_next_slice = nanmedian(vector(next_slice(nz_inds_next_slice)));
                        if m==9 && n==1 && slice_check_order(i)==22
                            disp('');
                        end
                        n_two_pi_jumps = round((mean_this_slice - mean_next_slice)/one_phase_jump_rads);
                        if isnan(n_two_pi_jumps)
                            n_two_pi_jumps = 0;
                        end
                        if n_two_pi_jumps ~= 0
                            if m==9 && n==1 && slice_check_order(i)==33
                                disp('');
                            end
                            next_slice(next_slice~=0) = next_slice(next_slice~=0) + n_two_pi_jumps*one_phase_jump_rads;
                            phase_nii.img(:,:,slice_check_order(i+1)) = next_slice;
                            switch any_jumps_corrected
                                case 'no'
                                    any_jumps_corrected = 'yes';
                            end                            
                        end
                    end
                end
                centre_and_save_nii(phase_nii, char(fnCurrentPhaseImagesJC(m,j)), nii_pixdim);
            end
        end
        switch any_jumps_corrected
            case 'yes'
                disp(' * - jumps were removed, writing out amended phase images');
            case 'no'
                disp(' - no jumps identified');
        end
    case 'no'
        disp(' - jump-corrected phase images found');
end

data.fnCurrentPhaseImages = fnCurrentPhaseImagesJC;
