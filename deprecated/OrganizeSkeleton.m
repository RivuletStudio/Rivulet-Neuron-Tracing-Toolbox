function S=OrganizeSkeleton(SkeletonSegments,IS3D)
n=length(SkeletonSegments);
if(IS3D)
    Endpoints=zeros(n*2,3);
else
    Endpoints=zeros(n*2,2);
end
l=1;
for w=1:n
    ss=SkeletonSegments{w};
    l=max(l,length(ss));
    Endpoints(w*2-1,:)=ss(1,:); 
    Endpoints(w*2,:)  =ss(end,:);
end
CutSkel=spalloc(size(Endpoints,1),l,10000);
ConnectDistance=2^2;

for w=1:n
    ss=SkeletonSegments{w};
    ex=repmat(Endpoints(:,1),1,size(ss,1));
    sx=repmat(ss(:,1)',size(Endpoints,1),1);
    ey=repmat(Endpoints(:,2),1,size(ss,1));
    sy=repmat(ss(:,2)',size(Endpoints,1),1);
    if(IS3D)
        ez=repmat(Endpoints(:,3),1,size(ss,1));
        sz=repmat(ss(:,3)',size(Endpoints,1),1);
    end
    if(IS3D)
        D=(ex-sx).^2+(ey-sy).^2+(ez-sz).^2;
    else
        D=(ex-sx).^2+(ey-sy).^2;
    end
    check=min(D,[],2)<ConnectDistance;
    check(w*2-1)=false; check(w*2)=false;
    if(any(check))
        j=find(check);
        for i=1:length(j)
            line=D(j(i),:);
            [foo,k]=min(line);
            if((k>2)&&(k<(length(line)-2))), CutSkel(w,k)=1; end
        end
    end
end

pp=0;
for w=1:n
    ss=SkeletonSegments{w};
    r=[1 find(CutSkel(w,:)) length(ss)];
    for i=1:length(r)-1
        pp=pp+1;
        S{pp}=ss(r(i):r(i+1),:);
    end
end