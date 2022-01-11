% basicVoltageClampAcquisitionScript
% 
% simple aquisition script for aquiring electrophysiology data from 700B
% amplifier and NiDAQ card
%
% Yvette Fisher 12/2021
%% Input trial information and set up NiDAQ session object
clear all; close all

% trial information flyNum, trialNum... - TODO
settings.durSeconds = 1; % trial duration (seconds)

% V-Clamp settings
trialMeta.mode = 'V-Clamp';

% Save Mulitclamp gain settings
settings.membranePotentialGain = 10; % 10mV/mV 
settings.membraneCurrentGain = 0.5; % 0.5V/nA
MiliVOLTS_PER_VOLT = 1000; % 1000 mV/V  
PICOAMP_PER_NANOAMP = 1000; % 1000 pA/nA

% Aquisition settings
settings.devID = 'Dev1'; % Device string for NI PCIe-6351
settings.sampRate  = 20e3; % Samp Rate in Hz, make sure this is 2x > filtering

% Setup daq session
nidaq = daq("ni"); % create daq object
nidaq.Rate = settings.sampRate; % set aquisition rate
addinput(nidaq, settings.devID, "ai0", "Voltage"); % add primary channel
addinput(nidaq, settings.devID, "ai1", "Voltage"); % add secondary channel

nidaq.Channels(1).TerminalConfig = 'SingleEnded'; % save information that channel is in single ended on BOB
nidaq.Channels(2).TerminalConfig = 'SingleEnded'; % save information that channel is in single ended on BOB

%% Aquire trial %%
data = read(nidaq, seconds(settings.durSeconds));

% store current and voltage values in useful units
current_pA = (data.Dev1_ai0*PICOAMP_PER_NANOAMP) / settings.membraneCurrentGain; %pAmp
voltage_mV = (data.Dev1_ai1*MiliVOLTS_PER_VOLT) / settings.membranePotentialGain; % mV

%% Plot recorded V-Clamp data %%
figure; %create figure
set(gcf, 'Color', 'w'); % set figure border to white
title ('Voltage clamp plot')

ax(1) = subplot(2,1,1); % create first plot region and asign axes handle (top)
plot( data.Time, current_pA);
box off
ylabel('membrane current (pA), primary');

ax(2) = subplot(2,1,2); % create second plot region and asign axes handle (top)
plot( data.Time, voltage_mV);
ylabel('membrane potential (mV), secondary')
box off

linkaxes(ax, 'x'); % link x-axis

%% Calculate resistance (pipet resistance or seal resistance) %%

% logical array for when voltage is above the mean
highVoltageLog1 = voltage_mV > mean(voltage_mV);

%steps 'up' from 0 to 1 find all of the starts of the pulse
allPulseStarts = strfind(highVoltageLog1',[0 1]);
pulseStart = allPulseStarts(1) + 1;

% steps 'down' from 1 to 0 to find all of the ends of pulse 
allPulseEnds = strfind(highVoltageLog1',[1 0]);
pulseEnd = allPulseEnds(1);

if pulseEnd < pulseStart
    pulseEnd = allPulseEnds(2);
end

pulseEnd = pulseEnd - 3;
pulseMid = round(pulseEnd - ((pulseEnd - pulseStart)/2));

troughStart = pulseEnd + 1;
troughEnd = allPulseStarts(2) -3 ;
troughMid = round(troughEnd - ((troughEnd - troughStart)/2));

peakCurrent = mean(current_pA(pulseMid:pulseEnd));
peakVoltage = mean(voltage_mV(pulseMid:pulseEnd));
baselineCurrent = mean(current_pA(troughMid:troughEnd));
baselineVoltage = mean(voltage_mV(troughMid:troughEnd));

voltDiff = peakVoltage - baselineVoltage; % delta voltage 
currDiff = peakCurrent - baselineCurrent; % delta current

VOLTS_PER_MiliVOLTS = 1e-3; % V /1000 mV
AMPS_PER_pA = 1e-12; % 1e-12 A / 1 pA
MEGAOHM_PER_OHM = 1e-6; % 1 MOhm / 1e6 Ohm

%calculates resistance using change in Voltage and change in Current
resistance_megaOhms = ((voltDiff*VOLTS_PER_MiliVOLTS)/(currDiff*AMPS_PER_pA))*MEGAOHM_PER_OHM;  %(MOhms)
disp(['Resistance (Rpipet or Rseal) = ' num2str(resistance_megaOhms) 'MOhms']); %display to command line

%TODO add print statement with resistance value in Giga Ohms


%% Measure whole-cell stats: Calculate Access/Series Resistance, Input/Membrane Resistance and holding current 

disp('Whole cell stats below: ignore if not in whole cell mode)')

% solve for holding current
holdingCurrent = mean(current_pA);

% TODO add print statement of hold current in pAmps

% set current to where average is zero
currentZeroed = current_pA - holdingCurrent;

% find out when the voltage is above (1) and below (0) the mean value.
pulseOn =  voltage_mV > mean(voltage_mV);

% Extract the indexes where voltage steps Up or Down
voltageStepUpInd = find( diff(pulseOn) == 1);
voltageStepDownInd = find( diff(pulseOn) == -1);

lengthOfShorterArray = min([ length( voltageStepUpInd) ,length( voltageStepDownInd) ]); 

% Find average pulse duration
meanPulseFrameNum = mean( voltageStepUpInd(1 :lengthOfShorterArray) - voltageStepDownInd (1:lengthOfShorterArray) );

% Round to integer and make positive, time 2 to include up and down pulse
meanPulseFrameNum = 2 * abs( round (meanPulseFrameNum));

% plots to help with debugging
figure(88)
plot(voltage_mV); hold on;
scatter(voltageStepUpInd', -0.5 * ones(1, length(voltageStepUpInd))); hold on 
scatter(voltageStepDownInd', -0.5 * ones(1, length(voltageStepDownInd)))
plot(currentZeroed)
%

FIRST_PULSE_TO_USE = 2; % start on second pulse incase first pulse has aberation
LAST_PULSE_TO_USE = length(voltageStepUpInd) - 1;  % skip last pulse incase it is too short.
counter = 1;

for i = FIRST_PULSE_TO_USE: LAST_PULSE_TO_USE 
    
    %Store current trace for each pulse in this array
    allCurrentResp(:,counter) = currentZeroed( voltageStepUpInd(i) : voltageStepUpInd(i) + meanPulseFrameNum);
    counter = counter + 1;
end
% Get mean current trace
meanCurrentResp = mean(allCurrentResp');

%Find the baseline period current for the mean response trace:
 START_OF_BASELINE_TRACE = 1/6; % extract starting baseline period of the trace
 END_OF_BASELINE_TRACE = 2/6;
% 
 startBaselineIndex = round( meanPulseFrameNum* START_OF_BASELINE_TRACE);
 endBaselineIndex = round( meanPulseFrameNum* END_OF_BASELINE_TRACE) - 1;
% 
 baselineCurrent = mean(meanCurrentResp( startBaselineIndex : endBaselineIndex ));

meanCurrentRespCorrectBaseline = meanCurrentResp - baselineCurrent;
allCurrentRespCorrectBaseline = allCurrentResp - baselineCurrent;

% plot current traces for user to see
figure(); 
plot( allCurrentRespCorrectBaseline ); hold on;
h = plot( meanCurrentRespCorrectBaseline);

% make mean trace line thick
LINE_THICKNESS = 4;
set( h,'linewidth', LINE_THICKNESS) 

% Find peak Current response to the -5mV pulse
peakCurrent = abs( min( meanCurrentRespCorrectBaseline )); % pA

% Solve for acccessResistance using peak current value
VOLTAGE_STEP_AMP = 10; %mV  (seal test from the amplifier)
VOLTS_PER_MiliVOLTS = 1e-3; % V /1000 mV
AMPS_PER_pA = 1e-12; % 1e-12 A / 1 pA
MEGAOHM_PER_OHM = 1e-6; % 1 MOhm / 1e6 Ohm

accessResistance_megaOhms = ((VOLTAGE_STEP_AMP * VOLTS_PER_MiliVOLTS) / (peakCurrent * AMPS_PER_pA)) * MEGAOHM_PER_OHM; % MOhms
disp(['Access Resistance (aka series) = ' num2str(accessResistance_megaOhms) 'MOhms']); %display to command line

% Extract a steady state region of the trace
START_OF_STEADYSTATE_TRACE = 4/6; % extract middle 1/3 of trace
END_OF_STEADYSTATE_TRACE = 5/6;

startSteadyStateIndex = round( meanPulseFrameNum* START_OF_STEADYSTATE_TRACE);
endSteadyStateIndex = round( meanPulseFrameNum* END_OF_STEADYSTATE_TRACE);

steadyStateCurrentAmp = abs( mean( meanCurrentRespCorrectBaseline (startSteadyStateIndex:endSteadyStateIndex))); %pA

%solve for the membrane resistance using steady state current
inputResistance_megaOhms = ((VOLTAGE_STEP_AMP * VOLTS_PER_MiliVOLTS) / (steadyStateCurrentAmp * AMPS_PER_pA)) * MEGAOHM_PER_OHM; % MOhms
disp(['Input Resistance (aka membrane) = ' num2str(inputResistance_megaOhms) 'MOhms']); %display to command line


% TODO - using model cell, check how acurate these measurements are are see
% if we can improve the estimates by changing the code

 
% %% Save trial % TODO
% 
% % Data folder where you'd like to save the data
% dataDirectory = ''; % E.g. '/Users/evettita/Google Drive/EphyData/'
% 
% %save() 



