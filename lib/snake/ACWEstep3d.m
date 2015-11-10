function  MorphGAC = ACWEstep3d(MorphGAC)
    global P3
    u = MorphGAC.u;
    data = MorphGAC.data;
    data = double(data) / 255;
    % figure
    % imagesc(data*255);
    inside = u > 0;
    % size(inside)
    % figure
    % imagesc(inside)
    outside = u<=0;
    doubleoutside = double(outside);
    doubleinside = double(inside);
    
    dataoutside = data(outside);
    datainside = data(inside);

    c0 = sum(dataoutside(:)) / sum(doubleoutside(:));

    c1 = sum(datainside(:)) / sum(doubleinside(:));
    dres = distgradient(u);
    % size(dres)
    % Image attachment.
    % [dres(:,:,1), dres(:,:,2)] = imgradientxy(u);
    abs_dres = abs(dres(:,:,:,1)) + abs(dres(:,:,:,2)) + abs(dres(:,:,:,3));
    firstpart = (data - c1).^2;
    firstpart = MorphGAC.lambda1 * firstpart;
    secondpart = (data - c0).^2;
    secondpart = MorphGAC.lambda2 * secondpart;
    aux = double(abs_dres).* (firstpart - secondpart); 
    
    res = u;
    res(aux < 0) = 1;
    res(aux > 0) = 0;
    res = IS3d(res, P3);
    % res = SI3d(res, P3);
    % res = curvop3d(res, P3, MorphGAC.smoothing);
    
    MorphGAC.u = res;
end