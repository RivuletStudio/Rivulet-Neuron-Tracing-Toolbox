function MorphGAC = snakeinitialise(gI, smoothing, threshold, ballon)
	    %  data : array-like
        %     The stopping criterion g(I). See functions gborders and glines.
        % smoothing : scalar
        %     The number of repetitions of the smoothing step in each
        %     iteration. This is the parameter µ.
        % threshold : scalar
        %     The threshold that determines which areas are affected
        %     by the morphological balloon. This is the parameter θ.
        % balloon : scalar
        %     The strength of the morphological balloon. This is the parameter ν.
	MorphGAC.u = [];
	MorphGAC.v = ballon;
	MorphGAC.theta = threshold;
	MorphGAC.smoothing = smoothing;
	MorphGAC = snakedata(MorphGAC, gI);
end 