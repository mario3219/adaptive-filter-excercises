function lms1(a,mu,N,M,rea)
%
% Study of the influence of the adaptions constant for the adaption of the
% one-step predictor for AR(2)-processes. See Haykins book page 285. 
%
% a:   AR(2)-vector
% mu:  adaption constant (ev. vector)
% N:   length of the signal vector
% M:   length of the adaptive filter
% rea:  number of realizations (over which averaging is done)
%     
% Suitable parameters:
%                                   egenv?rdesspridning (kvot)
%        a1=[-.195; .95]               1.22
%        a2=[-.975; .95]               3
%        a3=[-1.5955; .95]            10
%        a4=[-1.9114; .95]           100
%
%        lms1(a1,[.1 .01],500,2,100)
%

R=[1 -a(1)/(1+a(2)); -a(1)/(1+a(2)) 1];
p=[-a(1)/(1+a(2)); -a(2)+(a(1))^2/(1+a(2))];
varu=(1+a(2))/(1-a(2))*1/((1+a(2))^2-(a(1))^2);
Jmin = 1 - p'*inv(R)*p;
disp(['Eigenvalues=(',num2str(1-a(1)+a(2)),',',num2str(1+a(1)+a(2)),')'])
egspr=(1-a(1)+a(2))/(1+a(1)+a(2));
Jt=zeros(N-1,length(mu));

Wt = zeros(N,M,2);

for r=1:max(2,rea),  
    J=Inf*ones(N-1,length(mu));
    W=zeros(N,M,2);           
    for k=1:length(mu),
        u=filter( 1,[1; a],sqrt(1/varu)*randn(N,1) );
        for n=M:N-1,
            uv=u(n:-1:n-M+1);  
            e(n)=u(n+1)-W(n,:,k)*uv;
            J(n,k)=( e(n) )^2;
            W(n+1,:,k)=W(n,:,k)+mu(k)*uv'*e(n); 
        end
    end
    
    Jt=(r-1)/r*Jt+1/r*J;
    Wt = (r-1)/r*Wt+1/r*W;
    
    subplot(211), plot( [1:N-1],log(Jt),'-',[1:N-1],log(Jmin)*ones(1,N-1),'-.' ), title(['\lambda_1/\lambda_2=',num2str(egspr),',dashed line=J_{min}, number of realizations=',num2str(r)]), grid on
    subplot(212), plot([1:N],Wt(:,:,1),'b',[1:N],Wt(:,:,2),'g',[1:N],-a*ones(1,N),'r:')
    title('Filter coefficients')
    pause(.1)
end
