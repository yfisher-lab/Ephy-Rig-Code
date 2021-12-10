function [data, trialMeta] = acquireTrial(stimulus, exptInfo , preExptData, trialMeta , varargin)
%AQUIRETRIAL  Runs and Records trials from the amplifier and runs input stimluli
%
% This is the main aquisition function within the ephy recording setting
% It sets up a session with the NiDAQ aquisition system, which both triggers
% any external stimulus hardward (Odor valves, Visual Panel system)
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
% Yvette Fisher 8/2016, updated 2/2017

fprintf('\n*********** Acquiring Trial ***********\n' ) 
% load ephy settings
ephysSettings;

% Create a default and empty command signal if one was not specified:
if ~exist('stimulus','var')  
    stimulus.command = zeros( 1, settings.sealTest.Dur * settings.sampRate );
    stimulus.name = 'No Stimulus';
end

%% record Trial time 
trialMeta.trialStartTime = datestr(now,'HH:MM:SS'); 

%% Code stamp: Saves a string with the short hash of the git repo housing the called function.
% exptInfo.codeStamp = getCodeStamp(1); 

%% Set up DAC
daqreset %reset DAC object
devID = 'Dev1';  % Set device ID

%% TODO update to new handling of ni DAQ objects

% Configure session: national instruments output/input
niOI = daq.createSession('ni');
% 
% niOI.Rate = settings.sampRate;% set sample rate
% 
% %set duration to length of  stimulus.command in seconds
% niOI.DurationInSeconds = length( stimulus.command )/settings.sampRate; %seconds
% 
% % Analog INPUT Channels
% aI = niOI.addAnalogInputChannel( devID , settings.bob.inChannelsUsed , 'Voltage' );
% 
% % Set all channels to the correct inputType, likely 'SingleEnded'
% for i = 1:length( settings.bob.inChannelsUsed )
%     aI(i).InputType = settings.bob.aiType;
% end
% 
% % add both ANALOG OUT and DIGITAL OUT channel if odorCommand is included in stimlulus
% if ( isfield(stimulus, 'odorCommand')) 
% 
%     % Analog OUTPUT Channels for current/voltage clamp control
%     niOI.addAnalogOutputChannel(devID, 0 , 'Voltage');
%     
%     % add Digital OUTPUT channel, for the olfactometer valves or for
%     % triggering the Panel display to start
%     niOI.addDigitalChannel(devID , 'port0/line0', 'OutputOnly');       % Shuttle valve
%     
%     % Queue output data:  DAQ will take channels based on the order they
%     % were added Analog OUT = 0, Digital OUT ie A = 0, D = 1 in this particular case
%     niOI.queueOutputData([ stimulus.command' stimulus.odorCommand' ]);
%     
%     % VISUAL stimulus and CHRIMSON without video
% elseif( isfield( stimulus, 'panelParams') && isfield ( stimulus, 'shutterCommand') && ~isfield( stimulus, 'cameraTrigger') )
%       % DAQ channel 1: Analog OUTPUT Channels
%     niOI.addAnalogOutputChannel(devID, 0 ,'Voltage');
%     
%             % add Digital OUTPUT channel for triggering the shutter for
%             % DAQ channel 2: Chrimson stimulation
%     niOI.addDigitalChannel(devID , 'port0/line2', 'OutputOnly');    
%     
%         
%     % DAQ channel 3: add Digital OUTPUT channel, for triggering the Panel display to start
%     niOI.addDigitalChannel(devID , 'port0/line0', 'OutputOnly');       % 5V signal for INT3 on Panel controler
%       
%     % Queue output data:  DAQ will take channels based on the order they
%     % were added Analog OUT = 0, Digital OUT ie A = 0, D = 1, D = 2 in this particular case
%     niOI.queueOutputData([ stimulus.command' stimulus.shutterCommand' stimulus.visualTriggerCommand' ]);
%     
%     % Code the used Panel_com() to setup Panel display system and gets it ready to
%     % recieve triggering to start
%      setUpPanelDisplayTrial ( stimulus )
%   
% %VISUAL STIMULI    
% % add both ANALOG OUT and DIGITAL OUT channel if panelParams is included in stimulus    
% elseif ( isfield( stimulus, 'panelParams') && ~isfield( stimulus, 'cameraTrigger'))   
%     
%     % Analog OUTPUT Channels for current/voltage clamp control
%     niOI.addAnalogOutputChannel(devID, 0 , 'Voltage');
%     
%     % add Digital OUTPUT channel, for triggering the Panel display to start
%     niOI.addDigitalChannel(devID , 'port0/line0', 'OutputOnly');       % 5V signal for INT3 on Panel controler
%     
%     % Queue output data:  DAQ will take channels based on the order they
%     % were added Analog OUT = 0, Digital OUT ie A = 0, D = 1 in this particular case
%     niOI.queueOutputData([ stimulus.command' stimulus.visualTriggerCommand' ]);
%     
%     % Code the used Panel_com() to setup Panel display system and gets it ready to
%     % recieve triggering to start
%      setUpPanelDisplayTrial ( stimulus )
%      
%      % CHRIMSON STIM w/ VISUAL STIMULI AND WITH FLY VIDEO AQU.   
% elseif( isfield ( stimulus, 'shutterCommand') && isfield( stimulus, 'cameraTrigger') && isfield( stimulus, 'panelParams') )
%      
%      niOI.addAnalogOutputChannel(devID, 0 , 'Voltage');
%     
%     % add Digital OUTPUT channel, for triggering the Panel display to start
%     niOI.addDigitalChannel(devID , 'port0/line0', 'OutputOnly');       % 5V signal for INT3 on Panel controler
%     
%     % add Digital OUTPUT channel to triggering the frames of CAMERA (Blackfly)
%     niOI.addDigitalChannel(devID , 'port0/line1', 'OutputOnly');       % Short 5V pulses (I think!)
%     
%     % add Digital OUTPUT channel for triggering the shutter for Chrimson stimulation
%     niOI.addDigitalChannel(devID , 'port0/line2', 'OutputOnly');   
%     
%     % Queue output data:  DAQ will take channels based on the order they
%     % were added Analog OUT = 0, Digital OUT ie A = 0, D = 1 in this particular case
%     niOI.queueOutputData([ stimulus.command' stimulus.visualTriggerCommand' stimulus.cameraTrigger' stimulus.shutterCommand' ]);
%     
%     disp(['Video frames to aquire: '  num2str( sum( stimulus.cameraTrigger )) ])
%     
%     % Code the used Panel_com() to setup Panel display system and gets it ready to
%     % recieve triggering to start
%      setUpPanelDisplayTrial ( stimulus )
%      
% %VISUAL STIMULI WITH FLY VIDEO AQU.     
% elseif ( isfield( stimulus, 'panelParams') && isfield( stimulus, 'cameraTrigger') )   
%     
%         % Analog OUTPUT Channels for current/voltage clamp control
%     niOI.addAnalogOutputChannel(devID, 0 , 'Voltage');
%     
%     % add Digital OUTPUT channel, for triggering the Panel display to start
%     niOI.addDigitalChannel(devID , 'port0/line0', 'OutputOnly');       % 5V signal for INT3 on Panel controler
%     
%     % add Digital OUTPUT channel to triggering the frames of CAMERA (Blackfly)
%     niOI.addDigitalChannel(devID , 'port0/line1', 'OutputOnly');       % Short 5V pulses (I think!)
%     
%     % Queue output data:  DAQ will take channels based on the order they
%     % were added Analog OUT = 0, Digital OUT ie A = 0, D = 1 in this particular case
%     niOI.queueOutputData([ stimulus.command' stimulus.visualTriggerCommand' stimulus.cameraTrigger' ]);
%     
%     disp(['Video frames to aquire: '  num2str( sum( stimulus.cameraTrigger )) ])
%     
%     % Code the used Panel_com() to setup Panel display system and gets it ready to
%     % recieve triggering to start
%      setUpPanelDisplayTrial ( stimulus )
%  
% % CHRIMSON STIM w/ VIDEO    
% elseif(isfield ( stimulus, 'shutterCommand') && isfield( stimulus, 'cameraTrigger') )
%      % Analog OUTPUT Channels
%     niOI.addAnalogOutputChannel(devID,0,'Voltage');
%     
%             % add Digital OUTPUT channel to triggering the frames of CAMERA (Blackfly)
%     niOI.addDigitalChannel(devID , 'port0/line1', 'OutputOnly');       % Short 5V pulses (I think!)
%             % add Digital OUTPUT channel for triggering the shutter for
%             % Chrimson stimulation
%     niOI.addDigitalChannel(devID , 'port0/line2', 'OutputOnly');     
%     
%         %Send command trace signal to DAQ as an output
%     niOI.queueOutputData( [ stimulus.command' stimulus.cameraTrigger' stimulus.shutterCommand' ] );
%     
%     disp(['video frames to aquire: '  num2str( sum( stimulus.cameraTrigger )) ])  
%     
% % CHRIMSON STIM WITHOUT VIDEO
% elseif(isfield ( stimulus, 'shutterCommand') && ~isfield( stimulus, 'cameraTrigger') )
%       % Analog OUTPUT Channels
%     niOI.addAnalogOutputChannel(devID,0,'Voltage');
%     
%             % add Digital OUTPUT channel for triggering the shutter for
%             % Chrimson stimulation
%     niOI.addDigitalChannel(devID , 'port0/line2', 'OutputOnly');     
%     
%         %Send command trace signal to DAQ as an output
%     niOI.queueOutputData( [ stimulus.command' stimulus.shutterCommand' ] );
% 
%    
%     % VIDEO AQU WITHOUT STIMULUS or STIM     
% elseif(isfield( stimulus, 'cameraTrigger') ) 
%         % Analog OUTPUT Channels
%     niOI.addAnalogOutputChannel(devID,0,'Voltage');
%     
%         % add Digital OUTPUT channel to triggering the frames of CAMERA (Blackfly)
%     niOI.addDigitalChannel(devID , 'port0/line1', 'OutputOnly');       % Short 5V pulses
%     
%     %Send command trace signal to DAQ as an output
%     niOI.queueOutputData( [ stimulus.command' stimulus.cameraTrigger' ] );
%     
%     disp(['video frames to aquire: '  num2str( sum( stimulus.cameraTrigger )) ])
%     
% else% add ONLY ANALOG OUT channel if no ODOR or Visual stimlulus Trigger command
%     
%     % Analog OUTPUT Channels
%     niOI.addAnalogOutputChannel(devID,0,'Voltage');
%     
%     %Send command trace signal to DAQ as an output
%     niOI.queueOutputData( stimulus.command');
%     
% end

%% aquire data
rawData = niOI.startForeground();


%% Decode telegraphed output
gainIndex = find(settings.bob.inChannelsUsed == settings.bob.gainCh); % get index of gain Ch.
freqIndex = find(settings.bob.inChannelsUsed == settings.bob.freqCh); % get index of freq Ch.
modeIndex = find(settings.bob.inChannelsUsed == settings.bob.modeCh); % get index of Mode Ch.

% decode and store output state of the amplifier 
[trialMeta.scaledOutput.gain, trialMeta.scaledOutput.freq, trialMeta.mode] = ...
    decodeTelegraphedOutput(rawData, gainIndex, freqIndex, modeIndex);

%% Process non-scaled data
data.voltage = settings.voltage.softGain .* rawData(:,settings.bob.voltCh + 1);% mV
data.current = settings.current.softGain .* rawData(:,settings.bob.currCh + 1);% pA

%% Process scaled data
% Scaled output
switch trialMeta.mode
    % Voltage Clamp
    case {'Track','V-Clamp'}
        trialMeta.scaledOutput.softGain = 1000 / (trialMeta.scaledOutput.gain * settings.current.betaFront);
        data.scaledCurrent = trialMeta.scaledOutput.softGain .* rawData(:, settings.bob.scalCh + 1);  %mV
    % Current Clamp
    case {'I=0','I-Clamp Normal','I-Clamp Fast'}
        trialMeta.scaledOutput.softGain = 1000 / ( trialMeta.scaledOutput.gain);
        data.scaledVoltage = trialMeta.scaledOutput.softGain .* rawData(:, settings.bob.scalCh + 1);  %pA   
end


%% Process X and Y stimulus information from the Panel system
% AND save the ficTrac ball position information for later
if ( isfield( stimulus, 'panelParams') )
    % stop the stimulus now and turn off the LEDs incase any were still on
    Panel_com('stop')
    Panel_com('all_off'); 
    % Turn off having panel waiting for external trigger from amp to start
    Panel_com('disable_extern_trig');
    
   % get channel index from ephysettings
   xPosIndex = find(settings.bob.inChannelsUsed == settings.bob.panelDAC0X); % get index 
   yPosIndex = find(settings.bob.inChannelsUsed == settings.bob.panelDAC1Y); % get index 

   data.xPanelVolts =  rawData (:, xPosIndex);
   % Decode Xpos from voltage reading
   data.xPanelPos = processPanelDataX ( data.xPanelVolts , stimulus.panelParams );
   
   data.yPanelVolts =  rawData (:, yPosIndex);
   % Decode Ypos from voltage reading
   data.yPanelPos = processPanelDataY ( data.yPanelVolts , stimulus.panelParams );
end

   % Save FicTrac angular Position signal from DAQ/Virtual Machine
   ficTracPosIndex = find( settings.bob.inChannelsUsed == settings.bob.ficTracAngularPosition); % get index
   ficTracIntxIndex = find( settings.bob.inChannelsUsed == settings.bob.ficTracIntx); % get index
   ficTracIntyIndex = find( settings.bob.inChannelsUsed == settings.bob.ficTracInty); % get index
   
   % if not closed loop trial this array might be empty/flat line, but that is fine
   data.ficTracAngularPosition = rawData ( : , ficTracPosIndex);
   data.ficTracIntx = rawData ( : , ficTracIntxIndex);
   data.ficTracInty = rawData ( : , ficTracIntyIndex);

%% Only if saving data
if nargin ~= 0
    % Get filename and save trial data
    [fileName, path, trialMeta.trialNum] = getDataFileName( exptInfo );
    fprintf(['\nTrial Number ', num2str( trialMeta.trialNum )])
    
    if ~isdir(path)
        mkdir(path);
    end
    
    % save data, stimlulus command, and other info
     save(fileName, 'data','trialMeta','stimulus','exptInfo');
     
     disp( ['.... Trial # ' num2str( trialMeta.trialNum )   ' was Saved!'] );
end

%% Close daq object
niOI.stop 
 
%% If there was a movie aquired then: %% Copy movies into trial folder within tmp video aqu.
 if ( isfield( stimulus, 'cameraTrigger') )
      copyFramesToTrialFolder( exptInfo, trialMeta );
 end
%% Plot data
plotTrialData( data, stimulus, settings ); % plot the trial that was just aquired for the user to sre

% plotInputResistance(figNum) % todo write this code eventually -yf
% TODO eventually...Calculate Ri based on the pulse at the end of the trace

%% chrimson stimulution plasticity experiments plot current IPSP amplitude
% on probe trials
PROBE_STRING = 'probeTrial';
% check if stim names long enough
if( length(stimulus.name) >= length( PROBE_STRING) )
    stimName = stimulus.name(1: length( PROBE_STRING) );
    % check if we are on a probe trial
    if( strcmp( stimName ,  PROBE_STRING) )
        
        if( strcmp(trialMeta.mode, 'I-Clamp Normal'))
            %Current clamp plotting version
            plotIPSPAmp_inputRes( data, stimulus, trialMeta, 2);
        elseif( strcmp(trialMeta.mode, 'V-Clamp'))
            % Voltage clamp plotting version
            plotIPSCAmplitude_VClamp( data, stimulus, trialMeta, 3);
        end
    end
end

% check if random string
RAND_STRING = 'RandLoc';
% check if stim names long enough
if( length(stimulus.name) >= length( RAND_STRING ) )
    stimName = stimulus.name;
    if( strfind( stimName ,  RAND_STRING) ~= 0 )
        plotBarRandLoc_duringExperiment;
    end
end


%%
% % make it so that the code pauses so I can look at the figure of data, but
% % only if we are NOT doing a the seal test where the stim is named No Stimulus
 if (~strcmp (stimulus.name, 'No Stimulus'))
    
keyboard;
 end

end

