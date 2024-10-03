function visai2(Bz,Az)
%
%
%
[H,W2]=freqz(Bz,Az);    
figure(3)
subplot(224)
hold on
plot(W2/(2*pi),1./abs(H),'r-.')
axis([0 .5 0 1/min(abs(H))*1.1])
hold off
