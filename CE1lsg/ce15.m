% Computer exercise 1.5% From exercise 3.1R=[2 1; 1 2];  % correlation matrix of the tap-input vectorp=[6; 4];      % cross-correlation vector between tap-input vector%  and desired signalJmin=5;        % minimum mean square errorwinit=[0;0];   % initial weightsN=100;         % number of iterations%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%wopt=R\p;      % optimum Wiener filter solution[V,L]=eig(R);            % eigenvector V=[v1 v2] and eigenvalues of Rlambda=diag(L);          % 2x1 vector containing the eigenvaluesmu1=1/10;mu2=1/20;[w1,J1]=sd(mu1,winit,N,R,p,Jmin);[w2,J2]=sd(mu2,winit,N,R,p,Jmin);vinit=V'*(winit-wopt);% effective time constantstaueff1=(log((lambda'*abs(vinit).^2)/((lambda.*((1-mu1*lambda).^2))'...    *abs(vinit).^2)))^(-1);taueff2=(log((lambda'*abs(vinit).^2)/((lambda.*((1-mu2*lambda).^2))'...    *abs(vinit).^2)))^(-1);% time constants of the slow modetauslow1=-1./(2*log(1-mu1*lambda(1)));tauslow2=-1./(2*log(1-mu2*lambda(1)));J1log=log(J1-Jmin);J2log=log(J2-Jmin);figureplot(0:N-1,J1log,'b'); hold on;plot(0:N-1,J2log,'r');plot(0:15,J1log(1)-(0:15)/taueff1,'m--');plot(0:15,J2log(1)-(0:15)/taueff2,'c--');plot(5:N-1,(N-1)/tauslow1+J1log(N)-(5:N-1)/tauslow1,'g--');plot(5:N-1,(N-1)/tauslow2+J2log(N)-(5:N-1)/tauslow2,'k--');zoom ongrid onhold onlegend('\mu=1/10: log(J-Jmin)',...    '\mu=1/20: log(J-Jmin)',...    ['\mu=1/10: tangent with slope -1/ \tau_{e,mse}, \tau_{e,mse}=', num2str(taueff1,3)],...    ['\mu=1/20: tangent with slope -1/\tau_{e,mse}, \tau_{e,mse}=', num2str(taueff2,3)],...    ['\mu=1/10: tangent with slope -1/ \tau_{2,mse}, \tau_{2,mse}=', num2str(tauslow1,3)],...    ['\mu=1/20: tangent with slope -1/\tau_{2,mse}, \tau_{2,mse}=', num2str(tauslow2,3)])title('CE 1.5');xlabel('iteration n');ylabel('ln(J(n)-Jmin)');