clc
clear all
close all
path2feat='/home/donghao/Desktop/OP/OP1';
X = [];
Y = [];
disp(['Searching path...', path2feat])
fields = {};
xrows = [];
yrows = [];
fprintf('Collecting %s\n', 'OP_1fea.mat');
feats = load(fullfile(path2feat, 'OP_1fea.mat'));
feats = feats.curfeats;
fields = fieldnames(feats);
for j = 1:numel(fields)
    if strcmp(fields{j}, 'gt')
        yrows = feats.(fields{j});
        sizegt = size(yrows);
    elseif strcmp(fields{j}, 'I')
        continue
    else
        x = feats.(fields{j});
        x = x(:);
        x = (x - mean(x)) / std(x);
        x = (x - min(x)) / (max(x) - min(x));
        xrows = [xrows, x];
    end
end
X = [X; xrows];
% We just need to predict so we do not need the ground truth anymore.  
%Y = [Y; yrows(:)];
clear rows, feats;

clf = load('/home/donghao/Desktop/OP/OPFEAT.mat');
cl = clf.obj;
pred = cl.predict(X);
X = reshape(pred, sizegt);
safeshowbox(X, 0.5)