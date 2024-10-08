function [e,w,w_track,J]=lms(mu,M,u,d,g);
%           Call:
%           [e,w]=lms(mu,M,u,d);
%
%           Input arguments:
%           mu      = step size, dim 1x1
%           M       = filter length, dim 1x1
%           u       = input signal, dim Nx1
%           d       = desired signal, dim Nx1    
%
%           Output arguments:
%           e       = estimation error, dim Nx1
%           w       = final filter coefficients, dim Mx1

%initial weights
w=zeros(M,1);

%length of input signal
N=length(u);

%make sure that u and d are column vectors
u=u(:);
d=d(:);

w_track = [];
e_track = [];

%LMS
for n=M:N
    uvec=u(n:-1:n-M+1);
    e(n)=d(n)-g*w'*w;  
    w=(1 - g*mu) * w+mu*uvec*conj(e(n));
    w_track = [w_track w];
    J(n) = mean(e(1:n).^2)+g*w'*w;
end
e=e(:);
