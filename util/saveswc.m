function saveswc( outfilename, swc )
%SAVESWC Summary of this function goes here
%   Detailed explanation goes here

if isempty(swc),
    return;
end

if size(swc,2)<7,
    error('The first variable must have at least 7 columns.'),
end

f = fopen(outfilename, 'wt');
if f<=0,
    error('Fail to open file to write');
end

for i=1:size(swc,1),
    fprintf(f, '%d %d %5.3f %5.3f %5.3f %5.3f %d\n',...
        swc(i,1), swc(i,2), swc(i,3), swc(i,4), swc(i,5), swc(i,6), swc(i,7));
end

fclose(f);

end

