%% Beam material parameter identification script
% Load test data

clear
analyser = BeamParameter(0.09475, 0.030, 0.0023);
% Plot raw data

analyser.plotLoad();
analyser.plotExtension();
analyser.plotStress();
analyser.plotStrain();
% Recalculate data
% calculate bending stress from all law data.

bendingstress = analyser.calcBendingStress();
bendingstrain = analyser.calcBendingStrain();
%% 
% Get a certain range of bending stress data

[bendingstrain, bendingstress] = analyser.getRange(bendingstress, bendingstrain, [0, 0.005]);
%% 
% Fit data

[p, error] = polyfit(bendingstrain, bendingstress, 1);
%% 
% Calculate flexual strength

flexuralmodulus = analyser.calcFlexuralModulus(p) / 10^9
%% 
% Plot result

analyser.plotResult(p, bendingstrain, bendingstress)