%   Create median, mean and stdev maps
function data = fm_median_mean_std(data)

echoes_to_use = data.echoes_to_use;
fnCurrentFieldmaps = data.fnCurrentFieldmaps;
fnAllMags = data.fnAllMags;
fnReconMag = data.fnReconMag;
fnMeanFM = data.fnMeanFM;
fnWMeanFM = data.fnWMeanFM;
fnTWMeanFM = data.fnTWMeanFM;
fnMedianFM = data.fnMedianFM;
fnWMedianFM = data.fnWMedianFM;
fnMedianFiltMedianFM = data.fnMedianFiltMedianFM;
fnStdFM = data.fnStdFM;
fnCVMap = data.fnCVMap;
fnNCMap = data.fnNCMap;
fnNzMap = data.fnNzMap;
fnBetMaskSubLarge = data.fnBetMaskSubLarge;
n_channels = data.n_channels;
nii_pixdim = data.nii_pixdim;

%   Check if anything needs doing
calculate_means = 'no';

if (exist(char(fnTWMeanFM(1)))~=2 || exist(char(fnStdFM(1)))~=2 || strcmp(data.do_all_remaing_processing_stages, 'yes'))
    calculate_means = 'yes';
    data.do_all_remaing_processing_stages = 'yes';
end

switch calculate_means
    case 'yes'
        for m = 1:n_channels
            disp(['Loading ' char(fnCurrentFieldmaps(m,1))]);
            fieldmap_nii = load_nii(char(fnCurrentFieldmaps(m,1)));
            if (m == 1)
                x = fieldmap_nii.hdr.dime.dim(2);
                y = fieldmap_nii.hdr.dime.dim(3);
                z = fieldmap_nii.hdr.dime.dim(4);
                all_fieldmaps = zeros(x,y,z,n_channels);
            end
            all_fieldmaps(:,:,:,m) = fieldmap_nii.img(:,:,:);
        end
        all_mags_nii = load_nii(fnAllMags);
        weightings = squeeze(all_mags_nii.img(:,:,:,:,1));
        weightings_sorted = zeros(x,y,z,n_channels);
        disp(' * - sorting fieldmap values and weights');
        [all_fieldmaps_sorted, fm_sort_indices] = sort(all_fieldmaps,4);
        for i=1:x
            for jj=1:y
                for k=1:z
                    weightings_sorted(i,jj,k,:) = weightings(i,jj,k,fm_sort_indices(i,jj,k,:));
                end
            end
        end
        %   set the number of channels to use (all if n_channels <=4, the central half otherwise)
        if n_channels <=4
            cl = 1;
            ch = n_channels;
        else
            cl = round(n_channels/4)+1;
            ch = round(3*n_channels/4);
        end
        disp(' * - creating a trimmed, weighted mean fieldmap');
        twmean_fieldmap = mean(all_fieldmaps_sorted(:,:,:,cl:ch).*weightings_sorted(:,:,:,cl:ch),4)./mean(weightings_sorted(:,:,:,cl:ch), 4);
        twmean_fieldmap_nii = make_nii(twmean_fieldmap);
        centre_and_save_nii(twmean_fieldmap_nii, char(fnTWMeanFM(1)), nii_pixdim);
        disp(' * - creating a map of trimmed std');
        std_fieldmap = std(all_fieldmaps_sorted(:,:,:,cl:ch), 0, 4);
        std_fieldmap_nii = make_nii(std_fieldmap);
        centre_and_save_nii(std_fieldmap_nii, char(fnStdFM(1)), nii_pixdim);
case 'no'
    disp(' - found trimmed weighted mean and stdev fieldmaps');
end
data.fnCurrentFieldmaps = fnTWMeanFM;
