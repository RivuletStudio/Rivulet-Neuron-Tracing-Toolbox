function gotrain(path2feat, skip, holdout, modelname)
	addpath('../util');
	parpool
	[X, Y] = featcollect(path2feat, skip);
	[obj, eidx] = train(X, Y, fullfile(path2feat, '..', [modelname, '.mat']), holdout);
	fprintf('Feature Index used for classification: \n', eidx);
end