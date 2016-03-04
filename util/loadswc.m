function swc = loadswc( filename )
%LOADSWC Summary of this function goes here
%   Detailed explanation goes here
L = loadfilelist(filename);
swc = zeros(length(L), 7);

k=0;
for i=1:length(L),
    if isempty(deblank(L{i})),
        continue;
    end;
    if (L{i}(1)=='#'),
        continue;
    end;
    
    k=k+1;
    tmp = str2num(L{i});
    swc(k,:) = tmp(1:7);
end;

swc = swc(1:k,:); %%remove the non-used lines


end


function filelist = loadfilelist(filename)
% filelist = loadfilelist(filename)
% read a plain text file for all image names. One line is an image name.
%
% By Hanchuan Peng
% Jan,2001
% June, 2005. Fix the non-return value bug

filelist = [];
fid = fopen(filename);
if fid==-1,
    disp(['Error to open the file : ' filename]);
    return;
else
    i=1;
    while 1
        tline = fgetl(fid);
        if ~ischar(tline), break; end;
        filelist{i} = deblank(tline);
        i = i+1;
    end;
end;
fclose(fid);
end