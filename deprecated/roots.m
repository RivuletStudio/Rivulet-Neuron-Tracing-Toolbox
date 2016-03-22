function z=roots(Coeff)
    a=Coeff(1); b=Coeff(2); c=Coeff(3); d=max((b*b)-4.0*a*c,0);
    if(a~=0)
        z(1)= (-b - sqrt(d)) / (2.0*a);
        z(2)= (-b + sqrt(d)) / (2.0*a);
    else 
        z(1)= (2.0*c)/(-b - sqrt(d));
        z(2)= (2.0*c)/(-b + sqrt(d));
    end
