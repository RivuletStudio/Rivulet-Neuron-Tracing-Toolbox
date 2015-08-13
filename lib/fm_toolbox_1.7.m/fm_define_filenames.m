function data = fm_define_filenames(data)

n_channels = data.n_channels;
n_echoes = data.n_echoes;
n_echoes_to_use = data.n_echoes_to_use;
writefile_dir = data.writefile_dir;
sep_dir = data.sep_dir;
extension = data.extension;
channel_key = data.channel_key;
echoes_to_use = data.echoes_to_use;
multi_channel_data = data.multi_channel_data;

fnCurrentFieldmaps = cell(n_channels, 2);
fnCurrentMagImages = cell(n_channels, n_echoes);
fnCurrentPhaseImages = cell(n_channels, n_echoes);
fnRawPhaseImages = cell(n_channels, n_echoes);
fnCurrentPhaseImagesPC = cell(n_channels, n_echoes);
fnCurrentPhaseOffsets = cell(n_channels, 1);
fnBetMaskSep = cell(n_channels, n_echoes);

fnCombPhase = cell(1, n_echoes);
fnCombMag = cell(1, n_echoes);
fnCombPhaseDiff = cell(1, n_echoes);
fnCombMagDiff = cell(1, n_echoes);

%   W = weighted, T = trimmed, Nz = number of voxels in a surrounding 3x3
%   cube ==0, CV = covariance, NC =

fnMedianFM = cell(n_echoes-1);
fnWMedianFM = cell(n_echoes-1);
fnMedianFiltMedianFM = cell(n_echoes-1);
fnMeanFM = cell(n_echoes-1);
fnWMeanFM = cell(n_echoes-1);
fnTWMeanFM = cell(n_echoes-1);
fnStdFM = cell(n_echoes-1);
fnCVMap = cell(n_echoes-1);
fnNCMap = cell(n_echoes-1);
fnNzMap = cell(n_echoes-1);
fnWMeanPI = cell(n_echoes-1);

for j=1:n_echoes_to_use
    n=echoes_to_use(j);
    fnCombPhase(1,j) = {fullfile(writefile_dir, sprintf('Combined_phase_%s%s', int2str(j), extension))};
    fnCombMag(1,j) = {fullfile(writefile_dir, sprintf('Combined_mag_%s%s', int2str(j), extension))};
    fnCombPhaseDiff(1,j) = {fullfile(writefile_dir, sprintf('Combined_phase_diff_%s%s', int2str(j), extension))};
    fnCombMagDiff(1,j) = {fullfile(writefile_dir, sprintf('Combined_mag_diff_%s%s', int2str(j), extension))};
    fnWMeanPI(j)  = {fullfile(writefile_dir, sprintf('weighted_mean_phase_%s%s', int2str(n), extension))};
    if n_channels == 1
        mc_filler = '';
    else
        mc_filler = '_';
    end
    for m=1:n_channels
        if n_channels == 1
            channel_number = '';
        else
            channel_number = [int2str(m)];
        end
        %   starting values
        switch multi_channel_data
            case 'yes'
                switch data.method
                    case {'phase-match','conj-diff'}
                        fnCurrentFieldmaps(m,j) = {fullfile(writefile_dir, sprintf('Fieldmap_%s%s', int2str(j), extension))};
                    case 'sep-channel'
                        fnCurrentFieldmaps(m,j) = {fullfile(writefile_dir, sprintf('Fieldmap_%s_%s%s%s', int2str(j), channel_key, channel_number, extension))};
                end
            case 'no'
                fnCurrentFieldmaps(m,j) = {fullfile(writefile_dir, sprintf('Fieldmap_%s%s', int2str(n), extension))};
        end
        if j == 1
            %   the phase offsets are always in the sep directory 
            fnCurrentPhaseOffsets(m) = {fullfile(sep_dir, sprintf('Phase-offset_%s%s%s', channel_key, channel_number, extension))};
        end
        fnCurrentMagImages(m,j) = {fullfile(sep_dir, sprintf('Image_mag_%s%s%secho_%s%s', channel_key, channel_number, mc_filler, int2str(n), extension))};
        fnRawPhaseImages(m,j) = {fullfile(sep_dir, sprintf('Image_phase_%s%s%secho_%s%s', channel_key, channel_number, mc_filler, int2str(n), extension))};
        fnCurrentPhaseImages(m,j) = {fullfile(sep_dir, sprintf('Image_phase_%s%s%secho_%s%s', channel_key, channel_number, mc_filler, int2str(n), extension))};
        fnCurrentPhaseImagesPC(m,j) = {fullfile(sep_dir, sprintf('Image_phase_%s%s%secho_%s_pc%s', channel_key, channel_number, mc_filler, int2str(n), extension))};
        fnBetMaskSep(m,j) = {fullfile(sep_dir, sprintf('Mask_%s%s%secho_%s_pc%s', channel_key, channel_number, mc_filler, int2str(n), extension))};
    end
end
for j=1:n_echoes_to_use
    fnMedianFM(j)  = {fullfile(writefile_dir, sprintf('median_fieldmap_%s%s', int2str(j), extension))};
    fnWMedianFM(j)  = {fullfile(writefile_dir, sprintf('weighted_median_fieldmap_%s%s', int2str(j), extension))};
    fnMedianFiltMedianFM(j)  = {fullfile(writefile_dir, sprintf('median_filtered_median_fieldmap_%s%s', int2str(j), extension))};
    fnMeanFM(j)  = {fullfile(writefile_dir, sprintf('mean_fieldmap_%s%s', int2str(j), extension))};
    fnWMeanFM(j)  = {fullfile(writefile_dir, sprintf('weighted_mean_fieldmap_%s%s', int2str(j), extension))};
    fnTWMeanFM(j)  = {fullfile(writefile_dir, sprintf('trimmed_weighted_mean_fieldmap_%s%s', int2str(j), extension))};
    fnStdFM(j)  = {fullfile(writefile_dir, sprintf('std_map_%s%s', int2str(j), extension))};
    fnCVMap(j) = {fullfile(writefile_dir, sprintf('cv_map_%s%s', int2str(j), extension))};
    fnNCMap(j) = {fullfile(writefile_dir, sprintf('nc_map_%s%s', int2str(j), extension))};
    fnNzMap(j) = {fullfile(writefile_dir, sprintf('Nz_map_%s%s', int2str(j), extension))};
end

switch multi_channel_data
    case 'yes'
        fnReconMag = fullfile(sep_dir, 'reconstructed_Image.nii');
    case 'no'
        fnReconMag = char(fnCurrentMagImages(1,1));
end

fnAllMags = fullfile(sep_dir, 'all_magnitude_images.nii');

%   bet
fnBetImSmall = strrep(fnReconMag, extension, ['_bet-small' extension]);
fnBetImLarge = strrep(fnReconMag, extension, ['_bet-large' extension]);
if ispc == 1
    fnBetMaskSmall = strrep(fnReconMag, extension, ['_bet-small.nii_mask' extension]);
    fnBetMaskLarge = strrep(fnReconMag, extension, ['_bet-large.nii_mask' extension]);
else
    fnBetMaskSmall = strrep(fnReconMag, extension, ['_bet-small_mask' extension]);
    fnBetMaskLarge = strrep(fnReconMag, extension, ['_bet-large_mask' extension]);
end

data.fnReconMag = fnReconMag;
data.fnAllMags = fnAllMags;
data.fnMeanFM = fnMeanFM;
data.fnWMeanFM = fnWMeanFM;
data.fnTWMeanFM = fnTWMeanFM;
data.fnMedianFM = fnMedianFM;
data.fnWMedianFM = fnWMedianFM;
data.fnMedianFiltMedianFM = fnMedianFiltMedianFM;
data.fnStdFM = fnStdFM;
data.fnCVMap = fnCVMap;
data.fnNCMap = fnNCMap;
data.fnNzMap = fnNzMap;
data.fnBetImSmall = fnBetImSmall;
data.fnBetImLarge = fnBetImLarge;
data.fnBetMaskSmall = fnBetMaskSmall;
data.fnBetMaskLarge = fnBetMaskLarge;
data.fnBetMaskSubSmall = fullfile(writefile_dir, 'mask_small.nii');
data.fnBetMaskSubLarge = fullfile(writefile_dir, 'mask_large.nii');
data.fnBetMaskSep = fnBetMaskSep;

data.fnCurrentFieldmaps = fnCurrentFieldmaps;
data.fnCurrentMagImages = fnCurrentMagImages;
data.fnRawPhaseImages = fnRawPhaseImages;
data.fnCurrentPhaseImages = fnCurrentPhaseImages;
data.fnCurrentPhaseImagesPC = fnCurrentPhaseImagesPC;
data.fnCurrentPhaseOffsets = fnCurrentPhaseOffsets;
data.fnCombPhase = fnCombPhase;
data.fnCombMag = fnCombMag;
data.fnCombPhaseDiff = fnCombPhaseDiff;
data.fnCombMagDiff = fnCombMagDiff;
data.fnWMeanPI = fnWMeanPI;
