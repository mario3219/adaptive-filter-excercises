%% load data
clc,clear

load("rec_1m.mat");
data = val';

%% calculate

n_start = 5000;
M = 30;
N = 3000;

u = data(n_start:n_start+N,1);
sigmav2=0.01;
u = u+sqrt(sigmav2)*randn(length(u),1);
d = data(n_start:n_start+N,2);

%calculate correlation matrix
R = xcorr(u, length(u)-1, 'unbiased');
R_matrix = toeplitz(R(length(u):end));
    
%calculate eigenvalues
[V,D] = eig(R_matrix);
    
%calculate stepsize
Vmax = max(D,[],'all');
mu = 2/Vmax;

figure
subplot(1,2,1)
for delay = 0:5:40

    d_delay=[zeros(delay,1);d];
    
    %initiate lms
    [e,w,w_track,J] = lms(mu,M,u,d_delay);

    plot(J), hold on

end
legend('delay=0','delay=5','delay=10','delay=15','delay=20','delay=25','delay=30','delay=35','delay=40')
title('Learning curve'), xlabel('Iterations'), ylabel('Mean Square Error')

subplot(1,2,2)
for delay = 0:5:40

    d_delay=[zeros(delay,1);d];
    
    %initiate lms
    [e,w,w_track,J] = lms(mu,M,u,d_delay);

    plot(J), hold on

end
legend('delay=0','delay=5','delay=10','delay=15','delay=20','delay=25','delay=30','delay=35','delay=40')
title('Learning curve (zoomed)'), xlabel('Iterations'), ylabel('Mean Square Error')
xlim([2990 3004]), ylim([79 82])


