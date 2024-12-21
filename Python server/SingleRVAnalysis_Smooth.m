classdef SingleRVAnalysis_Smooth
    properties
        Sample % Input sample array
        PDF % Probability Density Function (smoothed using histcounts + interpolation)
        CDF % Cumulative Distribution Function (smoothed using histcounts + interpolation)
        Mean % Mean of the sample
        Variance % Variance of the sample
        ThirdMoment % Third moment of the sample
        sampleValues % Sample values for interpolating the PDF and CDF
        MGF % Moment Generating Function
        MGF_prime % First derivative of the MGF
        MGF_doublePrime % Second derivative of the MGF
        Trange % Range for MGF computation
    end

    methods
        % Constructor: Initialize the object with the sample and number of bins
        function obj = SingleRVAnalysis_Smooth(sample, numBins, Trange)
            if nargin < 2
                numBins = 50; % Default number of bins
            end

            % Assign sample to the property
            obj.Sample = sample;

            % Call methods to compute PDF, CDF, and statistics
            obj = obj.computePDFandCDF(numBins);
            obj = obj.computeStatistics();
            obj = obj.setTrange(Trange);
            obj = obj.computeMGF();
        end

        % Method to compute PDF and CDF
        function obj = computePDFandCDF(obj, numBins)
            [counts, edges] = histcounts(obj.Sample, numBins, 'Normalization', 'pdf');
            binCenters = edges(1:end-1) + diff(edges)/2;

            obj.sampleValues = linspace(min(obj.Sample), max(obj.Sample), numBins);
            obj.PDF = interp1(binCenters, counts, obj.sampleValues, 'pchip', 0);
            obj.CDF = cumtrapz(obj.sampleValues, obj.PDF);
            obj.CDF = obj.CDF / max(obj.CDF);
        end

        % Manual computation of mean, variance, and third moment
        function obj = computeStatistics(obj)
            n = length(obj.Sample);

            % Mean
            obj.Mean = sum(obj.Sample) / n;

            % Variance
            deviations = obj.Sample - obj.Mean;
            obj.Variance = sum(deviations.^2) / (n - 1);

            % Third Moment
            obj.ThirdMoment = sum(deviations.^3) / n;
        end

        % Compute MGF and its derivatives
        function obj = computeMGF(obj)
            if isempty(obj.Trange)
                error('Trange is not set. Use setTrange to define the range of t.');
            end

            tRange = obj.Trange;

            % Compute histogram PDF
            [counts, edges] = histcounts(obj.Sample, 'Normalization', 'pdf');
            binCenters = edges(1:end-1) + diff(edges)/2; % Midpoints of bins
            binWidth = diff(edges); % Bin width (assume uniform width)
            binWidth = binWidth(1); % Use the first bin width for simplicity

            % Compute MGF, MGF', and MGF''
            obj.MGF = arrayfun(@(t) sum(binWidth * counts .* exp(t * binCenters)), tRange);
            obj.MGF_prime = arrayfun(@(t) sum(binWidth * counts .* binCenters .* exp(t * binCenters)), tRange);
            obj.MGF_doublePrime = arrayfun(@(t) sum(binWidth * counts .* (binCenters.^2) .* exp(t * binCenters)), tRange);
        end
        function plotPDF(obj, filename)
            figureHandle = figure('Visible', 'off'); % Create a figure, but keep it hidden
            axesHandle = axes('Parent', figureHandle); % Create axes within the hidden figure
            
            % Plot the PDF on the axes
            plot(axesHandle, obj.sampleValues, obj.PDF, 'LineWidth', 2);
            
            % Save the plot to a file if a filename is provided
            if nargin == 2
                saveas(figureHandle, filename); 
            end
            
            % Close the figure after saving
            close(figureHandle);
        end
        
        function plotCDF(obj, filename)
            figureHandle = figure('Visible', 'off'); % Create a figure, but keep it hidden
            axesHandle = axes('Parent', figureHandle); % Create axes within the hidden figure
            plot(axesHandle, obj.sampleValues, obj.CDF, '-', 'LineWidth', 1.5);
            
            % Save the plot to a file if a filename is provided
            if nargin == 2
                saveas(figureHandle, filename);
            end
            
            % Close the figure
            close(figureHandle);
        end
        function obj = setTrange(obj, t_max)
            obj.Trange = linspace(-1, t_max); 
        end
        function plotMGF(obj, filename)
            if isempty(obj.MGF)
                error('MGF is empty. Ensure Trange is set and computeMGF is called before plotting.');
            end
        
            figureHandle = figure('Visible', 'off'); 
            axesHandle = axes('Parent', figureHandle); 
        
            plot(axesHandle, obj.Trange, obj.MGF, 'b', 'LineWidth', 2);
            
            % Save the plot to a file if a filename is provided
            if nargin == 2
                saveas(figureHandle, filename);
            end
            
            % Close the figure
            close(figureHandle);
        end

        function plotMGF_prime(obj, filename)
            if isempty(obj.MGF_prime)
                error('MGF_prime has not been computed. Call computeMGF first.');
            end
        
            figureHandle = figure('Visible', 'off'); % Create a figure, but keep it hidden
            axesHandle = axes('Parent', figureHandle); % Create axes within the hidden figure
        
            plot(axesHandle, obj.Trange, obj.MGF_prime, 'r-', 'LineWidth', 2);
            
            % Save the plot to a file if a filename is provided
            if nargin == 2
                saveas(figureHandle, filename);
            end
            
            % Close the figure
            close(figureHandle);
        end

        function plotMGF_doublePrime(obj, filename)
            if isempty(obj.MGF_doublePrime)
                error('MGF_doublePrime has not been computed. Call computeMGF first.');
            end
        
            figureHandle = figure('Visible', 'off'); % Create a figure, but keep it hidden
            axesHandle = axes('Parent', figureHandle); % Create axes within the hidden figure
        
            plot(axesHandle, obj.Trange, obj.MGF_doublePrime, 'g-', 'LineWidth', 2);
            
            % Save the plot to a file if a filename is provided
            if nargin == 2
                saveas(figureHandle, filename);
            end
            
            % Close the figure
            close(figureHandle);
        end
    end
end
