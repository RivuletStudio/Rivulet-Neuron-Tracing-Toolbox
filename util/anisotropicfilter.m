function [v, lambda1, lambda2, lambda3] = anisotropicfilter(I, lsigma)

I = double(I);
vess = zeros(size(I, 1), size(I, 2), size(I, 3));
lambda1 = zeros(size(I, 1), size(I, 2), size(I, 3), numel(lsigma));
lambda2 = zeros(size(I, 1), size(I, 2), size(I, 3), numel(lsigma));
lambda3 = zeros(size(I, 1), size(I, 2), size(I, 3), numel(lsigma));

for i = 1 : numel(lsigma)
	fprintf('Hessian: Working on sigma %f\n', lsigma(i))
	[l1, l2, l3] = eigextract(I, lsigma(i));
	lambda1(:,:,:,i) = l1; lambda2(:,:,:,i) = l2; lambda3(:,:,:,i) = l3;
	k1 = exp(-(l1.^2) ./ (l1.^2 + l2.^2 + l3.^2));
	k2 = exp(-(l2.^2) ./ (l1.^2 + l2.^2 + l3.^2));
	k3 = exp(-(l3.^2) ./ (l1.^2 + l2.^2 + l3.^2));
	fu = 0.5*k1.*l1 + 0.5*k2.*l2 + 25*k3.*l3;
	grad = distgradient(I);
	sum_grad = grad(:,:,:,1).^2 + grad(:,:,:,2).^2 + grad(:,:,:,3).^2;
	fu(isnan(fu)) = 0;
	v = exp(-sum_grad).*fu;
	v = v .* fu;
	v = v .* double( (l1 - l2) > 0 & (l1 - l3) > 0 );
    replaceidx = vess < v;
    vess(replaceidx) = v(replaceidx);
end

%%The folowing code demonstrates how to use otsu library
%please notice that use the otsu rather than otsuown
% C = reshape(v,[],size(v,2),1);
% [IDX,sep] = otsu(C,2);
% newC = reshape(IDX, size(v));

end
