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

%% calculate

n_start = 5000;
M = 30;
N = 3000;
delay = 15;

time = linspace(0, 20, height(data));
time = time(n_start:n_start+N);

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

%test filter
n_start = 7000;
u = data(n_start:n_start+N,1);
d = data(n_start:n_start+N,2);
output_signal = filter(w, 1, u);

%calculate scaled output
scaled_output = [];
for i = 1:height(u)
    delta = max(output_signal)-max(d);
    scaled_value = output_signal(i)-delta;
    scaled_output = [scaled_output scaled_value];
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
plot(d), hold on, 
plot(scaled_output(1,18:length(scaled_output))), title('Output vs desired (LMS)'), xlabel('Sample'), ylabel("Voltage(mV)"), xlim([1400 1750])
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
subplot(3,1,2), plot(Fs/L*(0:L-1),abs(Yy)), title('FFT output'), xlim([0 60]), ylim([0 16000])
subplot(3,1,3), plot(Fs/L*(0:L-1),abs(Yd)), title('FFT desired'), xlim([0 60]), ylim([0 16000])
