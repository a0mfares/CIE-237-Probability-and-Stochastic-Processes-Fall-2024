% Script: generate_poisson.m

% Parameters
lambda = 10; % Rate (mean)
n = 1e+6;    % Number of samples

% Generate random samples
poisson_samples = poissrnd(lambda, 1, n);

% Save to .mat file
save('test_sample_RV_poisson.mat', 'poisson_samples');
disp('Poisson distribution samples saved to test_sample_RV_poisson.mat');
