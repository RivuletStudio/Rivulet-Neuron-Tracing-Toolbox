clc
clear all
close all
i = 1;
stri = num2str(i);  
oppath = '/home/donghao/Desktop/OP/OP';
opdraw = [oppath, stri, '/op', stri, '.v3draw'];
if ~exist('tmp', 'dir')
  mkdir('tmp');
end
X = load_v3d_raw_img_file(opdraw);
featextract(X, [], 1.2, fullfile('tmp', 'tmpfeat'));
[X, ~, feats] = featcollect('tmp', []);
X = int32(X);
clf = load('/home/donghao/Desktop/OP/OPFEAT.mat');
%clf = load('/home/donghao/Desktop/OP/quad.mat');
cl = clf.obj;
pred = predict(cl, X);
X = reshape(pred, size(feats.I));
fprintf('Removing %s\n', 'tmp');
rmdir('tmp', 's');
safeshowbox(X, 0.5)