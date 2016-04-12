function [obj, eidx] = train(X, Y, path2save, holdout, method)
    
	% Get all of the positive cases
	ypos = Y(Y==1, :);
	xpos = X(Y==1, :);

	% Get all of the negative cases
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
    [eidx, b, fitinfo] = elasticfilter(trainx, trainy);
    disp('eidx:');
    disp(eidx);
    trainx = trainx(:, eidx);
    testx = testx(:, eidx);
    save([path2save '.elastic.mat'], 'eidx', 'b', 'fitinfo');

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
end