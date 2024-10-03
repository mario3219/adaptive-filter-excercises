function visaw2(Bz,Az,N,br)
%
%
%
[H,W2]=freqz(Bz,Az);
figure(3)
subplot(224)
hold on
ax=axis; 
plot(W2/(2*pi),(abs(H))./((abs(H)).^2 + br*N),'k--')
axis([0 .5 0 max(ax(4),max((abs(H))./((abs(H)).^2 + br*N)))*1.1])
hold off
