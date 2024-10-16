function lms2(A,mu,N,M,rea)
%
% Study of the influence of the eigenvalue spread for the adaption of the
% one-step predictor for AR(2)-processes.
%
% A:   AR(2)-vector
% mu:  adaption constant (ev. vector)
% N:   length of the signal vector
% M:   length of the adaptive filter
% rea:  number of realizations (over which averaging is done)
%     
% Suitable parameters:
%
%    A=[-.195 .95; -1.5955 .95]'
%	 lms2(A,.05,1000,2,100)
%

[q,K]=size(A);

Jt=zeros(N-1,K);

Wt = zeros(N,M,2);

for k=1:K,
    a=A(:,k);
    disp(['Eigenvalues (',num2str(k),') = (',num2str(1-a(1)+a(2)),',',num2str(1+a(1)+a(2)),')'])
end
for r=1:max(2,rea),          
    J=Inf*ones(N-1,K);
    W=zeros(N,M,2);           
    for k=1:K,
        a=A(:,k);
        R=[1 -a(1)/(1+a(2)); -a(1)/(1+a(2)) 1];
        p=[-a(1)/(1+a(2)); -a(2)+(a(1))^2/(1+a(2))];
        varu=(1+a(2))/(1-a(2))*1/((1+a(2))^2-(a(1))^2);
        Jmin(1,k) = 1 - p'*inv(R)*p;
        egspr(1,k)=(1-a(1)+a(2))/(1+a(1)+a(2));
        u=filter( 1,[1; a],sqrt(1/varu)*randn(N,1));
        for n=M:N-1,
            uv=u(n:-1:n-M+1);  
            e(n)=u(n+1)-W(n,:,k)*uv;
            J(n,k)=( e(n) )^2;
            W(n+1,:,k)=W(n,:,k)+mu*uv'*e(n); 
        end
    end
    Jt=(r-1)/r*Jt+1/r*J;
    Wt = (r-1)/r*Wt+1/r*W;
    
    subplot(211), plot( [1:N-1],log10(Jt),'-',[1:N-1],ones(N-1,1)*log10(Jmin(1)),'b-.',[1:N-1],ones(N-1,1)*log10(Jmin(2)),'r-.')
    title(['\lambda_1/\lambda_2=',num2str(egspr),', dashed line=J_{min}, number of realizations=',num2str(r)])
   % title(['\lambda_1/\lambda_2=',num2str(egspr),', number of realizations=',num2str(r)])
    subplot(212), plot([1:N],Wt(:,:,1),'b',[1:N],Wt(:,:,2),'g',[1:N],-A(:,1)*ones(1,N),'b:',[1:N],-A(:,2)*ones(1,N),'g:')
    title('Filter coefficients')
    pause(.1)
end

