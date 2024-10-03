function [H,Fv]=studa1(N,Fg,Fs)
%
%
%
st=100;
Fv=[1/st:1/st:Fs];
[B,A]=butter(N,2*pi*Fg,'s');
H=freqs(B,A,2*pi*Fv); 
figure(3), subplot(221)
plot(Fv,abs(H),'b'), ax=axis; axis([0 Fs 0 1.1]), xlabel('F [Hz]'), title('analog amplitudfunktion')
