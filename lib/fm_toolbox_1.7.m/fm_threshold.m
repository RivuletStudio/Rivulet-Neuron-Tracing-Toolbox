%   Modify maps to chart the maximum remapping gradient possible without
%   causing conflict

function data = fm_threshold(data)

extension = data.extension;
fnCurrentFieldmaps = data.fnCurrentFieldmaps;
nii_pixdim = data.nii_pixdim;
gradient_thresh = data.gradient_thresh;
rbw = data.rbw;
PE_dir = data.PE_dir;
readout_dimension = data.readout_dimension;

number_of_dss_to_do = 1;

%   Check if the despeckled fm has already been calculated
threshold_fieldmaps = 'no';
for j = 1:number_of_dss_to_do
    fnCurrentFieldmapsTh = {strrep(char(fnCurrentFieldmaps(j)), extension, ['_th' extension])};
    if exist(char(fnCurrentFieldmapsTh(j)))~=2 || strcmp(data.do_all_remaing_processing_stages, 'yes')
        threshold_fieldmaps = 'yes';
        data.do_all_remaing_processing_stages = 'yes';
    end
end

switch threshold_fieldmaps
    case 'yes'
        disp([' * - thresholding field map(s) to limit voxel shift gradients to '  num2str(gradient_thresh)]);
        fieldmap_nii = load_nii(char(fnCurrentFieldmaps));
        %   smooth the fieldmap
        fieldmap_nii.img(fieldmap_nii.img == 0) = NaN;
        fieldmap_nii.img = medfilt3(fieldmap_nii.img, [5 5 5]);
        fieldmap_nii.img(isnan(fieldmap_nii.img)) = 0;        
        %   convert the fieldmaps to a voxel-shift map
        vsm = fieldmap_nii.img.*(fieldmap_nii.hdr.dime.dim(readout_dimension)/(2*pi*rbw));
        vsm_fn = fullfile(data.writefile_dir, 'vsm.nii');
        centre_and_save_nii(make_nii(vsm), vsm_fn, nii_pixdim);
        switch PE_dir
            case {'y','y-'}
                vsm_grad_PE = circshift(pad(diff(vsm,1,2),[0 1 0],0),[0 1 0]);
            case {'x','x-'} % needs checking
                vsm_grad_PE = circshift(pad(diff(vsm,1,1),[1 0 0],0),[1 0 0]);
            otherwise
                error('Phase-encode direction could not be determined')
        end        
        vsm_grad_PE_excess=zeros(size(vsm_grad_PE));
        vsm_grad_PE_excess(vsm_grad_PE>gradient_thresh) = vsm_grad_PE(vsm_grad_PE>gradient_thresh) - gradient_thresh;
        vsm_grad_PE_excess(vsm_grad_PE<-gradient_thresh) = vsm_grad_PE(vsm_grad_PE<-gradient_thresh) + gradient_thresh;        
        %   smooth the excess a bit
        vsm_grad_PE_excess = medfilt3(vsm_grad_PE_excess, [5 1 3]);        
        %   normalise vsm_grad_PE_excess
        for i=1:data.nii_dim(2)
            for k=1:data.nii_dim(4)
                one_line_excess = vsm_grad_PE_excess(i,:,k);
                one_line_excess_sum = sum(one_line_excess);
                one_line_excess(one_line_excess ~= 0) = one_line_excess(one_line_excess ~= 0)-one_line_excess_sum/nnz(one_line_excess);
                vsm_grad_PE_excess(i,:,k) = cumsum(one_line_excess);
            end
        end
        vsm_thresh = vsm-vsm_grad_PE_excess;
        vsm_reduced_fn = fullfile(data.writefile_dir, 'vsm_reduced.nii');
        centre_and_save_nii(make_nii(vsm_thresh), vsm_reduced_fn, nii_pixdim); % temp, for image and debugging
        
        fieldmap_nii.img = vsm_thresh./(fieldmap_nii.hdr.dime.dim(2)/(2*pi*rbw));
        for n = 1:number_of_dss_to_do
            centre_and_save_nii(fieldmap_nii, char(fnCurrentFieldmapsTh(1)), nii_pixdim);
        end
        disp('');
    case 'no'
        disp(' - thresholded field map(s) found');
end
data.fnCurrentFieldmaps = fnCurrentFieldmapsTh;

