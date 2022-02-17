classdef BeamParameter
    %BEAMPARAMETER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        lawdata
        
        length
        width
        thickness
    end
    
    properties (Constant)
        % Unit is nondimensional not percent
        strain1 = 0.0005 
        strain2 = 0.0025
    end
    
    methods
        function obj = BeamParameter(length, width, thickness)
            %BEAMPARAMETER Construct an instance of this class

            [file,path] = uigetfile('*.txt');
            absolutefilepath = fullfile(path, file);
            fileID = fopen(absolutefilepath);
            
            formatSpec = '"%f, %f, %f, %f, %f"';
            lawdata = textscan(fileID,formatSpec, 'CommentStyle','//');
            lawdata = cell2mat(lawdata);
            obj.lawdata = array2table(lawdata, "VariableNames", {'Load_N_' 'Time_s_' 'Extension_mm_' 'Stress_MPA_' 'Strain'});
            
            obj.length = length;
            obj.width = width;
            obj.thickness = thickness;
        end
        
        function fighandle = plotLoad(obj)
            time = obj.lawdata.Time_s_;
            plotdata = obj.lawdata.Load_N_;
            
            figure;
            fighandle = plot(time, plotdata);
            xlabel('Time (s)')
            ylabel('Load (N)')            
        end
        
        function fighandle = plotExtension(obj)
            time = obj.lawdata.Time_s_;
            plotdata = obj.lawdata.Extension_mm_;
            
            figure;
            fighandle = plot(time, plotdata);
            xlabel('Time (s)')
            ylabel('Extension (mm)')            
        end
        
        function fighandle = plotStress(obj)
            time = obj.lawdata.Time_s_;
            plotdata = obj.lawdata.Stress_MPA_;
            
            figure;
            fighandle = plot(time, plotdata);
            xlabel('Time (s)')
            ylabel('Stress (MPa)')     
        end
        
        function fighandle = plotStrain(obj)
            time = obj.lawdata.Time_s_;
            plotdata = obj.lawdata.Strain;
            
            figure;
            fighandle = plot(time, plotdata);
            xlabel('Time (s)')
            ylabel('Strain (-)')     
        end
        
        function bendingstress = calcBendingStress(obj)
            
            load = obj.lawdata.Load_N_;
            
            bendingstress = (3*obj.length)/(2*obj.width*obj.thickness^2) .* load;
            
            figure;
            plot(obj.lawdata.Strain, bendingstress)
            xlabel('Strain (-)')
            ylabel('Bending stress (Pa)')       
            
        end

        function bendingstrain = calcBendingStrain(obj)
            extenstion = obj.lawdata.Extension_mm_ * 10^-3;

            bendingstrain = (6 * obj.thickness)/(obj.length^2) .* extenstion;
        end
        
        function [rangestrain, rangebendingstress] = getRange(obj, bendingstress, bendingstrain, strainrange)
            
            logicalarray = strainrange(1,1) <= bendingstrain & bendingstrain <= strainrange(1,2);
            
            rangestrain = bendingstrain(logicalarray);
            rangebendingstress = bendingstress(logicalarray);            
        end
        
        function flexuralmodulus = calcFlexuralModulus(obj, fittedfunction)
            
            fittedstress = @(strain) polyval(fittedfunction, strain);
            
            flexuralmodulus = (fittedstress(obj.strain2) - fittedstress(obj.strain1)) / (obj.strain2 - obj.strain1);
        end
        
        function fighandle = plotResult(obj, fittedfunction, straindata, bendingstressdata)
      
            fittedstress = @(strain) polyval(fittedfunction, strain);
            
            fighandle = figure;
            hold on;   
            % processed data
            scatter(straindata, bendingstressdata, 'filled', 'DisplayName', 'Calculated data')
            
            % fitting function
            fittedstraindata = linspace(0, max(straindata), 1000);
            fittedstressdata = fittedstress(fittedstraindata);            
            plot(fittedstraindata, fittedstressdata, 'Color', [1.0 0 0.5], 'DisplayName', 'Fitted function')
            
            % flexual strength calculation point
            calculationstraindata = [obj.strain1, obj.strain2];
            calculationstressdata = fittedstress(calculationstraindata);
            scatter(calculationstraindata, calculationstressdata, 'filled', 'DisplayName', 'Calculation point')
            
            xlabel('Bending strain (-)')
            ylabel('Bending stress (Pa)')
            legend('Location', 'southeast')
        end
        
    end
end

