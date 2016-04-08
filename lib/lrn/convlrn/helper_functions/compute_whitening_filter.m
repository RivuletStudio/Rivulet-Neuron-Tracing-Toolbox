function [w_filter] = compute_whitening_filter(p,dataset)
%  compute_whitening_filter  compute the whitening filter for the given
%                            dataset
%
%  Synopsis:
%     [w_filter] = compute_whitening_filter(p,dataset)
%
%  Input:
%     p       = structure containing framework's configuration
%     dataset = cell array containing the training images
%  Output:
%     w_filter = whitening filter for the given dataset

%  author: Roberto Rigamonti, CVLab EPFL
%  e-mail: roberto <dot> rigamonti <at> epfl <dot> ch
%  web: http://cvlab.epfl.ch/~rigamont
%  date: April 2012
%  last revision: 27 April 2012

fprintf('  Computing the whitening filter from data\n');

fprintf('    Collecting training samples ...\n');
samples = zeros(p.wf_samples_no,p.wf_size^2);
for i_sample = 1:p.wf_samples_no
    rnd_sample_no = randi(length(dataset));
    img = dataset{rnd_sample_no};
    std_sample = 0;
    while (std_sample<p.wf_samples_std)
        rand_row = randi(size(img,1)-p.wf_size+1);
        rand_col = randi(size(img,2)-p.wf_size+1);
        samples(i_sample,:) = reshape(img(rand_row:rand_row+p.wf_size-1,rand_col:rand_col+p.wf_size-1)',1,p.wf_size^2);
        std_sample = std(samples(i_sample, :));
    end
end

fprintf('    Computing the SVD of data covariance matrix ...\n');
C = cov(samples);
[u, s, v] = svd(C);
ww = diag(s);
ww = 1./sqrt(ww);
W = u*diag(ww)*v';
w_filter = reshape(W(:,floor(p.wf_size^2/2)+1)',p.wf_size,p.wf_size);

end
