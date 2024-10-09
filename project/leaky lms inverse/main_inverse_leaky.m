%% load data
clc,clear

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

%% calculate

n_start = 5000;
M = 30;
N = 3000;
delay = 15;

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

%gamma
% 0 < g < 1/N
g = 1/N;

%initiate lms
[e,w,w_track,J] = lms_leaky(mu,M,u,d,g);

%test filter
n_start = 7000;
u = data(n_start:n_start+N,1);
d = data(n_start:n_start+N,2);
output_signal = filter(w, 1, u);

%scale signal
d_scaled = d/max(d);
output_scaled = output_signal/max(output_signal);

scaled_output = [];
for i = 1:height(u)
    delta = max(output_scaled)-max(d_scaled);
    scaled_value = output_scaled(i)-delta;
    scaled_output = [scaled_output scaled_value+0.3101];
end


%% plots

%plot lms performance
figure
subplot(2,1,1);
plot(w_track'), xlabel('Iterations'), ylabel('Tap-weights')
subplot(2,1,2)
plot(J), title('Learning curve'), xlabel('Iterations'), ylabel('Mean Square Error')

%plot results
figure
subplot(1,2,1)
plot(u), title('Input'), xlabel('Sample'), ylabel("Voltage(mV)"), xlim([1400 1750])
subplot(1,2,2)
plot(d_scaled), hold on, 
plot(scaled_output(1,18:length(scaled_output))), title('Output vs desired (Leaky LMS)'), xlabel('Sample'), ylabel("Voltage(mV)"), xlim([1400 1750])
legend('Desired','Output')

%% performance analysis

figure, freqz(w)

n_start = 7000;
u = data(n_start:n_start+N,1);
d = data(n_start:n_start+N,2);
L = height(u);
Fs = 500;
T = 1/Fs;
t = (0:L-1)*T;

Yu = fft(u);
Yd = fft(d);
Yy = fft(output_signal);
figure
subplot(3,1,1), plot(Fs/L*(0:L-1),abs(Yu)), title('FFT input'), xlim([0 60]), ylim([0 16000])
subplot(3,1,2), plot(Fs/L*(0:L-1),abs(Yy)), title('FFT output'), xlim([0 60]), ylim([0 1600000])
subplot(3,1,3), plot(Fs/L*(0:L-1),abs(Yd)), title('FFT desired'), xlim([0 60]), ylim([0 16000])
