function data = fm_jump_correct_fieldmaps(data)

extension = data.extension;
TEs = data.TEs;
method = data.method;
n_channels = data.n_channels;
echoes_to_use = data.echoes_to_use;
fnCurrentFieldmaps = data.fnCurrentFieldmaps;
fnBetMaskSubSmall = data.fnBetMaskSubSmall;
nii_pixdim = data.nii_pixdim;
nii_dim = data.nii_dim;

n_fieldmaps_to_correct = size(fnCurrentFieldmaps,1);

number_of_jcs_to_do = 1;

correct_jumps = 'no';
for m = 1:n_fieldmaps_to_correct
    for j = 1:number_of_jcs_to_do
        fnCurrentFieldmapsJC(m,j) = {strrep(char(fnCurrentFieldmaps(m,j)), extension, ['_jc' extension])};
        if exist(char(fnCurrentFieldmapsJC(m,j))) ~= 2 || strcmp(data.do_all_remaing_processing_stages, 'yes')
            correct_jumps = 'yes';
            data.do_all_remaing_processing_stages = 'yes';
        end
    end
end

switch correct_jumps
    case 'yes'
        any_jumps_corrected = 'no';
        disp(' * - checking single-value fieldmaps for different phase jumps in contributing phase maps, slice by slice, on the basis of their difference from the global median fieldmap');
        one_phase_jump_radsps = (2*pi)/((TEs(2)-TEs(1))/1000000.0);
        for m = 1:n_fieldmaps_to_correct
            for n = 1:number_of_jcs_to_do
                fieldmap_nii = load_nii(char(fnCurrentFieldmaps(m,n)));
                if (m == 1 && n == 1)
                    all_fieldmaps = squeeze(zeros(fieldmap_nii.hdr.dime.dim(2),fieldmap_nii.hdr.dime.dim(3),fieldmap_nii.hdr.dime.dim(4),n_fieldmaps_to_correct,number_of_jcs_to_do));
                end
                all_fieldmaps(:,:,:,m,n) = fieldmap_nii.img(:,:,:);
            end
        end
        mask_nii = load_nii(fnBetMaskSubSmall);
        nz_inds = find(mask_nii.img);
        for m = 1:n_fieldmaps_to_correct
            for n = 1:number_of_jcs_to_do
                one_fm = squeeze(all_fieldmaps(:,:,:,m,n));
                switch method
                    case 'sep-channel' % the global mask is no good for single channels
                        nz_inds = find(one_fm);
                end
                mean_one_fm = nanmean(vector(one_fm(nz_inds)));
                n_jumps = round((mean_one_fm)/one_phase_jump_radsps);
                if n_jumps ~= 0
                    all_fieldmaps(:,:,:,m,n) = one_fm - n_jumps*one_phase_jump_radsps;
                    any_jumps_corrected = 'yes';
                end
            end
        end
        switch any_jumps_corrected
            case 'yes'
                disp(' * - jumps were removed');
                %   Now resave the fieldmaps
            case 'no'
                disp(' * - no jumps identified');
        end
        for m = 1:n_fieldmaps_to_correct
            for n = 1:number_of_jcs_to_do
                fieldmap_nii = make_nii(squeeze(all_fieldmaps(:,:,:,m,n)));
                try
                    centre_and_save_nii(fieldmap_nii, char(fnCurrentFieldmapsJC(m,n)), nii_pixdim);
                catch
                    disp('');
                end
            end
        end
    case 'no'
        disp(' - jump-corrected fieldmaps found');
end

data.fnCurrentFieldmaps = fnCurrentFieldmapsJC;

