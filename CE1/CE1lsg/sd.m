function [w,J]=sd(mu,winit,N,R,p,Jmin);
%        Call:
%        [w,J]=sd(mu,winit,N,R,p,Jmin) 
%
%        Input arguments:
%        mu     = step size, dim 1x1
%        winit  = start values for filter coefficients, dim Mx1 
%        N      = no. of iterations, n=[0,...,N-1], dim 1x1
%        R      = autocorrelation matrix, dim MxM
%        p      = cross-correlation vector, dim Mx1   
%        Jmin   = minimum mean square error, dim 1x1
%
%        Output arguments:
%        w      = matrix containing the filter coefficients
%                 as a function of n along the rows, dim MxN
%        J      = mean square error as a function of n, dim 1XN
%

 w=zeros(length(winit),N);
 w(:,1)=winit;
 J=zeros(1,N);

 for n=1:N-1
  w(:,n+1)=w(:,n)+mu*(p-R*w(:,n));
  J(n)=Jmin+(w(:,n)-R\p)'*R*(w(:,n)-R\p);
 end
 J(N)=Jmin+(w(:,N)-R\p)'*R*(w(:,N)-R\p);
