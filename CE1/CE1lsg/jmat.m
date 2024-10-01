function [Jm]=jmat(w1,w2,R,p,Jmin);
%        Call:
%           [Jm]=jmat(w1,w2,R,p,Jmin);
%
%        Input arguments:
%        w1     = vector with K values of w1 over time, dim 1xK
%        w2     = vector with K values of w2 over time, dim 1xK
%        R      = autocorrelation matrix, dim MxM
%        p      = cross-correlation vector, dim Mx1
%        Jmin   = minimum mean square error, dim 1x1
%
%        Output arguments:
%        Jm     = matrix containing J(w1,w2) with w1 along 
%                 the rows and w2 along the columns, dim KxK
%

 if(length(w1)~=length(w2)) error('Lengths of w1 and w2 are different.');
 else K=length(w1); end;

 for n1=1:K
  for n2=1:K
   Jm(n2,n1)=Jmin+([w1(n1);w2(n2)]-R\p)'*R*([w1(n1);w2(n2)]-R\p);
  end
 end
