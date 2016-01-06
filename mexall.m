mfile = mfilename('fullpath');

projectroot = fileparts(mfile);

cd(fullfile(projectroot, 'lib', 'frangi_filter_version2a'));
mex('eig3volume.c');
mex('imgaussian.c');

cd(fullfile(projectroot, 'lib', 'FastMarching_version3b', 'functions'));
mex('msfm3d.c');
mex('msfm2d.c');

cd(fullfile(projectroot, 'lib', 'FastMarching_version3b', 'shortestpath'));
mex('rk4.c');