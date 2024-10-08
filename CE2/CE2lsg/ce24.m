% computer exercise 2.4, ASB 2003%% tmr%% eigenvalue spreadW=3.1;% filter lengthM=11;% channelh=[0 0.5*(1+cos(2*pi/W*((1:3)-2))) 0];% variance of the additive noisesigmav2=0.001;% length of the signalN=4500;% ensemble size for learning curveNbr=200;% step size of the LMSmu=[0.075 0.025 0.0075];[Jmin,R,p,wo]=wiener(W,sigmav2);% ensemble loope=zeros(N,Nbr,3);w=zeros(M,Nbr,3);u=zeros(N,Nbr);fprintf('\n');for nbr=1:Nbr fprintf('realization: %d\n',nbr); % generate Bernoulli sequence of length N x=2*round(rand(N,1))-1; % convolute input signal x with the channel h y=conv(x,h); % cut the result to length N y=y(1:N); % add Gaussian noise u(:,nbr)=y+sqrt(sigmav2)*randn(length(y),1); % delay x(n): d(n)=x(n-7) d=[zeros(7,1);x]; % LMS [e(:,nbr,1),w(:,nbr,1)]=lms(mu(1),M,u(:,nbr),d); [e(:,nbr,2),w(:,nbr,2)]=lms(mu(2),M,u(:,nbr),d); [e(:,nbr,3),w(:,nbr,3)]=lms(mu(3),M,u(:,nbr),d);end; % nbrJ=reshape(mean(e.^2,2),N,3).';% learning curvesfigure; semilogy(J(1,:),'b'); hold on semilogy(J(2,:),'r'); semilogy(J(3,:),'m'); semilogy(Jmin*ones(1,N),'g'); zoom on grid on legend(sprintf('learning curve for \\mu=%5.4f',mu(1)),...        sprintf('learning curve for \\mu=%5.4f',mu(2)),...        sprintf('learning curve for \\mu=%5.4f',mu(3)),...        sprintf('Jmin')); xlabel('iteration n'); ylabel(sprintf('mean(J(n)), %d realizations',Nbr)); axis([1 N 10^-3 1]); title('CE 2.4')%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% misadjustment % 1.) values extracted from the plotsNmean=100;  % !! make sure that you do not observe the            % the transient part of the average MSE curve !!Misadj(:,1)=(mean(J(:,N-Nmean+1:N),2)-Jmin)/Jmin;% 2.) exact values[V,L]=eig(R);lambda=diag(L);lambdaav=mean(lambda);Misadj(:,2)=diag((lambda*mu).'*(1./(2-lambda*mu)));% values according to the rules of thumb% 3.) an approximation:taumseav=1./(2*mu*lambdaav);Misadj(:,3)=M./(4*taumseav.');% 4.) a more practical form: mu/2*(tap-input power)Misadj(:,4)=mu.'/2*(M*mean(mean(u.^2,2))); format shortfprintf('========================================\n\n');fprintf('========================================\n\n');Misadjfprintf(' simulation |  exact  |  thumb1 | thumb2\n\n');fprintf('========================================\n\n');fprintf('========================================\n\n');fprintf('--- check Nmean, don''t average over the transient part of the learning curve! ---\n\n');