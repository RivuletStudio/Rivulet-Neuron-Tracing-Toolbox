sigma = 1;
% I = op1;
[Lambda1, Lambda2, Lambda3] = eigextract(I, sigma);
kone = exp(-(Lambda1.^2) ./ (Lambda1.^2 + Lambda2.^2 + Lambda3.^2));
ktwo = exp(-(Lambda2.^2) ./ (Lambda1.^2 + Lambda2.^2 + Lambda3.^2));
kthree = exp(-(Lambda3.^2) ./ (Lambda1.^2 + Lambda2.^2 + Lambda3.^2));
fu = 0.5*kone.*Lambda1 + 0.5*ktwo.*Lambda2 + 25*kthree.*Lambda3;
conditionone = (Lambda1 - Lambda2) > 0;
conditiontwo = (Lambda1 - Lambda3) > 0;
% conditionthree = abs(Lambda1) < 0.01;
% conditionfour = Lambda1 > (-1);
condition = conditionone & conditiontwo; %& conditionthree;% & conditionfour;
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
sum_grad = grad(:,:,:,1).^2 + grad(:,:,:,2).^2 + grad(:,:,:,3).^2;
fu(isnan(fu)) = 0;
v = exp(-sum_grad).*fu;
v = v .* fu;
v = v .* double(condition);
v = v / max(v(:)) * 255;

%disp(max(fu(:), min(fu(:))))
showbox(v, 0);
save_v3d_raw_img_file(uint8(v),'filter.v3draw');

