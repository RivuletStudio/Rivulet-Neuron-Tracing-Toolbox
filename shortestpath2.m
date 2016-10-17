function [ShortestLine, dump, merged, somamerged] = shortestpath2(T, G, I, swc, StartPoint, SourcePoint, Stepsize, Method, Gap)
% This function SHORTESTPATH traces the shortest path from start point to
% source point using Runge Kutta 4 in a 2D or 3D distance map.
%
% ShortestLine=shortestpath(T,StartPoint,SourcePoint,Stepsize,Method)
% 
% inputs,
%   T : A 2D or 3D distance map (from the functions msfm2d or msfm3d)
%   StartPoint : Start point of the shortest path
%   SourcePoint : (Optional), End point of the shortest path
%   Stepsize: (Optional), Line trace step size 
%   Method: (Optional), 'rk4' (default), 'euler' ,'simple'
%   Gap: the maximum voxel gap in step size to stop trace
% output,
%   ShortestLine: M x 2 or M x 3 array with the Shortest Path
%   dump: true if stoped due to large gap 
%
% Note, first compile the rk4 c-code with compile_c_files
%   
% Example,
% Function is written by D.Kroon University of Twente (June 2009)
% Adapted by Siqi (Aug 2015)

% Process inputs
if(~exist('Stepsize','var')), Stepsize=0.5; end
if(~exist('SourcePoint','var')), SourcePoint=[]; end
if(~exist('Method','var')), Method='rk4'; end

% G = distgradient(T);

dump = false;
merged = false;
somamerged = false;
i=0; % Count movemnet 
j = 0; % Count empty steps
% Reserve a block of memory for the shortest line array
ifree=10000;
ShortestLine=zeros(ifree,ndims(T));
stepsremain = -1; % It is only used when it touched the surface of any previously traced neuron

% Iteratively trace the shortest line
while(true)
    if (ndims(T) == 2)
        disp([ceil(StartPoint(1)), ceil(StartPoint(2))]);
        if isnan(ceil(StartPoint(1))) || isnan(ceil(StartPoint(2)))
            break;
        end
        dist = T(ceil(StartPoint(1)), ceil(StartPoint(2)));
    else
        if isnan(ceil(StartPoint(1))) || isnan(ceil(StartPoint(2))) || isnan(ceil(StartPoint(3)))
            break;
        end
        dist = T(ceil(StartPoint(1)), ceil(StartPoint(2)), ceil(StartPoint(3)));
    end
    
    if dist == -3 % It reaches the centreline mask
        break;
    end

    if stepsremain == 0 % if it did not reach any surface of traced neuron, it decrelent as a negative value
        break;
    end

    stepsremain = stepsremain - 1;

    if dist == -1 && stepsremain < 0
        merged = true;

        % Find the closest traced node to current node
        if size(swc, 1) == 0
            break;
        else
            d = pdist2(StartPoint', swc(:,3:5));
            [~, idx] = min(d);
            stepsremain = ceil(swc(idx, 6));
        end
    elseif dist == -2
        merged = true;
        somamerged = true;
        fprintf('The coordinate of point reading soma surface: x : %3.2f, y : %3.2f, z : %3.2f\n', StartPoint(1), StartPoint(2), StartPoint(3));
        break;
    end

    % Calculate the next point using runge kutta
    switch(lower(Method))
        case 'rk4'
            EndPoint=rk4(StartPoint, G, Stepsize);
        case 'euler'
            EndPoint=e1(StartPoint, G, Stepsize);
        case 'simple'
            EndPoint=s1(StartPoint,T);
        otherwise
            error('shortestpath:input','unknown method');
    end

    % scatter3(EndPoint(2), EndPoint(1), EndPoint(3), 'r');
    % plot3([EndPoint(2);StartPoint(2)], [EndPoint(1);StartPoint(1)], [EndPoint(3); StartPoint(3)], 'b.');
    % drawnow

    if (ndims(T) == 2)
        if isnan(ceil(EndPoint(1))) || isnan(ceil(EndPoint(2)))
            break;
        end
    else
        if isnan(ceil(EndPoint(1))) || isnan(ceil(EndPoint(2))) || isnan(ceil(EndPoint(3)))
            break;
        end
    end


    % Calculate the distance to the end point
    if(~isempty(SourcePoint))
        [DistancetoEnd,ind]=min(sqrt(sum((SourcePoint-repmat(EndPoint,1,size(SourcePoint,2))).^2,1)));
    else
        
        DistancetoEnd=inf;
    end
    
    % Calculate the movement between current point and point 15 itterations back
    if(i>15), Movement=sqrt(sum((EndPoint(:)-ShortestLine(i-15,:)').^2));  else Movement=Stepsize+1;  end
    
%     fprintf('I: %f; j: %i\n', I(int16(EndPoint(1)), int16(EndPoint(2)), int16(EndPoint(3))), j);
    [Ixsize, Iysize, Izsize] = size(I);
    Ixvalue = int16(EndPoint(1));
    Iyvalue = int16(EndPoint(2));
    Izvalue = int16(EndPoint(3));
    if Ixvalue <= 0
        Ixvalue =1;
    elseif Ixvalue >= Ixsize
        Ixvalue = Ixsize -1;
    end
    if Iyvalue <= 0
        Iyvalue =1;
    elseif Iyvalue >= Iysize
        Iyvalue = Iysize -1;
    end
    if Izvalue <= 0
        Izvalue =1;
    elseif Izvalue >= Izsize
        Izvalue = Izsize -1;        
    end
    
    if (I(Ixvalue, Iyvalue, Izvalue) == 0), j = j + 1; else j = 0; end
        
    % Stop if out of boundary, distance to end smaller then a pixel or
    % if we have not moved for 15 itterations
    if((EndPoint(1)<1) || (EndPoint(1)>size(I,1)) || EndPoint(2)<1 || EndPoint(2)>size(I,2) ||...
            EndPoint(3)<1 || EndPoint(3)>size(I,3)...
        ||(Movement<Stepsize))
        ShortestLine = ShortestLine(1:i,:);
        break;  
    end

    % Count the number of itterations
    i=i+1; 
        
    % Add a new block of memory if full
    if(i>ifree), ifree=ifree+10000; ShortestLine(ifree,:)=0; end
  
    % Add current point to the shortest line array
    ShortestLine(i,:)=EndPoint;

    if(DistancetoEnd<Stepsize), 
        i=i+1;  if(i>ifree), ifree=ifree+10000; ShortestLine(ifree,:)=0; end
        % Add (Last) Source point to the shortest line array
        ShortestLine(i,:)=SourcePoint(:,ind);
        break 
    end
    
    if (j == Gap), dump = true; break; end
    
    % Current point is next Starting Point
    StartPoint = EndPoint;
    
    
end

% Remove unused memory from array
ShortestLine = ShortestLine(1:i,:);

end
