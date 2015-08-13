function data = fm_phase_match(data)

extension = data.extension;
n_channels = data.n_channels;
echoes_to_use = data.echoes_to_use;
n_echoes_to_use = data.n_echoes_to_use;
fnCurrentPhaseImages = data.fnCurrentPhaseImages;
fnCurrentPhaseImagesPC = data.fnCurrentPhaseImagesPC;
fnCurrentPhaseOffsets = data.fnCurrentPhaseOffsets;
fnCombPhase = data.fnCombPhase;
fnCombMag = data.fnCombMag;
fnAllMags = data.fnAllMags;
nii_pixdim = data.nii_pixdim;
nii_dim = data.nii_dim;
phase_cor_method = data.phase_cor_method;

%   Check if the phase has already been corrected
match_phase = 'no';

for m = 1:n_channels
    for j = 1:n_echoes_to_use
        n=echoes_to_use(j);
        if exist(char(fnCurrentPhaseImagesPC(m,j))) ~= 2 || exist(char(fnCombPhase(j))) ~=2 || exist(char(fnCombMag(j))) ~=2 || strcmp(data.do_all_remaing_processing_stages, 'yes')
            match_phase = 'yes';
            data.do_all_remaing_processing_stages = 'yes';
        end
    end
end

switch match_phase
    case 'yes'
        disp(' * - matching the phase images at the first echo time and creating a combined phase image');
        %   load all magnitude and phase images
        all_mags_nii = load_nii(fnAllMags);
        for m = 1:n_channels
            for j = 1:n_echoes_to_use
                one_echo_one_channel_p_nii = load_nii(char(fnCurrentPhaseImages(m,j)));
                if (m == 1 && j == 1)
                    all_phase_images = zeros(nii_dim(2),nii_dim(3),nii_dim(4),n_channels,2);
                end
                all_phase_images(:,:,:,m,j) = one_echo_one_channel_p_nii.img;
            end
        end
        %% balance the channel phases
        for m = 1:n_channels
            for j = 1:n_echoes_to_use
                switch phase_cor_method
                    case 'hammond'
                        if j == 1
                            %   the correction ROI (cROI) is located at the centre of the image matrix
                            COM = floor(data.nii_dim(2:4)./2);
                            first_echo_one_channel_p = squeeze(all_phase_images(:,:,:,m,1));
                        end
                        phase_in_cROI = mean(vector(first_echo_one_channel_p(COM(1)-1:COM(1)+1,COM(2)-1:COM(2)+1,COM(3)-1:COM(3)+1)));
                        % disp(['Echo ' num2str(j) ', Channel ' num2str(m) ', phase offset = ' num2str(phase_in_cROI)]);
                        all_phase_images(:,:,:,m,j) = all_phase_images(:,:,:,m,j) - phase_in_cROI;
                    case 'schaefer' % balance using single voxel as the cROI - the maximum of the product over channels
                        if j == 1 && m == 1
                            product = ones(all_mags_nii.hdr.dime.dim(2),all_mags_nii.hdr.dime.dim(3),all_mags_nii.hdr.dime.dim(4));
                            for mm = 1:n_channels
                                product = product.*all_mags_nii.img(:,:,:,mm,1);
                            end
                            [dummy, linindex] = max(vector(product));
                            [indx, indy, indz] = ind2sub(size(product), linindex);
                            COM = [indx indy indz];
                        end
                        if j == 1
                            first_echo_one_channel_p = squeeze(all_phase_images(:,:,:,m,1));
                        end
                        phase_in_cROI = first_echo_one_channel_p(COM(1),COM(2),COM(3));
                        all_phase_images(:,:,:,m,j) = all_phase_images(:,:,:,m,j) - phase_in_cROI;
                        % disp(['Channel ' int2str(m) ' echo ' int2str(n) ', subtracted phase = ' num2str(phase_in_cROI)]);
                    case 'robinson'
                        if j == 1
                            pi_offsets_nii = load_nii(char(fnCurrentPhaseOffsets(m)));
                        end
                        all_phase_images(:,:,:,m,j) = all_phase_images(:,:,:,m,j) - pi_offsets_nii.img;
                otherwise
                    disp('not correcting for phase offsets');
            end
        end
end
%   create n_channels complex images
all_complex = all_mags_nii.img.*exp(i*all_phase_images);
%   combined phase - the weighted mean
wm_phase = angle(squeeze(sum(all_complex.*1,4)));
%   combined magnitude
wm_mag = abs(squeeze(sum(all_complex.*1,4)));
for j = 1:n_echoes_to_use
    wm_phase_nii = make_nii(squeeze(wm_phase(:,:,:,j)));
    wm_mag_nii = make_nii(squeeze(wm_mag(:,:,:,j)));
    %   rescale the phase images 0->2!PI
    wm_phase_nii.img = wm_phase_nii.img+pi;
    centre_and_save_nii(wm_phase_nii, char(fnCombPhase(j)), nii_pixdim);
    centre_and_save_nii(wm_mag_nii, char(fnCombMag(j)), nii_pixdim);
end
%   write out the single channel corrected phase images (not used, just for images/reference)
for j = 1:n_echoes_to_use
    for m = 1:n_channels
        one_phase_corrected_nii = make_nii(squeeze(angle(all_complex(:,:,:,m,j))));
        %   rescale the phase images 0->2!PI
        one_phase_corrected_nii.img = 2*pi*(one_phase_corrected_nii.img-min(vector(one_phase_corrected_nii.img)))./(max(vector(one_phase_corrected_nii.img))-min(vector(one_phase_corrected_nii.img)));
        centre_and_save_nii(one_phase_corrected_nii, char(fnCurrentPhaseImagesPC(m,j)), nii_pixdim);
    end
end
case 'no'
    disp(' - phase-corrected data found');
end

data.fnCurrentPhaseImages = fnCombPhase;
data.fnCurrentMagImages = fnCombMag;

end