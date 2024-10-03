function w=visa3(b,N,M,h,br,p,mu,typ,w)
%
%
%
K=fix(M/N);
x=zeros(2*M,1);
for i=1:K+1, x((i-1)*N+1:i*N)=[zeros(b,1); (-1)^i; zeros(N-1-b,1)]; end
x=x+sqrt(br)*randn(length(x),1);
y=conv(h,x);
%
if typ==1, d=x; end
xh=zeros(M,1);
for n=p:M, 
  xh(n)=w'*y(n:-1:n-p+1);
  e=d(n)-xh(n);
  w=w+mu*e*y(n:-1:n-p+1);
  [H,W]=freqz(w,1);    
end
figure(2)
subplot(222), stem(w), title('utjaemnarens impulssvar'), ax=axis; axis([0 p+1 ax(3) ax(4)])
subplot(224), plot(W/(2*pi),abs(H)), title('amplitudfkn'), xlabel('f'), ax=axis; axis([0 .5 ax(3) ax(4)])
%
figure(3)
subplot(311), stem(x,'+r'), axis([0 M -1 2]), title('saend signal')
subplot(312), stem(y(1:M),'ob'), axis([0 M -1 2]), title('mottagen signal')
subplot(313), stem(xh,'ob'), axis([0 M -1 2]), title('utjaemnad signal')


