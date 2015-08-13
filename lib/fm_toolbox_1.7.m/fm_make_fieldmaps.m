%   Make the fieldmaps
function data = fm_make_fieldmaps(data)

n_channels = data.n_channels;
fnCurrentFieldmaps = data.fnCurrentFieldmaps;
fnCurrentPhaseImages = data.fnCurrentPhaseImages;
TEs = data.TEs;
nii_pixdim = data.nii_pixdim;
method = data.method;

%   Check if the fieldmaps have already been calculated
make_fieldmaps = 'no';

number_of_fieldmaps_to_calc = 1;

for m = 1:n_channels
    for j = 1:number_of_fieldmaps_to_calc
        if exist(char(fnCurrentFieldmaps(m,j)))~=2 || strcmp(data.do_all_remaing_processing_stages, 'yes')
            make_fieldmaps = 'yes';
            data.do_all_remaing_processing_stages = 'yes';
        end
    end
end

switch make_fieldmaps
    case 'yes'
        if m == 1, disp(' * - calculating fieldmap(s)'), else disp(' * - calculating single-channel fieldmaps'), end
        switch method
            case {'phase-match','sep-channel'}
                for m = 1:n_channels
                    for j = 1:number_of_fieldmaps_to_calc
                        unwrapped_phase1_nii = load_nii(char(fnCurrentPhaseImages(m,j)));
                        unwrapped_phase2_nii = load_nii(char(fnCurrentPhaseImages(m,j+1)));
                        fieldmap_nii = unwrapped_phase1_nii;
                        fieldmap_nii.img = (unwrapped_phase2_nii.img - unwrapped_phase1_nii.img)./((TEs(j+1)-TEs(j))/1000000.0);
                        centre_and_save_nii(fieldmap_nii, char(fnCurrentFieldmaps(m,j)), nii_pixdim);
                    end
                end
            case 'conj-diff'
                phase_diff_unwrapped_nii = load_nii(char(fnCurrentPhaseImages(1,1)));
                fieldmap_nii = phase_diff_unwrapped_nii;
                fieldmap_nii.img = phase_diff_unwrapped_nii.img./((TEs(j+1)-TEs(j))/1000000.0);
                centre_and_save_nii(fieldmap_nii, char(fnCurrentFieldmaps(m,j)), nii_pixdim);
        end
    case 'no'
        disp(' - fieldmaps found');
end

data.fnCurrentFieldmaps = fnCurrentFieldmaps;

