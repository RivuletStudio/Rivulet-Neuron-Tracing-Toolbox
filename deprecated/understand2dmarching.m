SourcePoints = [30, 10, 51, 10; 30, 10, 51, 9];
SpeedImage = ones([101 101]);
F = SpeedImage;
T = zeros(size(F))-1;
usesecond = false;
usecross = false;
% Augmented Fast Marching (For skeletonize)
%Ed=nargout>1;
Ed = 1;
% Euclidian distance image 
if(Ed), Y = zeros(size(F)); end

% Pixels which are processed and have a final distance are frozen
Frozen   = zeros(size(F));

% Free memory to store neighbours of the (segmented) region
neg_free = 100000;
neg_pos=0;
if(Ed),
    neg_list = zeros(4,neg_free);
else
    neg_list = zeros(3,neg_free);
end

% (There are 3 pixel classes:
%   - frozen (processed)
%   - narrow band (boundary) (in list to check for the next pixel with smallest distance)
%   - far (not yet used)

% Neighbours
ne =[-1 0;
    1 0;
    0 -1;
    0 1];

SourcePoints=int32(floor(SourcePoints));

% set all starting points to distance zero and frozen
for z=1:size(SourcePoints,2)
    % starting point
    x= SourcePoints(1,z); y=SourcePoints(2,z);
    % Set starting point to frozen and distance to zero
    Frozen(x,y)=1; T(x,y)=0;
end

% Add all neighbours of the starting points to narrow list
for z=1:size(SourcePoints,2)
    % starting point
    x=SourcePoints(1,z); 
	y=SourcePoints(2,z);
    for k=1:4,
        % Location of neighbour
        i=x+ne(k,1); j=y+ne(k,2);
        % Check if current neighbour is not yet frozen and inside the
        % picture
        if((i>0)&&(j>0)&&(i<=size(F,1))&&(j<=size(F,2))&&(Frozen(i,j)==0))
            Tt=1/max(F(i,j),eps);
	        Ty=1;
            % Update distance in neigbour list or add to neigbour list
            if(T(i,j)>0)
				if(neg_list(1,T(i,j))>Tt)
					neg_list(1,T(i,j))=Tt;
	            end
				if(Ed)
                    neg_list(4,T(i,j))=min(Ty,neg_list(4,T(i,j)));
                end
            else
	            neg_pos=neg_pos+1;
                % If running out of memory at a new block
                if(neg_pos>neg_free), neg_free = neg_free +100000; neg_list(1,neg_free)=0; end
                if(Ed)
                    neg_list(:,neg_pos)=[Tt;i;j;Ty];
                else
                    neg_list(:,neg_pos)=[Tt;i;j];
                end
                T(i,j)=neg_pos;
            end
        end
    end
end
% Loop through all pixels of the image
for itt=1:numel(F)
    % Get the pixel from narrow list (boundary list) with smallest
    % distance value and set it to current pixel location
    [t,index]=min(neg_list(1,1:neg_pos));
    if(neg_pos==0), break; end
    x=neg_list(2,index); y=neg_list(3,index);
    Frozen(x,y)=1;
    T(x,y)=neg_list(1,index);
        
    if(Ed), Y(x,y)=neg_list(4,index); end
        
    % Remove min value by replacing it with the last value in the array
    if(index<neg_pos),
        neg_list(:,index)=neg_list(:,neg_pos);
        x2=neg_list(2,index); y2=neg_list(3,index);
        T(x2,y2)=index; 
    end
    neg_pos =neg_pos-1;
    
    % Loop through all 4 neighbours of current pixel
    for k=1:4,
        % Location of neighbour
        i=x+ne(k,1); j=y+ne(k,2);
        
        % Check if current neighbour is not yet frozen and inside the
        % picture
        if((i>0)&&(j>0)&&(i<=size(F,1))&&(j<=size(F,2))&&(Frozen(i,j)==0))
            
            Tt=CalculateDistance(T,F(i,j),size(F),i,j,usesecond,usecross,Frozen);
            if(Ed)
                Ty=CalculateDistance(Y,1,size(F),i,j,usesecond,usecross,Frozen);
            end
            
            % Update distance in neigbour list or add to neigbour list
            if(T(i,j)>0)
                neg_list(1,T(i,j))=min(Tt,neg_list(1,T(i,j)));
                if(Ed)
                    neg_list(4,T(i,j))=min(Ty,neg_list(4,T(i,j)));
                end
            else
                neg_pos=neg_pos+1;
                % If running out of memory at a new block
                if(neg_pos>neg_free), neg_free = neg_free +100000; neg_list(1,neg_free)=0; end
                if(Ed)
                    neg_list(:,neg_pos)=[Tt;i;j;Ty];
                else
                    neg_list(:,neg_pos)=[Tt;i;j];
                end
                T(i,j)=neg_pos;
            end
        end
    end
end