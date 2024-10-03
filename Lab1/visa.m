function visa(w,x,y,xh,p)
%
%
%
M=length(y);
[W,W2]=freqz(w,1);    
figure(2)
subplot(311), stem(x,'r+'), axis([0 M -1.2 1.2]), title('saend signal')
subplot(312), stem(y,'b+'), axis([0 M -1.2 1.2]), title('mottagen signal')
subplot(313), stem(xh,'k+'), axis([0 M -1.2 1.2]), title('utjaemnad signal')
figure(3)
subplot(222), stem(w), title('utjaemnarens impulssvar'), ax=axis; axis([0 p+1 ax(3) ax(4)])
subplot(224), plot(W2/(2*pi),abs(W)), title('utjaemnarens amplitudfkn'), xlabel('f'), ax=axis; axis([0 .5 0 ax(4)])










