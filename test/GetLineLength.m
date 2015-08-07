function ll=GetLineLength(L,IS3D)
if(IS3D)
    dist=sqrt((L(2:end,1)-L(1:end-1,1)).^2+ ...
              (L(2:end,2)-L(1:end-1,2)).^2+ ...
              (L(2:end,3)-L(1:end-1,3)).^2);
else
    dist=sqrt((L(2:end,1)-L(1:end-1,1)).^2+ ...
              (L(2:end,2)-L(1:end-1,2)).^2);
end
ll=sum(dist);
