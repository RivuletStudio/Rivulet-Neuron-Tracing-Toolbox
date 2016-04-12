function [Lambda1, Lambda2, Lambda3] = eigextract(I, sigma)

    [Dxx, Dyy, Dzz, Dxy, Dxz, Dyz] = Hessian3D(I,sigma);

    % Correct for scaling
    c = sigma^2;
    Dxx = c*Dxx; Dxy = c*Dxy;
    Dxz = c*Dxz; Dyy = c*Dyy;
    Dyz = c*Dyz; Dzz = c*Dzz;

    [Lambda1,Lambda2,Lambda3] = eig3volume(Dxx,Dxy,Dxz,Dyy,Dyz,Dzz);
    
end