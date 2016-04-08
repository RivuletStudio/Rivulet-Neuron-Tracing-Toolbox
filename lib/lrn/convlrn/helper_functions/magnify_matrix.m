function [magnified_matrix] = magnify_matrix(input_matrix,factor)
%  magnify_matrix  enlarges a matrix by a given factor
%
%  Synopsis:
%     [magnified_matrix] = magnify_matrix(input_matrix,factor)
%
%  Input:
%     input_matrix = matrix to magnify
%     factor = magnification factor
%  Output:
%     magnified_matrix = magnified matrix

%  author: Roberto Rigamonti, CVLab EPFL
%  e-mail: roberto <dot> rigamonti <at> epfl <dot> ch
%  web: http://cvlab.epfl.ch/~rigamont
%  date: April 2012
%  last revision: 30 April 2012

magnified_matrix = zeros(size(input_matrix,1)*factor,size(input_matrix,2)*factor);

for r = 1:size(input_matrix,1)
    for c = 1:size(input_matrix,2)
        magnified_matrix((r-1)*factor+1:r*factor,(c-1)*factor+1:c*factor) = input_matrix(r,c);
    end
end

end
