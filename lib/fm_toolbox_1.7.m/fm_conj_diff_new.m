function data = fm_conj_diff_new(data)

n_channels = data.n_channels;
fnCurrentPhaseImages = data.fnCurrentPhaseImages;
fnCurrentMagImages = data.fnCurrentMagImages;
fnCombPhaseDiff = data.fnCombPhaseDiff;
fnCombMagDiff = data.fnCombMagDiff;
nii_pixdim = data.nii_pixdim;
nii_dim = data.nii_dim;
processing_option = data.processing_option;
n_echoes_to_use = data.n_echoes_to_use;

%   Check if the phase has already been corrected
conj_diff = 'no';

for n = 1:n_echoes_to_use-1
    if exist(char(fnCombPhaseDiff(n))) ~=2 || exist(char(fnCombMagDiff(n))) ~=2 || strcmp(data.do_all_remaing_processing_stages, 'yes')
        conj_diff = 'yes';
        data.do_all_remaing_processing_stages = 'yes';
    end
end

switch conj_diff
    case 'yes'
        disp(' * - creating a combined phase difference image');
        switch processing_option
            case 'slice_by_slice'
                tic
                disp('   -- not enough memory to process all slices at once');
                %   load all magnitude and phase images - do slice by slice to keep memory req reasonable
                ns = data.nii_dim(4);
                wm_phase = zeros(data.nii_dim(2),data.nii_dim(3),data.nii_dim(4));
                wm_mag = zeros(data.nii_dim(2),data.nii_dim(3),data.nii_dim(4));
                for n = 1:n_echoes_to_use-1
                    for k = 1:ns
                        disp(['   -- processing slice ' num2str(k)]);
                        for m = 1:n_channels
                            for j = 1:2
                                one_echo_one_channel_m_nii = load_nii(char(fnCurrentMagImages(m,n+j-1)));
                                one_echo_one_channel_p_nii = load_nii(char(fnCurrentPhaseImages(m,n+j-1)));
                                if (m == 1 && j == 1)
                                    all_phase_images_one_slice = zeros(nii_dim(2),nii_dim(3),n_channels,2);
                                    all_mag_images_one_slice = zeros(nii_dim(2),nii_dim(3),n_channels,2);
                                end
                                all_phase_images_one_slice(:,:,m,j) = squeeze(one_echo_one_channel_p_nii.img(:,:,k));
                                all_mag_images_one_slice(:,:,m,j) = squeeze(one_echo_one_channel_m_nii.img(:,:,k));
                            end
                        end
                        %                        create n_channels complex images
                        wm_phase(:,:,k,:) = squeeze(angle(sum(exp(1i*(all_phase_images_one_slice(:,:,:,2)-all_phase_images_one_slice(:,:,:,1))),3)));
                        wm_mag(:,:,k,:) = squeeze(abs(sum((all_mag_images_one_slice(:,:,:,2)-all_mag_images_one_slice(:,:,:,1)),3)));
                    end
                    centre_and_save_nii(make_nii(wm_phase),char(fnCombPhaseDiff(n)), nii_pixdim);
                    centre_and_save_nii(make_nii(wm_mag),char(fnCombMagDiff(n)), nii_pixdim);
                    disp(['Time to create conj-diff phase image = ' secs2hms(toc)]);
                end
            case 'all_at_once'
                tic
                %   high memory requirement version - is faster if mem available - put in check
                for n = 1:n_echoes_to_use-1
                    for m = 1:n_channels
                        for j = 1:2
                            if (m == 1 && j == 1)
                                all_phase_images = zeros(nii_dim(2),nii_dim(3),nii_dim(4),n_channels,2);
                                all_mag_images = zeros(nii_dim(2),nii_dim(3),nii_dim(4),n_channels,2);
                            end
                            one_echo_one_channel_p_nii = load_nii(char(fnCurrentPhaseImages(m,n+j-1)));
                            one_echo_one_channel_m_nii = load_nii(char(fnCurrentMagImages(m,n+j-1)));
                            all_phase_images(:,:,:,m,j) = one_echo_one_channel_p_nii.img;
                            all_mag_images(:,:,:,m,j) = one_echo_one_channel_m_nii.img;
                        end
                    end
                    %                        create n_channels complex images
                    wm_phase = angle(sum(exp(1i*(all_phase_images(:,:,:,:,2)-all_phase_images(:,:,:,:,1))),4));
                    wm_mag = abs(sum((all_mag_images(:,:,:,:,2)-all_mag_images(:,:,:,:,1)),4));
                    centre_and_save_nii(make_nii(wm_phase),char(fnCombPhaseDiff(n)), nii_pixdim);
                    centre_and_save_nii(make_nii(wm_mag),char(fnCombMagDiff(n)), nii_pixdim);
                    %                     disp(['Time to create conj-diff phase image = ' secs2hms(toc)]);
                end
        end
    case 'no'
        disp(' - conj-diff data found');
end

data.fnCurrentPhaseImages = fnCombPhaseDiff;
data.fnCurrentMagImages = fnCombMagDiff;

end