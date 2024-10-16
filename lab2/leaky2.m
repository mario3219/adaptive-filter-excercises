function leaky2(mu,alfa,N,M,rea)
%
% Comparison of LMS and leaky LMS algorithm for the prediction of a sinus
% signal. 
%
% mu:   step size
% alfa: leaky-constant, < 1/mu
% M:    length of the adaptive filter
% rea:  number of realizations (over which averaging is done)
%
% Suitable parameters: leaky2(.5,.05,2000,4,100)
%
% Dessa kommandon skapar sinussignal st?rt av BANDBEGR?NSAT brus => 
% kovariansmatrisen blir singul?r =>
% filtrets alla moder exciteras inte av insignalen =>
% viktvektorn kan driva utan att det ?ndrar kriteriet J. 
%

% Filter to generate band-limited noise
[B,A]=butter(30,.25);
% Generate the band-limited noise
e=filter(B,A,randn(N,1)*.1);
% Define the variance of the noise
vare=1/N*sum(e.^2);
% Define the frequency of the cosine
f0=.1;
% Generate u = cosine + noise
u =cos(2*pi*f0*[1:N]') + e;
% Calculate the covariance matrix
R=kovmat(u,M);
disp('Kovariansmatrisens egenv?rden='), disp(' '), disp(num2str(eig(R)))
R=toeplitz(1/2*[1+vare cos(2*pi*f0)]);
p=1/2*[cos(2*pi*f0) cos(2*pi*2*f0)]';
w=R\p;
if M~=2, 
    w=[Inf Inf]'; 
end
%N=length(u);
Jt=zeros(N-1,2);
W1=zeros(M,N);
W2=zeros(M,N);
w
for r=1:rea,
    
    % Generate the band-limited noise
    e=filter(B,A,randn(N,1)*.1);
    % Generate u = cosine + noise
    u =cos(2*pi*f0*[1:N]') + e;
    
    w1=zeros(M,M);           
    w2=zeros(M,M); 
    J=Inf*ones(N-1,2);          
    for n=M:N-1,
        uv=u(n:-1:n-M+1);  
        e1(n)=u(n+1)-w1(:,n)'*uv;
        e2(n)=u(n+1)-w2(:,n)'*uv;
        J(n,1)=( e1(n) )^2;
        J(n,2)=( e2(n) )^2;
        w1(:,n+1) = w1(:,n) + mu*uv*e1(n); 
        w2(:,n+1) = (1-mu*alfa)*w2(:,n) + mu*uv*e2(n); 
    end
    W1 = (r-1)/r*W1 + 1/r*w1;
    W2 = (r-1)/r*W2 + 1/r*w2;
    Jt = (r-1)/r*Jt + 1/r*J;
    
    subplot(311), plot( [1:N-1],log10(Jt(:,1)),'-'); hold on; plot( [1:N-1],log10(Jt(:,2)),'g-'); hold off
    title(['green = leaky LMS, Number of realizations = ',num2str(r)])
    subplot(312), plot([1:N],W1,'-',[1:N],w*ones(1,N),':'), title('filter coefficients, LMS, w_{opt} (dashed)')
    subplot(313), plot([1:N],W2,'-',[1:N],w*ones(1,N),':'), title('filter coefficients, leaky LMS, w_{opt} (dashed)')
    pause(.1)
end



function R=kovmat(u,M)

N=length(u);
for n=1:N-M+1,
    U(n,:)=u(n:n+M-1)';
end
R=cov(U);
