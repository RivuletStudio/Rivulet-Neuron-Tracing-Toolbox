function [precision, recall, fscore] = compare_swc(swcpath1, swcpath2, dist1, dist2)
% COMPARE_SWC  
%    compare_swc(swc1, swc2, dist1, dist2)
%    Calculate the precision, recall and F1 score between swc1 and swc2 (ground truth)
%    It generates a new swc file with node types indicating the agreement between two input swc files
%    In the output swc file: node type - 1. the node is in both swc1 agree with swc2
%                                                      - 2. the node is in swc1, not in swc2 (over-traced)
%                                                      - 3. the node is in swc2, not in swc1 (under-traced)
%    swc1: The swc from tracing method
%    swc2: The swc of ground truth
%    dist1: The distance to consider for precision
%    dist2: The distance to consider for recall

            TPCOLOUR = 3;
            FPCOLOUR = 2;
            FNCOLOUR = 180;

	swc1 = loadswc(swcpath1);
	swc2 = loadswc(swcpath2);

	% precision and recall
	d = pdist2(swc1(:, 3:5), swc2(:, 3:5));
	[near_val1, near_index1] = min(d, [], 2);

	% TPnum : True positive, TPthres : the length difference smaller than thredhold which is 4 voxels now 
	true_positive = sum(near_val1 < dist1);
	false_positive = size(swc1, 1) - true_positive; % Incorrect traces: FP(false positive)	
	[near_val2, near_index2] = min(d, [], 1);

	% missing traces as false negatives
	false_negative = sum(near_val2>dist2);
	precision = true_positive / (true_positive + false_positive);
	recall = true_positive / (true_positive + false_negative); 
	fscore = 2 * precision * recall /(precision + recall);

	% Make the swc for visual comparison
	swc1(near_val1 <= dist1, 2) = TPCOLOUR; % Label the true positive nodes in swc1
	swc1(near_val1 > dist1, 2) = FPCOLOUR; % Label the false positive nodes in swc1
	swc2_fn = swc2(near_val2 > dist2, :); % Label the false negative nodes in swc2
	swc2_fn(:, 1) = swc2_fn(:, 1) + 100000;
	swc2_fn(:, 7) = swc2_fn(:, 7) + 100000;
	swc2_fn(:, 2) = FNCOLOUR;

	swc_compare = [swc1; swc2_fn];
	swc_compare(:, 6) = 1;
	[fpath, fname, ~] = fileparts(swcpath1);
	saveswc(swc_compare, fullfile(fpath, [fname, '.compare.swc']));
	fprintf('%-10s %-10s %-10s\n', 'PRECISION', 'RECALL', 'F1');
	fprintf('%-10.3f %-10.3f %-10.3f\n', precision, recall, fscore);
end