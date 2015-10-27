function dirRatio = directionalRatio(image,nbands, msize)
% This function obtains the ratio between the minimum and maximum
% directional responses in image of the filters generated with the bands
% and sizes specified, and returns those values for the pixels specified by
% the variable mask.
% 
% INPUT:
%  - image: 2D image to be processed.
%  - mask: Binary image, separating background from foreground.
%  - nbands: Number of bands to be generated.
%  - msize: Size of the filter to be generated.
% 
% OUTPUT:
%  - dirRatio: 2D image containing the directional ratio values for those
%              elements specified in the mask.
% 

opt.featType = {'DIR'};
opt.featParam = {[msize,nbands]};
[~,~,F] = gen2DFeats(image,1,opt);
maxF = max(F,[],3);
minF = min(F,[],3);
dirRatio = minF./maxF;

end