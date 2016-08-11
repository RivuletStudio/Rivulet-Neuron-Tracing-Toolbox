function [precision, recall, fscore] = compare_swc(methodswcpath, gtswcpath, dist)

	methodswc =  loadswc(methodswcpath);
	gtswc = loadswc(gtswcpath);

	% The following example focus on calculating statistics such as precision and recall
	d = pdist2(methodswc(:,3:5), gtswc(:,3:5));
	[near_val,near_index] = min(d,[],2);

	% TPnum : True positive, TPthres : the length difference smaller than thredhold which is 4 voxels now 
	true_positive = sum(near_val<dist);
	false_positive = size(methodswc, 1) - true_positive; % Incorrect traces: FP(false positive)
	precision = true_positive / (true_positive + false_positive);
	[near_val,near_index] = min(d,[],1);

	% missing traces as false negatives
	false_negative = sum(near_val>dist);
	recall = true_positive / (true_positive + false_negative); 
	fscore = 2 * precision * recall /(precision + recall);
end