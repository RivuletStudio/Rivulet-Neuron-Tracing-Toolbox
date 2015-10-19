% close all
% I = load_v3d_raw_img_file('/home/donghao/Desktop/OP/OP1/op1.v3draw');
% I = I > 30;
I = curfeats.gt; 
figure
safeshowbox(I, 0.5)
S=ones(3,3,3);
dialatedI = imdilate(I,S);
figure
safeshowbox(dialatedI, 0.5)
newgt = xor(dialatedI, I);
figure 
safeshowbox(newgt, 0.5)
finalgt = newgt * 2 + I;
figure
safeshowbox(finalgt, 0.5)