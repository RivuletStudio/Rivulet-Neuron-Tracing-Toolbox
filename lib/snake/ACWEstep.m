function  MorphGAC = ACWEstep(MorphGAC)
    global P2
    u = MorphGAC.u;
    data = MorphGAC.data;
    % figure
    % imagesc(data*255);
    inside = u > 0;
    size(inside)
    % figure
    % imagesc(inside)
    outside = u<=0;
    doubleoutside = double(outside);
    doubleinside = double(inside);
    
    dataoutside = data(outside);
    datainside = data(inside);

    c0 = sum(dataoutside(:)) / sum(doubleoutside(:));

    c1 = sum(datainside(:)) / sum(doubleinside(:));
    
    % Image attachment.
    [dres(:,:,1), dres(:,:,2)] = imgradientxy(u);
    abs_dres = abs(dres(:,:,1)) + abs(dres(:,:,2));
    % size(abs_dres)
    firstpart = (data - c1).^2;
    firstpart = MorphGAC.lambda1 * firstpart;
    secondpart = (data - c0).^2;
    secondpart = MorphGAC.lambda2 * secondpart;
    aux = double(abs_dres).* (firstpart - secondpart); 
    % %%%%%%%%% abs_dres = np.abs(dres).sum(0);
    % % aux = abs_dres * (c0 - c1) * (c0 + c1 - 2*data)

    % aux = abs_dres * (MorphGAC.lambda1*(data - c1).^2 - MorphGAC.lambda2*(data - c0).^2);
    
    res = u;
    res(aux < 0) = 1;
    res(aux > 0) = 0;
    % res = SI(res, P2);
    % res = IS(res, P2);
    % res = SI(res, P2);
    % res = SI(res, P2);

    % res = IS(res, P2);
    
    % for i = 1 : MorphGAC.smoothing
    res = curvop(res, P2, MorphGAC.smoothing);
    
    MorphGAC.u = res;
end