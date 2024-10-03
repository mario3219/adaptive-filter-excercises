function visa1(h)
%
%
%
N=length(h);
[H,W]=freqz(h,1);    
figure(3)
subplot(221), stem(h), title('channel imp. resp.'), ax=axis; axis([0 N+1 ax(3) ax(4)])
subplot(223), plot(W/(2*pi),abs(H)), title('channel magn. resp.'), xlabel('f'), ax=axis; axis([0 .5 0 1.1])


