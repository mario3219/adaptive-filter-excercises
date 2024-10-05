clc,clear,close all

subplot(3,1,1);

% import and plot data
subplot(3,1,1);
data = readtable('QDL-BCHAIN.csv');
data.value = data.value./1e+6;
plot(data.value)


% choose order
M = 10;
u = data{1:1000, 'value'};
d = data{1001, 'value'};

R = xcorr(u, length(u)-1, 'unbiased');
R_matrix = toeplitz(R(length(u):end));

[V,D] = eig(R_matrix);
Vmax = max(D,[],'all');
mu = 2/Vmax;

[e,w,w_track,e_track] = lms(mu,M,u,d);

subplot(3,1,2);
plot(w_track');
subplot(3,1,3);
plot(e_track);

