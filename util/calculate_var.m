function [weight,var]=calculate_var(m,n)
%Weight Calculation
weight=sum(H(m:n))/sum(H);
%Mean Calculation
value=H(m:n).*Index(m:n);
total=sum(value);
mean=total/sum(H(m:n));
if(isnan(mean)==1)
	mean=0;
end
%Variance calculation.
value2=(Index(m:n)-mean).^2;
numer=sum(value2.*H(m:n));
var=numer/sum(H(m:n));
if(isnan(var)==1)
var=0;
end
