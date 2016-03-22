function Tt=CalculateDistance(T,Fij,sizeF,i,j,usesecond,usecross,Frozen)
% Boundary and frozen check -> current patch
Tpatch=inf(5,5);
for nx=-2:2
    for ny=-2:2
        in=i+nx; jn=j+ny;
        if((in>0)&&(jn>0)&&(in<=sizeF(1))&&(jn<=sizeF(2))&&(Frozen(in,jn)==1))
            Tpatch(nx+3,ny+3)=T(in,jn);
        end
    end
end

% The values in order is 0 if no neighbours in that direction
% 1 if 1e order derivatives is used and 2 if second order
% derivatives are used
Order=zeros(1,4);

% Make 1e order derivatives in x and y direction
Tm(1) = min( Tpatch(2,3) , Tpatch(4,3)); if(isfinite(Tm(1))), Order(1)=1; end
Tm(2) = min( Tpatch(3,2) , Tpatch(3,4)); if(isfinite(Tm(2))), Order(2)=1; end
% Make 1e order derivatives in cross directions
if(usecross)
    Tm(3) = min( Tpatch(2,2) , Tpatch(4,4)); if(isfinite(Tm(3))), Order(3)=1; end
    Tm(4) = min( Tpatch(2,4) , Tpatch(4,2)); if(isfinite(Tm(4))), Order(4)=1; end
end

% Make 2e order derivatives
if(usesecond)
    Tm2=zeros(1,4);
    % pixels with a pixeldistance 2 from the center must be
    % lower in value otherwise use other side or first order
    ch1=(Tpatch(1,3)<Tpatch(2,3))&&isfinite(Tpatch(2,3)); ch2=(Tpatch(5,3)<Tpatch(4,3))&&isfinite(Tpatch(4,3));

    if(ch1&&ch2),Tm2(1) =min( (4*Tpatch(2,3)-Tpatch(1,3))/3 , (4*Tpatch(4,3)-Tpatch(5,3))/3);  Order(1)=2;
    elseif(ch1), Tm2(1) =(4*Tpatch(2,3)-Tpatch(1,3))/3; Order(1)=2;
    elseif(ch2), Tm2(1) =(4*Tpatch(4,3)-Tpatch(5,3))/3; Order(1)=2;
    end

    ch1=(Tpatch(3,1)<Tpatch(3,2))&&isfinite(Tpatch(3,2)); ch2=(Tpatch(3,5)<Tpatch(3,4))&&isfinite(Tpatch(3,4));

    if(ch1&&ch2),Tm2(2) =min( (4*Tpatch(3,2)-Tpatch(3,1))/3 , (4*Tpatch(3,4)-Tpatch(3,5))/3); Order(2)=2;
    elseif(ch1), Tm2(2)=(4*Tpatch(3,2)-Tpatch(3,1))/3; Order(2)=2;
    elseif(ch2), Tm2(2)=(4*Tpatch(3,4)-Tpatch(3,5))/3; Order(2)=2;
    end

    if(usecross)
        ch1=(Tpatch(1,1)<Tpatch(2,2))&&isfinite(Tpatch(2,2)); ch2=(Tpatch(5,5)<Tpatch(4,4))&&isfinite(Tpatch(4,4));
        if(ch1&&ch2),Tm2(3) =min( (4*Tpatch(2,2)-Tpatch(1,1))/3 , (4*Tpatch(4,4)-Tpatch(5,5))/3); Order(3)=2;
        elseif(ch1), Tm2(3)=(4*Tpatch(2,2)-Tpatch(1,1))/3; Order(3)=2;
        elseif(ch2), Tm2(3)=(4*Tpatch(4,4)-Tpatch(5,5))/3; Order(3)=2;
        end

        ch1=(Tpatch(1,5)<Tpatch(2,4))&&isfinite(Tpatch(2,4)); ch2=(Tpatch(5,1)<Tpatch(4,2))&&isfinite(Tpatch(4,2));
        if(ch1&&ch2),Tm2(4) =min( (4*Tpatch(2,4)-Tpatch(1,5))/3 , (4*Tpatch(4,2)-Tpatch(5,1))/3); Order(4)=2;
        elseif(ch1), Tm2(4)=(4*Tpatch(2,4)-Tpatch(1,5))/3; Order(4)=2;
        elseif(ch2), Tm2(4)=(4*Tpatch(4,2)-Tpatch(5,1))/3; Order(4)=2;
        end
    end
else
    Tm2=zeros(1,4);
end

% Calculate the distance using x and y direction
Coeff = [0 0 -1/(max(Fij^2,eps))];
for t=1:2;
    switch(Order(t))
        case 1,
            Coeff=Coeff+[1 -2*Tm(t) Tm(t)^2];
        case 2,
            Coeff=Coeff+[1 -2*Tm2(t) Tm2(t)^2]*(2.2500);
    end
end

Tt=roots(Coeff); Tt=max(Tt);
% Calculate the distance using the cross directions
if(usecross)
    Coeff = Coeff + [0 0 -1/(max(Fij^2,eps))];
    for t=3:4;
        switch(Order(t))
            case 1,
                Coeff=Coeff+0.5*[1 -2*Tm(t) Tm(t)^2];
            case 2,
                Coeff=Coeff+0.5*[1 -2*Tm2(t) Tm2(t)^2]*(2.2500);
        end
    end
    Tt2=roots(Coeff); Tt2=max(Tt2);
    % Select minimum distance value of both stensils
    if(~isempty(Tt2)), Tt=min(Tt,Tt2); end
end

% Upwind condition check, current distance must be larger
% then direct neighbours used in solution
DirectNeigbInSol=Tm(isfinite(Tm));
if(nnz(DirectNeigbInSol>=Tt)>0) % Will this ever happen?
    Tt=min(DirectNeigbInSol)+(1/(max(Fij,eps)));
end
