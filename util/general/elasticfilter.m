function [eidx, b, fitinfo] = elasticfilter(X, Y)
    [b,fitinfo] = lasso(X, Y, 'Alpha',0.8);
    [~, minmseidx] = min(fitinfo.MSE);
    pvalue = b(:, minmseidx); 
    eidx = find(pvalue ~= 0);
end