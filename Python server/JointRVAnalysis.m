classdef JointRVAnalysis
    properties
        X % Random variable X
        Y % Random variable Y
        analysis_X; % to calculate the mean and variance
        analysis_Y; % to calculate the mean and variance
        numBins % Number of bins for histograms
        mean_X;
        var_X;
        mean_Y;
        var_Y;
    end
    
    methods
        % Constructor
        function obj = JointRVAnalysis(data, numBins)
            % Validate the data
            if size(data, 1) ~= 2
                error('Input data must be of size 2 x N.');
            end
        
            obj.X = data(1, :); % Assign X
            obj.Y = data(2, :); % Assign Y
            obj.numBins = numBins; % Assign number of bins
        
            % Initialize analysis_X and analysis_Y
            obj.analysis_X = SingleRVAnalysis_Smooth(obj.X, obj.numBins,1);
            obj.analysis_Y = SingleRVAnalysis_Smooth(obj.Y, obj.numBins,1);
        
            % Debugging: Check if these are objects
            if ~isa(obj.analysis_X, 'SingleRVAnalysis_Smooth') || ~isa(obj.analysis_Y, 'SingleRVAnalysis_Smooth')
                error('analysis_X or analysis_Y was not initialized properly.');
            end
        end


        % function to display mean and variance
        function [meanValue, varianceValue] = calculateStatistics_X(obj)
            % Ensure obj.analysis_X is a valid SingleRVAnalysis object
            if ~isa(obj.analysis_X, 'SingleRVAnalysis_Smooth')
                error('analysis_X is not a valid SingleRVAnalysis object.');
            end
        
            % Compute mean and variance
            meanValue = obj.analysis_X.Mean;
            obj.mean_X = meanValue;
            varianceValue = obj.analysis_X.Variance;
            obj.var_X = varianceValue;
        end

        
        function [mean, var] = calculateStatistics_Y(obj)
            mean = obj.analysis_Y.Mean;
            obj.mean_Y = mean;
            var = obj.analysis_Y.Variance;
            obj.var_Y = var;
        end

        % Plot 2D Joint Distribution
        function plot_2d_distribution(obj, filename)
            % Create hidden figure and axes
            figureHandle = figure('Visible', 'off'); 
            axesHandle = axes('Parent', figureHandle); 
            
            edgesX = linspace(min(obj.X), max(obj.X), obj.numBins);
            edgesY = linspace(min(obj.Y), max(obj.Y), obj.numBins);
            jointHist = histcounts2(obj.X, obj.Y, edgesX, edgesY, 'Normalization', 'probability');
            
            % Plot on the hidden axes
            imagesc(axesHandle, edgesX, edgesY, jointHist');
            colorbar(axesHandle);
            title(axesHandle, '2D Joint Distribution (Heatmap)');
            xlabel(axesHandle, 'X');
            ylabel(axesHandle, 'Y');
            axesHandle.YDir = 'normal'; % Ensure correct axis orientation
        
            % Save and close the figure
            saveas(figureHandle, filename);
            close(figureHandle);
        end
        
        % Plot 3D Joint Distribution
        function plot_3d_distribution(obj, filename)
            % Create hidden figure and axes
            figureHandle = figure('Visible', 'off');
            axesHandle = axes('Parent', figureHandle);
            
            edgesX = linspace(min(obj.X), max(obj.X), obj.numBins);
            edgesY = linspace(min(obj.Y), max(obj.Y), obj.numBins);
            [jointHist, ~, ~] = histcounts2(obj.X, obj.Y, edgesX, edgesY, 'Normalization', 'probability');
            
            binCentersX = edgesX(1:end-1) + diff(edgesX) / 2;
            binCentersY = edgesY(1:end-1) + diff(edgesY) / 2;
            [XGrid, YGrid] = meshgrid(binCentersX, binCentersY);
            
            % Plot the surface on the hidden axes
            surf(axesHandle, XGrid, YGrid, jointHist', 'EdgeColor', 'none');
            colorbar(axesHandle);
            title(axesHandle, '3D Joint Distribution (Surface Plot)');
            xlabel(axesHandle, 'X');
            ylabel(axesHandle, 'Y');
            zlabel(axesHandle, 'Probability');
            shading(axesHandle, 'interp');
        
            % Save and close the figure
            saveas(figureHandle, filename);
            close(figureHandle);
        end
        
        % Plot Marginal Distribution of X
        function plot_mariginal_X(obj, filename)
            % Create hidden figure and axes
            figureHandle = figure('Visible', 'off');
            axesHandle = axes('Parent', figureHandle);
        
            % Compute PDF for X
            edgesX = linspace(min(obj.X), max(obj.X), obj.numBins);
            marginalX = histcounts(obj.X, edgesX, 'Normalization', 'probability');
            binCentersX = edgesX(1:end-1) + diff(edgesX) / 2;
        
            % Interpolate to smooth the distribution
            smoothX = linspace(min(binCentersX), max(binCentersX), 1000);
            smoothY = interp1(binCentersX, marginalX, smoothX, 'pchip');
        
            % Plot the marginal distribution as a smooth curve
            plot(axesHandle, smoothX, smoothY, 'LineWidth', 2, 'Color', 'b');
            title(axesHandle, 'Marginal Distribution of X');
            xlabel(axesHandle, 'X');
            ylabel(axesHandle, 'Probability');
            grid(axesHandle, 'on');
        
            % Save and close the figure
            saveas(figureHandle, filename);
            close(figureHandle);
        end
        
        % Plot Marginal Distribution of Y
        function plot_mariginal_Y(obj, filename)
            % Create hidden figure and axes
            figureHandle = figure('Visible', 'off');
            axesHandle = axes('Parent', figureHandle);
        
            % Use ksdensity to estimate the PDF
            [densityY, valuesY] = ksdensity(obj.Y);
        
            % Plot the marginal distribution as a smooth curve
            plot(axesHandle, valuesY, densityY, 'LineWidth', 2, 'Color', 'r');
            title(axesHandle, 'Marginal Distribution of Y');
            xlabel(axesHandle, 'Y');
            ylabel(axesHandle, 'Density');
            grid(axesHandle, 'on');
        
            % Save and close the figure
            saveas(figureHandle, filename);
            close(figureHandle);
        end
        function covarianceXY = calculate_covariance(obj)
            x = obj.X - mean(obj.X);
            y = obj.Y - mean(obj.Y);

            covarianceXY = sum((x) .* (y)) / (length(obj.X) - 1);
        end
        
        % Calculate Correlation Coefficient Manually
        function correlationXY = calculate_correlation(obj)
            covarianceXY = obj.calculate_covariance();
            x = obj.X - mean(obj.X);
            y = obj.Y - mean(obj.Y);

            varianceX = sum((x).^2) / (length(obj.X) - 1);
            varianceY = sum((y).^2) / (length(obj.Y) - 1);
            correlationXY = covarianceXY / sqrt(varianceX * varianceY);
        end
    end
end
