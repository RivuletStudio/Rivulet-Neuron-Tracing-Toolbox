%   B0 field mapping/fieldmapping - implementation of methods described in Robinson and Jovicich (Magnetic Resonance in Medicine, 2011)
%   fm_calc_caller passes essential parameters and configurable options to the main function in the calculation of field maps, fm_calc_main.m
%   for help, type >> help fm_calc_main
%   Simon Robinson 25.3.2011
%   Any of the options specified below which is the same for all the user's analysis can be specified in the 'Start of User-defined Parameters' section in fm_calc_main.m instead, to keep the number of parameters here to a minimum. 
%   If the parameters specified here are duplicated in fm_calc_main, these prevail
%   Examples here are for test data available for download at http://dl.dropbox.com/u/9241799/field_mapping/fm_example_data.tar.gz
%       To test, download and unzip the test data, and change 'data.root_dir' below to the directory you unzipped the results to. Set the first part of the path in 'data.writefile_dir' to the directory where you want to have the results
%       The subdirectories (case1, case2, case3) will be created. 
version_number = 1.7;

for run=1:1    %   each run is for the calculation of a single fieldmap. 
    clear -regexp ^(?!run$).
    switch run
        case 1
            % Example 1 : (x,y,z,echo,channel,[magnitude phase]) NIfTI created from DICOM with dicom_sort_convert_main.m, which creates a 'reform' directory with the 6D NIfTI and a text_header.txt file, which contains acquisition pars
            data.n_channels = 8;
            data.sep_files_for_echoes = 'no';
            data.sep_files_for_pm = 'no';
            data.root_dir = '/tmp/fm_example_data/';
            data.readfile_dirs = {'6D'};
            data.writefile_dir = '/tmp/fm_example_results/case1';
            data.do_gradient_thresholding = 'yes';  % threshold gradients in fieldmaps
            data.epi_dir = 'epi';
        case 2
            % Example 2 : NIfTI data in the same format as Example 1 (x,y,z,echo,channel,[magnitude phase]), but this time not generated from DICOM with dicom_sort_convert_main.m
            data.n_channels = 8;
            data.sep_files_for_echoes = 'no';
            data.sep_files_for_pm = 'no';
            data.root_dir = '/tmp/fm_example_data/';
            data.readfile_dirs = {'6D'};
            data.writefile_dir = '/tmp/fm_example_results/case2';
            % In this case, because the program won't find a text_header.txt containing acquisition parametesr, the echo times have to be specified
            data.TEs = [5040 13040]; % TEs, in us.
            % And if thresholding the maximum voxel shift gradient, the reciever bandwidth and phase-encoding direction also need to be specified
            data.do_gradient_thresholding = 'yes';  % threshold gradients in fieldmaps
            data.rbw = 1055;
            data.PE_dir = '-y';
        case 3
            % Example 3 : MGE NIfTI data in two files, the first containing magnitude values, the second containing phase values (x,y,z,echo,channel,magnitude), (x,y,z,echo,channel,phase). 
            % These have been created from DICOM with dicom_sort_convert_main.m
            data.n_channels = 8;
            data.sep_files_for_echoes = 'no';
            data.sep_files_for_pm = 'yes';
            data.root_dir = '/tmp/fm_example_data/5D';
            data.readfile_dirs = {'mag','phase'};
            data.writefile_dir = '/tmp/fm_example_results/case3';
            data.do_gradient_thresholding = 'no';  % threshold gradients in fieldmaps
            % and just to show how parameters in fm_calc_main.m can be moved here or overwritten with selections here, we will set the fm_calc_main parameter 'data.cleanup' to 'yes', and remove all interim data
            data.cleanup = 'yes';
    end
        
    fm_calc_main(data);
    
end

clear all;
disp('If you used this toolbox in your research, please cite the related paper:');
disp('Robinson, S and Jovicich, J. (2011). B0 Field Mapping With Multichannel Radiofrequency Coils at High Field. Magnetic Resonance in Medicine doi:10.1002/mrm.22879.');
disp('http://www.ncbi.nlm.nih.gov/pubmed/21608027 or http://onlinelibrary.wiley.com/doi/10.1002/mrm.22879/pdf');
disp('***Finished****');
