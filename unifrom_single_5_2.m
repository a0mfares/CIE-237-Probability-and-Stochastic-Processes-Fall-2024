% MATLAB Code to generate a .mat file with a uniform RV

% Define the parameters of the uniform distribution
a = -5; % Lower bound
b = 2;  % Upper bound

% Number of samples to generate
N = 1e+6; % Adjust as needed

% Generate the uniform random variable
uniformRV = a + (b - a) * rand(1, N);

% Save the variable to a .mat file
save('UniformRV.mat', 'uniformRV');

% Display a message to confirm the file is saved
disp('Uniform random variable saved to UniformRV.mat');
