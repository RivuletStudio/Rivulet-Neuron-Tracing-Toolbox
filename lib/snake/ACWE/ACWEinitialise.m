function MorphGAC = ACWEinitialise(data, smoothing, lambda1, lambda2)
	%  data : ndarray
        %     The image data.
        % smoothing : scalar
        %     The number of repetitions of the smoothing step (the
        %     curv operator) in each iteration. In other terms,
        %     this is the strength of the smoothing. This is the
        %     parameter µ.
        % lambda1, lambda2 : scalars
        %     Relative importance of the inside pixels (lambda1)
        %     against the outside pixels (lambda2).
	MorphGAC.u = [];
	MorphGAC.lambda1 = lambda1;
	MorphGAC.lambda2 = lambda2;
	MorphGAC.smoothing = smoothing;
	MorphGAC.data = data;
end
