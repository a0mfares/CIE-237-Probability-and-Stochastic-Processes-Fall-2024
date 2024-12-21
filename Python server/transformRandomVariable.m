function [Z, transformed_pdf] = transformRandomVariable(X, transformation_func, numbins)
% TRANSFORMRANDOMVARIABLE Transforms a random variable with user-defined function
% Inputs:
% - X: Sample Random Variable X (optional)
% - transformation_func: Function handle for transformation Z = f(X)
%
% Outputs:
% - Z: Transformed random variable
% - transformed_pdf: Struct with PDF information

% Check input arguments
if nargin < 2
    error('Please provide both the random variable and transformation function.');
end

% Check if X is a function handle (meaning only transformation function was provided)
if isa(X, 'function_handle')
    % If only transformation function is given, prompt user to load random variable
    [file, path] = uigetfile('*.mat', 'Select the MAT-file containing the 1xN sample space');
    if isequal(file, 0)
        error('No file selected. Exiting.');
    end
    
    % Load the random variable
    data = load(fullfile(path, file));
    fieldNames = fieldnames(data);
    samples = data.(fieldNames{1});
    X = samples(1, :);
    
    % Update transformation function
    transformation_func = X;
end

% Validate inputs
if ~isnumeric(X) || isempty(X)
    error('Input X must be a non-empty numeric vector');
end

% Apply transformation
try
    Z = transformation_func(X);
catch ME
    error('Error applying transformation: %s', ME.message);
end

% Additional validation of transformed variable
if ~isnumeric(Z) || isempty(Z)
    error('Transformation resulted in an empty or non-numeric vector');
end

% Perform analysis
try
    Z_analysis = SingleRVAnalysis_Smooth(Z,numbins,5);
    X_analysis = SingleRVAnalysis_Smooth(X,numbins,5);
catch ME
    % Debug information
    disp('Error in creating SingleRVAnalysis_K:');
    disp(ME.message);
    disp('Transformed Z details:');
    disp('Size: '); disp(size(Z));
    disp('Class: '); disp(class(Z));
    disp('First few elements: '); disp(Z(1:min(end,10)));
    error('Failed to create SingleRVAnalysis_K object');
end

% Compute basic statistics
transformed_pdf.original_mean = X_analysis.Mean();
transformed_pdf.original_var = X_analysis.Variance();
transformed_pdf.transformed_mean = Z_analysis.Mean();
transformed_pdf.transformed_var = Z_analysis.Variance();
end