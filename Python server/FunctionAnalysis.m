classdef FunctionAnalysis
    %FUNCTIONANALYSIS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        sample;
        numBins;

        X;
        Y;

        Z;
        Z_data;
        Z_plot;

        W;
        W_data;
        W_plot;

        ZW;

        transZ;
        transW;

        joint_WZ;
    end
    
    methods
        function obj = FunctionAnalysis(sample, numbins, transZ, transW)
            %FUNCTIONANALYSIS Construct an instance of this class
            %   Detailed explanation goes here
            obj.sample = sample;
            obj.X = sample(1,:); 
            obj.Y = sample(2,:);
            
            obj.numBins = numbins;

            obj.transZ = transZ;
            obj.transW = transW;

            [obj.Z,obj.Z_data] = transformRandomVariable(obj.X,obj.transZ,numbins);
            [obj.W,obj.W_data] = transformRandomVariable(obj.Y,obj.transW,numbins);

            obj.Z_plot = SingleRVAnalysis_Smooth(obj.Z,numbins,5);
            obj.W_plot = SingleRVAnalysis_Smooth(obj.W,numbins,5);

            obj.ZW = [obj.Z; obj.W];

            obj.joint_WZ = JointRVAnalysis(obj.ZW,obj.numBins);
        end
        
        function [meanX, meanZ] = calculateMeansZ(obj)
            meanX = obj.Z_data.original_mean;
            meanZ = obj.Z_data.transformed_mean;
        end

        function [meanY, meanW] = calculateMeansW(obj)
            meanY = obj.W_data.original_mean;
            meanW = obj.W_data.transformed_mean;
        end

        function [varX, varZ] = calculateVarZ(obj)
            varX = obj.Z_data.original_var;
            varZ = obj.Z_data.transformed_var;
        end

        function [varY, varW] = calculateVarW(obj)
            varY = obj.W_data.original_var;
            varW = obj.W_data.transformed_var;
        end

        function covZW = calculateCov(obj)
            covZW = obj.joint_WZ.calculate_covariance();
        end

        function corrZW = calculateCorr(obj)
            corrZW = obj.joint_WZ.calculate_correlation();
        end

        function plot_dis_Z(obj, fileName)
            if nargin < 2 
                fileName = 'dis_Z_plot.png'; 
            end

             

            % Plot the data
            obj.joint_WZ.plot_mariginal_X(fileName);

            
        end

        function plot_dis_W(obj, fileName)
            if nargin < 2 
                fileName = 'dis_W_plot.png'; 
            end

           
            % Plot the data
            obj.joint_WZ.plot_mariginal_Y(fileName);

            
        end

        function plot_joint(obj, fileName)
            if nargin < 2
                fileName = 'joint_plot.png'; 
            end

            
            % Plot the data
            obj.joint_WZ.plot_3d_distribution(fileName);

           
        end


    end
end

