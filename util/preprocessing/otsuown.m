function binaryI = otsuown(I)
V = I(:);
global H;
global Index;
G=hist(V,0:255);
H=G';
Ind=0:255;
Index=reshape(Ind,[],1);
result=zeros(size([1 256]));
for i=0:255
	[wbk,varbk]=calculate_var(1,i);
	[wfg,varfg]=calculate_var(i+1,255);
	result(i+1)=(wbk*varbk)+(wfg*varfg);   
end
% Find the minimum value in the array.                
[threshold_value,val]=min(result);
disp(threshold_value);
disp(val);
%tval=(val-1)/256;
%binaryI = (I>threshold_value);
binaryI = I > val;
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
end
end