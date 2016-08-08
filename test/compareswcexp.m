% The following example focus on calculating statistics such as precision and recall
rivuletswc =  loadswc('/home/donghao/Desktop/soma_field/soma_case1/soma_original.v3draw-rivuletwithoutsomafield.swc');
app2swc = loadswc('/home/donghao/Desktop/soma_field/soma_case1/soma_original.v3draw_x248_y254_z22_app2.swc');
d = pdist2(rivuletswc(:,3:5), app2swc(:,3:5));
[near_val,near_index] = min(d,[],2);
% TPnum : True positive, TPthres : the length difference smaller than thredhold which is 4 voxels now 
TP_thres = 4;
TP_num = sum(near_val<TP_thres);
% Incorrect traces: FP(false positive)
FPnum = size(rivuletswc, 1) - TPnum;
precision_value = TPnum / (TPnum + FPnum);
[near_val,near_index] = min(d,[],1);
% missing traces as false negatives
FNnum = sum(near_val>TP_thres);
recall_value = TPnum / (TPnum + FNnum); 
Fvalue = 2 * precision_value * recall_value /(precision_value + recall_value);

% Test it using compswc function
[precision_value, recall_value, Fvalue] = compswc('/home/donghao/Desktop/soma_field/soma_case1/soma_original.v3draw-rivuletwithoutsomafield.swc', '/home/donghao/Desktop/soma_field/soma_case1/soma_original.v3draw_x248_y254_z22_app2.swc');