function x = constrain(x, a, b)
	% constrain a vector between a and b
	x(x<a) = a;
	x(x>b) = b;
end