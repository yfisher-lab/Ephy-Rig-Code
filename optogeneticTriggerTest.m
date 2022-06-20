% optogeneticTriggerTest
ephysSettings;

% set up daq object
nidaq = daq("ni"); % create daq object
nidaq.Rate = 1;% rigSettings.sampRate; % set aquisition rate

% set up output signal to the nidaq
addinput(nidaq, rigSettings.devID, "ai1", "Voltage")
addoutput(nidaq, rigSettings.devID,"port0/line0","Digital"); % output channel for current or voltage injection command

% for troubleshooting
LEDTimeOff = 5; %initial time (seconds) that LED is turned OFF
LEDTimeOn = 5; %time (seconds) that LED is turned ON

% pattern for epi fluorescence
outputArray = [zeros([1, LEDTimeOff]), ones([1, LEDTimeOn]), 0];

% run a trial 
rawData = readwrite(nidaq, outputArray');



