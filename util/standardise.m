function x = standardise(x)
    x = (x - mean(x)) / std(x);
	x = (x - min(x)) / (max(x) - min(x));
end