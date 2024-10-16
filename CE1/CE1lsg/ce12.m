% Computer exercise 1.2
%

% From exercise 3.1
R=[2 1; 1 2];  % correlation matrix of the tap-input vector
p=[6; 4];      % cross-correlation vector between tap-input vector
               %  and desired signal
Jmin=5;        % minimum mean square error
winit=[0;0];   % initial weights
N=50;          % number of iterations

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

wopt=R\p      % optimum Wiener filter solution

[V,L]=eig(R);            % eigenvector V=[v1 v2] and eigenvalues of R
lambdamax=max(diag(L));  % maximum eigenvalue

epsilon=0;   % tune epsilon (e.g. +-0.01) and observe the weights!

[w1,J1]=sd(1/6,winit,N,R,p,Jmin);
[w2,J2]=sd(1/3,winit,N,R,p,Jmin);
[w3,J3]=sd(2/3+epsilon,winit,N,R,p,Jmin);

figure
 plot(0:N-1,w1(1,:),'g'); hold on;
 plot(0:N-1,w1(2,:),'g--');
 plot(0:N-1,w2(1,:),'b');
 plot(0:N-1,w2(2,:),'b--');
 plot(0:N-1,w3(1,:),'r');
 plot(0:N-1,w3(2,:),'r--');
 legend(sprintf('w_1, \\mu=1/6'),...
        sprintf('w_2, \\mu=1/6'),...
        sprintf('w_1, \\mu=1/3'),...
        sprintf('w_2, \\mu=1/3'),...
        sprintf('w_1, \\mu=2/3+\\epsilon, \\epsilon=%3.2f',epsilon),...
        sprintf('w_2, \\mu=2/3+\\epsilon, \\epsilon=%3.2f',epsilon));
 xlabel('Iteration n');
 ylabel('Filter coefficients w_1 and w_2');
 hold on
 grid on
 zoom on
 title('CE 1.2');