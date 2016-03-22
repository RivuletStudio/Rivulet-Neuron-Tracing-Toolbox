% Usage [u,v] = mggvf(f, mu, v1, v2, threshold); computes the GVF of
% an edge map f.
%
% mu is the GVF regularization coefficient.
%
% v1 and v2 define the number of iterations for the multi-grid pre-
% and post- smoothing operators. Typically, 1 or 2 iterations are
% sufficient.
%
% threshold is a convergence parameter: e.g., 1e-5.
