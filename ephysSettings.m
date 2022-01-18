%% ephysSettings
% Holds the hard coded CONSTANT parameters for Ephy acquisition experiment
% including data directory path and parametters sepecific to the
% rig channels and acquisition settings
%
% Yvette Fisher
% Created: 6/2016, updated 1/2022

%% Parameters

% Data folder
rigSettings.dataDirectory = 'C:\Users\fisherlab\Documents\EphyData\'; % 

% Device
rigSettings.devID = 'Dev1'; %for NI PCIe-6351

% for seal test or any other case when not specified
rigSettings.defaultTrialDur = 2; % second

% Samp Rate
rigSettings.sampRate  = 20e3;

%% TODO: UPDATE these values to match the configuration of each individual rig

rigSettings.bob.primary = 0; % primary 700b output, voltage or current depending on mode
rigSettings.bob.secondary = 1; % secondary 700b outputs, voltage or current depending on mode
% As of 1/2022 the code assumes voltage clamp for seal tests periods and current
% clamp for all other experimental trials

rigSettings.bob.aiType = 'SingleEnded'; % as opposed to 'differential' on the BOB, keep singleEnded.
rigSettings.bob.inChannelsUsed  = [0:1]; %TODO update for output channels...


PICOAMP_PER_NANOAMP = 1000; % 1000 pA/nA
rigSettings.current.amplifierGain = 0.5; % 0.5V/nA
rigSettings.current.softGain_pA = PICOAMP_PER_NANOAMP / rigSettings.current.amplifierGain; %pAmp

MiliVOLTS_PER_VOLT = 1000; % 1000 mV/V  
rigSettings.voltage.amplifierGain = 10; % 10mV/mV 
rigSettings.voltage.softGain_mV = MiliVOLTS_PER_VOLT / rigSettings.voltage.amplifierGain; % mV

% TODO add logic for current injection with analog output and scaling
% factors

% TODO add back in seal test at start and end of each trial if wanted


%% % OLD values from 200B in Wilson lab


% % Camera frame rate % For recording video of the fly during the recording
% settings.camRate = 30; %Hz
% settings.rawVidDir = 'Y:\flyVideos\';



% % Break out box, UPDATED TO 2090a on 8/30
% settings.bob.currCh = 0;
% settings.bob.voltCh = 1;
% settings.bob.scalCh = 2;
% settings.bob.gainCh = 3;
% settings.bob.freqCh = 5;
% settings.bob.modeCh = 6;
% % Panel channels added 2/2017 channels to record the X-pos and Y-pos coming from the Panel
% % DAC0: voltage proportional to current frame number (in the unit of volt) in mode 1, 2, 3, 4, and PC dumping mode of channel x, update analog output in mode 5 (debugging function generator) of channel x;
% % DAC1: voltage proportional to current frame number (in the unit of volt) in mode 1,2,3, 4, and PC dumping mode of channel y, update analog output in mode 5 (debugging function generator) of channel y;
% settings.bob.panelDAC0X = 7;
% settings.bob.panelDAC1Y = 8;
% 
% % Channel storing ball position send from the FicTrac DAQ (USB 3101)
% settings.bob.ficTracAngularPosition = 9; % 10 Volt (VOUT1) signal based on amount ball has revolved in heading (yaw/heading)
% settings.bob.ficTracIntx = 10; % 10 Volt (VOUT0) signal based on ball revolution in x  
% settings.bob.ficTracInty = 11; % 10 Volt (VOUT2) signal based on ball revolution in y  
% 
% settings.bob.aiType = 'SingleEnded'; % as opposed to 'differential' on the BOB, keep singleEnded.
% %settings.bob.inChannelsUsed  = [0:3,5:6];
% %settings.bob.inChannelsUsed  = [0:3,5:8];
% settings.bob.inChannelsUsed  = [0:3,5:11];

% %% TODO: UPDATE logic to work with 700B and Multiclamp - these values are match to input/output of 200B amplifier
% 
% % Current input settings - No signalCond at the moment
% settings.current.betaRear  = 1; % Rear switch for current output set to beta = 1 mV/pA
% settings.current.betaFront  = 1; % Front switch (CONFIG) for current output set to beta = 1      mV/pA
% % settings.current.sigCond.Ch = 1;
% % settings.current.sigCond.gain = 1;
% % settings.current.sigCond.freq = 5; %kHz
% MiliVOLTS_PER_VOLT = 1000; % 1000 mV/V  
% settings.current.softGain   = MiliVOLTS_PER_VOLT/(settings.current.betaRear * settings.current.betaFront); % converted into pA and mV since 1pA/mV
% 
% 
% % Voltage input settings - I am not using the signal conditioner currently
% %settings.voltage.sigCond.Ch = 2;
% %settings.voltage.sigCond.gain = 1;
% %settings.voltage.sigCond.freq = 5; %kHz
% settings.voltage.amplifierGain = 10; % 10 Vm, set coming out of the back of the amplifier
% MiliVOLTS_PER_VOLT = 1000; % 1000 mV/V  
% settings.voltage.softGain = MiliVOLTS_PER_VOLT / ( settings.voltage.amplifierGain); % To get voltage in mV
% 
% 
% % Digital Voltage output settings:
% %settings.daq.voltageDividerScaling = 0.0598; % voltage divider conversion factor, voltage divider cuts the volate by a factor of 0.0598
% settings.daq.voltageDividerScaling = 1; % voltage divider removed from back of amplifier on 11/2
% settings.daq.currentConversionFactor = 1 / (2000 * settings.current.betaFront * settings.daq.voltageDividerScaling); % V/pA   1 volt goes to 2 nA aka 2000 pA  
% 
% settings.daq.frontExtScale = 20 / 1000; %20mV/ 1000mV (1V) amplifier cuts the voltage down by this factor, every 1volt from the DAQ is 20mV into the Axopatch
% settings.daq.voltageConversionFactor =  1 / (settings.daq.frontExtScale * settings.daq.voltageDividerScaling * MiliVOLTS_PER_VOLT); % use this for votlage clamp experiment commands 
% %1 Volt = 2nA * Beta (1 normally)
% 
% % Pipette, seal, access Resistance measurement period
% settings.sealTest.Dur = 2; % second
% 
% % Cell attached Voltage Clamp mesurements
% settings.cellAttached.Dur = 60; % seconds
% 
% % Pulse settings (Current Clamp)
% settings.pulse.Amp =  -3; %5 % changed on 9/2/16;  %pA     0.0394/2; %  
% settings.pulse.Dur = 0.8; %seconds, DO NOT MAKE LARGER THAN spacerDur % changed from 0.5 to 0.8 on 11/2/16
% settings.pulse.spacerDur = 2; %seconds
% % settings.pulse.Start = 1*settings.sampRate.out + 1;
% % settings.pulse.End = 2*settings.sampRate.out;
% 
% % Pulse settings (Voltage Clamp)
% settings.voltagePulse.Amp =  5; %mv
% settings.voltagePulse.Dur = 0.5; %seconds
% settings.voltagePulse.spacerDur = 2; %seconds
