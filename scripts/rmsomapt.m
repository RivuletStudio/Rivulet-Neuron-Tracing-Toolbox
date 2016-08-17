clear all
somapath = '/media/donghao/My Passport/ISBI2016soma/Table/GMR_57C10_AD_01-1xLwt_attp40_4stop1-f-A01-20110325_3_B2-left_optic_lobe.v3draw.extract_6/cropped.v3draw-rivuletsomamask.mat';
methodswcpath = '/media/donghao/My Passport/ISBI2016soma/Table/GMR_57C10_AD_01-1xLwt_attp40_4stop1-f-A01-20110325_3_B2-left_optic_lobe.v3draw.extract_6/newrivulet.swc';
gtswcpath = '/media/donghao/My Passport/ISBI2016soma/Table/GMR_57C10_AD_01-1xLwt_attp40_4stop1-f-A01-20110325_3_B2-left_optic_lobe.v3draw.extract_6/gtresample.swc';
methodswc =  loadswc(methodswcpath);
load(somapath);
gtswc = loadswc(gtswcpath);
B = cursoma.I > 0.5;
[x y z] = ind2sub(size(B), find(B));
somapt(:,1) = x;
somapt(:,2) = y;
somapt(:,3) = z;
% put x y z soma binary into x y x matrix
d = pdist2(methodswc(:,3:5), somapt);
[near_val,near_index] = min(d,[],2);
soma_dt_thres = 2;
truepostive_num = sum(near_val<soma_dt_thres);

% cut rivulet swc into two parts 
swc_in_soma_index = find(near_val<soma_dt_thres);
swc_out_soma =  methodswc;
swc_out_soma(swc_in_soma_index,:) = [];
swc_in_soma =  methodswc(swc_in_soma_index,:);

% calculate new precision value
d = pdist2(swc_out_soma(:,3:5), gtswc(:,3:5));
[near_val,near_index] = min(d,[],2);
true_positive_thres = 4;
true_positive = sum(near_val<true_positive_thres);
false_positive = size(swc_out_soma, 1) - true_positive;
size(swc_in_soma,1)
precision_value = (true_positive + size(swc_in_soma,1)) / (true_positive + false_positive + size(swc_in_soma,1));

% cut gt swc into two parts 
d = pdist2(gtswc(:,3:5), somapt);
[near_val,near_index] = min(d,[],2);
soma_dt_thres = 2;
truepostive_num = sum(near_val<soma_dt_thres);
gt_swc_in_soma_index = find(near_val<soma_dt_thres);
gt_swc_out_soma =  gtswc;
gt_swc_out_soma(gt_swc_in_soma_index,:) = [];
gt_swc_in_soma =  gtswc(gt_swc_in_soma_index,:);

% calculate new recall value
d = pdist2(swc_out_soma(:,3:5), gt_swc_out_soma(:,3:5));
[near_val,near_index] = min(d,[],1);
% missing traces as false negatives
false_negative = sum(near_val>true_positive_thres);
recall_value = (true_positive + size(swc_in_soma,1)) / (true_positive + false_negative + size(swc_in_soma,1));




