function visaw3(w,x,y,xh,p,h,N,br)
%
%
%
M=length(y);
[W,W2]=freqz(w,1);    
figure(2)
subplot(311), stem(x,'r+'), axis([0 M -1.2 1.2]), title('transmit signal')
subplot(312), stem(y,'b+'), axis([0 M -1.2 1.2]), title('receive signal')
subplot(313), stem(xh,'k+'), axis([0 M -1.2 1.2]), title('equalized signal')
N=length(h);
[H,W2]=freqz(h,1);    
figure(3)
subplot(222), stem(w), title('equalizer imp. resp.'), ax=axis; axis([0 p+1 ax(3) ax(4)])
subplot(224), plot(W2/(2*pi),abs(W),'b-',W2/(2*pi),(abs(H))./((abs(H)).^2 + br*N),'k--'), title('equalizer magn. resp.'), xlabel('f')
ax=axis; 
axis([0 .5 0 ax(4)*1.1])
