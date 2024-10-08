%% load data
clc,clear,close all

load("rec_1m.mat");
data = val';

%% present data
clc

n_start = 5000;
n_stop = 6000;

figure
subplot(2,1,1)
plot(data(:,1)), title("Raw data"), xlim([n_start n_stop])
subplot(2,1,2)
plot(data(:,2)), title("Filtered data"), xlim([n_start n_stop])

%%

n_start = 5000;
M = 30;
N = 3000;
delay = 10;

u = data(n_start:n_start+N,1);
d = data(n_start:n_start+N,2);
d=[zeros(delay,1);d];

sigmav2=0.01;
u = u+sqrt(sigmav2)*randn(length(u),1);

%calculate correlation matrix
R = xcorr(u, length(u)-1, 'unbiased');
R_matrix = toeplitz(R(length(u):end));

%calculate eigenvalues
[V,D] = eig(R_matrix);

%calculate stepsize
Vmax = max(D,[],'all');
mu = 2/Vmax;

%initiate lms
[e,w,w_track,J] = lms(mu,M,u,d);

%plot lms performance
figure
subplot(2,1,1);
plot(w_track), xlabel('Iterations'), ylabel('Tap-weights')
subplot(2,1,2)
plot(J), title('Learning curve'), xlabel('Iterations'), ylabel('Mean Square Error')

%plot output vs desired
output_signal = filter(w, 1, u);

figure
subplot(3,1,1)
plot(u), title('Input')
subplot(3,1,2)
plot(output_signal), title('Output')
subplot(3,1,3)
plot(d), title('Desired signal')
