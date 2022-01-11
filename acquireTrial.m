function [data, trialMeta] = acquireTrial(stimulus, exptInfo , preExptData, trialMeta , varargin)
%AQUIRETRIAL  Runs and Records trials from the amplifier and runs input stimluli
%
% This is the main aquisition function within the ephy recording setting
% It sets up a session with the NiDAQ aquisition system, which both triggers
% any external stimulus hardware (Odor valves, Visual Panel system)
% And also stores incoming data from the NiDAQ as the trial occurs
% At the end of the trial the data is save to the PC
% 
% INPUT
% stimulus = Struct that contains the information about the parameters and
% the array for injection command
% 
% OUTPUT
% 
% SAVED:
% data 
% stimulus
% trialMeta
% exptInfo
% 
% Yvette Fisher 8/2016, updated 2/2017, updated for 700b 1/2022

fprintf('\n*********** Acquiring Trial ***********\n' ) 
% load ephy settings
ephysSettings;

% Determine trial duration and build default stimulus command 
if exist('stimulus','var')
    trialDurSec = length(stimulus.command) / settings.sampRate; % sec
else
    trialDurSec = settings.defaultTrialDur; % sec

    % Create a default and empty command signal if one was not specified:
    stimulus.command = zeros( 1, settings.defaultTrialDur * settings.sampRate );
    stimulus.name = 'No Stimulus';
end

%% record Trial time 
trialMeta.trialStartTime = datestr(now,'HH:MM:SS'); 


%% Set up DAQ session
nidaq = daq("ni"); % create daq object
nidaq.Rate = settings.sampRate; % set aquisition rate
addinput(nidaq, settings.devID, "ai0", "Voltage"); % add primary channel
addinput(nidaq, settings.devID, "ai1", "Voltage"); % add secondary channel


%% Aquire data
rawData = read(nidaq, seconds(trialDurSec));
%rawData = niOI.startForeground();

% TODO
%trialMeta.mode = getRecordingMode; % TODO 'V-Clamp' or 'I-Clamp' ...
trialMeta.mode = 'V-Clamp'; % hardcoded placeholder for testing

%% 200B logic %% Decode telegraphed output
% gainIndex = find(settings.bob.inChannelsUsed == settings.bob.gainCh); % get index of gain Ch.
% freqIndex = find(settings.bob.inChannelsUsed == settings.bob.freqCh); % get index of freq Ch.
% modeIndex = find(settings.bob.inChannelsUsed == settings.bob.modeCh); % get index of Mode Ch.
% 
% % decode and store output state of the amplifier 
% [trialMeta.scaledOutput.gain, trialMeta.scaledOutput.freq, trialMeta.mode] = ...
%     decodeTelegraphedOutput(rawData, gainIndex, freqIndex, modeIndex);

%% Process and scale data

% either save as primary and secondary OR add logic here about VC vs CC and
% from that scale into voltage and current values....

switch trialMeta.mode
    % Voltage Clamp
    case {'Track','V-Clamp'}

        data.current = rawData.Dev1_ai0 * settings.current.softGain_pA; % convert to pA
        data.voltage = rawData.Dev1_ai1 * settings.voltage.softGain_mV; % convert to mV

    % Current Clamp
    case {'I=0','I-Clamp Normal','I-Clamp Fast'} % TODO update based on decoding

        data.voltage = rawData.Dev1_ai0 * settings.voltage.softGain_mV; % convert to mV
        data.current = rawData.Dev1_ai1 * settings.current.softGain_pA; % convert to pA
end


% 2000B logic %% Process scaled data
% % Scaled output
% switch trialMeta.mode
%     % Voltage Clamp
%     case {'Track','V-Clamp'}
%         trialMeta.scaledOutput.softGain = 1000 / (trialMeta.scaledOutput.gain * settings.current.betaFront);
%         data.scaledCurrent = trialMeta.scaledOutput.softGain .* rawData(:, settings.bob.scalCh + 1);  %mV
%     % Current Clamp
%     case {'I=0','I-Clamp Normal','I-Clamp Fast'}
%         trialMeta.scaledOutput.softGain = 1000 / ( trialMeta.scaledOutput.gain);
%         data.scaledVoltage = trialMeta.scaledOutput.softGain .* rawData(:, settings.bob.scalCh + 1);  %pA   
% end


%% %% Process X and Y stimulus information from the Panel system
% % AND save the ficTrac ball position information for later
% if ( isfield( stimulus, 'panelParams') )
%     % stop the stimulus now and turn off the LEDs incase any were still on
%     Panel_com('stop')
%     Panel_com('all_off'); 
%     % Turn off having panel waiting for external trigger from amp to start
%     Panel_com('disable_extern_trig');
%     
%    % get channel index from ephysettings
%    xPosIndex = find(settings.bob.inChannelsUsed == settings.bob.panelDAC0X); % get index 
%    yPosIndex = find(settings.bob.inChannelsUsed == settings.bob.panelDAC1Y); % get index 
% 
%    data.xPanelVolts =  rawData (:, xPosIndex);
%    % Decode Xpos from voltage reading
%    data.xPanelPos = processPanelDataX ( data.xPanelVolts , stimulus.panelParams );
%    
%    data.yPanelVolts =  rawData (:, yPosIndex);
%    % Decode Ypos from voltage reading
%    data.yPanelPos = processPanelDataY ( data.yPanelVolts , stimulus.panelParams );
% end
% 
%    % Save FicTrac angular Position signal from DAQ/Virtual Machine
%    ficTracPosIndex = find( settings.bob.inChannelsUsed == settings.bob.ficTracAngularPosition); % get index
%    ficTracIntxIndex = find( settings.bob.inChannelsUsed == settings.bob.ficTracIntx); % get index
%    ficTracIntyIndex = find( settings.bob.inChannelsUsed == settings.bob.ficTracInty); % get index
%    
%    % if not closed loop trial this array might be empty/flat line, but that is fine
%    data.ficTracAngularPosition = rawData ( : , ficTracPosIndex);
%    data.ficTracIntx = rawData ( : , ficTracIntxIndex);
%    data.ficTracInty = rawData ( : , ficTracIntyIndex);

%% Only if saving data
if nargin ~= 0
    % Get filename and save trial data
    [fileName, path, trialMeta.trialNum] = getDataFileName( exptInfo );
    fprintf(['\nTrial Number ', num2str( trialMeta.trialNum )])
    
    if ~isfolder(path)
        mkdir(path);
    end
    
    % save data, stimlulus command, and other info
     save(fileName, 'data','trialMeta','stimulus','exptInfo');
     
     disp( ['.... Trial # ' num2str( trialMeta.trialNum )   ' was Saved!'] );
end

%% Close daq object
% niOI.stop  % not needed if using "Read"
 
%% If there was a movie aquired then: %% Copy movies into trial folder within tmp video aqu.
 if ( isfield( stimulus, 'cameraTrigger') )
      copyFramesToTrialFolder( exptInfo, trialMeta );
 end
%% Online plotting of data
plotTrialData( data, stimulus, settings ); % plot the trial that was just aquired for the user to sre

% plotInputResistance(figNum) % todo write this code eventually -yf
% TODO eventually...Calculate Ri based on the pulse at the end of the trace

% %% chrimson stimulution plasticity experiments plot current IPSP amplitude
% % on probe trials
% PROBE_STRING = 'probeTrial';
% % check if stim names long enough
% if( length(stimulus.name) >= length( PROBE_STRING) )
%     stimName = stimulus.name(1: length( PROBE_STRING) );
%     % check if we are on a probe trial
%     if( strcmp( stimName ,  PROBE_STRING) )
%         
%         if( strcmp(trialMeta.mode, 'I-Clamp Normal'))
%             %Current clamp plotting version
%             plotIPSPAmp_inputRes( data, stimulus, trialMeta, 2);
%         elseif( strcmp(trialMeta.mode, 'V-Clamp'))
%             % Voltage clamp plotting version
%             plotIPSCAmplitude_VClamp( data, stimulus, trialMeta, 3);
%         end
%     end
% end
% 
% % check if random string
% RAND_STRING = 'RandLoc';
% % check if stim names long enough
% if( length(stimulus.name) >= length( RAND_STRING ) )
%     stimName = stimulus.name;
%     if( strfind( stimName ,  RAND_STRING) ~= 0 )
%         plotBarRandLoc_duringExperiment;
%     end
% end
% 

%%
% % make it so that the code pauses so I can look at the figure of data, but
% % only if we are NOT doing a the seal test where the stim is named No Stimulus
 if (~strcmp (stimulus.name, 'No Stimulus'))
    
keyboard;
 end

end

