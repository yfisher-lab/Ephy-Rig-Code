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

% I-Clamp settings or V-Clamp settings
%trialMeta.mode = 'I-Clamp Normal';
trialMeta.mode = 'V-Clamp';

% Save Mulitclamp gain settings
settings.membranePotentialGain = 10; % 10mV/mV   % Units?
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

% Aquire trial
data = read(nidaq, seconds(settings.durSeconds));


%% Plot recorded V-Clamp data
figure; %create figure
set(gcf, 'Color', 'w'); % set figure border to white
title ('Voltage clamp plot')

ax(1) = subplot(2,1,1); % create first plot region and asign axes handle (top)
current_pA = (data.Dev1_ai0*PICOAMP_PER_NANOAMP) / settings.membraneCurrentGain; %pAmp
plot( data.Time, current_pA); %TODO update to avoid this hard coded field value
box off
ylabel('membrane current (pA), primary'); %TOOD check these units

ax(2) = subplot(2,1,2); % create second plot region and asign axes handle (top)
voltage_mV = (data.Dev1_ai1*MiliVOLTS_PER_VOLT) / settings.membranePotentialGain; % mV
plot( data.Time, voltage_mV);
ylabel('membrane potential (mV), secondary')
box off

linkaxes(ax, 'x'); % link x-axis

%% calculate pipet or membrane resistance
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

%calculates pipette resistance using change in Voltage and change in Current
pipetteResistance_megaOhms = ((voltDiff*VOLTS_PER_MiliVOLTS)/(currDiff*AMPS_PER_pA))*MEGAOHM_PER_OHM  %(MOhms)


%% Plot recorded I-Clamp data
figure; %create figure
set(gcf, 'Color', 'w'); % set figure border to white
title ('Current clamp plot')

ax(1) = subplot(2,1,1); % create first plot region and asign axes handle (top)
voltage_mV = (data.Dev1_ai0*MiliVOLTS_PER_VOLT) / settings.membranePotentialGain; % mV
plot( data.Time, voltage_mV);
ylabel('membrane potential (mV), primary')
box off

ax(2) = subplot(2,1,2); % create second plot region and asign axes handle (top)
current_pA = (data.Dev1_ai0*PICOAMP_PER_NANOAMP) / settings.membraneCurrentGain; %pAmp
plot( data.Time, current_pA); %TODO update to avoid this hard coded field value
box off
ylabel('membrane current (pA), secondary'); %TOOD check these units

linkaxes(ax, 'x'); % link x-axis

% 
% %% Save trial % TODO
% 
% % Data folder where you'd like to save the data
% dataDirectory = ''; % E.g. '/Users/evettita/Google Drive/EphyData/'
% 
% %save() 



