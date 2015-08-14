%   centre_header_file.m
%   Simon Robinson. 21/11/2007
%   Sets the origin of a NIfTI image to be the centre of the image
%   syntax: centre_header_file(filename)

function centre_header_file(filename)

nii = load_nii(filename);

nii.hdr.hist.originator(1) = ceil(nii.hdr.dime.dim(2)/2);
nii.hdr.hist.originator(2) = ceil(nii.hdr.dime.dim(3)/2);
nii.hdr.hist.originator(3) = ceil(nii.hdr.dime.dim(4)/2);
nii.hdr.hist.originator(4) = 0;
nii.hdr.hist.originator(5) = 0;

save_nii(nii, filename);

end