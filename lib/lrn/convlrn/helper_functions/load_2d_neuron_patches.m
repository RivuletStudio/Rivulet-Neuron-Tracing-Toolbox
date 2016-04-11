function dataset = load_2d_neuron_patches(p)
	% if (~exist(p.paths.processed_dataset,'file'))
	    [blocks_list,blocks_no] = get_list(p.dataset_filelist);
	    dataset = {};
	    
	    for i_block = 1:blocks_no
	        fprintf('Loading 2D neuron pathces from %s, block %d/%d\n', blocks_list{i_block}, i_block,blocks_no);
	        x = double(h5read(blocks_list{i_block}, '/data'));
	        tdataset = cell(size(x, 4), 1);
	        neuronpatch = zeros(size(x, 1), size(x, 2));
	        for i_img = 1:size(x, 4)
	        		neuronpatch = x(:,:, 1, i_img);
		            tdataset{i_img} = neuronpatch;
	        end

	        dataset = [dataset; tdataset];
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
	% else
	%     load(p.paths.processed_dataset,'dataset');
	% end
end