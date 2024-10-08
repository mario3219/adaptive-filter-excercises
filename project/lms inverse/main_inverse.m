%% load data
clc,clear

load("rec_1m.mat");
data = val';

%% present data
clc

time = linspace(0, 20, height(data));

figure
subplot(1,2,1)
plot(time, data(:,1)), title("Raw data - Person 01 (Recording 01)"), ylabel("Voltage(mV)"), xlabel("Time(s)"), xlim([9 11])
subplot(1,2,2)
plot(time, data(:,2)), title("Filtered data - Person 01 (Recording 01)"), ylabel("Voltage(mV)"), xlabel("Time(s)"), xlim([9 11])

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
mu = 4/(Vmax);

%initiate lms
[e,w,w_track,J] = lms(mu,M,u,d);

%plot lms performance
figure
subplot(2,1,1);
plot(w_track'), xlabel('Iterations'), ylabel('Tap-weights')
subplot(2,1,2)
plot(J), title('Learning curve'), xlabel('Iterations'), ylabel('Mean Square Error')

%test filter
n_start = 7000;
u = data(n_start:n_start+N,1);
d = data(n_start:n_start+N,2);
output_signal = filter(w, 1, u);

figure
subplot(3,1,1)
plot(u), title('Input'), xlabel('Sample'), ylabel("Voltage(mV)"), xlim([1350 1750])
subplot(3,1,2)
plot(output_signal), title('Output'), xlabel('Sample'), ylabel("Voltage(mV)"), xlim([1350 1750])
subplot(3,1,3)
plot(d), title('Desired signal'), xlabel('Sample'), ylabel("Voltage(mV)"), xlim([1350 1750])
