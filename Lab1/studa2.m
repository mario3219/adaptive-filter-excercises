function [Ht,Fv]=studa2(N,Fg,Fs)
%
%
%
st=100;
Fv=[1/st:1/st:Fs];
[B,A]=butter(N,2*pi*Fg,'s');
H=freqs(B,A,2*pi*Fv); 
im=.6*5*2*pi; 
re1=3; 
re2=1;
Ha=freqs(poly([re1+j*im re1-j*im]),poly([-re2+j*im -re2-j*im]),2*pi*Fv);
Ht=H.*Ha;
figure(3), subplot(221)
plot(Fv,abs(Ht),'b'), ax=axis; axis([0 Fs 0 1.1]), xlabel('F [Hz]'), title('|H(s)|')
