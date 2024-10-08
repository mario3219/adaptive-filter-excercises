clc,clear,close all

subplot(3,1,1);

% import and plot data
subplot(3,1,1);
data = readtable('QDL-BCHAIN.csv');
data.value = data.value./1e+6;
plot(data.value)

% choose order
n_start = 5215;
M = 20;
N = 2000;
u = data{n_start:n_start+N, 'value'};

R = xcorr(u, length(u)-1, 'unbiased');
R_matrix = toeplitz(R(length(u):end));

[V,D] = eig(R_matrix);
Vmax = max(D,[],'all');
mu = 2/Vmax;

[e,w,w_track,J] = lms(mu,M,u);

subplot(3,1,2);
plot(w_track');
subplot(3,1,3);
plot(J);

%%

u = data{n_start:n_start+N, 'value'};

nFuture = 1;  % Number of future values to predict
futurePredictions = zeros(nFuture, 1);
y = u;

% Use the last known values of the signal to predict future ones
for i = 1:nFuture
    % Use the last known input data (from d) as the input vector
    xVec = y(end:-1:end-M+1);
    
    % Predict the next value using the final weights (dot product)
    futurePredictions(i) = w' * xVec;
    
    % Shift the input vector for the next prediction (use the new predicted value)
    y = [y; futurePredictions(i)];
end

figure
%plot(y), hold on
u = data{n_start:n_start+N+nFuture, 'value'};
plot(u)%, xlim([(height(u)-2*nFuture) height(u)+nFuture])

