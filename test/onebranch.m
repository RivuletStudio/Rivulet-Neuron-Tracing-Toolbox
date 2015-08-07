% function S=onebranch(I,verbose)
% This function Skeleton will calculate an accurate skeleton (centerlines) 
% of an object represented by an binary image / volume using the fastmarching 
% distance transform.
%
% S=skeleton(I,verbose)
%
% inputs,
%	I : A 2D or 3D binary image
%	verbose : Boolean, set to true (default) for debug information
%
% outputs
%   S : Cell array with the centerline coordinates of the skeleton branches
%
% Literature
%   Robert van Uitert and Ingmar Bitter : "Subvoxel precise skeletons of volumetric 
%	data base on fast marching methods", 2007.
%
% Example 2D,
%
% % Read Blood vessel image
%   I=im2double(rgb2gray(imread('images/vessels2d.png')));
%
% % Convert double image to logical
%   Ibin=I<0.5;
%
% % Use fastmarching to find the skeleton
%   S=skeleton(Ibin);
% % Display the skeleton
%   figure, imshow(Ibin); hold on;
%   for i=1:length(S)
%     L=S{i};
%     plot(L(:,2),L(:,1),'-','Color',rand(1,3));
%   end
%
%
%  Example 3D,
%
% % Read Blood vessel image
%   load('images/vessels3d');
% % Note, this data is pre-processed from Dicom ConeBeam-CT with
% % V = imfill(Vraw > 30000,'holes');
%
% % Use fastmarching to find the skeleton
%   S=skeleton(V);
%
%
% % Show the iso-surface of the vessels
% figure,
%   FV = isosurface(V,0.5)
%   patch(FV,'facecolor',[1 0 0],'facealpha',0.3,'edgecolor','none');
%   view(3)
%   camlight
% % Display the skeleton
%   hold on;
%   for i=1:length(S)
%     L=S{i};
%     plot3(L(:,2),L(:,1),L(:,3),'-','Color',rand(1,3));
%   end

%if(nargin<2), verbose=true; end
tic
clc
clear all
close all
I=im2double(rgb2gray(imread('vessels2d.png')));
imshow(I);
I = I < 0.5;
% load('vessels3d.mat');
% I = V;
verbose = true;
%if(size(I,3)>1), IS3D=true; else IS3D=false; end
IS3D = false;
% Distance to vessel boundary
BoundaryDistance=getBoundaryDistance(I,IS3D);
if(verbose),
    disp('Distance Map Constructed');
end
    
% Get maximum distance value, which is used as starting point of the
% first skeleton branch
[SourcePoint,maxD]=maxDistancePoint(BoundaryDistance,I,IS3D);

% Make a fastmarching speed image from the distance image
SpeedImage=(BoundaryDistance/maxD).^4;
SpeedImage(SpeedImage==0)=1e-10;
%figure 
%imshow(SpeedImage)

% Skeleton segments found by fastmarching
SkeletonSegments=cell(1,1000);
itt = 0;
%while(1)
% Number of skeleton iterations

    if(verbose),
        disp(['Find Branches Iterations : ' num2str(itt)]);
    end

    % Do fast marching using the maximum distance value in the image
    % and the points describing all found branches are sourcepoints.
    [T,Y] =  msfm(SpeedImage, SourcePoint, false, false);
    %figure
    %Y = Y/(max(Y(:)));
    %imagesc(Y)
    %figure
    %T = T/(max(T(:)));
    %imagesc(T)  
    % Trace a branch back to the used sourcepoints
    StartPoint=maxDistancePoint(Y,I,IS3D);
    %T = T/(max(T(:)));
    %T = single(T);
    %StartPoint = [202, 307, 11]; 
    
    ShortestLine=shortestpath(T,StartPoint,SourcePoint,1,'rk4');
    %ShortestLine=unique(round(ShortestLine),'rows');
    
    hold on
    colorrnd = rand(1,3);
    plot(ShortestLine(:,2), ShortestLine(:,1), '-', 'Color', colorrnd, 'LineWidth', 3);
    %plot(StartPoint(2), StartPoint(1), '-s', 'Color', colorrnd);
    pause(3);
    % Calculate the length of the new skeleton segment
    linelength=GetLineLength(ShortestLine,IS3D);
        
    % Stop finding branches, if the lenght of the new branch is smaller
    % then the diameter of the largest vessel
    if(linelength<maxD*2), break; end;
    
    % Store the found branch skeleton
    itt=itt+1;
    SkeletonSegments{itt}=ShortestLine;
    
    % Add found branche to the list of fastmarching SourcePoints
    SourcePoint=[SourcePoint ShortestLine'];
%end
%SkeletonSegments(itt+1:end)=[];
%S=OrganizeSkeleton(SkeletonSegments,IS3D);
% if(verbose),
%     disp(['Skeleton Branches Found : ' num2str(length(S))]);
% end
toc
    



