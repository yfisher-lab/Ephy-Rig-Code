% basicCurrentClampAcquisitionScript
% 
% simple aquisition script for aquiring electrophysiology data from 700B
% amplifier and NiDAQ card
%
% Yvette Fisher 1/2022
%% Input trial information and set up NiDAQ session object
clear all; close all

% trial information flyNum, trialNum... - TODO
settings.durSeconds = 60; % trial duration (seconds)

% I-Clamp settings
trialMeta.mode = 'I-Clamp Normal';

% Save Mulitclamp gain settings
settings.membranePotentialGain = 10; % 10mV/mV   % Units?
settings.membraneCurrentGain = 0.5; % 0.5V/nA
settings.ExternalCommandSensitivity = 400; %pA/V
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
%addinput(nidaq, settings.devID, "ai2", "Voltage"); % add third channel
addoutput(nidaq, settings.devID,"ao0","Voltage"); % output 0

nidaq.Channels(1).TerminalConfig = 'SingleEnded'; % save information that channel is in single ended on BOB
nidaq.Channels(2).TerminalConfig = 'SingleEnded'; % save information that channel is in single ended on BOB

% add in logic for current injection patterns
[OutputArray]= makeInjectionWaveform (10,1,1,1,nidaq.Rate,settings.ExternalCommandSensitivity)'; %InjpA,BaselineDuration(s),PulseDuration(s),PostPulseDuration(s),Rate(Hz),amplitudeGain(XXXX)
data = readwrite(nidaq,OutputArray);


%% Aquire trial
%data = read(nidaq, seconds(3));

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
current_pA = (data.Dev1_ai1*PICOAMP_PER_NANOAMP) / settings.membraneCurrentGain; %pAmp
plot( data.Time, current_pA);
box off
ylabel('membrane current (pA), secondary'); %TOOD check these units

linkaxes(ax, 'x'); % link x-axis

 
% %% Save trial % TODO
% 
% % Data folder where you'd like to save the data
% dataDirectory = ''; % E.g. '/Users/evettita/Google Drive/EphyData/'
% 
% %save() 


