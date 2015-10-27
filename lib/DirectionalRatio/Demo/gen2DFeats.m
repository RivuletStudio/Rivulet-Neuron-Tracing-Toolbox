% Copyright � 2012 Computational Biomedicine Lab (CBL), 
% University of Houston. All rights reserved.
% 
% Redistribution and use in source and binary forms, with or without
% modification, is prohibited without the prior written consent of CBL.
%

function [feats,M,F] = gen2DFeats(image,indices,opt)
% function opt = genFeats(opt)
% This function receives a 2D image, the set of indices for which the
% features have to be generated, and the set of options indicating what
% features should be generated. 
% 
% INPUT:
%  - image: This is the two dimensional image.
%  - indices: This is the set of indices for which the features will be
%            stored.
%  - opt: This is a struct containing two cell fields: 
%     * featType, that contains a list of the types of features: 'LP' (Low
%       Pass), 'HP' (High Pass), 'Lap' (Laplacian), 'Shear' (Shearlets),
%       'DIR' (directional filters).
 %
%     * featParam, For 'LP' or 'Lap', the respective parameter is an Nx1
%       array, where each element is the respective fact. For 'HP' it is an
%       Nx2  array, where the entry (i,1) is the upper fact for the i-th
%       feature, and the entry (i,2) is the lower fact. For 'Shear', it is
%       the number of bands on each level, including the coarse level.
%       For 'DIR'the number of bands.
%     * cubeSize: In the case that 
% 
% OUTPUT:
%  - feats: This is the feature matrix for the SVM.
%  - M: Matrix with maximum and minimum intensities for each image.
%  - F:  3D Array with filtered images.
% 

opt =  countFeat(opt);
feats = zeros(length(indices),opt.totFeat,'single');
nFeatTypes = length(opt.featParam); % Number of feature types.
M = zeros(2,opt.totFeat,'single');
F = [];

for k = 1:nFeatTypes
    n = opt.cumFeat(k) + 1;
    if k < nFeatTypes
        N = opt.cumFeat(k+1);
    else
        N = opt.totFeat;
    end
    switch opt.featType{k}
        case{'LP'}
            [TF, mM, FI] = genLP(image,indices,opt.featParam{k});
            M(:,n:N) = mM;
            feats(:,n:N) = TF;
            F = cat(3,F,FI);
        case{'Lap'}
            [TF, mM, FI] = genLap(image,indices,opt.featParam{k});
            M(:,n:N) = mM;
            feats(:,n:N) = TF;
            F = cat(3,F,FI);
        case{'HP'}
            [TF, mM, FI] = genHP(image,indices,opt.featParam{k});
            M(:,n:N) = mM;
            feats(:,n:N) = TF;
            F = cat(3,F,FI);
        case{'DIR'}
            [TF, mM, FI] = genDIR(image,indices,opt.featParam{k});
            M(:,n:N) = mM;
            feats(:,n:N) = TF;
            F = cat(3,F,FI);
        case{'Shear'}
            [TF, mM,FI]=genShear(image,indices,opt.featParam{k},...
                opt.cubeSize);
            M(:,n:N) = mM;
            feats(:,n:N) = TF;
            F = cat(3,F,FI);
        case{'SDIR'}
            [TF, mM, FI] = genSDIR(image,indices,opt.featParam{k});
            M(:,n:N) = mM;
            feats(:,n:N) = TF;
            F = cat(3,F,FI);
    end
end

end


function [tempFeat, mM, filtIm] = genDIR(S,I,P)
% This function generates the a set of Directional filtered features.
% 
% INPUT: 
%  - S: The solid to be filtered.
%  - I: The set of indices for which the features will be stored.
%  - P: The set of parameters.
% 
% OUTPUT:
%  - tempFeat: The matrix where the features will be generated.
%  - mM: A 2xN array containing maximum and minimum of the feature.
%  - filtIm:set of filtered images

tempFeat = zeros(length(I), sum(P(:,2)), 'single');
mM = zeros(2,sum(P(:,2)), 'single');

Q = cumsum(P(:,2));

filtIm = zeros([size(S),sum(P(:,2))]);

for i = 1:size(P,1)
    [F,~] = dirFilters2D(P(i,1),P(i,2));
    for k = 1:size(F,1)
        FI = convn(S,F{k},'same');
        M = max(FI(:));
        m = min(FI(:));
        
        n = Q(i) - P(i,2) + k;
        
        mM(1,n) = M;
        mM(2,n) = m;
        tempFeat(:,n) = FI(I);
        
        filtIm(:,:,n) = FI;
        
    end
end


end


function [tempFeat, mM, filtIm] = genShear(S,I,B,C)
% This function generates the a set of Shearlet filtered features.
% 
% INPUT: 
%  - S: The 2D image to be filtered.
%  - I: The set of indices for which the features will be stored.
%  - B: Bands per level.
%  - C: The cube size
% 
% OUTPUT:
%  - tempFeat: The matrix where the features will be generated.
%  - mM: A 2xN array containing maximum and minimum of the feature.
% 

L = length(B); % Level.
N = 2*sum(B);
tempFeat = zeros(length(I),N,'single');
filtIm = zeros([size(S),2*sum(B)]);
mM = zeros(2,N,'single');
% mM = zeros(N,2,'single');

F = meyerFilter(L,C,B);
P = radPyrDec(S,L);

currentFeature = 1;
for l = 1:L
    for k = 1:2
        II = length(F{k,l});
        for i = 1:II
            TF = convn(P{l},F{k,l}{i},'same');
            % TF = convnfft(P{l},F{k,l}{i,j},'same');
            M = max(TF(:));
            m = min(TF(:));
            mM(1,currentFeature) = M;
            mM(2,currentFeature) = m;
            tempFeat(:,currentFeature) = TF(I);
            filtIm(:,:,currentFeature) = TF;
            currentFeature = currentFeature + 1;
        end
    end
end

end


function [tempFeat, mM, filtIm] = genLap(S,I,P)
% This function generates the a set of Laplacian filtered features.
% 
% INPUT: 
%  - S: The 3D solid to be filtered.
%  - I: The set of indices for which the features will be stored.
%  - P: The set of parameters.
% 
% OUTPUT:
%  - tempFeat: The matrix where the features will be generated.
%  - mM: A 2xN array containing maximum and minimum of the feature.
% 

tempFeat = zeros(length(I), length(P), 'single');
mM = zeros(2,length(P), 'single');
[Nx Ny] = size(S);
SF = fftn(S);

filtIm = zeros([size(S),size(P,1)]);

for i = 1:length(P)
    F = makeLapFilter(Nx,Ny,P(i));
    TF = SF.*F;
    TF = ifftn(TF);
    m = min(TF(:));
    M = max(TF(:));
    mM(1,i) = M;
    mM(2,i) = m;
    tempFeat(:,i) = TF(I);
    
    filtIm(:,:,i) = TF;
end

end


function [tempFeat, mM, filtIm] = genLP(S,I,P)
% This function generates the a set of Low Pass filtered features.
% 
% INPUT: 
%  - S: The 2D image to be filtered.
%  - I: The set of indices for which the features will be stored.
%  - P: The set of parameters.
% 
% OUTPUT:
%  - tempFeat: The matrix where the features will be generated.
%  - mM: A 2xN array containing maximum and minimum of the feature.
% 

tempFeat = zeros(length(I), length(P), 'single');
mM = zeros(2,length(P), 'single');
[Nx Ny] = size(S);
SF = fftn(S);

filtIm = zeros([size(S),size(P,1)]);

for i = 1:length(P)
    F = makeFilter(Nx,Ny,P(i));
    TF = SF.*F;
    TF = ifftn(TF);
    m = min(TF(:));
    M = max(TF(:));
    mM(1,i) = M;
    mM(2,i) = m;
    tempFeat(:,i) = TF(I);
    
    filtIm(:,:,i) = TF;
end

end


function [tempFeat, mM, filtIm] = genHP(S,I,P)
% This function generates the a set of Low Pass filtered features.
% 
% INPUT: 
%  - S: The 2D image to be filtered.
%  - I: The set of indices for which the features will be stored.
%  - P: The set of parameters.
% 
% OUTPUT:
%  - tempFeat: The matrix where the features will be generated.
%  - mM: A 2xN array containing maximum and minimum of the feature.
% 

tempFeat = zeros(length(I), size(P,1), 'single');
mM = zeros(2, size(P,1), 'single');
[Nx Ny] = size(S);
SF = fftn(S);

filtIm = zeros([size(S),size(P,1)]);


for i = 1:size(P,1)
    F = makeFilter(Nx,Ny,P(i,1)) - makeFilter(Nx,Ny,P(i,2));
    TF = SF.*F;
    TF = ifftn(TF);
    m = min(TF(:));
    M = max(TF(:));
    mM(1,i) = M;
    mM(2,i) = m;
    tempFeat(:,i) = TF(I);
    
    filtIm(:,:,i) = TF;
end

end


function opt = countFeat(opt)
% This is a small subroutine that counts the amount of features, both total
% and individual. It will also compute the shifted cumulative sum of the
% number of features.
% 
% INPUT:
%  - opt: Struct with a bunch of options to be counted and expanded.
% 
% OUTPUT: 
%  - opt: Struct of the expanded options.
%

n = length(opt.featParam);
opt.featN = zeros(n,1);

for k = 1:n
    switch opt.featType{k}
        case{'LP'}
            opt.featN(k) = length(opt.featParam{k});
        case{'Lap'}
            opt.featN(k) = length(opt.featParam{k});
        case{'HP'}
            opt.featN(k) = size(opt.featParam{k},1);
        case{'DIR'}
            opt.featN(k) = sum(opt.featParam{k}(:,2));
        case{'SDIR'}
            opt.featN(k) = sum(opt.featParam{k}(:,2));
        case{'Shear'}
            opt.featN(k) = 2*sum(opt.featParam{k});


    end
end

opt.totFeat = sum(opt.featN);
opt.cumFeat = circshift(cumsum(opt.featN),1);
opt.cumFeat(1) = 0;

end


function filt = makeLapFilter(nx,ny,fact)
% This is the routine that generates filters for Laplacian filters.
% 
% INPUT:
%  - nx, ny, nz: Dimensions of the three dimensional filter.
%  - fact: Fact parameters for the filters.
% 
% OUTPUT:
%  - filt: The filter needed.
% 

% Determine maximum frequencies
kxmax = pi; kymax = pi; 

% Determine Reflexion values
nhx=floor(nx/2); 
nhy=floor(ny/2); 

flipx=mod(nx,2); 
flipy=mod(ny,2); 

% Arrays
kx=(kxmax/nhx)*(0:nhx); 
ky=(kymax/nhy)*(0:nhy); 

%HDAF parameters
ndaf=60;
kd=fact*kxmax;
sigma=sqrt(2.0*ndaf+1)/kd;

[Kx,Ky]=ndgrid(kx,ky);
Kxy = Kx.^2+Ky.^2;
filtro = Kxy.*hdaf(ndaf,sigma,Kxy);
filt = zeros(nx,ny,'single');

% Filter reflexion.
filt(1:nhx+1,1:nhy+1) = filtro;
filt(nhx+2:nx,:) = filt(nhx+flipx:-1:2,:);
filt(:,nhy+2:ny) = filt(:,nhy+flipy:-1:2);

end


function filt = makeFilter(nx,ny,fact)
% This is the routine that generates filters for Low Pass and High Pass
% filters.
% 
% INPUT:
%  - nx, ny, nz: Dimensions of the three dimensional filter.
%  - fact: Fact parameters for the filters.
% 
% OUTPUT:
%  - filt: The filter needed.
% 

% Determine maximum frequencies
kxmax = pi;
kymax = pi;

% Determine Reflexion values
nhx = floor(nx/2);
nhy = floor(ny/2);

flipx = mod(nx,2);
flipy = mod(ny,2);

% Arrays
kx=(kxmax/nhx)*(0:nhx); 
ky=(kymax/nhy)*(0:nhy); 

%HDAF parameters
ndaf = 60;
kd = fact * kxmax;
sigma = sqrt(2.0*ndaf+1)/kd;

% Filter reflexion.
[Kx,Ky] = ndgrid(kx,ky);
Kxy = Kx.^2+Ky.^2;
filtro = hdaf(ndaf,sigma,Kxy);
filt = single(zeros(nx,ny));

% Filter reflexion.
filt(1:nhx+1,1:nhy+1) = filtro;
filt(nhx+2:nx,:) = filt(nhx+flipx:-1:2,:);
filt(:,nhy+2:ny) = filt(:,nhy+flipy:-1:2);

end


function filt = makeShearFilter(nx,ny,fact)
% This is the routine that generates filters for Low Pass and High Pass
% filters.
% 
% INPUT:
%  - nx, ny Dimensions of the 2D dimensional filter.
%  - fact: Fact parameters for the filters.
% 
% OUTPUT:
%  - filt: The filter needed.
% 

% Determine maximum frequencies
kxmax = pi;
kymax = pi;

% Determine Reflexion values
nhx = floor(nx/2);
nhy = floor(ny/2);

flipx = mod(nx,2);
flipy = mod(ny,2);

% Arrays
kx=(kxmax/nhx)*(0:nhx); 
ky=(kymax/nhy)*(0:nhy); 

%HDAF parameters
ndaf = 60;
kd = fact * kxmax;
sigma = sqrt(2.0*ndaf+1)/kd;

% Filter reflexion.
[Kx,Ky] = ndgrid(kx,ky);
Kxy = max(Kx,Ky);
Kxy= Kxy.^2;
filtro = hdaf(ndaf,sigma,Kxy);
filt = single(zeros(nx,ny));

% Filter reflexion.
filt(1:nhx+1,1:nhy+1) = filtro;
filt(nhx+2:nx,:) = filt(nhx+flipx:-1:2,:);
filt(:,nhy+2:ny) = filt(:,nhy+flipy:-1:2);

end


function F = hdaf(n,s,x)
% INPUT
%  - n: Number of Approximations for the Taylor Polynomial
%  - s: Deviation of the Gaussian (sigma)
%  - x: Values to evaluate. It may be a scalar, or an array.
% 
% OUTPUT
% \left[\sum_{i=0}^{n}\frac{1}{k!}\left(\frac{x\sigma^2}{2}\right)^{i}
% \right]e^{-\frac{x\sigma^2}{2}}
% 

  en = 1.0; 
  ft = 1.0;
  for i=1:n
    ft = ft*i;
    en = en+((x*s^2)/2).^i/ft;
  end
  F = single(en.*exp((-1.0)*x*(s^2)/2));
  
end


function [filts dirs] = dirFilters2D(mSize,nBands)
% This function computes a set of filters for Soma Detection.
% 
% INPUT:
%  - mSize: The size of the filters.
%  - nBands: Number of bands.
% 
% OUTPUT:
%  - filts: Cell containing the filters in question
%  - dirs: The direction of the corresponding filters
% 

filts = cell(nBands,1);
dirs = zeros(2,nBands);

theta = (0:(nBands-1))*pi/nBands;
rho = ones(1,nBands);
[X Y] = pol2cart(theta, rho);
dirs(1,:) = X;
dirs(2,:) = Y;

for k = 0:(nBands-1)
    ang1 = (k-1/2)*pi/nBands;
    ang2 = (k+1/2)*pi/nBands;
    theta = [ang1, ang2, ang1, ang2, ang1];
    rho = [1,1,-1,-1,1]*floor(mSize/2);
    [X Y] = pol2cart(theta, rho);
    X = X + ceil(mSize/2);
    Y = Y + ceil(mSize/2);
    F = poly2mask(X,Y,mSize,mSize);
    N = numel(find(F==1));
    filts{k+1} = F/N;
   
end


end


function P = radPyrDec(S,L)
% Radial Pyramidal Decomposition of the number of levels indicated
% 
% INPUT:
%  - S: The Solid in Question
%  - L: the number of levels of the decomposition.
% 
% OUTPUT:
%  - P: an L+1 by 1 cell array storyng the subbands from the finest to the
%       coarsest scale.
% 

S = single(S);
X = fftn(S);
[nx ny ] = size(X);
uf = 1.3; % Upper adjustment factor. Works for ndaf = 60.
lf = 0.8; % Lower adjustment factor. Works for ndaf = 60.
P = cell(L,1);
for k = 1:L
    if k == 1
        fact1 = lf*(L-1)/L;
        F = makeShearFilter(nx,ny,fact1);
        F(isinf(F)) = 0;
        F(isnan(F)) = 0;
        F = 1 - F;
    elseif k == L
        fact2 = uf/(L);
        F = makeShearFilter(nx,ny,fact2);
        F(isinf(F)) = 0;
        F(isnan(F)) = 0;
    else
        fact1 = uf*(L+1-k)/(L);
        fact2 = lf*(L-k)/(L);
        F1 = makeShearFilter(nx,ny,fact1);
        F2 = makeShearFilter(nx,ny,fact2);
        F1(isinf(F1)) = 0;
        F1(isnan(F1)) = 0;
        F2(isinf(F2)) = 0;
        F2(isnan(F2)) = 0;
        F = F1 - F2;
    end
    P{k} = single(ifftn(X.*F));
end

end


function F = meyerFilter(level,cubeSize,levBands)
% It generates a set of Meyer Based Filters in 2D, according to Pooran's
% code.
% 
% INPUT: 
%  - level: Number of level decomposition. Integer.
%  - cubeSize: The length of the filt level for convolution. Integer
%  - levBands: the number of bands at eachel. Integer array level-long.
% 
% OUTPUT:
%  - F: 2xlevel cell of cells, each subsell contains a set of band filters
%       for the indicated dimension (direction) and level.
%

F = cell(2,level);
for l = 1:level
    numDir = levBands(l);
    P = genPyrSection(cubeSize);%,'single');
    S = cubeSize/numDir; % variable shift from Pooran's
    A = zeros(cubeSize,'single');
    for c = 1:2
        for i = 1:numDir
            % Define I, the size of R, and fill the 1s and 1/2s.
            if (i == numDir)
                R = ones(S,cubeSize)/2;
                R(2:(S-1),1:cubeSize) = 1;
                I = [(i-1)*S+1, i*S;1, cubeSize];
            else
                R = ones(S+1,cubeSize)/2;
                R(2:S, 1:cubeSize) = 1;
                I = [(i-1)*S+1, i*S+1; 1, cubeSize];
            end
            F{c,l}{i} = polToRec(I,R,P{c});
            A = A + F{c,l}{i};
        end
    end
    
    for c = 1:2
        for i = 1:numDir
            for j = 1:numDir
                F{c,l}{i} = F{c,l}{i}./A;
                F{c,l}{i} = single(real(fftshift(ifftn(fftshift(F{c,l}{i})))));
            end
        end
    end
end

end


function B = polToRec(radIdx,mRad,P)
% The transformation of the filter from polar to rectangular coordinates. I
% need a better understanding of how this works, and potentially, a way to
% make it more efficient. For now, I just modified Pooran's code to make it
% less redundant.
%
% INPUT:
%  - radIdx: Coordinates of inference.
%  - mRad: Value.
%  - P: Filter in Polar Coordinates.
%
% OUTPUT:
%  - B: Filter in rectangular coordinates.
%

B = single(zeros(size(P.X)));
for i = radIdx(1,1):radIdx(1,2)
    for j = radIdx(2,1):radIdx(2,2)
        B(P.X(i,j),P.Y(i,j)) = ...
            mRad(i-radIdx(1,1)+1,j-radIdx(2,1)+1);
    end
end

end


function P = genPyrSection(n)
% This function generates the 2 dimensional cones.
%
% INPUT:
%  - n: square size.
%
% OUTPUT:
%  - P: Cell with the pyramidal sections.
%

P = cell(1,2);
[P{1}.X P{1}.Y]= genXY(n);
P{2}.X = P{1}.Y; P{2}.Y = P{1}.X; 

end


function [X,Y] = genXY(n)
% This right now corresponds to genXY
[pI, pJ] = ndgrid(1:n,1:n);
[nI, ~] = ndgrid(n:-1:1,n:-1:1);
X = uint16(pJ);
Y = uint16(pI + (pJ-1).*abs(pI-nI)/(n-1));
mP = ceil(n/2);
pDir = 1:mP;
nDir = n+1-pDir;
Y(nDir,n:-1:1) = Y(pDir,1:n);

end


% CREATED: 
% - Date: 09/06/2012
% - By: David Jimenez & Burcin Ozcan
% 
