% Script: generate_binomial.m

% Parameters
n_trials = 5;   % Number of trials
p = 0.3;        % Success probability
n = 1e+6;       % Number of samples

% Generate random samples
binomial_samples = binornd(n_trials, p, 1, n);

% Save to .mat file
save('test_sample_RV_binomial.mat', 'binomial_samples');
disp('Binomial distribution samples saved to test_sample_RV_binomial.mat');
