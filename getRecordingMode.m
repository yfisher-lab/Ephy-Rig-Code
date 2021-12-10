function [ out ] = getRecordingMode( )
%GETRECORDINGMODE Figure out if the recording is being preformed in
%current clamp or voltage clamp mode
%
% OUTPUT: Returns
% True: for Current Clamp  'I-Clamp Normal'
% False: for Voltage Clamp 'V-Clamp'
% True: any other mode 
%
% Yvette Fisher 2/2017 

%% TODO re-write this logic for new NI DAQ objects and 700B set up
ephysSettings;
% Future version draft:
SAMPLE_DURATION = 0.5;% seconds

daqreset %reset DAC object
devID = 'Dev1';  % Set device ID
% Configure session: national instruments output/input
niOI = daq.createSession('ni');
niOI.Rate = settings.sampRate;% set sample rate

%set duration to length of  stimulus.command in seconds
niOI.DurationInSeconds = SAMPLE_DURATION; %seconds

% Analog INPUT Channels
aI = niOI.addAnalogInputChannel( devID , settings.bob.inChannelsUsed , 'Voltage' );

% Set all channels to the correct inputType, likely 'SingleEnded'
for i = 1:length( settings.bob.inChannelsUsed )
    aI(i).InputType = settings.bob.aiType;
end

% aquire the data from the amplifier
rawData = niOI.startForeground();

% Decode telegraphed output
gainIndex = find(settings.bob.inChannelsUsed == settings.bob.gainCh); % get index of gain Ch.
freqIndex = find(settings.bob.inChannelsUsed == settings.bob.freqCh); % get index of freq Ch.
modeIndex = find(settings.bob.inChannelsUsed == settings.bob.modeCh); % get index of Mode Ch.

% decode and store output state of the amplifier
[trialMeta.scaledOutput.gain, trialMeta.scaledOutput.freq, trialMeta.mode] = ...
    decodeTelegraphedOutput(rawData, gainIndex, freqIndex, modeIndex);

disp(['Mode decoded as: ' trialMeta.mode])

if (strcmp ( trialMeta.mode,  'I-Clamp Normal') )
    out = true;
elseif (strcmp ( trialMeta.mode,  'V-Clamp') )
    out = false;    
else
    disp('WARNING: since mode was decoded as something other than I-Clamp Normal or V-Clamp code defaulted to I-clamp settings!!')
    out = true;
end

end

%%BACKUP CODE for if we ever want to promopt the user instead
%   This function either asks the user, or in future version of the code it
%   could be updated to aquire this information from the amplifier

% %Ask the user if we are in voltage clamp or current clamp mode:
% % USE this is opening a NiDaq session is too slow
% CURRENT_CLAMP_BOL = input('Is this recording in current Clamp (y)? (code will assume V-clamp if answer is (n)) ','s');
% if strcmp(CURRENT_CLAMP_BOL,'y')
%     out =  true;
% else
%     % this means voltage clamp
%     out = false;
% end

