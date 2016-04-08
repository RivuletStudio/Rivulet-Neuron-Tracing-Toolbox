function [dataset] = load_CIFAR10_dataset(p)
%  load_CIFAR10_dataset  loads the CIFAR-10 dataset, eventually performing
%                        the whitening
%
%  Synopsis:
%     [dataset] = load_CIFAR10_dataset(p)
%
%  Input:
%     p = structure containing framework's configuration
%  Output:
%     dataset = loaded CIFAR-10 dataset

%  author: Roberto Rigamonti, CVLab EPFL
%  e-mail: roberto <dot> rigamonti <at> epfl <dot> ch
%  web: http://cvlab.epfl.ch/~rigamont
%  date: April 2012
%  last revision: 27 April 2012

if (~exist(p.paths.processed_dataset,'file'))
    [blocks_list,blocks_no] = get_list(p.dataset_filelist);
    dataset = cell(blocks_no*p.imgs_per_block,1);
    
    % Load CIFAR-10's blocks and convert the images to grayscale, storing them
    % in the dataset's cell array
    for i_block = 1:blocks_no
        fprintf('  Loading CIFAR-10 dataset, block %d/%d\n',i_block,blocks_no);
        x = load(blocks_list{i_block});
        x = x.data;
        cifar_10_img = zeros(32,32,3);
        for i_img = 1:size(x,1)
            cifar10_img(:,:,1) = reshape(x(i_img,1:1024),32,32)';
            cifar10_img(:,:,2) = reshape(x(i_img,1025:2048),32,32)';
            cifar10_img(:,:,3) = reshape(x(i_img,2049:end),32,32)';
            dataset{(i_block-1)*p.imgs_per_block+i_img} = im2double(rgb2gray(cifar10_img));
        end
    end
    
    % Center dataset. We can safely divide by the standard deviation as we are
    % certain that it is different from zero.
    for i_img = 1:length(dataset)
        dataset{i_img} = (dataset{i_img}-mean(dataset{i_img}(:)))/std(dataset{i_img}(:));
    end
    
    % If requested, whiten images
    if (p.whiten_images)
        if (~exist(p.paths.w_filter_filename,'file'))
            w_filter = compute_whitening_filter(p,dataset);
            save(p.paths.w_filter_filename,'w_filter','-v7.3');
        else
            load(p.paths.w_filter_filename,'w_filter');
        end
        dataset = whiten_dataset(dataset,w_filter);
    end
    
    save(p.paths.processed_dataset,'dataset','-v7.3');
else
    load(p.paths.processed_dataset,'dataset');
end

end
