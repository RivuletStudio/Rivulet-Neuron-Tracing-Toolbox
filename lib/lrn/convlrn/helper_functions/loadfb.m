function [p, filters] = loadfb(p)

tmp_fb = load(p.filters_txt);
filters_size = size(tmp_fb,2);
filters_no = size(tmp_fb,1)/filters_size;

filters = cell(filters_no, 1);

for i_filter = 1:filters_no
    filters{i_filter} = tmp_fb((i_filter-1)*filters_size+1:i_filter*filters_size,:);
end

p.filters_no = filters_no;
p.filters_size = filters_size;

end