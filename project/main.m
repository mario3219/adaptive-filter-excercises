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
plot(data(:,1)), title("Raw"), xlim([n_start n_stop])
subplot(2,1,2)
plot(data(:,2)), title("Filtered"), xlim([n_start n_stop])

%%

n_start = 5000;
M = 25;
N = 3000;

u = data(n_start:n_start+N,1);
d = data(n_start:n_start+N,2);

%calculate correlation matrix
R = xcorr(u, length(u)-1, 'unbiased');
R_matrix = toeplitz(R(length(u):end));

%calculate eigenvalues
[V,D] = eig(R_matrix);

%calculate stepsize
Vmax = max(D,[],'all');
mu = 2/(2*Vmax);

%initiate lms
[e,w,w_track] = lms(mu,M,u,d);

%plot lms performance
figure
subplot(2,1,1);
plot(w_track), title('w')
subplot(2,1,2)
plot(e), title('e')

%plot output vs desired
output_signal = filter(w, 1, data(:,1));

figure
subplot(3,1,1)
plot(data(:,1)), title('Input')
subplot(3,1,2)
plot(output_signal), title('Output')
subplot(3,1,3)
plot(data(:,2)), title('Desired signal')