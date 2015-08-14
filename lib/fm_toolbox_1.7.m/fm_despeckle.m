%   Despeckle fieldmaps, either with FUGUE or interpolation

function data = fm_despeckle(data)

extension = data.extension;
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

number_of_dss_to_do = 1;

%   Check if the despeckled fm has already been calculated
despeckle_fieldmaps = 'no';

for j = 1:number_of_dss_to_do
    fnCurrentFieldmapsDs = {strrep(char(fnCurrentFieldmaps(j)), extension, ['_ds' extension])};
    if exist(char(fnCurrentFieldmapsDs(j)))~=2 || strcmp(data.do_all_remaing_processing_stages, 'yes')
        despeckle_fieldmaps = 'yes';
        data.do_all_remaing_processing_stages = 'yes';
    end
end

switch despeckle_fieldmaps
    case 'yes'
        for j = 1:number_of_dss_to_do
            despeckle_method = data.despeckle_method;
            unzip_command = data.unzip_command;
            nii_pixdim = data.nii_pixdim;
            switch despeckle_method
                case 'STD'
                    disp(' * - despeckling field map(s) using the standard deviation to threshold');
                    %   load all the useful maps and make a matrix for ds
                    current_fieldmap_nii = load_nii(char(fnCurrentFieldmaps(1)));
                    std_fieldmap_nii = load_nii(char(fnStdFM(1)));
                    mask_nii = load_nii(char(fnBetMaskSubLarge));
                    std_thresh = 3*median(vector(std_fieldmap_nii.img(mask_nii.img==1)));
                    ds_fieldmap_nii = current_fieldmap_nii;
                    ds_fieldmap_nii.img(std_fieldmap_nii.img > std_thresh) = 0;
                    centre_and_save_nii(ds_fieldmap_nii, char(fnCurrentFieldmapsDs(1)), nii_pixdim);
                case 'FUGUE'
                    disp(' * - despeckling field map(s) with FSL''s FUGUE (removing rogue pixels)');
                    despeckle_treshold = 0.1;
                    for j = 1:number_of_dss_to_do
                        despeckle_command = sprintf('export LD_LIBRARY_PATH="/usr/lib/fsl:/usr/lib/fsl"; fugue --loadfmap=%s  --despike --despikethreshold=%f --savefmap=%s', char(fnCurrentFieldmaps(j)), despeckle_treshold, char(fnCurrentFieldmapsDs(j)));
                        [res, message] = unix(despeckle_command);
                        if res ~= 0
                            error('Couldn''t despeckle: %s', message);
                        end
                    end
                case 'EXTREMES'
                    disp(' * - despeckling field map(s) by replacing extremes by local median of non-zero values');
                    for j = 1:number_of_dss_to_do
                        fieldmap_nii = load_nii(char(fnCurrentFieldmaps(j)));
                        smoothed_fm = medfilt3(fieldmap_nii.img);
                        percentile = 5;
                        percentiles = [percentile (100-percentile)];
                        pct_limits = prctile(vector(fieldmap_nii.img), percentiles);
                        ds_fieldmap_nii = fieldmap_nii;
                        ds_fieldmap_nii.img(fieldmap_nii.img == 0) = NaN;
                        ds_fieldmap_nii.img(ds_fieldmap_nii.img < pct_limits(1)) = smoothed_fm(ds_fieldmap_nii.img < pct_limits(1));
                        ds_fieldmap_nii.img(ds_fieldmap_nii.img > pct_limits(2)) = smoothed_fm(ds_fieldmap_nii.img > pct_limits(2));
                        ds_fieldmap_nii.img(fieldmap_nii.img == 0) = 0;
                        centre_and_save_nii(ds_fieldmap_nii, char(fnCurrentFieldmapsDs(1)), nii_pixdim);
                    end
                case 'INTERP'
                    disp(' * - despeckling field map(s) with the INTERP/griddata3 method (removing rogue pixels)');
                    for j = 1:number_of_dss_to_do
                        fieldmap_nii = load_nii(char(fnCurrentFieldmaps(j)));
                        xs = fieldmap_nii.hdr.dime.dim(2);
                        ys = fieldmap_nii.hdr.dime.dim(3);
                        zs = fieldmap_nii.hdr.dime.dim(4);
                        M = fieldmap_nii.img(:,:,:);
                        %   extract the (x,y,z) information into a list of non-zero values
                        [x,y,z,v] = find3(M);
                        % Define the range and spacing of the x- and y-coordinates,
                        % and then fit them into X and Y
                        [xinterp,yinterp,zinterp] = meshgrid((1:xs),(1:ys),(1:zs));
                        % Calculate Z in the X-Y interpolation space, which is an
                        % evenly spaced grid:
                        zinterp = griddata3(x,y,z,v,xinterp,yinterp,zinterp, 'nearest');
                        disp('');
                        for zz=1:zs; zinterp(:,:,zz) = flipud(rot90(zinterp(:,:,zz))); end
                        fieldmap_nii.img = zinterp;
                        centre_and_save_nii(fieldmap_nii, char(fnCurrentFieldmapsDs(1)), nii_pixdim);
                    end
            end
            unix(unzip_command);
            centre_header_file(char(fnCurrentFieldmapsDs(j)));
            set_nii_voxel_size(char(fnCurrentFieldmapsDs(j)), nii_pixdim);
        end
    case 'no'
        disp(' - despeckled field map(s) found');
end

data.fnCurrentFieldmaps = fnCurrentFieldmapsDs;