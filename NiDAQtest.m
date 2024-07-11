
ephysSettings
%
nidaq = daq("ni"); % create daq object
nidaq.Rate = rigSettings.sampRate; % set aquisition rate
addinput(nidaq, rigSettings.devID, "ai0", "Voltage"); % add primary channel
addinput(nidaq, rigSettings.devID, "ai1", "Voltage"); % add secondary channel

for i = 1:numel(nidaq.Channels)
    % for all channels with TerminalConfig as an option set ot single ended
    currentChannel = nidaq.Channels(i);
    if (isprop(currentChannel, 'TerminalConfig'))
    nidaq.Channels(i).TerminalConfig = 'SingleEnded'; % Set channel to single ended on BOB
    end
end


    trialDurSec = 1; %rigSettings.defaultTrialDur; % sec
 
    % Create a default and empty command signal if one was not specified:
    command = zeros( 1, 1 * rigSettings.sampRate );
    stimulus.command = buildOutputSignal('command', command);



fields = fieldnames(stimulus);
outputMatrix = [];

for i = 1:length(fields)
 if( isstruct(stimulus.(fields{i})))

     currStim = stimulus.(fields{i});

   % add it to the output matrix, each command needs to be a column vector
    outputMatrix = [outputMatrix, currStim.output'];

    % add output channel to daq session
    addoutput(nidaq, rigSettings.devID,currStim.channelID,currStim.measurementType); % output channel for current or voltage injection command

 end
end

outputMatrix = makeFinalSignalsZerosForAllCommandChannels( outputMatrix ); 


rawData = readwrite(nidaq, outputMatrix);