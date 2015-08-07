function k = VessFileters(l1, l2, l3)
	%Calculate additional Vesselness filters

	% Krissian-Inspired Vesselness
    k = zeros(size(l1));
    eigensum = l1 + l2 + l3;
    k = - (l2 ./ l3) .* (l2 + l3);
    k(eigensum >= 0) = 0;

	% Krissian-Inspired Vesselness using bi-Gaussian kernel
end