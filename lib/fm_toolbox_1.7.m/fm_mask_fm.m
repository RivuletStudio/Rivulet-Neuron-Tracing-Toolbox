function data = fm_mask_fm(data)

extension = data.extension;
fnBetMaskSubLarge = data.fnBetMaskSubLarge;
echoes_to_use = data.echoes_to_use;
fnCurrentFieldmaps = data.fnCurrentFieldmaps;
nii_pixdim = data.nii_pixdim;

%   How many masks do there need to be
number_of_masks_to_make = 1;
n_fieldmaps_to_correct = 1;

%   Check if anything needs doing
mask = 'no';
for m = 1:n_fieldmaps_to_correct
    for j = 1:number_of_masks_to_make
        fnCurrentFieldmapsBet(m,j) = {strrep(char(fnCurrentFieldmaps(m,j)), extension, ['_bet' extension])};
        if exist(char(fnCurrentFieldmapsBet(m,j))) ~=2 || strcmp(data.do_all_remaing_processing_stages, 'yes')
            mask = 'yes';
            data.do_all_remaing_processing_stages = 'yes';
        end
    end
end

switch mask
    case 'yes'
        ('* masking fieldmap(s)');
        %   Load the mask
        mask_nii = load_nii(fnBetMaskSubLarge);
        for m = 1:n_fieldmaps_to_correct
            for j = 1:number_of_masks_to_make
                one_fm_nii = load_nii(char(fnCurrentFieldmaps(m,j)));
                one_fm_nii.img(mask_nii.img == 0) = 0;
                centre_and_save_nii(one_fm_nii, char(fnCurrentFieldmapsBet(m,j)), nii_pixdim);
            end
        end
    case 'no'
        ('- mask found');
end

data.fnCurrentFieldmaps = fnCurrentFieldmapsBet;
