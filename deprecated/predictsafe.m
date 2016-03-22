clc
clear all
close all
path2feat='/home/donghao/Desktop/OP/OP5';
X = [];
Y = [];
disp(['Searching path...', path2feat])
fnames = dir2(path2feat, '*.mat', '-r');
fields = {};
skip = 0;
for i = 1 : numel(fnames)   
    f = fnames(i);
    xrows = [];
    yrows = [];

    if any(abs(skip-i)<1e-10)
        fprintf('skipping %s\n', f.name);
        continue
    end

    % if numel(f) > 4 && strcmp(f(end-3:end), '.mat')
    fprintf('Collecting %s\n', f.name);
    feats = load(fullfile(path2feat, f.name));
    feats = feats.curfeats;
    fields = fieldnames(feats);

    for j = 1:numel(fields)
        if strcmp(fields{j}, 'gt')
            yrows = feats.(fields{j});
            sizegt = size(yrows);
            % yrows = yrows(:, end:-1:1, :);
            % S=ones(4,4,4);
            % dialatedI = imdilate(yrows,S);
            % newgt = xor(dialatedI, yrows);
            % yrows= newgt * 2 + yrows;
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
    %Y = [Y; yrows(:)];
    clear rows, feats;
end
clf = load('/home/donghao/Desktop/OP/OPFEAThpc.mat');
%clf = load('/home/donghao/Desktop/OP/quad.mat');
cl = clf.obj;
pred = cl.predict(X);
X = reshape(pred, sizegt);
safeshowbox(X, 0.5)