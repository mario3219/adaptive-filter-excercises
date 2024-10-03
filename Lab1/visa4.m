function visa4(w,x,y,xh,M,p)
%
%
%
[W,W2]=freqz(w,1);    
figure(2)
subplot(222), stem(w), title('utjaemnarens impulssvar'), ax=axis; axis([0 p+1 ax(3) ax(4)])
subplot(224), plot(W2/(2*pi),abs(W)), title('amplitudfkn'), xlabel('f'), ax=axis; axis([0 .5 ax(3) ax(4)])
figure(3)
subplot(311), stem(x(p:length(x)),'r+'), axis([0 M -1.2 1.2]), title('saend signal')
subplot(312), stem(y(p:length(x)),'ob'), axis([0 M -1.2 1.2]), title('mottagen signal')
subplot(313), stem(xh,'ok'), axis([0 M -1.2 1.2]), title('utjaemnad signal')










