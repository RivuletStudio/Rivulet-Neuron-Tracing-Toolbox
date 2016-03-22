function [u,v,w] = GVF3D(f, mu, iterations)
    % This function calculates the gradient vector flow (GVF)
    % of a 3D image f.
    %
    % inputs:
    %   f : The 3D image
    %   mu : The regularization parameter. Adjust it to the amount
    %        of noise in the image. More noise higher mu
    %   iterations: The number of iterations. 
    %               sqrt(nr of voxels) is a good choice
    %
    % outputs:
    %   u,v,w : The GVF
    %
    % Function is written by Erik Smistad, Norwegian University 
    % of Science and Technology (June 2011) based on the original 
    % 2D implementation by Xu and Prince

    % Normalize 3D image to be between 0 and 1
    f = (f-min(f(:)))/(max(f(:))-min(f(:)));

    % Enforce the mirror conditions on the boundary
    f = EnforceMirrorBoundary(f);

    % Calculate the gradient of the image f
    [Fx, Fy, Fz] = gradient(f);
    magSquared = Fx.*Fx + Fy.*Fy + Fz.*Fz;
    
    % Set up the initial vector field
    u = Fx;
    v = Fy;
    w = Fz;
       
    for i = 1:iterations
        fprintf(1, '%d\n', i);

        % Enforce the mirror conditions on the boundary
        u = EnforceMirrorBoundary(u);
        v = EnforceMirrorBoundary(v);
        w = EnforceMirrorBoundary(w);

        % Update the vector field
        u = u + mu*6*del2(u) - (u-Fx).*magSquared;
        v = v + mu*6*del2(v) - (v-Fy).*magSquared;
        w = w + mu*6*del2(w) - (w-Fz).*magSquared;
    end
end


function [f] = EnforceMirrorBoundary(f)
    % This function enforces the mirror boundary conditions
    % on the 3D input image f. The values of all voxels at 
    % the boundary is set to the values of the voxels 2 steps 
    % inward
    [N M O] = size(f);

    xi = 2:M-1;
    yi = 2:N-1;
    zi = 2:O-1;

    % Coners
    f([1 N], [1 M], [1 O]) = f([3 N-2], [3 M-2], [3 O-2]);

    % Edges
    f([1 N], [1 M], zi) = f([3 N-2], [3 M-2], zi);
    f(yi, [1 M], [1 O]) = f(yi, [3 M-2], [3 O-2]);
    f([1 N], xi, [1 O]) = f([3 N-2], xi, [3 O-2]);

    % Faces
    f([1 N], xi, zi) = f([3 N-2], xi, zi);
    f(yi, [1 M], zi) = f(yi, [3 M-2], zi);
    f(yi, xi, [1 O]) = f(yi, xi, [3 O-2]);   
end
