function [ out ] = addAccessStepPeriodVoltageClamp( in )
%ADDACCESSSTEPPERIOD adds a spacer period that checks cell access before and after the main trial
%
%   Short (2) second spacer period at the start and end of the trail
%   with a small current injection step that will be used to analize the neurons' access resistance
%
%      ephySettings is reference to obtain these variables (commented current 10/2016):
%      settings.sampRate.out
%      Pulse settings (Voltage Clamp)
%    settings.voltagePulse.Amp =  5; %mV
%    settings.voltagePulse.Dur = 0.5; %seconds
%    settings.voltagePulse.spacerDur = 2; %seconds
%
% Yvette Fisher 11/2016
ephysSettings %used to be samp Rate and pulse amplitude

spacer = zeros(1,settings.voltagePulse.spacerDur*settings.sampRate);
spacerEpochNum = zeros(1,settings.voltagePulse.spacerDur*settings.sampRate);

middleIndex = numel(spacer)/ 2; % find the middle of the spacer duration

% find start and end of the pulse time
pulseStart_ind = round( middleIndex - ((settings.voltagePulse.Dur * settings.sampRate)/2));
pulseEnd_ind = round( middleIndex + ((settings.voltagePulse.Dur * settings.sampRate)/2));

% set portion of spacer to be larger than zero for the step of pA injection
spacer( pulseStart_ind : pulseEnd_ind) = settings.voltagePulse.Amp * settings.daq.voltageConversionFactor; % in Voltage for the daq to send

% if in is a struct (thus contains mutliple fields)
if ( isstruct(in) );
    % add command to command field
    out.command = [spacer in.command spacer ];
    % and epoch to epoch field
    out.epochs = [spacerEpochNum in.epochs spacerEpochNum];
else
    %add spacer before and after command
    out = [spacer in spacer];
end

end
