function v3d2nii(path2dir)
% V3D2NII Converts a directory of *.v3draw files to *.nii files 
%    v3d2nii(dir2vaa3d) 
%    Requires V3D Matlab IO on path
%    The converted nii files will be saved in path2dir/nii/* 

	outdir = fullfile(path2dir, 'nii');
	if exist(outdir, 'dir')
        rmdir(outdir, 's')
    	mkdir(outdir)
    else
    	mkdir(outdir)
	end

	v3drawlist = dir(fullfile(path2dir, '*.v3draw'));
	for i = 1 : numel(v3drawlist)
		fprintf('Converting %d/%d', i, numel(v3drawlist))
		img = load_v3d_raw_img_file(fullfile(path2dir, v3drawlist(i).name));
		outputFileName = fullfile(path2dir, 'nii', strcat(v3drawlist(i).name, '.nii'));
		nii = make_nii(img);
		save_nii(nii, outputFileName);
	end
	disp('== Done ==')
end
