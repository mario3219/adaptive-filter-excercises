%% compare data

clc,clear,close all

%data_trim
data_trim = readtable('Data_trim.csv');

%import data
data1 = readtable('s01_ex01_s01.csv');
data2 = readmatrix('s01_ex01_s01.txt');

%trim to match samples in filtered
data2_trim = data2(9000:33000,2);

%scaling
%scaling_factor = mean(data1.P4)/mean(data2_trim);
%data2_trim = scaling_factor * data2_trim;
%data2_trim = data2_trim - mean(data1.P4);

%filtered data: sample index, four eeg channels
subplot(2,1,1);
time_steps = linspace(0, 2*60, height(data1));
plot(time_steps, data1.P4(:)), title('Filtered')%, xlim([45 46])

%raw data: sample index, four eeg channels
subplot(2,1,2);
time_steps = linspace(0, 2*60, height(data2_trim));
plot(time_steps, data2_trim), title('Raw')%, xlim([45 46])

%set training sample size and FIR order
M = 30;
N = 2000;

%split into input and desired signal
u = data2_trim(1:N);

%calculate eigenvalues and stepsize
R = xcorr(u, length(u)-1, 'unbiased');
R_matrix = toeplitz(R(length(u):end));
[V,D] = eig(R_matrix);
Vmax = max(D,[],'all');
%mu = 2/Vmax;
mu = 2/(Vmax);

%initiate lms
[e,w,w_track,J] = lms(mu,M,u);

%plot lms performance
figure
subplot(2,1,1);
plot(w_track'), title('w')
subplot(2,1,2)
plot(J), title('J')

%plot output vs desired
output_signal = filter(w, 1, data2_trim);
figure, subplot(2,1,1)
plot(output_signal), title('Output')
xlim([13600 13800])
subplot(2,1,2)
plot(data1.P4), title('Desired signal')
xlim([13600 13800])




