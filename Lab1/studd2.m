function [Bz,Az]=studd2(N,Fg,Fs)
%
%
%
st=100;
Fv=[1/st:1/st:Fs];
[B,A]=butter(N,2*pi*Fg,'s');
H=freqs(B,A,2*pi*Fv); 
im=.6*5*2*pi; re1=3; re2=1;
Ba=poly([ re1+j*im  re1-j*im]); 
Aa=poly([-re2+j*im -re2-j*im]); 
Ha=freqs(Ba,Aa,2*pi*Fv);
Ht=H.*Ha;
[Bz,Az]=impinvar(conv(B,Ba),conv(A,Aa),Fs);
figure(3)
subplot(221)
plot(Fv,abs(Ht),'b'), ax=axis; axis([0 Fs 0 1.1*ax(4)]), xlabel('F [Hz]'), title('|H(s)|')
%
Hz=freqz(Bz,Az,2*pi/Fs*Fv(1:st*Fs));
subplot(223)
impz(Bz,Az), title('h(n)'), pause(2)
plot(1/Fs*Fv(1:st*Fs),abs(Hz),'b')
ax=axis;
axis([0 1/2 0 1.1*ax(4)])
xlabel('f')
title('|H(z)|')

