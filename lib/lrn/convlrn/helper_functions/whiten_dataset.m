function [dataset] = whiten_dataset(dataset,w_filter)
%  whiten_dataset  whiten the dataset with the given whitening filter
%
%  Synopsis:
%     [dataset] = whiten_dataset(dataset,w_filter)
%
%  Input:
%     dataset  = cell array containing the training images
%     w_filter = whitening filter
%  Output:
%     dataset = whitened dataset

%  author: Roberto Rigamonti, CVLab EPFL
%  e-mail: roberto <dot> rigamonti <at> epfl <dot> ch
%  web: http://cvlab.epfl.ch/~rigamont
%  date: April 2012
%  last revision: 27 April 2012

fprintf('  Whitening the dataset\n');

for i_img = 1:length(dataset)
    img = imfilter(dataset{i_img},w_filter,'symmetric','same');
    dataset{i_img} = img;
end

end
