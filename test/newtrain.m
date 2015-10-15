% I = load_v3d_raw_img_file('/home/donghao/Desktop/OP/OP1/op1.v3draw');
% swc = load_v3d_swc_file('/home/donghao/Desktop/OP/OP1/OP_1.swc');
% sigma = 1.2;
% feats = featextract(I, swc, sigma);
clc
clear all
close all
sigma = 1.2;
oppath = '/home/donghao/Desktop/OP/OP';
for i = 1 : 9
    if i ~= 2
        stri = num2str(i);                                                                                                                           
        opdraw = [oppath, stri, '/op', stri, '.v3draw'];
        disp(opdraw)
        opswc = [oppath, stri, '/OP_', stri, '-gt-edited.swc'];
        disp(opswc)
        opfeat = [oppath, stri, '/OP_', stri, 'fea.mat'];
        I = load_v3d_raw_img_file(opdraw);
        swc = load_v3d_swc_file(opswc);
        curfeats = featextract(I, swc, sigma);
        save(opfeat, 'curfeats');
    end
end
path2feat='/home/donghao/Desktop/OP/OPFEAT';
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
    Y = [Y; yrows(:)];
    clear rows, feats;
end
save('X','X');
save('Y','Y');
clear all
load('X.mat');
load('Y.mat');

% originalX = X;
holdout = 0.5;
method = 'quadratic';
% Get all of the positive cases
ypos = Y(Y==1, :);
xpos = X(Y==1, :);

% Get all of the negative cases
% yneg = Y(Y==2, :);
% xneg = X(Y==2, :);
yneg = Y(Y==0, :);
xneg = X(Y==0, :);
% Randomly pick only the same number of negative cases
randnegidx = randperm(size(yneg, 1));
randnegidx = randnegidx(1:size(ypos, 1) * 1.5);
yneg = yneg(randnegidx, :);
xneg = xneg(randnegidx, :);

Y = [ypos; yneg];
X = [xpos; xneg];

ndata = size(X, 1);
randidx = randperm(ndata);
Y = Y(randidx, :);
X = X(randidx, :);
ntrain = int32(ndata * holdout);
ntest = ndata - ntrain;

trainx = X(1:ntrain, :);
trainy = Y(1:ntrain, :);
testx = X(end-ntest:end, :);
testy = Y(end-ntest:end, :);

% Run Elastic Net whatever
% [eidx, b, fitinfo] = elasticfilter(trainx, trainy);
% disp('eidx:');
% disp(eidx);
% trainx = trainx(:, eidx);
% testx = testx(:, eidx);
path2save = '/home/donghao/Desktop/OP/OPFEAT'
% save([path2save '.elastic.mat'], 'eidx', 'b', 'fitinfo');

fprintf('Fitting %s\n', method);
if strcmp(method, 'linear') || strcmp(method, 'quadratic')
    % obj = fitcdiscr(X, Y, 'CrossVal', 'on', 'DiscrimType', 'linear', 'Holdout', 0.1);
    obj = fitcdiscr(trainx, trainy, 'DiscrimType', 'quadratic', 'Prior', 'empirical');
    predY = obj.predict(testx);
    testacc = sum(testy == predY) / size(predY, 1);
    
    predY = obj.predict(trainx);
    trainacc = sum(trainy == predY) / size(predY, 1);
    fprintf('Train Acc: %f; Test Acc: %f\n', trainacc, testacc);
    
    fprintf('Saving model to %s\n', path2save);
    save(path2save, 'obj');
elseif strcmp(method, 'svm')
    obj = fitcsvm(trainx, trainy, 'KernelFunction','rbf',...
        'ClassNames',[0, 1], 'standardize', true);
    predY = predict(obj, testx);
    testacc = sum(testy == predY) / size(predY, 1);
    
    predY = predict(obj, trainx);
    trainacc = sum(trainy == predY) / size(predY, 1);
    fprintf('Train Acc: %f; Test Acc: %f\n', trainacc, testacc);
    
    fprintf('Saving model to %s\n', path2save);
    save(path2save, 'obj');
else
    fprintf('Training method %s not defined. Aborting...', method);
end
% pred = obj.predict(originalX);
% X = reshape(pred, sizegt);
% safeshowbox(X, 0.5)
% trainedpath='/home/donghao/Desktop/OP/OPFEAT/train.mat';
% [obj, eidx] = train(X, Y, trainedpath, holdout, method);
% fprintf('Feature Index used for classification: \n', eidx);

