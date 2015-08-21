function input_matrix = tifread(pathdir)
lastfour = pathdir(end-3:end);
disp(lastfour)
if strcmp(lastfour, '.tif')
    info = imfinfo(pathdir);
    num_images = numel(info);
    for k = 1 : num_images
        input_matrix(:,:,k) = imread(pathdir, k);
    end
else
    tifpath = ([pathdir filesep '*.tif']);
    disp(tifpath)
    listOftif = dir(tifpath);
    [numtif useless] = size(listOftif);
    for i = 1 : numtif
        stringi = num2str(i);
        tifname = [stringi '.tif'];
        input_matrix(:,:,i) = imread([pathdir filesep tifname]);
    end
end
end
 