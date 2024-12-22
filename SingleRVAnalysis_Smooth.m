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
        MGF_Prime_0; % first derivative at t = 0
        MGF_doublePrime % Second derivative of the MGF
        MGF_doublePrime_0; % Second derivative at t = 0
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
        end

        % Method to compute PDF and CDF
        % function obj = computePDFandCDF(obj, numBins)
        % 
            % [counts, edges] = histcounts(obj.Sample, numBins, 'Normalization', 'pdf');
            % binCenters = edges(1:end-1) + diff(edges)/2;
            % 
            % obj.sampleValues = linspace(min(obj.Sample), max(obj.Sample), numBins);
            % obj.PDF = interp1(binCenters, counts, obj.sampleValues, 'pchip', 0);
            % obj.CDF = cumtrapz(obj.sampleValues, obj.PDF);
            % obj.CDF = obj.CDF / max(obj.CDF);
        % end

        function obj = computePDFandCDF(obj, numBins)
            % Check if the data is discrete by analyzing unique values
            uniqueVals = unique(obj.Sample);
            isDiscrete = (length(uniqueVals) <= numBins/2) || ...
                        all(mod(obj.Sample, 1) == 0);  % Check if all values are integers
            
            if isDiscrete
                % For discrete data, use the unique values directly
                [counts, edges] = histcounts(obj.Sample, 'BinMethod', 'integers', ...
                                          'Normalization', 'probability');
                binCenters = edges(1:end-1) + diff(edges)/2;
                
                % Store exact points for discrete values
                obj.sampleValues = binCenters;
                obj.PDF = counts;
                
                % Compute CDF
                obj.CDF = cumsum(counts);
            else
                % For continuous data, use regular histcounts with smoothing
                [counts, edges] = histcounts(obj.Sample, numBins, 'Normalization', 'pdf');
                binCenters = edges(1:end-1) + diff(edges)/2;
                
                % Use shape-preserving piecewise cubic interpolation for continuous data
                obj.sampleValues = linspace(min(obj.Sample), max(obj.Sample), numBins);
                obj.PDF = interp1(binCenters, counts, obj.sampleValues, 'pchip', 0);
                
                % Normalize PDF
                obj.PDF = obj.PDF / trapz(obj.sampleValues, obj.PDF);
                
                % Compute CDF using numerical integration
                obj.CDF = cumtrapz(obj.sampleValues, obj.PDF);
                obj.CDF = obj.CDF / max(obj.CDF);
            end
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

            % compute the MGF' and MGF" at t = 0
            obj.MGF_Prime_0 = sum(binWidth * counts .* binCenters);
            obj.MGF_doublePrime_0 = sum(binWidth * counts .* (binCenters.^2));
        end

        % Plotting methods
        % function plotPDF(obj, axesHandle)
        %     if nargin < 2
        %         figure;
        %         axesHandle = axes;
        %     end
        %     plot(axesHandle, obj.sampleValues, obj.PDF, 'LineWidth', 2);
        % end

        function plotPDF(obj, axesHandle)
            if nargin < 2
                figure;
                axesHandle = axes;
            end
            
            % Check if data is discrete
            uniqueVals = unique(obj.Sample);
            isDiscrete = (length(uniqueVals) <= length(obj.sampleValues)/2) || ...
                        all(mod(obj.Sample, 1) == 0);
            
             if isDiscrete
                % For discrete data, use stem plot to show impulses
                stem(axesHandle, obj.sampleValues, obj.PDF, 'r', 'LineWidth', 2, 'MarkerFaceColor', 'r');
                title(axesHandle, 'Probability Mass Function');
            else
                % For continuous data, use line plot
                plot(axesHandle, obj.sampleValues, obj.PDF, 'LineWidth', 2);
                title(axesHandle, 'Probability Density Function');
            end
            
            xlabel(axesHandle, 'Value');
            ylabel(axesHandle, 'Probability');
            grid(axesHandle, 'on');
        end


        function plotCDF(obj, axesHandle)
            if nargin < 2
                figure;
                axesHandle = axes;
            end
            plot(axesHandle, obj.sampleValues, obj.CDF, '-', 'LineWidth', 1.5);
        end

        function obj = setTrange(obj, t_max)
            obj.Trange = linspace(-1, t_max, 100); % Set 100 points by default
        end

        function plotMGF(obj, axesHandle)
            if isempty(obj.MGF)
                error('MGF is empty. Ensure Trange is set and computeMGF is called before plotting.');
            end
        
            if nargin < 2
                figure;
                axesHandle = axes;
            end
        
            plot(axesHandle, obj.Trange, obj.MGF, 'b', 'LineWidth', 2);
        end


        function plotMGF_prime(obj, axesHandle)
            if isempty(obj.MGF_prime)
                error('MGF_prime has not been computed. Call computeMGF first.');
            end

            if nargin < 2
                figure;
                axesHandle = axes;
            end

            plot(axesHandle, obj.Trange, obj.MGF_prime, 'r--', 'LineWidth', 2);
        end

        function plotMGF_doublePrime(obj, axesHandle)
            if isempty(obj.MGF_doublePrime)
                error('MGF_doublePrime has not been computed. Call computeMGF first.');
            end

            if nargin < 2
                figure;
                axesHandle = axes;
            end

            plot(axesHandle, obj.Trange, obj.MGF_doublePrime, 'g-', 'LineWidth', 2);
        end

    end
end
