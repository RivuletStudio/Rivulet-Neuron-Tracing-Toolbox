% Recursively Search all .mat files and save the vesselness image in 
function vesselnessall(path2vessel)
	[pathstr, ~, ~] = fileparts(mfilename('fullpath'));
	addpath(fullfile(pathstr, '..', 'util'));
    addpath(fullfile(pathstr, '..', 'lib', 'dir2'));
    addpath(fullfile(pathstr, '..', 'lib', 'frangi_filter_version2a'));
	addpath(fullfile(pathstr, '..', '..', '..', 'v3d', 'v3d_external', 'matlab_io_basicdatatype'));
	disp(['Searching path...', path2vessel])
    fnames = dir2(path2vessel, '*.mat', '-r');

	options.BlackWhite = false;
	options.FrangiScaleRange = [1 5]
    for i = 1 : numel(fnames)   
    	f = fnames(i);
    	f = f.name;

		fprintf('Calculate Vesselness %s\n', f);
		d = load(fullfile(path2vessel, f));
		I = d.vision_box;
		[Iout] = FrangiFilter3D(I, options);
		Iscale = Iout * 1e7;
		path2save = fullfile(path2vessel, [f '-vess.v3draw']);
		save_v3d_raw_img_file(uint8(Iscale), path2save);
    end
end