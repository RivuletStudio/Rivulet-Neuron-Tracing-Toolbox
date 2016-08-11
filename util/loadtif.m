function input_matrix = loadtif(destpath)
[~, ~, ext] = fileparts(destpath);

if strcmp(ext, '.tif')
    info = imfinfo(destpath);
    num_images = numel(info);
    for k = 1 : num_images
        input_matrix(:,:,k) = rot90(imread(destpath, k), -1);
    end
else
    tifpath = ([destpath filesep '*.tif']);
    disp(tifpath)
    listOftif = dir(tifpath);
    [numtif useless] = size(listOftif);
    for i = 1 : numtif
        stringi = num2str(i);
        tifname = [stringi '.tif'];
        input_matrix(:,:,i) = imread([destpath filesep tifname]);
    end
end

end
 