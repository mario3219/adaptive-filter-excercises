%% load data
clc,clear,close all

load("rec_1m.mat");
data = val';

figure, plot(data(:,2)), title("Filtered")

%%

n_start = 5000;
M = 10;
N = 1000;

u = data(n_start:n_start+N,2);

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
[e,w,w_track,J] = lms_predictor(mu,M,u,g);

figure
subplot(2,1,1), plot(w_track'), title('W')
subplot(2,1,2), plot(J), title('Learning curve')

%%

n_start = 5215;
u = data(n_start:n_start+N,2);

nFuture = 10;  % Number of future values to predict
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
plot(y), hold on
u = data(n_start:n_start+N+nFuture,2);
plot(u)%, xlim([(height(u)-2*nFuture) height(u)+nFuture])
