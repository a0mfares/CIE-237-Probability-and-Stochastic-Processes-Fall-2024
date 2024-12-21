% Number of samples
num_samples = 1e6;

% Generate and save X2, Y2
X2 = normrnd(3, sqrt(4), [1, num_samples]); % N(3, 4)
Y2 = normrnd(-5, sqrt(2), [1, num_samples]); % N(-5, 2)
XY2 = [X2; Y2]; % Combine into a single variable
save('XY2.mat', 'XY2');

% Generate and save X3, Y3
X3 = gamrnd(2, 10, [1, num_samples]); % Gamma(2, 10)
Y3 = binornd(4, 0.5, [1, num_samples]); % Bin(4, 0.5)
XY3 = [X3; Y3]; % Combine into a single variable
save('XY3.mat', 'XY3');

% Generate and save X4, Y4
X4 = exprnd(1/0.05, [1, num_samples]); % Exp(0.05)
Y4 = 3 * X4 + 2; % Linear transformation
XY4 = [X4; Y4]; % Combine into a single variable
save('XY4.mat', 'XY4');

% Generate and save X5, Y5
X5 = randi([-1, 1], [1, num_samples]); % Uniform {-1, 1}
n = normrnd(0, 0.5, [1, num_samples]); % N(0, 0.5)
Y5 = X5 + n; % Add noise
XY5 = [X5; Y5]; % Combine into a single variable
save('XY5.mat', 'XY5');

disp('All joint random variable files have been created.');
