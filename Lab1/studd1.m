function [Bz,Az]=studd1(N,Fg,Fs)
%
%
%
st=100;
Fv=[1/st:1/st:Fs];
[B,A]=butter(N,2*pi*Fg,'s');
H=freqs(B,A,2*pi*Fv); 
[Bz,Az]=impinvar(B,A,Fs);
figure(3)
subplot(221)
plot(Fv,abs(H),'b'), ax=axis; axis([0 Fs 0 1.1*ax(4)]), xlabel('F [Hz]'), title('analog amplitudfunktion')
%
Hz=freqz(Bz,Az,2*pi/Fs*Fv(1:st*Fs));
subplot(223)
impz(Bz,Az), title('diskretiserat impulssvar'), pause(2)
plot(1/Fs*Fv(1:st*Fs),abs(Hz),'b')
ax=axis;
axis([0 1/2 0 1.1*ax(4)])
xlabel('f [rel frekv]')
title('diskretiserad ampl.-fkn.')

