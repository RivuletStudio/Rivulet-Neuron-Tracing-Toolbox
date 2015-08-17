function v = anisotropicfilter(I, sigma)
% The input I is M * N * 3 matrix
I = double(I);
[Lambda1, Lambda2, Lambda3] = eigextract(I, sigma);
disp('Lambda calculation finished');
kone = exp(-(Lambda1.^2) ./ (Lambda1.^2 + Lambda2.^2 + Lambda3.^2));
ktwo = exp(-(Lambda2.^2) ./ (Lambda1.^2 + Lambda2.^2 + Lambda3.^2));
kthree = exp(-(Lambda3.^2) ./ (Lambda1.^2 + Lambda2.^2 + Lambda3.^2));
fu = 0.5*kone.*Lambda1 + 0.5*ktwo.*Lambda2 + 25*kthree.*Lambda3;
conditionone = (Lambda1 - Lambda2) > 0;
conditiontwo = (Lambda1 - Lambda3) > 0;
% The folowing code makes the condition more strict which is not desired
% conditionthree = abs(Lambda1) < 0.01;
% conditionfour = Lambda1 > (-1);
condition = conditionone & conditiontwo; %& conditionthree;% & conditionfour;
disp('condition calculation finished');
clear conditionone;
clear conditiontwo;
clear conditionthree;
clear conditionfour;
clear Lambda1;
clear Lambda2;
clear Lambda3;
clear kone;
clear ktwo;
clear kthree;
grad = distgradient(I);
disp('gradient calculation finished');
sum_grad = grad(:,:,:,1).^2 + grad(:,:,:,2).^2 + grad(:,:,:,3).^2;
fu(isnan(fu)) = 0;
v = exp(-sum_grad).*fu;
v = v .* fu;
v = v .* double(condition);
vvec = v(:);
maxv = max(vvec);
v = v / maxv * 255;
v = abs(v);
v = round(v);

%%The folowing code demonstrates how to use otsu library
%please notice that use the otsu rather than otsuown

%disp('begin otsu');
%binaryI = otsuown(v);
%safeshowbox(binaryI,0.5);
C = reshape(v,[],size(v,2),1);
[IDX,sep] = otsu(C,2);
newC = reshape(IDX, size(v));
% fuck = newC==6;
%fucker = ac_linear_diffusion_AOS(newC == 2, 1);
safeshowbox(newC,1);
%afterls = ac_linear_diffusion_AOS(newC == 2, 1);
%safeshowbox(afterls, 0.5);
%figure(1);
%showbox(double(fucker), 0.5);
%disp(max(fu(:), min(fu(:))))
%showbox(v, 10);
%save_v3d_raw_img_file(uint8(v),'filter.v3draw');
end
