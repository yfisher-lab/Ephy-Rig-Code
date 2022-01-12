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




%% Set up DAQ session
nidaq = daq("ni"); % create daq object
nidaq.Rate = settings.sampRate; % set aquisition rate
addinput(nidaq, settings.devID, "ai0", "Voltage"); % add primary channel
addinput(nidaq, settings.devID, "ai1", "Voltage"); % add secondary channel

% TODO add output channel logic for commands or other signals 


%% Aquire data (read and write in forground)
trialMeta.trialStartTime = datestr(now,'HH:MM:SS'); % record Trial time for record

rawData = read(nidaq, seconds(trialDurSec)); %TODO update to readwrite once add command signals....

%% Process and scale data
% code assumes that all modes of Multiclamp 700b have primary=membrane potential & secondary=membrane current'
data.voltage = rawData.Dev1_ai0 * settings.voltage.softGain_mV; % convert to mV
data.current = rawData.Dev1_ai1 * settings.current.softGain_pA; % convert to pA

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

%% Save data if normal trial with stimulus (typically anything but seal test)
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

%% If there was a movie aquired then: %% Copy movies into trial folder within tmp video aqu.
 if ( isfield( stimulus, 'cameraTrigger') )
      copyFramesToTrialFolder( exptInfo, trialMeta );
 end
%% Online plotting of data
plotTrialData( data, stimulus, settings ); % plot the trial that was just aquired for the user to sre


%% Pause code to view plots
% % make it so that the code pauses so I can look at the figure of data, but
% % only if we are NOT doing a the seal test where the stim is named No Stimulus
 if (~strcmp (stimulus.name, 'No Stimulus'))
    
keyboard;
 end

end

