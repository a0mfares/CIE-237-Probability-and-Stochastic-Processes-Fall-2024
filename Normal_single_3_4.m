% Script: generate_normal.m

% Parameters
mu = 3;  % Mean
sigma = sqrt(4); % Standard deviation
n = 1e+6; % Number of samples

% Generate random samples
normal_samples = mu + sigma * randn(1, n);

% Save to .mat file
save('test_sample_RV_normal.mat', 'normal_samples');
disp('Normal distribution samples saved to test_sample_RV_normal.mat');
