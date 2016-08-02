%% 3D Gaussian
function g = gaussian3(s, sigma)

if isempty(s)
    s = 5;
end

if isempty(sigma)
    sigma = s/(4*sqrt(2*log(2)));
end

super_s = ceil(sigma * (4*sqrt(2*log(2))));

if super_s > s
    super_g = zeros(super_s, super_s, super_s);
    c = (1+super_s)/2;
    for x = 1:super_s
        for y = 1:super_s
            for z = 1:super_s
                r = (x-c)^2 + (y-c)^2 + (z-c)^2;
                % super_g(x, y, z) = exp(-(2*sigma^2)/r);
                % super_g(x, y, z) = exp(-(r)/2*sigma^2);
                
                % super_g(x, y, z) = log(r/(2*sigma^2));
            end
        end
    end
    super_g = super_g/sum(super_g(:));
    m = ceil((super_s - s)/2);
    n = floor((super_s - s)/2);
    g = super_g(m:end-n, m:end-n, m:end-n);
else
    g = zeros(s, s, s);
    c = (1+s)/2;
    for x = 1:s
        for y = 1:s
            for z = 1:s
                r = (x-c)^2 + (y-c)^2 + (z-c)^2;
                % g(x, y, z) = exp(-r/(2*sigma^2));
                % g(x, y, z) = exp(-(2*sigma^2)/r);
                g(x, y, z) = exp(-(r)/2*sigma^2);
                % g(x, y, z) = log((r)/2*sigma^2);
            end
        end
    end
    % g = g/sum(g(:));
end


end
