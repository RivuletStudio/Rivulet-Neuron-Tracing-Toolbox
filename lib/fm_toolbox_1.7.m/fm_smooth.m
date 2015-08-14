%   Smooth field maps
function data = fm_smooth(data);

extension = data.extension;
echoes_to_use = data.echoes_to_use;
fnCurrentFieldmaps = data.fnCurrentFieldmaps;

number_of_fms_to_smooth = 1;
    
smooth_fieldmaps = 'no';
%   Check if anything needs to be done
for j = 1:number_of_fms_to_smooth
    fnCurrentFieldmapsS = {strrep(char(fnCurrentFieldmaps(j)), extension, ['_s' extension])};
    if exist(char(fnCurrentFieldmapsS(j)))~=2 || strcmp(data.do_all_remaing_processing_stages, 'yes')
        smooth_fieldmaps = 'yes';
        data.do_all_remaing_processing_stages = 'yes';
    end
end

switch smooth_fieldmaps
    case 'yes'
        smoothing_kernel = data.smoothing_kernel;
        unzip_command = data.unzip_command;
        nii_pixdim = data.nii_pixdim;
        switch ispc
            case 0 % linux
                maths_call_smooth = 'fslmaths';
            case 1 % windows
                maths_call_smooth = 'avwmaths++';
        end
        disp([' * - smoothing field map(s) using the smoothn function with a ' num2str(smoothing_kernel) ' voxel kernel']);
        for j = 1:number_of_fms_to_smooth
            %   using smoothn
            one_fieldmap_nii = load_nii(char(fnCurrentFieldmaps(j)));
            %   don't include zero's - turn these to NaN to omit
            one_fieldmap_NaN = one_fieldmap_nii.img;
            one_fieldmap_NaN(one_fieldmap_nii.img == 0) = NaN;
            one_fieldmap_nii.img = smoothn(one_fieldmap_NaN);
            %   turn back NaNs to 0s
            one_fieldmap_nii.img(isnan(one_fieldmap_nii.img)) = 0;
            centre_and_save_nii(one_fieldmap_nii, char(fnCurrentFieldmapsS(j)), nii_pixdim);
        end
    case 'no'
        disp([' - smoothed field map(s) found']);
end

data.fnCurrentFieldmaps = fnCurrentFieldmapsS;