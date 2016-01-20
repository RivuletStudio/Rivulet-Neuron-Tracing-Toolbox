function M = augmask(M, I, l, radius)
% Use 3D simple fast marching to march the 3D mask further towards the boundary

% Get the surface indices of mask 
eM = imerode(M, ones(3, 3, 3));
dM = imdilate(M, ones(3, 3, 3));

I = I & dM;
I(eM == 1) = 0;
% remove 2 balls at both termini from fastmarching
neighbours = int16(neighbourpoints3d(l(1, 1), l(1, 2), l(1, 3), 6*radius(1)));
neighbours(:, 1) = constrain(neighbours(:, 1), 1, size(I, 1));
neighbours(:, 2) = constrain(neighbours(:, 2), 1, size(I, 2));
neighbours(:, 3) = constrain(neighbours(:, 3), 1, size(I, 3)); 
ind = sub2ind(size(I), neighbours(:, 1), neighbours(:, 2), neighbours(:, 3));
I(ind) = 0;
M(ind) = 0;

neighbours = int16(neighbourpoints3d(l(end, 1), l(end, 2), l(end, 3), 6*radius(end)));
neighbours(:, 1) = constrain(neighbours(:, 1), 1, size(I, 1));
neighbours(:, 2) = constrain(neighbours(:, 2), 1, size(I, 2));
neighbours(:, 3) = constrain(neighbours(:, 3), 1, size(I, 3)); 
ind = sub2ind(size(I), neighbours(:, 1), neighbours(:, 2), neighbours(:, 3));
ind = sub2ind(size(I), neighbours(:, 1), neighbours(:, 2), neighbours(:, 3));
I(ind) = 0;
M(ind) = 0;

M = M - eM;
M = simplemarching3d(I, M, 100);
M = eM | M;

end