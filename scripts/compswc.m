function [precision_value, recall_value, Fvalue] = compswc(methodswcpath, gtswcpath)
	methodswc =  loadswc(methodswcpath);
	gtswc = loadswc(gtswcpath);
	% The following example focus on calculating statistics such as precision and recall
	d = pdist2(methodswc(:,3:5), gtswc(:,3:5));
	[near_val,near_index] = min(d,[],2);
	% TPnum : True positive, TPthres : the length difference smaller than thredhold which is 4 voxels now 
	TP_thres = 4;
	TP_num = sum(near_val<TP_thres);
	% Incorrect traces: FP(false positive)
	FP_num = size(methodswc, 1) - TP_num;
	precision_value = TP_num / (TP_num + FP_num);
	[near_val,near_index] = min(d,[],1);
	% missing traces as false negatives
	FN_num = sum(near_val>TP_thres);
	recall_value = TP_num / (TP_num + FN_num); 
	Fvalue = 2 * precision_value * recall_value /(precision_value + recall_value);
end