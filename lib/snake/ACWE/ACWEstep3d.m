function  MorphGAC = ACWEstep3d(MorphGAC, snakestep)
        %  data : ndarray
        %     The image data.
        % smoothing : scalar
        %     The number of repetitions of the smoothing step (the
        %     curv operator) in each iteration. In other terms,
        %     this is the strength of the smoothing. This is the
        %     parameter µ.
        % lambda1, lambda2 : scalars
        %     Relative importance of the inside pixels (lambda1)
        %     against the outside pixels (lambda2).
    global P3
    u = MorphGAC.u;
    data = MorphGAC.data;
    data = double(data);

    inside = u > 0;
    outside = u<=0;
    doubleoutside = double(outside);
    doubleinside = double(inside);
    
    dataoutside = data(outside);
    datainside = data(inside);

    c0 = sum(dataoutside(:)) / sum(doubleoutside(:));
    % disp(c0);
    c1 = sum(datainside(:)) / sum(doubleinside(:));
    % disp(c1);
    % dres = distgradient(u);
    % abs_dres = abs(dres(:,:,:,1)) + abs(dres(:,:,:,2)) + abs(dres(:,:,:,3));
    [Fx, Fy, Fz] = gradient(u);
    abs_dres = abs(Fx) + abs(Fy) + abs(Fz);
    firstpart = (data - c1).^2;
    firstpart = MorphGAC.lambda1 * firstpart;
    secondpart = (data - c0).^2;
    secondpart = MorphGAC.lambda2 * secondpart;
    aux = double(abs_dres).* (firstpart - secondpart); 
    
    res = u;
    res(aux < 0) = 1;
    res(aux > 0) = 0;
    % res = imdilate(res, ones(3, 3, 3));
    stepjudge = rem(snakestep, 2);
    res = IS3d(res, P3);
    % res = IS3d(res, P3);

    if stepjudge == 1
        % res = SI3d(res, P3);
        res = IS3d(res, P3);
        res = SI3d(res, P3);
        % res = IS3d(res, P3);

    else
        res = SI3d(res, P3);
        res = IS3d(res, P3);
    end    
    % res = IS3d(res, P3);

    % res = IS3d(res, P3);
    % res = SI3d(res, P3);
    % res = IS3d(res, P3);
    
    % res = curvop3d(res, P3, MorphGAC.smoothing);
    
    MorphGAC.u = res;
end