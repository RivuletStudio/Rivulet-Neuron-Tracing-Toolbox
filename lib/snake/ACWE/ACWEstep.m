function  MorphGAC = ACWEstep(MorphGAC)
    global P2
    u = MorphGAC.u;
    data = MorphGAC.data;
    inside = u > 0;
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
    firstpart = (data - c1).^2;
    firstpart = MorphGAC.lambda1 * firstpart;
    secondpart = (data - c0).^2;
    secondpart = MorphGAC.lambda2 * secondpart;
    aux = double(abs_dres).* (firstpart - secondpart); 

    
    res = u;
    res(aux < 0) = 1;
    res(aux > 0) = 0;
    
    res = curvop(res, P2, MorphGAC.smoothing);
    
    MorphGAC.u = res;
end