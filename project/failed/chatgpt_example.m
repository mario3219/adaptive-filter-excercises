clc,clear

% Parameters
fs = 256; % Sampling frequency in Hz
N = 1024; % Number of samples
mu = 0.01; % Step size
num_taps = 32; % Number of filter coefficients

% Simulated EEG signal (replace with actual data)
t = (0:N-1)/fs;
eeg_signal = sin(2*pi*10*t) + 0.5*randn(size(t)); % 10 Hz sine wave + noise
reference_signal = randn(size(t)); % Simulated reference signal (e.g., noise)

% Initialize filter coefficients
w = zeros(num_taps, 1); % Ensure w is a column vector (32x1)
output_signal = zeros(size(eeg_signal));
error_signal = zeros(size(eeg_signal));

% Adaptive filtering using LMS
for n = num_taps:N
    % Create the input vector for the current sample
    x = reference_signal(n:-1:n-num_taps+1); % This will be a row vector of size (1x32)

    % Calculate the filter output
    output_signal(n) = w' * x'; % Transpose x to ensure it is a column vector (1x32 -> 32x1)

    % Calculate the error signal
    error_signal(n) = eeg_signal(n) - output_signal(n); % Error signal

    % Update the filter coefficients
    w = w + mu * error_signal(n) * x'; % x should be a column vector; x' is now 32x1
end

% Plot results
figure;
subplot(3, 1, 1);
plot(t, eeg_signal);
title('EEG Signal');
xlabel('Time (s)');
ylabel('Amplitude');

subplot(3, 1, 2);
plot(t, output_signal);
title('Filtered Output Signal');
xlabel('Time (s)');
ylabel('Amplitude');

subplot(3, 1, 3);
plot(t, error_signal);
title('Error Signal');
xlabel('Time (s)');
ylabel('Amplitude');