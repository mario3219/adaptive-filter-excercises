% Computer exercise 1.4


%From exercise 3.1
R=[2 1; 1 2];  % correlation matrix of the tap-input vector
p=[6; 4];      % cross-correlation vector between tap-input vector
               %  and desired signal
Jmin=5;        % minimum mean square error
winit=[0;0];   % initial weights
N=50;          % number of iterations

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

wopt=R\p;      % optimum Wiener filter solution

[V,L]=eig(R);            % eigenvector V=[v1 v2] and eigenvalues of R
lambda=diag(L);          % 2x1 vector containing the eigenvalues

mu1=1/3;
mu2=1/6;

[w1,J1]=sd(mu1,winit,N,R,p,Jmin);
[w2,J2]=sd(mu2,winit,N,R,p,Jmin);

v1=V'*(w1-wopt*ones(1,N));
v2=V'*(w2-wopt*ones(1,N));

tau1=-1./log(1-mu1*lambda);
tau2=-1./log(1-mu2*lambda);

fprintf('\n\n !!! Observe the following warnings:\n\n');

figure
 plot(0:N-1,log(v1(1,:)),'b'); hold on;
 plot(0:N-1,log(v1(2,:)),'b-.');
 plot(0:N-1,log(v2(1,:)),'r');
 plot(0:N-1,log(v2(2,:)),'r-.');
 grid on
 zoom on
 legend(['\mu=1/3: \nu coupled to \lambda=' num2str(lambda(1))],...
        ['\mu=1/3: \nu coupled to \lambda=' num2str(lambda(2))],...
          ['\mu=1/6: \nu coupled to \lambda=' num2str(lambda(1))],...
            ['\mu=1/6: \nu coupled to \lambda=' num2str(lambda(2))])
 title('CE 1.4');
 xlabel('iteration n');
 ylabel('ln(v(n))');

figure
 plot(0:N-1,log(v1(1,:)),'b'); hold on;
 plot(0:N-1,log(v1(2,:)),'b-.');
 plot(0:N-1,log(v2(1,:)),'r');
 plot(0:N-1,log(v2(2,:)),'r-.');
 grid on
 zoom on
 axis([0 6 -1 1]);
 plot(tau1(1),log(v1(1,1))-1,'r-o');
 plot(tau1(2),log(v1(2,1))-1,'r-v');
 plot(tau2(1),log(v2(1,1))-1,'r-s');
 plot(tau2(2),log(v2(2,1))-1,'r-*');
 legend(['\mu=1/3: \nu coupled to \lambda=' num2str(lambda(1))],...
        ['\mu=1/3: \nu coupled to \lambda=' num2str(lambda(2))],...
          ['\mu=1/6: \nu coupled to \lambda=' num2str(lambda(1))],...
            ['\mu=1/6: \nu coupled to \lambda=' num2str(lambda(2))],...
            ['\mu=1/3: \nu coupled to \lambda=' num2str(lambda(1)),' \tau_k=2.5'],...
        ['\mu=1/3: \nu coupled to \lambda=' num2str(lambda(2)),' \tau_k=0'],...
          ['\mu=1/6: \nu coupled to \lambda=' num2str(lambda(1)),' \tau_k=5.5'],...
            ['\mu=1/6: \nu coupled to \lambda=' num2str(lambda(2)),' \tau_k=1.45'])
 title('CE 1.4');
 xlabel('Iteration n');
 ylabel('ln(v(n))');
fprintf('\n!!! They indicate that we are attempting to calculate the logarithm of a number smaller or equal to 0.\n\n\n');

function [w,J] = sd(mu,winit,N,R,p,Jmin)
    w = 0;
    wcalc(N);
    J = Jmin + (w-inv(R)*p)'*R*(w-inv(R)*p);
    function w_next = wcalc(n)
        if n <= 0
            w_next = winit;
        else
            w_past = wcalc(n-1);
            w_next = w_past+mu*(p-R*w_past);
            w = w_next;
        end
    end
end
