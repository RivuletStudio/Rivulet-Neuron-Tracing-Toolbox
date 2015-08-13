function data = fm_recon_mags(data)

fnReconMag = data.fnReconMag;
fnAllMags = data.fnAllMags;
n_channels = data.n_channels;
echoes_to_use = data.echoes_to_use;
n_echoes_to_use = data.n_echoes_to_use;
fnCurrentMagImages = data.fnCurrentMagImages;

reco_mag = 'no';

if exist(fnReconMag)~=2 || exist(fnAllMags)~=2 || strcmp(data.do_all_remaing_processing_stages, 'yes')
    reco_mag = 'yes';
    data.do_all_remaing_processing_stages = 'yes';
end

switch reco_mag
    case 'yes'
        disp(' * - reconstructing magnitude image');
        nii_pixdim = data.nii_pixdim;
        nii_dim = data.nii_dim;
        x = nii_dim(2);
        y = nii_dim(3);
        z = nii_dim(4);
        reco_image = zeros(x,y,z);
        all_mags = zeros(x,y,z,n_channels,2);
        for j = 1:n_echoes_to_use
            for m = 1:n_channels
                one_mag_nii = load_nii(char(fnCurrentMagImages(m,j)));
                all_mags(:,:,:,m,j) = double(one_mag_nii.img(:,:,:,1));
                if j == 1
                    reco_image = reco_image + double(one_mag_nii.img(:,:,:,1)).^2;
                end
            end
        end
        reco_image = reco_image.^0.5;
        reco_image_nii = make_nii(reco_image);
        all_mags_nii = make_nii(all_mags);
        clear all_mags;
        centre_and_save_nii(reco_image_nii, fnReconMag, nii_pixdim);
        centre_and_save_nii(all_mags_nii, fnAllMags, nii_pixdim);
    case 'no'
        disp(' - reconstructed magnitude image found');
end
