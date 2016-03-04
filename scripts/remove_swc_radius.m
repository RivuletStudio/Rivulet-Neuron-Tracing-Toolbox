% Make all the swc files in one folder with radius 1
function remove_swc_radius(folderpath)

lswc = dir(fullfile(folderpath,'*.swc'));

for i = 1 : numel(lswc)
    swc = loadswc(fullfile(folderpath, lswc(i).name));
    swc(:, 6) = 1;
    save_v3d_swc_file(swc, fullfile(folderpath, lswc(i).name));
end

end
