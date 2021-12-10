function [] = visualStimulus_v13( exptInfo, preExptData )
%VISUALSTIMULUS_V13 function that runs the Panel visual display system and also some current injection
%stimuli as well if needed
%   within the function the user will be given the option to run multiple
%   trials the contain different current injection or visual display protocols
%
% Updated version of visualStimulus code that is compatable with Patterns
% and position functions written after 7/2017 for the panel contoller
% system running v1.3
%
% Yvette Fisher 8/2017, updated often 4/2018 most recently


% Figure out if we are in I-Clamp or V-clamp from the amplifier/NiDaq
% this is important to make sure the test (i or v) pulse is the correct amplitude
currentClampBool = getRecordingMode;

% [~, dirPath, ~, ~] = getDataFileName(exptInfo);
ephysSettings;
% Ask user if we are aquiring a video of the fly for this experiment
[videoRecordingBool , movieDirectoryGroupedVideo] = setUpVideoAquisition( settings.rawVidDir , exptInfo );

while 1
    ephysSettings;
    GETSTIMULUSNAME = true;
    while(GETSTIMULUSNAME)
        
        prompt = ['Which stimulus would you like to run? Options: q, constantCurrent(InjAmp), closedLoop_vertStripeON(dur),closedLoop_1pixeldotON(dur),closedLoop_4pixelVertStripeON(dur),'...
            ' \n  closedLoop_2bars_90deg(dur),closedLoop_2bars_180deg(dur), closedLoop_3bars_120deg(dur), closedLoop_dotAndBar_270(dur), closedLoop_vertStripeON_270_middle90Blank(dur), closedLoop_vertStripeON_270_right90Blank'...
            ' \n  closedLoop_vertStripeON_270world(dur,patt Num: 14-16),closedLoop_vertStripeOFF_270world_phase1(dur),closedLoop_Ofstad( dur , patt Num: 26-28 ) closedLoop_complexWorld(dur,29-31), closedLoop_2bars_135deg_270world(dur,patt Num: 45-47);'...
            ' \n  closedLoop_complexScene(dur,32-34), closedLoop_invertedGain_270world(dur), closedLoop_2bars_90deg_270world(dur)'...
            ' \n  closedLoop_starField(),closedLoop_starField_invertedBar(),closedLoop_structuredStarField_invertedBar()'...
            ' \n  closedLoop_stripeLowContrast_270(dur, contrast = 1vs2,1vs4,6vs7)closedLoop_stripeLowContrast_270Inverted(dur, contrast = 1vs2,1vs4,6vs7)' ...
            ' \n  dotRandLocONIpsi(), dotONLocalSearch(xpos_offset), dotRandLocON(),'...
            ' \n  dotRandHorizLocON(ele_Y), dotRandHorizLoc4pixelON( elevation_Y ), barRandLocON_8locs()'...
            ' \n  barRandLocON(),barRandLocOFF(),barRandLocON270(contrast=6vs7, 1vs2, 1vs4),complexWorldRandLocON270(),ofstadRandLocON270(),distractBarRand_FAST( ),'...
            ' \n  barRandLocON_1pixel(), barRandLocON_4pixel(), movingGrating_4pixel_15degS(dur), movingGrating_4pixel_50degS(dur)' ...
            ' \n  flashStripeON_2s(offset), flashStripeON_500ms(offset), flashStripeON_10s_1s(offset)'...
            ' \n  flashStripeON4pixel_2s(offset) flashStripeON4pixel_500ms(offset) , FFF2s(), FFF500ms(), staticStripeOn(barPos,dur_s)' ...
            ' \n  movingRightStripeON(),movingRightStripeON_flexibleDur(dur), movingRightStripeON_10mins(), movingRightStripeON_15ds(dur).50.150.300.450.movingRightStripeON_600ds(dur, contrast=6vs7,1vs2,1vs4 or high), movingRightStripeON_4pixel(), movingLeftStripeON(offset),' ...
            ' \n  movingRightStripeON_8mins_dark61to250sec(),movingRightStripeON_8mins(),movingRightStripeON_8mins_dark0to240sec()'...
            ' \n  movingRightDotON(ele),movingRightDot_Opto(ele_Y,stimDur,interStimDur), movingRightDotON_flexDur(ele_Y, dur),movingLeftDotON_flexDur(ele_Y, dur),movingRightDot4pixelON(ele),movingLeftDotON(ele), movingLeftDot4pixelON(ele),movingRight2Bar_currInjWithOpto(X_loc, injAmp)'...
            ' \n  movingRightStripe_currentInj( X_loc,inj_amp), movingRightStripe_currInjWithOpto(Xloc, amp),controlForMovingStripe_currInjWithOpto(X_loc,inj_amp), movingRightStripe4pixel_currentInj(X_loc,inj_amp) '...
            ' \n  movingTopAndBottomDot2Swings(),movingTopAndMiddleDot(), movingTopAndBottomDot(), movingRightDotON_topAndBottom(),movingRightDotON_topAndMiddle(), movingRightDotON_currentInj( ele_Y ,X_loc,inj_amp), movingRightDot4pixelON_currentInj( ele_Y ,X_loc,inj_amp),'...
            ' \n  flashStripeON_500msON_5sOFF_currInj(offset,amp), flashStripe500msON_2Loc60deg_1stLocInjPaired(offset,amp),flashStripeON_300msON_300msOFF_currInj(offset,inj ),'...
            ' \n  flashStripeON_300msON_300msOFF_chrinmsonStim( xpos_offset ), flashStripeON_300msON_300msOFF_chStimAndCurrInj(offset,inj)'...
            ' \n chrStim( dur ), stimLoop(dur, reps), movingRightStripe_Opto5ms_1secIPD(), movingRightStripe_Opto10ms_2secIPD(), movingRightStripe_Opto( stimDur, interStimDur), movingRight_2Stripes_Opto( )'...
            ' \n optoOnly5ms_1secIPD(), optoOnly10ms_2secIPD(), optoOnly( stimDur, interStimDur) ,'...   
            '\n probeTrial(dur,reps), probeCurrInj(dur, amp, reps),probeTrial_deCorrInject(dur,amp,reps), '...
            '\n stimTrain(dur,interStimDur,reps), currInjectTrain(dur,interStimDur,amp,reps), stimTrain_corrInject(dur,interStimDur,amp,reps), stimTrain_injectWholeTrial '...
            '\n step(amp_pA,dur_s), stepRamp(min,max), stepLoop(amp_pA,dur_s,reps), IVcurve(injAmp)'...
            '\n intialShutter_stimTrain_corrInject(intialStimDur,dur,interStimDur,amp,reps),'...
            '\n , n=exit: '];
        % Ask user for stimulus command to run
        choosenStimulus = input( prompt, 's');
        
        try
            % evaluate stimulus contruction code and obtain the current command wave form to be used.
            outCommand = eval(choosenStimulus);
            GETSTIMULUSNAME = false; % If eval ran without breaking, exit this loop and continue on with the rest of the code
        catch
            if(choosenStimulus == 'n'); break; end % exit this loop if 'n' was entered and user wants to quit...
            
            disp('ERROR: there is a problem with the stimulus command you entered, please try to enter it again :)  ');
        end
    end
    
    % break out of code if 'n' was entered and user wants to quit...
    if(choosenStimulus == 'n')
        %If video files were aquired: zip and save them into the data
        %directory
         if ( videoRecordingBool )
             %moveGroupedVideosToDataDirectory( exptInfo );
             zipVideoDirectoryFolder( exptInfo, movieDirectoryGroupedVideo ); % zipped whole video folder with trials inside
         end
        break;
    end % exit whole set of code
    
    %add spacer with access test pulse and save this information into
    %stimlulus
    stimulus = addAccessStepPeriod(outCommand , currentClampBool);
    
    % Also store information about the stimlulus name and waveform
    stimulus.name = choosenStimulus;
    
    if( videoRecordingBool ) % check if camera recording will be preformed
        % Create array containing the trigger for the camera to aquire frames
        stimulus.cameraTrigger = createCameraTrigger( stimulus );
    end
    
    % plot command, and Trigger signal that are in stimulus
    plotCommandSignals( stimulus );
    
    % aquire a trial, YVETTE: add more input/output arguments
    [data] = acquireTrial(stimulus, exptInfo, preExptData);
end
end

%% Visual Stimulus functions
% out must be a struct with at least on field called 'command' !!!
%% q
function [out] = q( )
% quick function that records for 15 seconds
    ephysSettings;
    TRIAL_DURATION = 15; %seconds  % trial duration
    fprintf('Running the no injection 15 second function');
    out.command  = zeros(1,TRIAL_DURATION*settings.sampRate);
end
%% constantCurrent
function [out] = constantCurrent(InjAmp)
% quick function that records in I-Clamp for 60 seconds no visual stimuli
    ephysSettings;
    % trial duration
    TRIAL_DURATION = 60; %seconds
    fprintf('Running constant injection for 60 second function');

    injectionCommand = InjAmp * ones(1,TRIAL_DURATION*settings.sampRate);
    out.command = injectionCommand * settings.daq.currentConversionFactor; % send full command out, in Voltage for the daq to send
end

%% basicCurrentClamp
function [out] = basicCurrentClamp(duration)
% quick function that records in I-Clamp for duration set by user
    ephysSettings;
    % trial duration
    TRIAL_DURATION = duration; %seconds

    injectionCommand = zeros(1,TRIAL_DURATION*settings.sampRate);
    out.command = injectionCommand * settings.daq.currentConversionFactor; % send full command out, in Voltage for the daq to send
end

%% closedLoop_vertStripeON
function [out ] = closedLoop_vertStripeON( dur )
ephysSettings;
TOTAL_DURATION = dur; % seconds 
% Panel trigger digital signal
out.visualTriggerCommand = buildVisualVoltageTrigger( TOTAL_DURATION );

% Build PANEL parameters
panelParams.patternNum = 3;
 panelParams.positionFuncNumX = 12;% moving 15 deg right
 panelParams.positionFuncNumY = 8;% static
 
panelParams.initialPosition = [ 96, 0]; % [ X, Y ]
 
% store parameter values
out.panelParams = panelParams;
% tell system closed loop setting in use
out.closedLoop = true;

% no current command
out.command = zeros(1, TOTAL_DURATION * settings.sampRate) * settings.daq.currentConversionFactor ; % send full command out, in Voltage for the daq to send
end



%% closedLoop_vertStripeON_270_middle90Blank
function [out ] = closedLoop_vertStripeON_270_middle90Blank( dur )
ephysSettings;
TOTAL_DURATION = dur; % seconds 
% Panel trigger digital signal
out.visualTriggerCommand = buildVisualVoltageTrigger( TOTAL_DURATION );

% Build PANEL parameters
panelParams.patternNum = 18;
 panelParams.positionFuncNumX = 12;% moving 15 deg right
 panelParams.positionFuncNumY = 8;% static
 
panelParams.initialPosition = [ 0, 0]; % [ X, Y ]
 
% store parameter values
out.panelParams = panelParams;
% tell system closed loop setting in use
out.closedLoop = true;

% no current command
out.command = zeros(1, TOTAL_DURATION * settings.sampRate) * settings.daq.currentConversionFactor ; % send full command out, in Voltage for the daq to send
end

%% closedLoop_vertStripeON_270_right90Blank
function [out ] = closedLoop_vertStripeON_270_right90Blank( dur )
ephysSettings;
TOTAL_DURATION = dur; % seconds 
% Panel trigger digital signal
out.visualTriggerCommand = buildVisualVoltageTrigger( TOTAL_DURATION );

% Build PANEL parameters
panelParams.patternNum = 19;
 panelParams.positionFuncNumX = 12;% moving 15 deg right
 panelParams.positionFuncNumY = 8;% static
 
panelParams.initialPosition = [ 0, 0]; % [ X, Y ]
 
% store parameter values
out.panelParams = panelParams;
% tell system closed loop setting in use
out.closedLoop = true;

% no current command
out.command = zeros(1, TOTAL_DURATION * settings.sampRate) * settings.daq.currentConversionFactor ; % send full command out, in Voltage for the daq to send
end


%% closedLoop_4pixelVertStripeON
function [out ] = closedLoop_4pixelVertStripeON( dur )
ephysSettings;
TOTAL_DURATION = dur; % seconds 
% Panel trigger digital signal
out.visualTriggerCommand = buildVisualVoltageTrigger( TOTAL_DURATION );

% Build PANEL parameters
panelParams.patternNum = 5;
 panelParams.positionFuncNumX = 12;% moving 15 deg right
 panelParams.positionFuncNumY = 8;% static
panelParams.initialPosition = [ 96, 0]; % [ X, Y ]

% store parameter values
out.panelParams = panelParams;
% tell system closed loop setting in use
out.closedLoop = true;

% no current command
out.command = zeros(1, TOTAL_DURATION * settings.sampRate) * settings.daq.currentConversionFactor ; % send full command out, in Voltage for the daq to send
end


%% closedLoop_2bars_90deg
function [out ] = closedLoop_2bars_90deg( dur )
ephysSettings;
TOTAL_DURATION = dur; % seconds 
% Panel trigger digital signal
out.visualTriggerCommand = buildVisualVoltageTrigger( TOTAL_DURATION );

% Build PANEL parameters
panelParams.patternNum = 9;
 panelParams.positionFuncNumX = 12;% moving 15 deg right
 panelParams.positionFuncNumY = 8;% static
panelParams.initialPosition = [ 96, 0]; % [ X, Y ]

% store parameter values
out.panelParams = panelParams;
% tell system closed loop setting in use
out.closedLoop = true;

% no current command
out.command = zeros(1, TOTAL_DURATION * settings.sampRate) * settings.daq.currentConversionFactor ; % send full command out, in Voltage for the daq to send
end

%% closedLoop_2bars_180deg
function [out ] = closedLoop_2bars_180deg( dur )
ephysSettings;
TOTAL_DURATION = dur; % seconds 
% Panel trigger digital signal
out.visualTriggerCommand = buildVisualVoltageTrigger( TOTAL_DURATION );

% Build PANEL parameters
panelParams.patternNum = 10;
 panelParams.positionFuncNumX = 12;% moving 15 deg right
 panelParams.positionFuncNumY = 8;% static
panelParams.initialPosition = [ 96, 0]; % [ X, Y ]

% store parameter values
out.panelParams = panelParams;
% tell system closed loop setting in use
out.closedLoop = true;

% no current command
out.command = zeros(1, TOTAL_DURATION * settings.sampRate) * settings.daq.currentConversionFactor ; % send full command out, in Voltage for the daq to send
end

%% closedLoop_3bars_120
function [out ] = closedLoop_3bars_120deg( dur )
ephysSettings;
TOTAL_DURATION = dur; % seconds 
% Panel trigger digital signal
out.visualTriggerCommand = buildVisualVoltageTrigger( TOTAL_DURATION );

% Build PANEL parameters
panelParams.patternNum = 13;
 panelParams.positionFuncNumX = 12;% moving 15 deg right
 panelParams.positionFuncNumY = 8;% static
panelParams.initialPosition = [ 96, 0]; % [ X, Y ]

% store parameter values
out.panelParams = panelParams;
% tell system closed loop setting in use
out.closedLoop = true;

% no current command
out.command = zeros(1, TOTAL_DURATION * settings.sampRate) * settings.daq.currentConversionFactor ; % send full command out, in Voltage for the daq to send
end

%% closedLoop_dotAndBar_270
function [out ] = closedLoop_dotAndBar_270( dur )
ephysSettings;
TOTAL_DURATION = dur; % seconds 
% Panel trigger digital signal
out.visualTriggerCommand = buildVisualVoltageTrigger( TOTAL_DURATION );

% Build PANEL parameters
panelParams.patternNum = 20;
 panelParams.positionFuncNumX = 12;% moving 15 deg right
 panelParams.positionFuncNumY = 8;% static
panelParams.initialPosition = [ 72, 0]; % [ X, Y ]

% store parameter values
out.panelParams = panelParams;
% tell system closed loop setting in use
out.closedLoop = true;

% no current command
out.command = zeros(1, TOTAL_DURATION * settings.sampRate) * settings.daq.currentConversionFactor ; % send full command out, in Voltage for the daq to send
end

%% closedLoop_vertStripeON_270world
function [out ] = closedLoop_vertStripeON_270world( dur , patternNum )
ephysSettings;
TOTAL_DURATION = dur; % seconds 
% Panel trigger digital signal
out.visualTriggerCommand = buildVisualVoltageTrigger( TOTAL_DURATION );

% Build PANEL parameters
%panelParams.patternNum = 14;
panelParams.patternNum = patternNum; %currently 14, 15 or 16

panelParams.positionFuncNumX = 12;% moving 15 deg right
panelParams.positionFuncNumY = 8;% static
panelParams.initialPosition = [ 72, 0]; % [ X, Y ]

% store parameter values
out.panelParams = panelParams;
% tell system closed loop setting in use
out.closedLoop = true;

% no current command
out.command = zeros(1, TOTAL_DURATION * settings.sampRate) * settings.daq.currentConversionFactor ; % send full command out, in Voltage for the daq to send
end

%% closedLoop_2bars_135deg_270world
function [out ] = closedLoop_2bars_135deg_270world( dur , patternNum )
ephysSettings;
TOTAL_DURATION = dur; % seconds 
% Panel trigger digital signal
out.visualTriggerCommand = buildVisualVoltageTrigger( TOTAL_DURATION );

% Build PANEL parameters
panelParams.patternNum = patternNum; %currently 45, 46 or 47
panelParams.positionFuncNumX = 12;% moving 15 deg right
panelParams.positionFuncNumY = 8;% static
panelParams.initialPosition = [ 72, 0]; % [ X, Y ]

% store parameter values
out.panelParams = panelParams;
% tell system closed loop setting in use
out.closedLoop = true;

% no current command
out.command = zeros(1, TOTAL_DURATION * settings.sampRate) * settings.daq.currentConversionFactor ; % send full command out, in Voltage for the daq to send
end

%% closedLoop_1pixeldotON_270
function [out ] = closedLoop_1pixeldotON_270( dur )
ephysSettings;
TOTAL_DURATION = dur; % seconds 
% Panel trigger digital signal
out.visualTriggerCommand = buildVisualVoltageTrigger( TOTAL_DURATION );
% Build PANEL parameters
panelParams.patternNum = 40; 

panelParams.positionFuncNumX = 12;% moving 15 deg right
panelParams.positionFuncNumY = 8;% static
panelParams.initialPosition = [ 72, 0]; % [ X, Y ]

% store parameter values
out.panelParams = panelParams;
% tell system closed loop setting in use
out.closedLoop = true;

% no current command
out.command = zeros(1, TOTAL_DURATION * settings.sampRate) * settings.daq.currentConversionFactor ; % send full command out, in Voltage for the daq to send
end

%% closedLoop_stripeLowContrast_270
function [out ] = closedLoop_stripeLowContrast_270( dur , contrast)
ephysSettings;
TOTAL_DURATION = dur; % seconds 
out.visualTriggerCommand = buildVisualVoltageTrigger( TOTAL_DURATION );% Panel trigger digital signal 

% Build PANEL parameters
if strcmp(contrast, '1vs4')
    panelParams.patternNum = 38;
elseif strcmp(contrast, '1vs2')
    panelParams.patternNum = 37;
elseif strcmp(contrast, '6vs7')
    panelParams.patternNum = 44;
else
    warning('Warning: contrast input does not match expected strings, defaulted to 1vs4 contrast');
    panelParams.patternNum = 38;
end

panelParams.positionFuncNumX = 12;% moving 15 deg right
panelParams.positionFuncNumY = 8;% static
panelParams.initialPosition = [ 72, 0]; % [ X, Y ]
% store parameter values
out.panelParams = panelParams;
% tell system closed loop setting in use
out.closedLoop = true;
% no current command
out.command = zeros(1, TOTAL_DURATION * settings.sampRate) * settings.daq.currentConversionFactor ; % send full command out, in Voltage for the daq to send
end

%% closedLoop_stripeLowContrast_270Inverted
function [out ] = closedLoop_stripeLowContrast_270Inverted( dur , contrast)
ephysSettings;
TOTAL_DURATION = dur; % seconds 
out.visualTriggerCommand = buildVisualVoltageTrigger( TOTAL_DURATION );% Panel trigger digital signal 

% Build PANEL parameters
if strcmp(contrast, '1vs4')
    panelParams.patternNum = 42;
elseif strcmp(contrast, '1vs2')
    panelParams.patternNum = 41;
elseif strcmp(contrast, '6vs7')
    panelParams.patternNum = 43;
else
    warning('Warning: contrast input does not match expected strings, defaulted to 1vs4 contrast');
    panelParams.patternNum = 42;
end

panelParams.positionFuncNumX = 12;% moving 15 deg right
panelParams.positionFuncNumY = 8;% static
panelParams.initialPosition = [ 72, 0]; % [ X, Y ]
% store parameter values
out.panelParams = panelParams;
% tell system closed loop setting in use
out.closedLoop = true;
% no current command
out.command = zeros(1, TOTAL_DURATION * settings.sampRate) * settings.daq.currentConversionFactor ; % send full command out, in Voltage for the daq to send
end

%% closedLoop_vertStripeOFF_270world_phase1
function [out ] = closedLoop_vertStripeOFF_270world_phase1( dur )
ephysSettings;
TOTAL_DURATION = dur; % seconds 
% Panel trigger digital signal
out.visualTriggerCommand = buildVisualVoltageTrigger( TOTAL_DURATION );

% Build PANEL parameters
%panelParams.patternNum = 14;
panelParams.patternNum = 25; %

panelParams.positionFuncNumX = 12;% moving 15 deg right
panelParams.positionFuncNumY = 8;% static
panelParams.initialPosition = [ 72, 0]; % [ X, Y ]

% store parameter values
out.panelParams = panelParams;
% tell system closed loop setting in use
out.closedLoop = true;

% no current command
out.command = zeros(1, TOTAL_DURATION * settings.sampRate) * settings.daq.currentConversionFactor ; % send full command out, in Voltage for the daq to send
end

%% closedLoop_Ofstad
function [out ] = closedLoop_Ofstad( dur , patternNum )
ephysSettings;
TOTAL_DURATION = dur; % seconds 
% Panel trigger digital signal
out.visualTriggerCommand = buildVisualVoltageTrigger( TOTAL_DURATION );

% Build PANEL parameters
%panelParams.patternNum = 14;
panelParams.patternNum = patternNum; %currently 26, 27 or 28

panelParams.positionFuncNumX = 12;% moving 15 deg right
panelParams.positionFuncNumY = 8;% static
panelParams.initialPosition = [ 72, 0]; % [ X, Y ]

% store parameter values
out.panelParams = panelParams;
% tell system closed loop setting in use
out.closedLoop = true;

% no current command
out.command = zeros(1, TOTAL_DURATION * settings.sampRate) * settings.daq.currentConversionFactor ; % send full command out, in Voltage for the daq to send
end

%% closedLoop_complexWorld
function [out ] = closedLoop_complexWorld( dur , patternNum )
ephysSettings;
TOTAL_DURATION = dur; % seconds 
% Panel trigger digital signal
out.visualTriggerCommand = buildVisualVoltageTrigger( TOTAL_DURATION );

% Build PANEL parameters
panelParams.patternNum = patternNum; %currently 29, 30, 31

panelParams.positionFuncNumX = 12;% moving 15 deg right
panelParams.positionFuncNumY = 8;% static
panelParams.initialPosition = [ 72, 0]; % [ X, Y ]

% store parameter values
out.panelParams = panelParams;
% tell system closed loop setting in use
out.closedLoop = true;

% no current command
out.command = zeros(1, TOTAL_DURATION * settings.sampRate) * settings.daq.currentConversionFactor ; % send full command out, in Voltage for the daq to send
end

%% closedLoop_complexScene
function [out ] = closedLoop_complexScene( dur , patternNum )
ephysSettings;
TOTAL_DURATION = dur; % seconds 
% Panel trigger digital signal
out.visualTriggerCommand = buildVisualVoltageTrigger( TOTAL_DURATION );

% Build PANEL parameters
panelParams.patternNum = patternNum; %currently 32, 33, 34

panelParams.positionFuncNumX = 12;% moving 15 deg right
panelParams.positionFuncNumY = 8;% static
panelParams.initialPosition = [ 72, 0]; % [ X, Y ]

% store parameter values
out.panelParams = panelParams;
% tell system closed loop setting in use
out.closedLoop = true;

% no current command
out.command = zeros(1, TOTAL_DURATION * settings.sampRate) * settings.daq.currentConversionFactor ; % send full command out, in Voltage for the daq to send
end

%% closedLoop_starField
function [out ] = closedLoop_starField( dur )
ephysSettings;
TOTAL_DURATION = dur; % seconds 
% Panel trigger digital signal
out.visualTriggerCommand = buildVisualVoltageTrigger( TOTAL_DURATION );

% Build PANEL parameters
panelParams.patternNum = 35; %

panelParams.positionFuncNumX = 12;% moving 15 deg right
panelParams.positionFuncNumY = 8;% static
panelParams.initialPosition = [ 72, 0]; % [ X, Y ]

% store parameter values
out.panelParams = panelParams;
% tell system closed loop setting in use
out.closedLoop = true;

% no current command
out.command = zeros(1, TOTAL_DURATION * settings.sampRate) * settings.daq.currentConversionFactor ; % send full command out, in Voltage for the daq to send
end

%% closedLoop_starField_invertedBar
function [out ] = closedLoop_starField_invertedBar( dur )
ephysSettings;
TOTAL_DURATION = dur; % seconds 
% Panel trigger digital signal
out.visualTriggerCommand = buildVisualVoltageTrigger( TOTAL_DURATION );

% Build PANEL parameters
panelParams.patternNum = 36; %

panelParams.positionFuncNumX = 12;% moving 15 deg right
panelParams.positionFuncNumY = 8;% static
panelParams.initialPosition = [ 72, 0]; % [ X, Y ]

% store parameter values
out.panelParams = panelParams;
% tell system closed loop setting in use
out.closedLoop = true;

% no current command
out.command = zeros(1, TOTAL_DURATION * settings.sampRate) * settings.daq.currentConversionFactor ; % send full command out, in Voltage for the daq to send
end

%% closedLoop_structuredStarField_invertedBar
function [out ] = closedLoop_structuredStarField_invertedBar( dur )
ephysSettings;
TOTAL_DURATION = dur; % seconds 
% Panel trigger digital signal
out.visualTriggerCommand = buildVisualVoltageTrigger( TOTAL_DURATION );

% Build PANEL parameters
panelParams.patternNum = 39; %

panelParams.positionFuncNumX = 12;% moving 15 deg right
panelParams.positionFuncNumY = 8;% static
panelParams.initialPosition = [ 72, 0]; % [ X, Y ]

% store parameter values
out.panelParams = panelParams;
% tell system closed loop setting in use
out.closedLoop = true;

% no current command
out.command = zeros(1, TOTAL_DURATION * settings.sampRate) * settings.daq.currentConversionFactor ; % send full command out, in Voltage for the daq to send
end

%% closedLoop_invertedGain_270world
function [out ] = closedLoop_invertedGain_270world( dur )
ephysSettings;
TOTAL_DURATION = dur; % seconds 

% Panel trigger digital signal
out.visualTriggerCommand = buildVisualVoltageTrigger( TOTAL_DURATION );

% Build PANEL parameters
panelParams.patternNum = 23;

panelParams.positionFuncNumX = 12;% moving 15 deg right
panelParams.positionFuncNumY = 8;% static
panelParams.initialPosition = [ 72, 0]; % [ X, Y ]

% store parameter values
out.panelParams = panelParams;
% tell system closed loop setting in use
out.closedLoop = true;

% no current command
out.command = zeros(1, TOTAL_DURATION * settings.sampRate) * settings.daq.currentConversionFactor ; % send full command out, in Voltage for the daq to send
end

%% closedLoop_2bars_90deg_270world
function [out ] = closedLoop_2bars_90deg_270world( dur )
ephysSettings;
TOTAL_DURATION = dur; % seconds 
% Panel trigger digital signal
out.visualTriggerCommand = buildVisualVoltageTrigger( TOTAL_DURATION );

% Build PANEL parameters
panelParams.patternNum = 17;
 panelParams.positionFuncNumX = 12;% moving 15 deg right
 panelParams.positionFuncNumY = 8;% static
panelParams.initialPosition = [ 72, 0]; % [ X, Y ]

% store parameter values
out.panelParams = panelParams;
% tell system closed loop setting in use
out.closedLoop = true;

% no current command
out.command = zeros(1, TOTAL_DURATION * settings.sampRate) * settings.daq.currentConversionFactor ; % send full command out, in Voltage for the daq to send
end
%% dotRandLocONIpsi
function [out ] = dotRandLocONIpsi( )
ephysSettings;
TOTAL_DURATION = 150; % seconds  140 sec for 1 round 
% Panel trigger digital signal
out.visualTriggerCommand = buildVisualVoltageTrigger( TOTAL_DURATION );

% Build PANEL parameters
panelParams.patternNum = 1;
panelParams.positionFuncNumX = 1;
panelParams.positionFuncNumY = 2;
% store parameter values
out.panelParams = panelParams;

% no current command
out.command = zeros(1, TOTAL_DURATION * settings.sampRate) * settings.daq.currentConversionFactor ; % send full command out, in Voltage for the daq to send
end

%% dotONLocalSearch ( xpos_offset )
function [out ] = dotONLocalSearch( xpos_offset )
ephysSettings;
TOTAL_DURATION = 200; % seconds  35 sec for 1 round X 5 = 175
% Panel trigger digital signal
out.visualTriggerCommand = buildVisualVoltageTrigger( TOTAL_DURATION );

% Build PANEL parameters
panelParams.patternNum = 1;
panelParams.positionFuncNumX = 3;
panelParams.positionFuncNumY = 4;
panelParams.initialPosition = [ xpos_offset, 0]; % [ X, Y ]

% store parameter values
out.panelParams = panelParams;

% no current command
out.command = zeros(1, TOTAL_DURATION * settings.sampRate) * settings.daq.currentConversionFactor ; % send full command out, in Voltage for the daq to send
end
%% dotRandLocON
function [out ] = dotRandLocON( )
ephysSettings;
TOTAL_DURATION = 200; % seconds  196 sec for 1 round 
% Panel trigger digital signal
out.visualTriggerCommand = buildVisualVoltageTrigger( TOTAL_DURATION );

% Build PANEL parameters
panelParams.patternNum = 1;
panelParams.positionFuncNumX = 5;
panelParams.positionFuncNumY = 6;
% store parameter values
out.panelParams = panelParams;

% no current command
out.command = zeros(1, TOTAL_DURATION * settings.sampRate) * settings.daq.currentConversionFactor ; % send full command out, in Voltage for the daq to send
end
%% barRandLocON
function [out ] = barRandLocON( )
ephysSettings;
TOTAL_DURATION = 150; % seconds  36 sec for 1 round X 4 = 144 
% Panel trigger digital signal
out.visualTriggerCommand = buildVisualVoltageTrigger( TOTAL_DURATION );

% Build PANEL parameters
panelParams.patternNum = 3;
panelParams.positionFuncNumX = 7;
panelParams.positionFuncNumY = 8;% static, 0
% store parameter values
out.panelParams = panelParams;

% no current command
out.command = zeros(1, TOTAL_DURATION * settings.sampRate) * settings.daq.currentConversionFactor ; % send full command out, in Voltage for the daq to send
end

%% barRandLocON
function [out ] = barRandLocON_8locs( )
ephysSettings;
TOTAL_DURATION = 90; % ~ 10 sample of each location 
% Panel trigger digital signal
out.visualTriggerCommand = buildVisualVoltageTrigger( TOTAL_DURATION );

% Build PANEL parameters
panelParams.patternNum = 3;
panelParams.positionFuncNumX = 28;
panelParams.positionFuncNumY = 8;% static, 0
% store parameter values
out.panelParams = panelParams;

% no current command
out.command = zeros(1, TOTAL_DURATION * settings.sampRate) * settings.daq.currentConversionFactor ; % send full command out, in Voltage for the daq to send
end

%% barRandLocOFF
function [out ] = barRandLocOFF( )
ephysSettings;
TOTAL_DURATION = 150; % seconds  36 sec for 1 round X 4 = 144 
% Panel trigger digital signal
out.visualTriggerCommand = buildVisualVoltageTrigger( TOTAL_DURATION );

% Build PANEL parameters
panelParams.patternNum = 24;
panelParams.positionFuncNumX = 7;
panelParams.positionFuncNumY = 8;% static, 0
% store parameter values
out.panelParams = panelParams;

% no current command
out.command = zeros(1, TOTAL_DURATION * settings.sampRate) * settings.daq.currentConversionFactor ; % send full command out, in Voltage for the daq to send
end

%% barRandLocON270
function [out ] = barRandLocON270( contrast )
ephysSettings;
TOTAL_DURATION = 150; % seconds  36 sec for 1 round X 4 = 144
% Panel trigger digital signal
out.visualTriggerCommand = buildVisualVoltageTrigger( TOTAL_DURATION );

% Build PANEL parameters
if strcmp(contrast, '1vs4')
    panelParams.patternNum = 38;
elseif strcmp(contrast, '1vs2')
    panelParams.patternNum = 37;
elseif strcmp(contrast, '6vs7')
    panelParams.patternNum = 44;
else
    warning('Warning: contrast input does not match expected strings, defaulted to 1vs4 contrast');
    panelParams.patternNum = 38;
end

panelParams.positionFuncNumX = 16;
panelParams.positionFuncNumY = 17;% static, 0
% store parameter values
out.panelParams = panelParams;

% no current command
out.command = zeros(1, TOTAL_DURATION * settings.sampRate) * settings.daq.currentConversionFactor ; % send full command out, in Voltage for the daq to send
end

%% distractBarRand_FAST
function [out ] = distractBarRand_FAST( )
ephysSettings;
TOTAL_DURATION = 150; % seconds  36 sec for 1 round X 4 = 144 
% Panel trigger digital signal
out.visualTriggerCommand = buildVisualVoltageTrigger( TOTAL_DURATION );

% Build PANEL parameters
panelParams.patternNum = 3;
panelParams.positionFuncNumX = 19;
panelParams.positionFuncNumY = 8;% static, 0
% store parameter values
out.panelParams = panelParams;

% no current command
out.command = zeros(1, TOTAL_DURATION * settings.sampRate) * settings.daq.currentConversionFactor ; % send full command out, in Voltage for the daq to send
end
%% complexWorldRandLocON270
function [out ] = complexWorldRandLocON270( )
ephysSettings;
TOTAL_DURATION = 150; % seconds  36 sec for 1 round X 4 = 144 
% Panel trigger digital signal
out.visualTriggerCommand = buildVisualVoltageTrigger( TOTAL_DURATION );

% Build PANEL parameters
panelParams.patternNum = 29;
panelParams.positionFuncNumX = 16;
panelParams.positionFuncNumY = 17;% static, 0
% store parameter values
out.panelParams = panelParams;

% no current command
out.command = zeros(1, TOTAL_DURATION * settings.sampRate) * settings.daq.currentConversionFactor ; % send full command out, in Voltage for the daq to send
end

%% complexWorldRandLocON270
function [out ] = ofstadRandLocON270( )
ephysSettings;
TOTAL_DURATION = 150; % seconds  36 sec for 1 round X 4 = 144 
% Panel trigger digital signal
out.visualTriggerCommand = buildVisualVoltageTrigger( TOTAL_DURATION );

% Build PANEL parameters
panelParams.patternNum = 26;
panelParams.positionFuncNumX = 16;
panelParams.positionFuncNumY = 17;% static, 0
% store parameter values
out.panelParams = panelParams;

% no current command
out.command = zeros(1, TOTAL_DURATION * settings.sampRate) * settings.daq.currentConversionFactor ; % send full command out, in Voltage for the daq to send
end

%% barRandLocON_1pixel
function [out ] = barRandLocON_1pixel( )
ephysSettings;
TOTAL_DURATION = 150; % seconds  36 sec for 1 round X 4 = 144 
% Panel trigger digital signal
out.visualTriggerCommand = buildVisualVoltageTrigger( TOTAL_DURATION );

% Build PANEL parameters
panelParams.patternNum = 8;
panelParams.positionFuncNumX = 7;
panelParams.positionFuncNumY = 8;% static, 0
% store parameter values
out.panelParams = panelParams;

% no current command
out.command = zeros(1, TOTAL_DURATION * settings.sampRate) * settings.daq.currentConversionFactor ; % send full command out, in Voltage for the daq to send
end

%% barRandLocON_4pixel
function [out ] = barRandLocON_4pixel( )
ephysSettings;
TOTAL_DURATION = 150; % seconds  36 sec for 1 round X 4 = 144  
% Panel trigger digital signal
out.visualTriggerCommand = buildVisualVoltageTrigger( TOTAL_DURATION );

% Build PANEL parameters
panelParams.patternNum = 5;
panelParams.positionFuncNumX = 7;
panelParams.positionFuncNumY = 8;% static, 0
% store parameter values
out.panelParams = panelParams;

% no current command
out.command = zeros(1, TOTAL_DURATION * settings.sampRate) * settings.daq.currentConversionFactor ; % send full command out, in Voltage for the daq to send
end
%% 4pixel Grating 15 deg/s
function [out ] = movingGrating_4pixel_15degS( dur )
ephysSettings;
TOTAL_DURATION = dur; % 200; % seconds  36 sec for 1 round X 4 = 144 
% Panel trigger digital signal
out.visualTriggerCommand = buildVisualVoltageTrigger( TOTAL_DURATION );

% Build PANEL parameters
panelParams.patternNum = 12;
panelParams.positionFuncNumX = 14;
panelParams.positionFuncNumY = 8;% static, 0
% store parameter values
out.panelParams = panelParams;

% no current command
out.command = zeros(1, TOTAL_DURATION * settings.sampRate) * settings.daq.currentConversionFactor ; % send full command out, in Voltage for the daq to send
end
%% 4pixel Grating 50deg/s
function [out ] = movingGrating_4pixel_50degS( dur )
ephysSettings;
TOTAL_DURATION = dur; % 200; % seconds  36 sec for 1 round X 4 = 144 
% Panel trigger digital signal
out.visualTriggerCommand = buildVisualVoltageTrigger( TOTAL_DURATION );

% Build PANEL parameters
panelParams.patternNum = 12;
panelParams.positionFuncNumX = 15;
panelParams.positionFuncNumY = 8;% static, 0
% store parameter values
out.panelParams = panelParams;

% no current command
out.command = zeros(1, TOTAL_DURATION * settings.sampRate) * settings.daq.currentConversionFactor ; % send full command out, in Voltage for the daq to send
end
%% flashStripeON_2s( offset )
function [out ] = flashStripeON_2s( xpos_offset )
ephysSettings;
TOTAL_DURATION = 40; % seconds 
% Panel trigger digital signal
out.visualTriggerCommand = buildVisualVoltageTrigger( TOTAL_DURATION );

% Build PANEL parameters
panelParams.patternNum = 3;
panelParams.positionFuncNumX = 8;
panelParams.positionFuncNumY = 9;% 2 sec off, 2 sec on
panelParams.initialPosition = [ xpos_offset, 0]; % [ X, Y ]
% store parameter values
out.panelParams = panelParams;

% no current command
out.command = zeros(1, TOTAL_DURATION * settings.sampRate) * settings.daq.currentConversionFactor ; % send full command out, in Voltage for the daq to send
end

%% flashStripeON_500ms( offset )
function [out ] = flashStripeON_500ms( xpos_offset )
ephysSettings;
TOTAL_DURATION = 40; % seconds 
% Panel trigger digital signal
out.visualTriggerCommand = buildVisualVoltageTrigger( TOTAL_DURATION );

% Build PANEL parameters
panelParams.patternNum = 3;
panelParams.positionFuncNumX = 8;
panelParams.positionFuncNumY = 10;% 500ms off, 500msec on
panelParams.initialPosition = [ xpos_offset, 0]; % [ X, Y ]
% store parameter values
out.panelParams = panelParams;

% no current command
out.command = zeros(1, TOTAL_DURATION * settings.sampRate) * settings.daq.currentConversionFactor ; % send full command out, in Voltage for the daq to send
end

%% flashStripeON_500msON_5sOFF( offset , currentInjection )
function [out ] = flashStripeON_500msON_5sOFF_currInj( xpos_offset , inj_amp )
ephysSettings;
TOTAL_DURATION = 60; % seconds 
TRIGGER_DELAY = 7.6 / 1000;% 7.6 ms is ave delay, pretty consistent across trials!
% Panel trigger digital signal
out.visualTriggerCommand = buildVisualVoltageTrigger( TOTAL_DURATION );

% Build PANEL parameters
panelParams.patternNum = 3;
panelParams.positionFuncNumX = 8;
panelParams.positionFuncNumY = 25;% 4500ms off, 500msec on
panelParams.initialPosition = [ xpos_offset, 0]; % [ X, Y ]
% store parameter values
out.panelParams = panelParams;

%build current command to align in time with when the bar is flashed
PATTERN_FLASH_DURATION = 0.5; % seconds
INTER_FLASH_DURATION = 4.5; % seconds
currentCommand = zeros(1, TOTAL_DURATION * settings.sampRate);

% injection timing
injectStartTime = TRIGGER_DELAY + INTER_FLASH_DURATION;
injectEndTime = TRIGGER_DELAY + INTER_FLASH_DURATION + PATTERN_FLASH_DURATION;

stimulusPeriod = PATTERN_FLASH_DURATION + INTER_FLASH_DURATION;

while ( injectEndTime <= TOTAL_DURATION )
    injectStartFrame = injectStartTime * settings.sampRate;
    injectEndFrame = injectEndTime * settings.sampRate;
    
    if(injectStartFrame < 0) % check if injectStartFrame is negative which will not work
    injectStartFrame = 1; % if the X location is too early in the pattern, this will shorten the inj period for this first stimulus, but not the later ones. 
    end
    
    currentCommand ( injectStartFrame : injectEndFrame) = 1;
    injectStartTime = injectStartTime + stimulusPeriod;
    injectEndTime = injectEndTime + stimulusPeriod;
end

% scale current command by wanted amplitude of injection
currentCommand = inj_amp *  currentCommand ;

% build current command in correct units
out.command = currentCommand * settings.daq.currentConversionFactor ; % send full command out, in Voltage for the daq to send
end

%% flashStripeON_300msON_300msOFF_currInj( offset , currentInjection )
function [out ] = flashStripeON_300msON_300msOFF_currInj( xpos_offset , inj_amp )
ephysSettings;
TOTAL_DURATION = 60; % seconds 
TRIGGER_DELAY = 7.6 / 1000;% 7.6 ms is ave delay, pretty consistent across trials!
% Panel trigger digital signal
out.visualTriggerCommand = buildVisualVoltageTrigger( TOTAL_DURATION );

% Build PANEL parameters
panelParams.patternNum = 3;
panelParams.positionFuncNumX = 8;
panelParams.positionFuncNumY = 29;% 300ms off, 300msec on
panelParams.initialPosition = [ xpos_offset, 0]; % [ X, Y ]
% store parameter values
out.panelParams = panelParams;

%build current command to align in time with when the bar is flashed
PATTERN_FLASH_DURATION = 0.3; % seconds
INTER_FLASH_DURATION = 0.3; % seconds
currentCommand = zeros(1, TOTAL_DURATION * settings.sampRate);

% injection timing
injectStartTime = TRIGGER_DELAY + INTER_FLASH_DURATION;
injectEndTime = TRIGGER_DELAY + INTER_FLASH_DURATION + PATTERN_FLASH_DURATION;

stimulusPeriod = PATTERN_FLASH_DURATION + INTER_FLASH_DURATION;

while ( injectEndTime <= TOTAL_DURATION )
    injectStartFrame = injectStartTime * settings.sampRate;
    injectEndFrame = injectEndTime * settings.sampRate;
    
    if(injectStartFrame < 0) % check if injectStartFrame is negative which will not work
    injectStartFrame = 1; % if the X location is too early in the pattern, this will shorten the inj period for this first stimulus, but not the later ones. 
    end
    
    currentCommand ( round( injectStartFrame) : round( injectEndFrame) ) = 1;
    injectStartTime = injectStartTime + stimulusPeriod;
    injectEndTime = injectEndTime + stimulusPeriod;
end

% scale current command by wanted amplitude of injection
currentCommand = inj_amp *  currentCommand ;

% build current command in correct units
out.command = currentCommand * settings.daq.currentConversionFactor ; % send full command out, in Voltage for the daq to send
end


%% flashStripeON_300msON_300msOFF_chrimsonStim( offset )
function [out ] = flashStripeON_300msON_300msOFF_chrimsonStim( xpos_offset )
ephysSettings;
TOTAL_DURATION = 60; % seconds 
TRIGGER_DELAY = 7.6 / 1000;% 7.6 ms is ave delay, pretty consistent across trials!
% Panel trigger digital signal
out.visualTriggerCommand = buildVisualVoltageTrigger( TOTAL_DURATION );

% Build PANEL parameters
panelParams.patternNum = 3;
panelParams.positionFuncNumX = 8;
panelParams.positionFuncNumY = 29;% 300ms off, 300msec on
panelParams.initialPosition = [ xpos_offset, 0]; % [ X, Y ]
% store parameter values
out.panelParams = panelParams;

%build current command to align in time with when the bar is flashed
PATTERN_FLASH_DURATION = 0.3; % seconds
INTER_FLASH_DURATION = 0.3; % seconds
shutterCommand = zeros(1, TOTAL_DURATION * settings.sampRate);

% injection timing
injectStartTime = TRIGGER_DELAY + INTER_FLASH_DURATION;
injectEndTime = TRIGGER_DELAY + INTER_FLASH_DURATION + PATTERN_FLASH_DURATION;

stimulusPeriod = PATTERN_FLASH_DURATION + INTER_FLASH_DURATION;

while ( injectEndTime <= TOTAL_DURATION )
    injectStartFrame = injectStartTime * settings.sampRate;
    injectEndFrame = injectEndTime * settings.sampRate;
    
    if(injectStartFrame < 0) % check if injectStartFrame is negative which will not work
    injectStartFrame = 1; % if the X location is too early in the pattern, this will shorten the inj period for this first stimulus, but not the later ones. 
    end
    
    shutterCommand ( round( injectStartFrame) : round( injectEndFrame) ) = 1;
    injectStartTime = injectStartTime + stimulusPeriod;
    injectEndTime = injectEndTime + stimulusPeriod;
end

%  trigger digital signal should be sent as 1 = ON 5V, which will be used
%  to open the lamp shutter
out.shutterCommand = shutterCommand;
% no current command
out.command = zeros(1, TOTAL_DURATION * settings.sampRate) * settings.daq.currentConversionFactor ; % send full command out, in Voltage for the daq to send

end

%% flashStripeON_300msON_300msOFF_chStimAndCurrInj( offset )
function [out ] = flashStripeON_300msON_300msOFF_chStimAndCurrInj( xpos_offset , inj_amp )
ephysSettings;
TOTAL_DURATION = 60; % seconds 
TRIGGER_DELAY = 7.6 / 1000;% 7.6 ms is ave delay, pretty consistent across trials!
% Panel trigger digital signal
out.visualTriggerCommand = buildVisualVoltageTrigger( TOTAL_DURATION );

% Build PANEL parameters
panelParams.patternNum = 3;
panelParams.positionFuncNumX = 8;
panelParams.positionFuncNumY = 29;% 300ms off, 300msec on
panelParams.initialPosition = [ xpos_offset, 0]; % [ X, Y ]
% store parameter values
out.panelParams = panelParams;

%build current command to align in time with when the bar is flashed
PATTERN_FLASH_DURATION = 0.3; % seconds
INTER_FLASH_DURATION = 0.3; % seconds
shutterCommand = zeros(1, TOTAL_DURATION * settings.sampRate);
currentCommand = zeros(1, TOTAL_DURATION * settings.sampRate);

% injection timing
injectStartTime = TRIGGER_DELAY + INTER_FLASH_DURATION;
injectEndTime = TRIGGER_DELAY + INTER_FLASH_DURATION + PATTERN_FLASH_DURATION;

stimulusPeriod = PATTERN_FLASH_DURATION + INTER_FLASH_DURATION;

while ( injectEndTime <= TOTAL_DURATION )
    injectStartFrame = injectStartTime * settings.sampRate;
    injectEndFrame = injectEndTime * settings.sampRate;
    
    if(injectStartFrame < 0) % check if injectStartFrame is negative which will not work
    injectStartFrame = 1; % if the X location is too early in the pattern, this will shorten the inj period for this first stimulus, but not the later ones. 
    end
    
    shutterCommand ( round( injectStartFrame) : round( injectEndFrame) ) = 1;
    currentCommand ( round( injectStartFrame) : round( injectEndFrame) ) = 1;
    
    injectStartTime = injectStartTime + stimulusPeriod;
    injectEndTime = injectEndTime + stimulusPeriod;
end


% scale current command by wanted amplitude of injection
currentCommand = inj_amp *  currentCommand ;


%  trigger digital signal should be sent as 1 = ON 5V, which will be used
%  to open the lamp shutter
out.shutterCommand = shutterCommand;
% build current command in correct units
out.command = currentCommand * settings.daq.currentConversionFactor ; % send full command out, in Voltage for the daq to send
end

%% flashStripe500msON_2Loc60deg_1stLocInjPaired( xpos_offset_1st , currentInjection )
function [out ] = flashStripe500msON_2Loc60deg_1stLocInjPaired( xpos_offset , inj_amp )
ephysSettings;
TOTAL_DURATION = 60; % seconds 
TRIGGER_DELAY = 7.6 / 1000;% 7.6 ms is ave delay, pretty consistent across trials!
% Panel trigger digital signal
out.visualTriggerCommand = buildVisualVoltageTrigger( TOTAL_DURATION );

% Build PANEL parameters
panelParams.patternNum = 3;
panelParams.positionFuncNumX = 26; %4sec initial x, 4 sec xpos #16
panelParams.positionFuncNumY = 27;% 3500ms off, 500msec on
panelParams.initialPosition = [ xpos_offset, 0]; % [ X, Y ]
% store parameter values
out.panelParams = panelParams;

%build current command to align in time with when the bar is flashed
PATTERN_FLASH_DURATION = 0.5; % seconds
INTER_FLASH_DURATION = 7.5; % seconds
currentCommand = zeros(1, TOTAL_DURATION * settings.sampRate);

% injection timing
injectStartTime = TRIGGER_DELAY + INTER_FLASH_DURATION;
injectEndTime = TRIGGER_DELAY + INTER_FLASH_DURATION + PATTERN_FLASH_DURATION;

stimulusPeriod = PATTERN_FLASH_DURATION + INTER_FLASH_DURATION;

while ( injectEndTime <= TOTAL_DURATION )
    injectStartFrame = injectStartTime * settings.sampRate;
    injectEndFrame = injectEndTime * settings.sampRate;
    
    if(injectStartFrame < 0) % check if injectStartFrame is negative which will not work
    injectStartFrame = 1; % if the X location is too early in the pattern, this will shorten the inj period for this first stimulus, but not the later ones. 
    end
    
    currentCommand ( injectStartFrame : injectEndFrame) = 1;
    injectStartTime = injectStartTime + stimulusPeriod;
    injectEndTime = injectEndTime + stimulusPeriod;
end

% scale current command by wanted amplitude of injection
currentCommand = inj_amp *  currentCommand ;

% build current command in correct units
out.command = currentCommand * settings.daq.currentConversionFactor ; % send full command out, in Voltage for the daq to send

end

%% flashStripeON_10s_1s( offset )
function [out ] = flashStripeON_10s_1s( xpos_offset )
ephysSettings;
TOTAL_DURATION = 40; % seconds 
% Panel trigger digital signal
out.visualTriggerCommand = buildVisualVoltageTrigger( TOTAL_DURATION );

% Build PANEL parameters
panelParams.patternNum = 3;
panelParams.positionFuncNumX = 8;
panelParams.positionFuncNumY = 11;% 10sec off, 1 sec on
panelParams.initialPosition = [ xpos_offset, 0]; % [ X, Y ]
% store parameter values
out.panelParams = panelParams;

% no current command
out.command = zeros(1, TOTAL_DURATION * settings.sampRate) * settings.daq.currentConversionFactor ; % send full command out, in Voltage for the daq to send
end

%% flashStripeON4pixel_2s( offset )
function [out ] = flashStripeON4pixel_2s( xpos_offset )
ephysSettings;
TOTAL_DURATION = 40; % seconds 
% Panel trigger digital signal
out.visualTriggerCommand = buildVisualVoltageTrigger( TOTAL_DURATION );

% Build PANEL parameters
panelParams.patternNum = 5;
panelParams.positionFuncNumX = 8;
panelParams.positionFuncNumY = 9;% 2 sec off, 2 sec on
panelParams.initialPosition = [ xpos_offset, 0]; % [ X, Y ]
% store parameter values
out.panelParams = panelParams;

% no current command
out.command = zeros(1, TOTAL_DURATION * settings.sampRate) * settings.daq.currentConversionFactor ; % send full command out, in Voltage for the daq to send
end

%% flashStripeON4pixel_500ms( offset )
function [out ] = flashStripeON4pixel_500ms( xpos_offset )
ephysSettings;
TOTAL_DURATION = 40; % seconds 
% Panel trigger digital signal
out.visualTriggerCommand = buildVisualVoltageTrigger( TOTAL_DURATION );

% Build PANEL parameters
panelParams.patternNum = 5;
panelParams.positionFuncNumX = 8;
panelParams.positionFuncNumY = 10;% 500ms off, 500msec on
panelParams.initialPosition = [ xpos_offset, 0]; % [ X, Y ]
% store parameter values
out.panelParams = panelParams;

% no current command
out.command = zeros(1, TOTAL_DURATION * settings.sampRate) * settings.daq.currentConversionFactor ; % send full command out, in Voltage for the daq to send
end

%% FFF2s( )
function [out ] = FFF2s( )
ephysSettings;
TOTAL_DURATION = 20; % seconds 
% Panel trigger digital signal
out.visualTriggerCommand = buildVisualVoltageTrigger( TOTAL_DURATION );

% Build PANEL parameters
panelParams.patternNum = 6;
panelParams.positionFuncNumX = 8;
panelParams.positionFuncNumY = 9;% 2 sec off, 2 sec on

% store parameter values
out.panelParams = panelParams;

% no current command
out.command = zeros(1, TOTAL_DURATION * settings.sampRate) * settings.daq.currentConversionFactor ; % send full command out, in Voltage for the daq to send
end

%% FFF500ms(  )
function [out ] = FFF500ms( )
ephysSettings;
TOTAL_DURATION = 20; % seconds 
% Panel trigger digital signal
out.visualTriggerCommand = buildVisualVoltageTrigger( TOTAL_DURATION );

% Build PANEL parameters
panelParams.patternNum = 6;
panelParams.positionFuncNumX = 8;
panelParams.positionFuncNumY = 10;% 500ms off, 500msec on
% store parameter values
out.panelParams = panelParams;

% no current command
out.command = zeros(1, TOTAL_DURATION * settings.sampRate) * settings.daq.currentConversionFactor ; % send full command out, in Voltage for the daq to send
end

%% staticStripeOn
function [out ] = staticStripeOn( barPanelPos, duration_secs )
ephysSettings;
TOTAL_DURATION = duration_secs; % seconds 
% Panel trigger digital signal
out.visualTriggerCommand = buildVisualVoltageTrigger( TOTAL_DURATION );

% Build PANEL parameters
panelParams.patternNum = 3;
panelParams.positionFuncNumX = 8;% static 0
panelParams.positionFuncNumY = 8;% static

panelParams.initialPosition = [ barPanelPos, 0]; % [ X, Y ]
% store parameter values
out.panelParams = panelParams;

% no current command
out.command = zeros(1, TOTAL_DURATION * settings.sampRate) * settings.daq.currentConversionFactor ; % send full command out, in Voltage for the daq to send
end


%% movingRightStripeON
function [out ] = movingRightStripeON( )
ephysSettings;
TOTAL_DURATION = 120; % seconds 
% Panel trigger digital signal
out.visualTriggerCommand = buildVisualVoltageTrigger( TOTAL_DURATION );

% Build PANEL parameters
panelParams.patternNum = 3;
panelParams.positionFuncNumX = 12;% moving 15 deg right
panelParams.positionFuncNumY = 8;% static
% store parameter values
out.panelParams = panelParams;

% no current command
out.command = zeros(1, TOTAL_DURATION * settings.sampRate) * settings.daq.currentConversionFactor ; % send full command out, in Voltage for the daq to send
end

%% movingRightStripeON_flexibleDur
function [out ] = movingRightStripeON_flexibleDur( duration_secs )
ephysSettings;
TOTAL_DURATION = duration_secs; % seconds 
% Panel trigger digital signal
out.visualTriggerCommand = buildVisualVoltageTrigger( TOTAL_DURATION );

% Build PANEL parameters
panelParams.patternNum = 3;
panelParams.positionFuncNumX = 12;% moving 15 deg right
panelParams.positionFuncNumY = 8;% static
% store parameter values
out.panelParams = panelParams;

% no current command
out.command = zeros(1, TOTAL_DURATION * settings.sampRate) * settings.daq.currentConversionFactor ; % send full command out, in Voltage for the daq to send
end

%% movingRightStripeON_8mins
function [out ] = movingRightStripeON_8mins( )
ephysSettings;
TOTAL_DURATION = 480; % seconds 
% Panel trigger digital signal
out.visualTriggerCommand = buildVisualVoltageTrigger( TOTAL_DURATION );

% Build PANEL parameters
panelParams.patternNum = 3;
panelParams.positionFuncNumX = 12;% moving 15 deg right
panelParams.positionFuncNumY = 8;% static
% store parameter values
out.panelParams = panelParams;

% no current command
out.command = zeros(1, TOTAL_DURATION * settings.sampRate) * settings.daq.currentConversionFactor ; % send full command out, in Voltage for the daq to send
end

%% movingRightStripeON_8mins_dark60to250sec
function [out ] = movingRightStripeON_8mins_dark61to250sec( )
ephysSettings;
TOTAL_DURATION = 480; % seconds 
% Panel trigger digital signal
out.visualTriggerCommand = buildVisualVoltageTrigger( TOTAL_DURATION );

% Build PANEL parameters
panelParams.patternNum = 3;
panelParams.positionFuncNumX = 12;% moving 15 deg right
panelParams.positionFuncNumY = 31;% hard coded to saline timing....
% store parameter values
out.panelParams = panelParams;

% no current command
out.command = zeros(1, TOTAL_DURATION * settings.sampRate) * settings.daq.currentConversionFactor ; % send full command out, in Voltage for the daq to send
end

%% movingRightStripeON_8mins_dark0to240sec
function [out ] = movingRightStripeON_8mins_dark0to240sec( )
ephysSettings;
TOTAL_DURATION = 480; % seconds 
% Panel trigger digital signal
out.visualTriggerCommand = buildVisualVoltageTrigger( TOTAL_DURATION );

% Build PANEL parameters
panelParams.patternNum = 3;
panelParams.positionFuncNumX = 12;% moving 15 deg right
panelParams.positionFuncNumY = 32;% hard coded to saline timing....
% store parameter values
out.panelParams = panelParams;

% no current command
out.command = zeros(1, TOTAL_DURATION * settings.sampRate) * settings.daq.currentConversionFactor ; % send full command out, in Voltage for the daq to send
end

%% movingRightStripeON_10mins
function [out ] = movingRightStripeON_10mins( )
ephysSettings;
TOTAL_DURATION = 600; % seconds 
% Panel trigger digital signal
out.visualTriggerCommand = buildVisualVoltageTrigger( TOTAL_DURATION );

% Build PANEL parameters
panelParams.patternNum = 3;
panelParams.positionFuncNumX = 12;% moving 15 deg right
panelParams.positionFuncNumY = 8;% static
% store parameter values
out.panelParams = panelParams;

% no current command
out.command = zeros(1, TOTAL_DURATION * settings.sampRate) * settings.daq.currentConversionFactor ; % send full command out, in Voltage for the daq to send
end

%% movingRightStripeON_15ds
function [out ] = movingRightStripeON_15ds( dur, contrast )
ephysSettings;
TOTAL_DURATION = dur; % seconds 
% Panel trigger digital signal
out.visualTriggerCommand = buildVisualVoltageTrigger( TOTAL_DURATION );

% Build PANEL parameters
if strcmp(contrast, 'high')
    panelParams.patternNum = 3;
elseif strcmp(contrast, '1vs4')
    panelParams.patternNum = 38;
elseif strcmp(contrast, '1vs2')
    panelParams.patternNum = 37;
elseif strcmp(contrast, '6vs7')
    panelParams.patternNum = 44;
else
    warning('Warning: contrast input does not match expected strings, defaulted to high contrast');
    panelParams.patternNum = 3;
end

panelParams.positionFuncNumX = 12;% moving 15 deg right
panelParams.positionFuncNumY = 8;% static
% store parameter values
out.panelParams = panelParams;

% no current command
out.command = zeros(1, TOTAL_DURATION * settings.sampRate) * settings.daq.currentConversionFactor ; % send full command out, in Voltage for the daq to send
end

%% movingRightStripeON_50ds
function [out ] = movingRightStripeON_50ds( dur, contrast )
ephysSettings;
TOTAL_DURATION = dur; % seconds 
% Panel trigger digital signal
out.visualTriggerCommand = buildVisualVoltageTrigger( TOTAL_DURATION );

% Build PANEL parameters
if strcmp(contrast, 'high')
    panelParams.patternNum = 3;
elseif strcmp(contrast, '1vs4')
    panelParams.patternNum = 38;
elseif strcmp(contrast, '1vs2')
    panelParams.patternNum = 37;
elseif strcmp(contrast, '6vs7')
    panelParams.patternNum = 44;
else
    warning('Warning: contrast input does not match expected strings, defaulted to high contrast');
    panelParams.patternNum = 3;
end

panelParams.positionFuncNumX = 20;% moving 50 deg right
panelParams.positionFuncNumY = 8;% static
% store parameter values
out.panelParams = panelParams;

% no current command
out.command = zeros(1, TOTAL_DURATION * settings.sampRate) * settings.daq.currentConversionFactor ; % send full command out, in Voltage for the daq to send
end

%% movingRightStripeON_150ds
function [out ] = movingRightStripeON_150ds( dur, contrast )
ephysSettings;
TOTAL_DURATION = dur; % seconds 
% Panel trigger digital signal
out.visualTriggerCommand = buildVisualVoltageTrigger( TOTAL_DURATION );

% Build PANEL parameters
if strcmp(contrast, 'high')
    panelParams.patternNum = 3;
elseif strcmp(contrast, '1vs4')
    panelParams.patternNum = 38;
elseif strcmp(contrast, '1vs2')
    panelParams.patternNum = 37;
elseif strcmp(contrast, '6vs7')
    panelParams.patternNum = 44;
else
    warning('Warning: contrast input does not match expected strings, defaulted to high contrast');
    panelParams.patternNum = 3;
end

panelParams.positionFuncNumX = 21;% moving 150 deg right
panelParams.positionFuncNumY = 8;% static
% store parameter values
out.panelParams = panelParams;

% no current command
out.command = zeros(1, TOTAL_DURATION * settings.sampRate) * settings.daq.currentConversionFactor ; % send full command out, in Voltage for the daq to send
end
%% movingRightStripeON_300ds
function [out ] = movingRightStripeON_300ds( dur , contrast)
ephysSettings;
TOTAL_DURATION = dur; % seconds 
% Panel trigger digital signal
out.visualTriggerCommand = buildVisualVoltageTrigger( TOTAL_DURATION );

% Build PANEL parameters
if strcmp(contrast, 'high')
    panelParams.patternNum = 3;
elseif strcmp(contrast, '1vs4')
    panelParams.patternNum = 38;
elseif strcmp(contrast, '1vs2')
    panelParams.patternNum = 37;
elseif strcmp(contrast, '6vs7')
    panelParams.patternNum = 44;
else
    warning('Warning: contrast input does not match expected strings, defaulted to high contrast');
    panelParams.patternNum = 3;
end
panelParams.positionFuncNumX = 22;% moving 300 deg right
panelParams.positionFuncNumY = 8;% static
% store parameter values
out.panelParams = panelParams;

% no current command
out.command = zeros(1, TOTAL_DURATION * settings.sampRate) * settings.daq.currentConversionFactor ; % send full command out, in Voltage for the daq to send
end
%% movingRightStripeON_450ds
function [out ] = movingRightStripeON_450ds( dur, contrast )
ephysSettings;
TOTAL_DURATION = dur; % seconds 
% Panel trigger digital signal
out.visualTriggerCommand = buildVisualVoltageTrigger( TOTAL_DURATION );

% Build PANEL parameters
if strcmp(contrast, 'high')
    panelParams.patternNum = 3;
elseif strcmp(contrast, '1vs4')
    panelParams.patternNum = 38;
elseif strcmp(contrast, '1vs2')
    panelParams.patternNum = 37;
elseif strcmp(contrast, '6vs7')
    panelParams.patternNum = 44;
else
    warning('Warning: contrast input does not match expected strings, defaulted to high contrast');
    panelParams.patternNum = 3;
end

panelParams.positionFuncNumX = 23;% moving 450 deg right
panelParams.positionFuncNumY = 8;% static
% store parameter values
out.panelParams = panelParams;

% no current command
out.command = zeros(1, TOTAL_DURATION * settings.sampRate) * settings.daq.currentConversionFactor ; % send full command out, in Voltage for the daq to send
end

%% movingRightStripeON_600ds
function [out ] = movingRightStripeON_600ds( dur , contrast)
ephysSettings;
TOTAL_DURATION = dur; % seconds 
% Panel trigger digital signal
out.visualTriggerCommand = buildVisualVoltageTrigger( TOTAL_DURATION );

% Build PANEL parameters
if strcmp(contrast, 'high')
    panelParams.patternNum = 3;
elseif strcmp(contrast, '1vs4')
    panelParams.patternNum = 38;
elseif strcmp(contrast, '1vs2')
    panelParams.patternNum = 37;
elseif strcmp(contrast, '6vs7')
    panelParams.patternNum = 44;
else
    warning('Warning: contrast input does not match expected strings, defaulted to high contrast');
    panelParams.patternNum = 3;
end

panelParams.positionFuncNumX = 24;% moving 600 deg right
panelParams.positionFuncNumY = 8;% static
% store parameter values
out.panelParams = panelParams;

% no current command
out.command = zeros(1, TOTAL_DURATION * settings.sampRate) * settings.daq.currentConversionFactor ; % send full command out, in Voltage for the daq to send
end

%% movingRightStripe_currentInj
function [out ] = movingRightStripe_currentInj( X_locationToInject , inj_amp)
ephysSettings;

DOT_DWELL_DURATION = 200 / 1000; %200 ms
DWELL_LOCATIONS = 73; 
INJECTION_DURATION = 2000 / 1000; % 2 sec
TRIGGER_DELAY = 7.6 / 1000;% 7.6 ms is ave delay, pretty consistent across trials!
TOTAL_DURATION = 120; % seconds 
% Panel trigger digital signal
out.visualTriggerCommand = buildVisualVoltageTrigger( TOTAL_DURATION );

% Build PANEL parameters
panelParams.patternNum = 3;
panelParams.positionFuncNumX = 12;% moving 15 deg right
panelParams.positionFuncNumY = 8;% static
% store parameter values
out.panelParams = panelParams;

currentCommand = zeros(1, TOTAL_DURATION * settings.sampRate);
% Build current command to inject current centered around when the pattern is at X_locationToInject
timeToCenterOfFirstXlocation = TRIGGER_DELAY + X_locationToInject * DOT_DWELL_DURATION - (DOT_DWELL_DURATION / 2);
% calc first injection timing
injectStartTime = timeToCenterOfFirstXlocation - ( INJECTION_DURATION / 2);


injectEndTime = timeToCenterOfFirstXlocation + ( INJECTION_DURATION / 2);
stimulusPeriod = DOT_DWELL_DURATION * DWELL_LOCATIONS;

while ( injectEndTime <= TOTAL_DURATION )
    injectStartFrame = round ( injectStartTime * settings.sampRate );
    injectEndFrame = round ( injectEndTime * settings.sampRate );
    
    if(injectStartFrame < 0)
    injectStartFrame = 1; % if the X location is too early in the pattern, this will shorten the inj period for this first stimulus, but not the later ones. 
    end
    
    currentCommand ( injectStartFrame : injectEndFrame) = 1;
    injectStartTime = injectStartTime + stimulusPeriod;
    injectEndTime = injectEndTime + stimulusPeriod;
end

% scale current command by wanted amplitude of injection
currentCommand = inj_amp *  currentCommand ;

out.command = currentCommand * settings.daq.currentConversionFactor;% send full command out, in Voltage for the daq to send
end

%% movingRightStripe_currINJWithOpto, chrimson activation while the current injection occurs
function [out ] = movingRightStripe_currInjWithOpto( X_locationToInject , inj_amp)
ephysSettings;

DOT_DWELL_DURATION = 200 / 1000; %200 ms
DWELL_LOCATIONS = 73; 
INJECTION_DURATION = 2000 / 1000; % 2 sec
TRIGGER_DELAY = 7.6 / 1000;% 7.6 ms is ave delay, pretty consistent across trials!
TOTAL_DURATION = 120; % seconds 
% Panel trigger digital signal
out.visualTriggerCommand = buildVisualVoltageTrigger( TOTAL_DURATION );

% Build PANEL parameters
panelParams.patternNum = 3;
panelParams.positionFuncNumX = 12;% moving 15 deg right
panelParams.positionFuncNumY = 8;% static
% store parameter values
out.panelParams = panelParams;

currentCommand = zeros(1, TOTAL_DURATION * settings.sampRate);
% Build current command to inject current centered around when the pattern is at X_locationToInject
timeToCenterOfFirstXlocation = TRIGGER_DELAY + X_locationToInject * DOT_DWELL_DURATION - (DOT_DWELL_DURATION / 2);
% calc first injection timing
injectStartTime = timeToCenterOfFirstXlocation - ( INJECTION_DURATION / 2);


injectEndTime = timeToCenterOfFirstXlocation + ( INJECTION_DURATION / 2);
stimulusPeriod = DOT_DWELL_DURATION * DWELL_LOCATIONS;

while ( injectEndTime <= TOTAL_DURATION )
    injectStartFrame = round ( injectStartTime * settings.sampRate );
    injectEndFrame = round ( injectEndTime * settings.sampRate );
    
    if(injectStartFrame < 0)
    injectStartFrame = 1; % if the X location is too early in the pattern, this will shorten the inj period for this first stimulus, but not the later ones. 
    end
    
    currentCommand ( injectStartFrame : injectEndFrame) = 1;
    injectStartTime = injectStartTime + stimulusPeriod;
    injectEndTime = injectEndTime + stimulusPeriod;
end

out.shutterCommand = currentCommand; % logical 0 or 1 for when shutter should be open

% scale current command by wanted amplitude of injection
currentCommand = inj_amp *  currentCommand ;

out.command = currentCommand * settings.daq.currentConversionFactor;% send full command out, in Voltage for the daq to send
end


%% controlForMovingStripe_currInjWithOpto, chrimson activation while the current injection occurs with no stimulus the whole time
function [out ] = controlForMovingStripe_currInjWithOpto( X_locationToInject , inj_amp)
ephysSettings;

DOT_DWELL_DURATION = 200 / 1000; %200 ms
DWELL_LOCATIONS = 73; 
INJECTION_DURATION = 2000 / 1000; % 2 sec
TRIGGER_DELAY = 7.6 / 1000;% 7.6 ms is ave delay, pretty consistent across trials!
TOTAL_DURATION = 120; % seconds 
% Panel trigger digital signal
out.visualTriggerCommand = buildVisualVoltageTrigger( TOTAL_DURATION );

% Build PANEL parameters
panelParams.patternNum = 6;
panelParams.positionFuncNumX = 8;% static
panelParams.positionFuncNumY = 30;% static
% store parameter values
out.panelParams = panelParams;

currentCommand = zeros(1, TOTAL_DURATION * settings.sampRate);
% Build current command to inject current centered around when the pattern is at X_locationToInject
timeToCenterOfFirstXlocation = TRIGGER_DELAY + X_locationToInject * DOT_DWELL_DURATION - (DOT_DWELL_DURATION / 2);
% calc first injection timing
injectStartTime = timeToCenterOfFirstXlocation - ( INJECTION_DURATION / 2);


injectEndTime = timeToCenterOfFirstXlocation + ( INJECTION_DURATION / 2);
stimulusPeriod = DOT_DWELL_DURATION * DWELL_LOCATIONS;

while ( injectEndTime <= TOTAL_DURATION )
    injectStartFrame = round ( injectStartTime * settings.sampRate );
    injectEndFrame = round ( injectEndTime * settings.sampRate );
    
    if(injectStartFrame < 0)
    injectStartFrame = 1; % if the X location is too early in the pattern, this will shorten the inj period for this first stimulus, but not the later ones. 
    end
    
    currentCommand ( injectStartFrame : injectEndFrame) = 1;
    injectStartTime = injectStartTime + stimulusPeriod;
    injectEndTime = injectEndTime + stimulusPeriod;
end

out.shutterCommand = currentCommand; % logical 0 or 1 for when shutter should be open

% scale current command by wanted amplitude of injection
currentCommand = inj_amp *  currentCommand ;

out.command = currentCommand * settings.daq.currentConversionFactor;% send full command out, in Voltage for the daq to send
end

%% movingRightStripe_Opto5ms_1secIPD, chrimson stim pulsed for 5ms at 1 sec intervals throught visual stimulus trial
function [out ] = movingRightStripe_Opto5ms_1secIPD()
ephysSettings;

DOT_DWELL_DURATION = 200 / 1000; %200 ms
DWELL_LOCATIONS = 73; 
OPTO_STIM_DURATION = 5 / 1000; % 5 msec
INTER_OPTO_STIM_DURATION = 1000 / 1000; % 1 sec

TRIGGER_DELAY = 7.6 / 1000;% 7.6 ms is ave delay, pretty consistent across trials!
TOTAL_DURATION = 120; % seconds 
% Panel trigger digital signal
out.visualTriggerCommand = buildVisualVoltageTrigger( TOTAL_DURATION );

% Build PANEL parameters
panelParams.patternNum = 3;
panelParams.positionFuncNumX = 12;% moving 15 deg right
panelParams.positionFuncNumY = 8;% static
% store parameter values
out.panelParams = panelParams;

% solve for number of stimulations in the trial, round up
stimulationRepetitions = ceil( TOTAL_DURATION / ( INTER_OPTO_STIM_DURATION + OPTO_STIM_DURATION) );
shutterCommand = [];

for i = 1: stimulationRepetitions
    
    preStimCommand = zeros(1, INTER_OPTO_STIM_DURATION * settings.sampRate );
    
    stimCommand = ones( 1, OPTO_STIM_DURATION * settings.sampRate );
    
    shutterCommand = [shutterCommand preStimCommand stimCommand];
end
% clip off any numbers that passed the duration the planned trial
shutterCommand = shutterCommand(1:TOTAL_DURATION * settings.sampRate);

out.shutterCommand = shutterCommand; % logical 0 or 1 for when shutter should be open

% no current command
out.command = zeros(1, TOTAL_DURATION * settings.sampRate) * settings.daq.currentConversionFactor ; % send full command out, in Voltage for the daq to send
end

%% movingRightStripe_Opto10ms_2secIPD, chrimson stim pulsed for 10ms at 2 sec intervals throught visual stimulus trial
function [out ] = movingRightStripe_Opto10ms_2secIPD()
ephysSettings;

DOT_DWELL_DURATION = 200 / 1000; %200 ms
DWELL_LOCATIONS = 73; 
OPTO_STIM_DURATION = 10 / 1000; % 10 msec
INTER_OPTO_STIM_DURATION = 2000 / 1000; % 2 sec

TRIGGER_DELAY = 7.6 / 1000;% 7.6 ms is ave delay, pretty consistent across trials!
TOTAL_DURATION = 120; % seconds 
% Panel trigger digital signal
out.visualTriggerCommand = buildVisualVoltageTrigger( TOTAL_DURATION );

% Build PANEL parameters
panelParams.patternNum = 3;
panelParams.positionFuncNumX = 12;% moving 15 deg right
panelParams.positionFuncNumY = 8;% static
% store parameter values
out.panelParams = panelParams;

% solve for number of stimulations in the trial, round up
stimulationRepetitions = ceil( TOTAL_DURATION / ( INTER_OPTO_STIM_DURATION + OPTO_STIM_DURATION) );
shutterCommand = [];

for i = 1: stimulationRepetitions
    
    preStimCommand = zeros(1, INTER_OPTO_STIM_DURATION * settings.sampRate );
    
    stimCommand = ones( 1, OPTO_STIM_DURATION * settings.sampRate );
    
    shutterCommand = [shutterCommand preStimCommand stimCommand];
end
% clip off any numbers that passed the duration the planned trial
shutterCommand = shutterCommand(1:TOTAL_DURATION * settings.sampRate);

out.shutterCommand = shutterCommand; % logical 0 or 1 for when shutter should be open

% no current command
out.command = zeros(1, TOTAL_DURATION * settings.sampRate) * settings.daq.currentConversionFactor ; % send full command out, in Voltage for the daq to send
end

%% movingRightStripe_Opto chrimson stim pulsed for user chosen time at user chosen intervals throught visual stimulus trial
function [out ] = movingRightStripe_Opto( stimDur, interStimDur )
ephysSettings;

DOT_DWELL_DURATION = 200 / 1000; %200 ms
DWELL_LOCATIONS = 73; 
OPTO_STIM_DURATION = stimDur; % sec
INTER_OPTO_STIM_DURATION = interStimDur; %  sec

TRIGGER_DELAY = 7.6 / 1000;% 7.6 ms is ave delay, pretty consistent across trials!
TOTAL_DURATION = 120; % seconds 
% Panel trigger digital signal
out.visualTriggerCommand = buildVisualVoltageTrigger( TOTAL_DURATION );

% Build PANEL parameters
panelParams.patternNum = 3;
panelParams.positionFuncNumX = 12;% moving 15 deg right
panelParams.positionFuncNumY = 8;% static
% store parameter values
out.panelParams = panelParams;

% solve for number of stimulations in the trial, round up
stimulationRepetitions = ceil( TOTAL_DURATION / ( INTER_OPTO_STIM_DURATION + OPTO_STIM_DURATION) );
shutterCommand = [];

for i = 1: stimulationRepetitions
    
    preStimCommand = zeros(1, INTER_OPTO_STIM_DURATION * settings.sampRate );
    
    stimCommand = ones( 1, OPTO_STIM_DURATION * settings.sampRate );
    
    shutterCommand = [shutterCommand preStimCommand stimCommand];
end
% clip off any numbers that passed the duration the planned trial
shutterCommand = shutterCommand(1:TOTAL_DURATION * settings.sampRate);

out.shutterCommand = shutterCommand; % logical 0 or 1 for when shutter should be open

% no current command
out.command = zeros(1, TOTAL_DURATION * settings.sampRate) * settings.daq.currentConversionFactor ; % send full command out, in Voltage for the daq to send
end


%% movingRightStripe_Opto chrimson stim pulsed for user chosen time at user chosen intervals throught visual stimulus trial
function [out ] = movingRight_2Stripes_Opto( stimDur, interStimDur )
ephysSettings;

DOT_DWELL_DURATION = 200 / 1000; %200 ms
DWELL_LOCATIONS = 73; 
OPTO_STIM_DURATION = stimDur; % sec
INTER_OPTO_STIM_DURATION = interStimDur; %  sec

TRIGGER_DELAY = 7.6 / 1000;% 7.6 ms is ave delay, pretty consistent across trials!
TOTAL_DURATION = 120; % seconds 
% Panel trigger digital signal
out.visualTriggerCommand = buildVisualVoltageTrigger( TOTAL_DURATION );

% Build PANEL parameters
panelParams.patternNum = 45;
panelParams.positionFuncNumX = 12;% moving 15 deg right
panelParams.positionFuncNumY = 8;% static
% store parameter values
out.panelParams = panelParams;

% solve for number of stimulations in the trial, round up
stimulationRepetitions = ceil( TOTAL_DURATION / ( INTER_OPTO_STIM_DURATION + OPTO_STIM_DURATION) );
shutterCommand = [];

for i = 1: stimulationRepetitions
    
    preStimCommand = zeros(1, INTER_OPTO_STIM_DURATION * settings.sampRate );
    
    stimCommand = ones( 1, OPTO_STIM_DURATION * settings.sampRate );
    
    shutterCommand = [shutterCommand preStimCommand stimCommand];
end
% clip off any numbers that passed the duration the planned trial
shutterCommand = shutterCommand(1:TOTAL_DURATION * settings.sampRate);

out.shutterCommand = shutterCommand; % logical 0 or 1 for when shutter should be open

% no current command
out.command = zeros(1, TOTAL_DURATION * settings.sampRate) * settings.daq.currentConversionFactor ; % send full command out, in Voltage for the daq to send
end


%% optoOnly5ms_1secIPD, chrimson stim pulsed for 5ms at 1 sec intervals 
function [out ] = optoOnly5ms_1secIPD()
ephysSettings;

DOT_DWELL_DURATION = 200 / 1000; %200 ms
DWELL_LOCATIONS = 73; 
OPTO_STIM_DURATION = 5 / 1000; % 5 msec
INTER_OPTO_STIM_DURATION = 1000 / 1000; % 1 sec

TRIGGER_DELAY = 7.6 / 1000;% 7.6 ms is ave delay, pretty consistent across trials!
TOTAL_DURATION = 120; % seconds 

% solve for number of stimulations in the trial, round up
stimulationRepetitions = ceil( TOTAL_DURATION / ( INTER_OPTO_STIM_DURATION + OPTO_STIM_DURATION) );
shutterCommand = [];

for i = 1: stimulationRepetitions
    
    preStimCommand = zeros(1, INTER_OPTO_STIM_DURATION * settings.sampRate );
    
    stimCommand = ones( 1, OPTO_STIM_DURATION * settings.sampRate );
    
    shutterCommand = [shutterCommand preStimCommand stimCommand];
end
% clip off any numbers that passed the duration the planned trial
shutterCommand = shutterCommand(1:TOTAL_DURATION * settings.sampRate);

out.shutterCommand = shutterCommand; % logical 0 or 1 for when shutter should be open

% no current command
out.command = zeros(1, TOTAL_DURATION * settings.sampRate) * settings.daq.currentConversionFactor ; % send full command out, in Voltage for the daq to send
end

%% optoOnly10ms_2secIPD, chrimson stim pulsed for 10ms at 2 sec intervals 
function [out ] = optoOnly10ms_2secIPD()
ephysSettings;

DOT_DWELL_DURATION = 200 / 1000; %200 ms
DWELL_LOCATIONS = 73; 
OPTO_STIM_DURATION = 10 / 1000; % 10 msec
INTER_OPTO_STIM_DURATION = 2000 / 1000; % 2 sec

TRIGGER_DELAY = 7.6 / 1000;% 7.6 ms is ave delay, pretty consistent across trials!
TOTAL_DURATION = 120; % seconds 

% solve for number of stimulations in the trial, round up
stimulationRepetitions = ceil( TOTAL_DURATION / ( INTER_OPTO_STIM_DURATION + OPTO_STIM_DURATION) );
shutterCommand = [];

for i = 1: stimulationRepetitions
    
    preStimCommand = zeros(1, INTER_OPTO_STIM_DURATION * settings.sampRate );
    
    stimCommand = ones( 1, OPTO_STIM_DURATION * settings.sampRate );
    
    shutterCommand = [shutterCommand preStimCommand stimCommand];
end
% clip off any numbers that passed the duration the planned trial
shutterCommand = shutterCommand(1:TOTAL_DURATION * settings.sampRate);

out.shutterCommand = shutterCommand; % logical 0 or 1 for when shutter should be open

% no current command
out.command = zeros(1, TOTAL_DURATION * settings.sampRate) * settings.daq.currentConversionFactor ; % send full command out, in Voltage for the daq to send
end

%% optoOnly, chrimson stim pulsed
function [out ] = optoOnly( stimDur, interStimDur)
ephysSettings;

DOT_DWELL_DURATION = 200 / 1000; %200 ms
DWELL_LOCATIONS = 73; 
OPTO_STIM_DURATION = stimDur; % seconds
INTER_OPTO_STIM_DURATION = interStimDur; % sec

TRIGGER_DELAY = 7.6 / 1000;% 7.6 ms is ave delay, pretty consistent across trials!
TOTAL_DURATION = 120; % seconds 

% solve for number of stimulations in the trial, round up
stimulationRepetitions = ceil( TOTAL_DURATION / ( INTER_OPTO_STIM_DURATION + OPTO_STIM_DURATION) );
shutterCommand = [];

for i = 1: stimulationRepetitions
    
    preStimCommand = zeros(1, INTER_OPTO_STIM_DURATION * settings.sampRate );
    
    stimCommand = ones( 1, OPTO_STIM_DURATION * settings.sampRate );
    
    shutterCommand = [shutterCommand preStimCommand stimCommand];
end
% clip off any numbers that passed the duration the planned trial
shutterCommand = shutterCommand(1:TOTAL_DURATION * settings.sampRate);

out.shutterCommand = shutterCommand; % logical 0 or 1 for when shutter should be open

% no current command
out.command = zeros(1, TOTAL_DURATION * settings.sampRate) * settings.daq.currentConversionFactor ; % send full command out, in Voltage for the daq to send
end



%% movingRightStripe_currINJWithOpto, chrimson activation while the current injection occurs
function [out ] = movingRight2Bar_currInjWithOpto( X_locationToInject , inj_amp)
ephysSettings;

DOT_DWELL_DURATION = 200 / 1000; %200 ms
DWELL_LOCATIONS = 73; 
INJECTION_DURATION = 2000 / 1000; % 2 sec
TRIGGER_DELAY = 7.6 / 1000;% 7.6 ms is ave delay, pretty consistent across trials!
TOTAL_DURATION = 120; % seconds 
% Panel trigger digital signal
out.visualTriggerCommand = buildVisualVoltageTrigger( TOTAL_DURATION );

% Build PANEL parameters
panelParams.patternNum = 45;
panelParams.positionFuncNumX = 12;% moving 15 deg right
panelParams.positionFuncNumY = 8;% static
% store parameter values
out.panelParams = panelParams;

currentCommand = zeros(1, TOTAL_DURATION * settings.sampRate);
% Build current command to inject current centered around when the pattern is at X_locationToInject
timeToCenterOfFirstXlocation = TRIGGER_DELAY + X_locationToInject * DOT_DWELL_DURATION - (DOT_DWELL_DURATION / 2);
% calc first injection timing
injectStartTime = timeToCenterOfFirstXlocation - ( INJECTION_DURATION / 2);


injectEndTime = timeToCenterOfFirstXlocation + ( INJECTION_DURATION / 2);
stimulusPeriod = DOT_DWELL_DURATION * DWELL_LOCATIONS;

while ( injectEndTime <= TOTAL_DURATION )
    injectStartFrame = round ( injectStartTime * settings.sampRate );
    injectEndFrame = round ( injectEndTime * settings.sampRate );
    
    if(injectStartFrame < 0)
    injectStartFrame = 1; % if the X location is too early in the pattern, this will shorten the inj period for this first stimulus, but not the later ones. 
    end
    
    currentCommand ( injectStartFrame : injectEndFrame) = 1;
    injectStartTime = injectStartTime + stimulusPeriod;
    injectEndTime = injectEndTime + stimulusPeriod;
end

out.shutterCommand = currentCommand; % logical 0 or 1 for when shutter should be open

% scale current command by wanted amplitude of injection
currentCommand = inj_amp *  currentCommand ;

out.command = currentCommand * settings.daq.currentConversionFactor;% send full command out, in Voltage for the daq to send
end



%% movingRightStripeON_4pixel
function [out ] = movingRightStripeON_4pixel( )
ephysSettings;
TOTAL_DURATION = 120; % seconds 
% Panel trigger digital signal
out.visualTriggerCommand = buildVisualVoltageTrigger( TOTAL_DURATION );

% Build PANEL parameters
panelParams.patternNum = 5;
panelParams.positionFuncNumX = 12;% moving 15 deg right
panelParams.positionFuncNumY = 8;% static
% store parameter values
out.panelParams = panelParams;

% no current command
out.command = zeros(1, TOTAL_DURATION * settings.sampRate) * settings.daq.currentConversionFactor ; % send full command out, in Voltage for the daq to send
end

%% movingRightStripe4pixel_currentInj
function [out ] = movingRightStripe4pixel_currentInj( X_locationToInject , inj_amp)
ephysSettings;

DOT_DWELL_DURATION = 200 / 1000; %200 ms
DWELL_LOCATIONS = 73; 
INJECTION_DURATION = 800 / 1000; % 200 ms
TRIGGER_DELAY = 7.6 / 1000;% 7.6 ms is ave delay, pretty consistent across trials!
TOTAL_DURATION = 120; % seconds 
% Panel trigger digital signal
out.visualTriggerCommand = buildVisualVoltageTrigger( TOTAL_DURATION );

% Build PANEL parameters
panelParams.patternNum = 5;
panelParams.positionFuncNumX = 12;% moving 15 deg right
panelParams.positionFuncNumY = 8;% static
% store parameter values
out.panelParams = panelParams;

currentCommand = zeros(1, TOTAL_DURATION * settings.sampRate);
% Build current command to inject current centered around when the pattern is at X_locationToInject
timeToCenterOfFirstXlocation = TRIGGER_DELAY + X_locationToInject * DOT_DWELL_DURATION - (DOT_DWELL_DURATION / 2);
% calc first injection timing
injectStartTime = timeToCenterOfFirstXlocation - ( INJECTION_DURATION / 2);


injectEndTime = timeToCenterOfFirstXlocation + ( INJECTION_DURATION / 2);
stimulusPeriod = DOT_DWELL_DURATION * DWELL_LOCATIONS;

while ( injectEndTime <= TOTAL_DURATION )
    injectStartFrame = injectStartTime * settings.sampRate;
    injectEndFrame = injectEndTime * settings.sampRate;
    
    if(injectStartFrame < 0)
    injectStartFrame = 1; % if the X location is too early in the pattern, this will shorten the inj period for this first stimulus, but not the later ones. 
    end
    
    currentCommand ( injectStartFrame : injectEndFrame) = 1;
    injectStartTime = injectStartTime + stimulusPeriod;
    injectEndTime = injectEndTime + stimulusPeriod;
end

% scale current command by wanted amplitude of injection
currentCommand = inj_amp *  currentCommand ;

out.command = currentCommand * settings.daq.currentConversionFactor;% send full command out, in Voltage for the daq to send
end




%% movingLeftStripeON
function [out ] = movingLeftStripeON( )
ephysSettings;
TOTAL_DURATION = 60; % seconds 
% Panel trigger digital signal
out.visualTriggerCommand = buildVisualVoltageTrigger( TOTAL_DURATION );

% Build PANEL parameters
panelParams.patternNum = 3;
panelParams.positionFuncNumX = 13;% moving 15 deg left
panelParams.positionFuncNumY = 8;% static
% store parameter values
out.panelParams = panelParams;

% no current command
out.command = zeros(1, TOTAL_DURATION * settings.sampRate) * settings.daq.currentConversionFactor ; % send full command out, in Voltage for the daq to send
end

%% movingRightDotON
function [out ] = movingRightDotON( elevation_Y )
ephysSettings;
TOTAL_DURATION = 120; % seconds 
% Panel trigger digital signal
out.visualTriggerCommand = buildVisualVoltageTrigger( TOTAL_DURATION );

% Build PANEL parameters
panelParams.patternNum = 1;
panelParams.positionFuncNumX = 12;% moving 15 deg right
panelParams.positionFuncNumY = 8;% static
panelParams.initialPosition = [ 0, elevation_Y ]; % [ X, Y ]
% store parameter values
out.panelParams = panelParams;

% no current command
out.command = zeros(1, TOTAL_DURATION * settings.sampRate) * settings.daq.currentConversionFactor ; % send full command out, in Voltage for the daq to send
end


%% movingRightDotON_topAndMiddle
function [out ] = movingRightDotON_topAndMiddle( )
ephysSettings;
TOTAL_DURATION = 120; % seconds 
% Panel trigger digital signal
out.visualTriggerCommand = buildVisualVoltageTrigger( TOTAL_DURATION );

% Build PANEL parameters
panelParams.patternNum = 1;
panelParams.positionFuncNumX = 12;% moving 15 deg right
panelParams.positionFuncNumY = 33;% static
panelParams.initialPosition = [ 0, 0]; % [ X, Y ]
% store parameter values
out.panelParams = panelParams;

% no current command
out.command = zeros(1, TOTAL_DURATION * settings.sampRate) * settings.daq.currentConversionFactor ; % send full command out, in Voltage for the daq to send
end

%% movingRightDotON_topAndBottom
function [out ] = movingRightDotON_topAndBottom( )
ephysSettings;
TOTAL_DURATION = 120; % seconds 
% Panel trigger digital signal
out.visualTriggerCommand = buildVisualVoltageTrigger( TOTAL_DURATION );

% Build PANEL parameters
panelParams.patternNum = 1;
panelParams.positionFuncNumX = 12;% moving 15 deg right and left alternativing
panelParams.positionFuncNumY = 34;% static
panelParams.initialPosition = [ 0, 0]; % [ X, Y ]
% store parameter values
out.panelParams = panelParams;

% no current command
out.command = zeros(1, TOTAL_DURATION * settings.sampRate) * settings.daq.currentConversionFactor ; % send full command out, in Voltage for the daq to send
end

%% movingTopAndMiddleDot 
function [out ] = movingTopAndMiddleDot( )
ephysSettings;
TOTAL_DURATION = 120; % seconds 
% Panel trigger digital signal
out.visualTriggerCommand = buildVisualVoltageTrigger( TOTAL_DURATION );

% Build PANEL parameters
panelParams.patternNum = 1;
panelParams.positionFuncNumX = 14;% moving 15 deg right and left alternating
panelParams.positionFuncNumY = 33;% 
panelParams.initialPosition = [ 0, 0]; % [ X, Y ]
% store parameter values
out.panelParams = panelParams;

% no current command
out.command = zeros(1, TOTAL_DURATION * settings.sampRate) * settings.daq.currentConversionFactor ; % send full command out, in Voltage for the daq to send
end

%% movingTopAndBottomDot
function [out ] = movingTopAndBottomDot( )
ephysSettings;
TOTAL_DURATION = 120; % seconds 
% Panel trigger digital signal
out.visualTriggerCommand = buildVisualVoltageTrigger( TOTAL_DURATION );

% Build PANEL parameters
panelParams.patternNum = 1;
panelParams.positionFuncNumX = 14;% moving 15 deg right and left alternating
panelParams.positionFuncNumY = 34;% static
panelParams.initialPosition = [ 0, 0]; % [ X, Y ]
% store parameter values
out.panelParams = panelParams;

% no current command
out.command = zeros(1, TOTAL_DURATION * settings.sampRate) * settings.daq.currentConversionFactor ; % send full command out, in Voltage for the daq to send
end

%% movingTopAndBottomDot2Swings
function [out ] = movingTopAndBottomDot2Swings( )
ephysSettings;
TOTAL_DURATION = 240; % seconds 
% Panel trigger digital signal
out.visualTriggerCommand = buildVisualVoltageTrigger( TOTAL_DURATION );

% Build PANEL parameters
panelParams.patternNum = 1;
panelParams.positionFuncNumX = 35;% moving 15 deg right and left alternating every 2 swings
panelParams.positionFuncNumY = 36;% top and then bottom 
panelParams.initialPosition = [ 0, 0]; % [ X, Y ]
% store parameter values
out.panelParams = panelParams;

% no current command
out.command = zeros(1, TOTAL_DURATION * settings.sampRate) * settings.daq.currentConversionFactor ; % send full command out, in Voltage for the daq to send
end

%% movingRightDotON_flexDur
function [out ] = movingRightDotON_flexDur( elevation_Y, dur )
ephysSettings;
TOTAL_DURATION = dur; % seconds 
% Panel trigger digital signal
out.visualTriggerCommand = buildVisualVoltageTrigger( TOTAL_DURATION );

% Build PANEL parameters
panelParams.patternNum = 1;
panelParams.positionFuncNumX = 12;% moving 15 deg right
panelParams.positionFuncNumY = 8;% static
panelParams.initialPosition = [ 0, elevation_Y ]; % [ X, Y ]
% store parameter values
out.panelParams = panelParams;

% no current command
out.command = zeros(1, TOTAL_DURATION * settings.sampRate) * settings.daq.currentConversionFactor ; % send full command out, in Voltage for the daq to send
end

%% movingLeftDotON_flexDur
function [out ] = movingLeftDotON_flexDur( elevation_Y, dur )
ephysSettings;
TOTAL_DURATION = dur; % seconds 
% Panel trigger digital signal
out.visualTriggerCommand = buildVisualVoltageTrigger( TOTAL_DURATION );

% Build PANEL parameters
panelParams.patternNum = 1;
panelParams.positionFuncNumX = 13;% moving 15 deg right
panelParams.positionFuncNumY = 8;% static
panelParams.initialPosition = [ 0, elevation_Y ]; % [ X, Y ]
% store parameter values
out.panelParams = panelParams;

% no current command
out.command = zeros(1, TOTAL_DURATION * settings.sampRate) * settings.daq.currentConversionFactor ; % send full command out, in Voltage for the daq to send
end

%% movingRightDot_Opto
function [out ] = movingRightDot_Opto( elevation_Y, stimDur, interStimDur )
ephysSettings;
DOT_DWELL_DURATION = 200 / 1000; %200 ms
DWELL_LOCATIONS = 73; 
OPTO_STIM_DURATION = stimDur; % sec
INTER_OPTO_STIM_DURATION = interStimDur; %  sec

TRIGGER_DELAY = 7.6 / 1000;% 7.6 ms is ave delay, pretty consistent across trials!
TOTAL_DURATION = 120; % seconds 
% Panel trigger digital signal
out.visualTriggerCommand = buildVisualVoltageTrigger( TOTAL_DURATION );

% Build PANEL parameters
panelParams.patternNum = 1;
panelParams.positionFuncNumX = 12;% moving 15 deg right
panelParams.positionFuncNumY = 8;% static
panelParams.initialPosition = [ 0, elevation_Y ]; % [ X, Y ]
% store parameter values
out.panelParams = panelParams;

% solve for number of stimulations in the trial, round up
stimulationRepetitions = ceil( TOTAL_DURATION / ( INTER_OPTO_STIM_DURATION + OPTO_STIM_DURATION) );
shutterCommand = [];

for i = 1: stimulationRepetitions
    
    preStimCommand = zeros(1, INTER_OPTO_STIM_DURATION * settings.sampRate );
    
    stimCommand = ones( 1, OPTO_STIM_DURATION * settings.sampRate );
    
    shutterCommand = [shutterCommand preStimCommand stimCommand];
end
% clip off any numbers that passed the duration the planned trial
shutterCommand = shutterCommand(1:TOTAL_DURATION * settings.sampRate);

out.shutterCommand = shutterCommand; % logical 0 or 1 for when shutter should be open

% no current command
out.command = zeros(1, TOTAL_DURATION * settings.sampRate) * settings.daq.currentConversionFactor ; % send full command out, in Voltage for the daq to send
end


%% movingRightDotON_currentInj
function [out ] = movingRightDotON_currentInj( elevation_Y , X_locationToInject , inj_amp)
ephysSettings;

DOT_DWELL_DURATION = 200 / 1000; %200 ms
DWELL_LOCATIONS = 73; 
INJECTION_DURATION = 800 / 1000; % 800 ms
TRIGGER_DELAY = 7.6 / 1000;% 7.6 ms is ave delay, pretty consistent across trials!
TOTAL_DURATION = 120; % seconds 
% Panel trigger digital signal
out.visualTriggerCommand = buildVisualVoltageTrigger( TOTAL_DURATION );

% Build PANEL parameters
panelParams.patternNum = 1;
panelParams.positionFuncNumX = 12;% moving 15 deg right
panelParams.positionFuncNumY = 8;% static
panelParams.initialPosition = [ 0, elevation_Y ]; % [ X, Y ]
% store parameter values
out.panelParams = panelParams;

currentCommand = zeros(1, TOTAL_DURATION * settings.sampRate);
% Build current command to inject current centered around when the pattern is at X_locationToInject
timeToCenterOfFirstXlocation = TRIGGER_DELAY + X_locationToInject * DOT_DWELL_DURATION - (DOT_DWELL_DURATION / 2);
% calc first injection timing
injectStartTime = timeToCenterOfFirstXlocation - ( INJECTION_DURATION / 2);

injectEndTime = timeToCenterOfFirstXlocation + ( INJECTION_DURATION / 2);
stimulusPeriod = DOT_DWELL_DURATION * DWELL_LOCATIONS;

while ( injectEndTime <= TOTAL_DURATION )
    injectStartFrame = injectStartTime * settings.sampRate;
    injectEndFrame = injectEndTime * settings.sampRate;
    
    if(injectStartFrame < 0) % check if injectStartFrame is negative which will not work
    injectStartFrame = 1; % if the X location is too early in the pattern, this will shorten the inj period for this first stimulus, but not the later ones. 
    end
    
    currentCommand ( injectStartFrame : injectEndFrame) = 1;
    injectStartTime = injectStartTime + stimulusPeriod;
    injectEndTime = injectEndTime + stimulusPeriod;
end

% scale current command by wanted amplitude of injection
currentCommand = inj_amp *  currentCommand ;

out.command = currentCommand * settings.daq.currentConversionFactor;% send full command out, in Voltage for the daq to send
end

%% movingRightDot4pixelON
function [out ] = movingRightDot4pixelON( elevation_Y )
ephysSettings;
TOTAL_DURATION = 120; % seconds 
% Panel trigger digital signal
out.visualTriggerCommand = buildVisualVoltageTrigger( TOTAL_DURATION );

% Build PANEL parameters
panelParams.patternNum = 2;
panelParams.positionFuncNumX = 12;% moving 15 deg right
panelParams.positionFuncNumY = 8;% static
panelParams.initialPosition = [ 0, elevation_Y ]; % [ X, Y ]
% store parameter values
out.panelParams = panelParams;

% no current command
out.command = zeros(1, TOTAL_DURATION * settings.sampRate) * settings.daq.currentConversionFactor ; % send full command out, in Voltage for the daq to send
end


%% movingRightDot4pixelON_currentInj
function [out ] = movingRightDot4pixelON_currentInj( elevation_Y , X_locationToInject , inj_amp)
ephysSettings;

DOT_DWELL_DURATION = 200 / 1000; %200 ms
DWELL_LOCATIONS = 73; 
INJECTION_DURATION = 800 / 1000; % 200 ms
TRIGGER_DELAY = 7.6 / 1000;% 7.6 ms is ave delay, pretty consistent across trials!
TOTAL_DURATION = 120; % seconds 
% Panel trigger digital signal
out.visualTriggerCommand = buildVisualVoltageTrigger( TOTAL_DURATION );

% Build PANEL parameters
panelParams.patternNum = 2;
panelParams.positionFuncNumX = 12;% moving 15 deg right
panelParams.positionFuncNumY = 8;% static
panelParams.initialPosition = [ 0, elevation_Y ]; % [ X, Y ]
% store parameter values
out.panelParams = panelParams;

currentCommand = zeros(1, TOTAL_DURATION * settings.sampRate);
% Build current command to inject current centered around when the pattern is at X_locationToInject
timeToCenterOfFirstXlocation = TRIGGER_DELAY + X_locationToInject * DOT_DWELL_DURATION - (DOT_DWELL_DURATION / 2);
% calc first injection timing
injectStartTime = timeToCenterOfFirstXlocation - ( INJECTION_DURATION / 2);

injectEndTime = timeToCenterOfFirstXlocation + ( INJECTION_DURATION / 2);
stimulusPeriod = DOT_DWELL_DURATION * DWELL_LOCATIONS;

while ( injectEndTime <= TOTAL_DURATION )
    injectStartFrame = injectStartTime * settings.sampRate;
    injectEndFrame = injectEndTime * settings.sampRate;
    
    if(injectStartFrame < 0) % check if injectStartFrame is negative which will not work
    injectStartFrame = 1; % if the X location is too early in the pattern, this will shorten the inj period for this first stimulus, but not the later ones. 
    end
    
    currentCommand ( injectStartFrame : injectEndFrame) = 1;
    injectStartTime = injectStartTime + stimulusPeriod;
    injectEndTime = injectEndTime + stimulusPeriod;
end

% scale current command by wanted amplitude of injection
currentCommand = inj_amp *  currentCommand ;

out.command = currentCommand * settings.daq.currentConversionFactor;% send full command out, in Voltage for the daq to send
end

%% dotRandHorizLocON()
function [out ] = dotRandHorizLocON( elevation_Y )
ephysSettings;
TOTAL_DURATION = 150; % seconds  36 sec for 1 round X 4 = 144 
% Panel trigger digital signal
out.visualTriggerCommand = buildVisualVoltageTrigger( TOTAL_DURATION );

% Build PANEL parameters
panelParams.patternNum = 1;
panelParams.positionFuncNumX = 7;% Random X position
panelParams.positionFuncNumY = 8;% static
panelParams.initialPosition = [ 0, elevation_Y ]; % [ X, Y ]
% store parameter values
out.panelParams = panelParams;

% no current command
out.command = zeros(1, TOTAL_DURATION * settings.sampRate) * settings.daq.currentConversionFactor ; % send full command out, in Voltage for the daq to send
end

%% dotRandHorizLocON()
function [out ] = dotRandHorizLoc4pixelON( elevation_Y )
ephysSettings;
TOTAL_DURATION = 150; % seconds  36 sec for 1 round X 4 = 144 
% Panel trigger digital signal
out.visualTriggerCommand = buildVisualVoltageTrigger( TOTAL_DURATION );

% Build PANEL parameters
panelParams.patternNum = 2;
panelParams.positionFuncNumX = 16;% Random X position
panelParams.positionFuncNumY = 8;% static
panelParams.initialPosition = [ 0, elevation_Y ]; % [ X, Y ]
% store parameter values
out.panelParams = panelParams;

% no current command
out.command = zeros(1, TOTAL_DURATION * settings.sampRate) * settings.daq.currentConversionFactor ; % send full command out, in Voltage for the daq to send
end

%% movingLeftDotON
function [out ] = movingLeftDotON( elevation_Y )
ephysSettings;
TOTAL_DURATION = 60; % seconds 
% Panel trigger digital signal
out.visualTriggerCommand = buildVisualVoltageTrigger( TOTAL_DURATION );

% Build PANEL parameters
panelParams.patternNum = 1;
panelParams.positionFuncNumX = 13;% moving 15 deg left
panelParams.positionFuncNumY = 8;% static
panelParams.initialPosition = [ 0, elevation_Y ]; % [ X, Y ]
% store parameter values
out.panelParams = panelParams;

% no current command
out.command = zeros(1, TOTAL_DURATION * settings.sampRate) * settings.daq.currentConversionFactor ; % send full command out, in Voltage for the daq to send
end

%% movingLeftDot4pixelON
function [out ] = movingLeftDot4pixelON( elevation_Y )
ephysSettings;
TOTAL_DURATION = 60; % seconds 
% Panel trigger digital signal
out.visualTriggerCommand = buildVisualVoltageTrigger( TOTAL_DURATION );

% Build PANEL parameters
panelParams.patternNum = 2;
panelParams.positionFuncNumX = 13;% moving 15 deg left
panelParams.positionFuncNumY = 8;% static
panelParams.initialPosition = [ 0, elevation_Y ]; % [ X, Y ]

% store parameter values
out.panelParams = panelParams;

% no current command
out.command = zeros(1, TOTAL_DURATION * settings.sampRate) * settings.daq.currentConversionFactor ; % send full command out, in Voltage for the daq to send
end
%%
%%
function out = buildVisualVoltageTrigger( trialDuration_sec )
ephysSettings;
VISUAL_TRIGGER_DURATION = 1; % second
% Panel trigger digital signal should be sent as 1 = ON 5V

% build trigger into the first second of the trial
out = [ ones(1, VISUAL_TRIGGER_DURATION * settings.sampRate)  zeros(1, (trialDuration_sec - VISUAL_TRIGGER_DURATION)  *  settings.sampRate) ]; 
end

%% Chrimson stimulation pattern functions
% 
% Open the shutter for the time in in variable 'dur'
function [out ] = chrStim( dur )
% 1 sec trigger pulse at the begining
ephysSettings;
PRE_STIM_DURATION = 2; % seconds
STIM_DURATION = dur; % seconds
POST_STIM_DURATION = 2; % seconds

TOTAL_DURATION = PRE_STIM_DURATION + STIM_DURATION + POST_STIM_DURATION; 

% build shutter Trigger 
shutterCommand = [ zeros(1, PRE_STIM_DURATION * settings.sampRate)  ones(1, STIM_DURATION * settings.sampRate) zeros(1, POST_STIM_DURATION * settings.sampRate)  ]; 

% no current command
out.command = zeros(1, TOTAL_DURATION * settings.sampRate) * settings.daq.currentConversionFactor ; % send full command out, in Voltage for the daq to send

%  trigger digital signal should be sent as 1 = ON 5V, which will be used
%  to open the lamp shutter
out.shutterCommand = shutterCommand;

end


%% stimLoop
function [out] = stimLoop ( dur, reps )
% step runs a quick trial with a single step of 
% dur = durations of the step in seconds
% for as many times as is specified in reps
ephysSettings;
PRE_STIM_DURATION = 2; % seconds
STIM_DURATION = dur; % seconds


shutterCommand = [];
for i = 1: reps
    
    preStimCommand = zeros(1, PRE_STIM_DURATION * settings.sampRate );
    
    stimCommand = ones( 1, STIM_DURATION * settings.sampRate );
    
    shutterCommand = [shutterCommand preStimCommand stimCommand];
end

%  trigger digital signal should be sent as 1 = ON 5V, which will be used
%  to open the lamp shutter
out.shutterCommand = shutterCommand;

% no current command
out.command = zeros(1, length(shutterCommand)) * settings.daq.currentConversionFactor ; % send full command out, in Voltage for the daq to send

end


%% probeTrial
function [out] = probeTrial ( dur, reps )
% step runs a quick trial with a single step of 
% dur = durations of the stimulation period when the shutter is open in seconds
% for as many times as is specified in reps
ephysSettings;
PRE_STIM_DURATION = 10; % seconds
STIM_DURATION = dur; % seconds

shutterCommand = [];
for i = 1: reps
    
    preStimCommand = zeros(1, PRE_STIM_DURATION * settings.sampRate );
    
    stimCommand = ones( 1, STIM_DURATION * settings.sampRate );
    
    shutterCommand = [shutterCommand preStimCommand stimCommand];
end

%  trigger digital signal should be sent as 1 = ON 5V, which will be used
%  to open the lamp shutter
out.shutterCommand = shutterCommand;

% no current command
out.command = zeros(1, length(shutterCommand)) * settings.daq.currentConversionFactor ; % send full command out, in Voltage for the daq to send
end


%% probeTrialPattern
function [out] = probeTrialPattern ( dur, interStimDur, reps )
% step runs a quick trial with a single step of 
% dur = durations of the stimulation period when the shutter is open in seconds
% for as many times as is specified in reps
ephysSettings;
PRE_STIM_DURATION = interStimDur; % seconds
STIM_DURATION = dur; % seconds

shutterCommand = [];
for i = 1: reps
    
    preStimCommand = zeros(1, PRE_STIM_DURATION * settings.sampRate );
    
    stimCommand = ones( 1, STIM_DURATION * settings.sampRate );
    
    shutterCommand = [shutterCommand preStimCommand stimCommand];
end

%  trigger digital signal should be sent as 1 = ON 5V, which will be used
%  to open the lamp shutter
out.shutterCommand = shutterCommand;

% no current command
out.command = zeros(1, length(shutterCommand)) * settings.daq.currentConversionFactor ; % send full command out, in Voltage for the daq to send
end


%% probeTrial_currInj
function [out] = probeCurrInj ( dur, amp, reps )
% step runs a quick trial with a single step of 
% dur = durations of the stimulation period when the shutter is open in seconds
% amp = is the amplitude of current injection (pA)
% for as many times as is specified in reps
ephysSettings;
PRE_STIM_DURATION = 10; % seconds
OFFSET_OF_CURR_INJECTION = 10; %seconds

STIM_DURATION = dur; % seconds
CURRENT_INJECTION_pA = amp; % pA

currentInjection = [];
for i = 1: reps
    

    preInjCommand = zeros(1, PRE_STIM_DURATION * settings.sampRate );
    

    injectionCommand = CURRENT_INJECTION_pA * ones( 1, STIM_DURATION * settings.sampRate );
      
    % build the current injection command
    currentInjection = [currentInjection preInjCommand injectionCommand];
end


% Convert the pA value into the amount to send in Volts from the DAQ
out.command = currentInjection * settings.daq.currentConversionFactor;% send full command out, in Voltage for the daq to send

end

%% probeTrial_DecorrelatedInjection
function [out] = probeTrial_deCorrInject ( dur,  amp,  reps )
% step runs a quick trial with a single step of 
% dur = durations of the stimulation period when the shutter is open in seconds
% amp = is the amplitude of current injection (pA)
% for as many times as is specified in reps
ephysSettings;
PRE_STIM_DURATION = 10; % seconds
OFFSET_OF_CURR_INJECTION = 10; %seconds

STIM_DURATION = dur; % seconds
CURRENT_INJECTION_pA = amp; % pA

shutterCommand = [];
currentInjection = [];
for i = 1: reps
    
    preStimCommand = zeros(1, PRE_STIM_DURATION * settings.sampRate );
    preInjCommand = zeros(1, PRE_STIM_DURATION * settings.sampRate );
    
    stimCommand = ones( 1, STIM_DURATION * settings.sampRate );
    injectionCommand = CURRENT_INJECTION_pA * ones( 1, STIM_DURATION * settings.sampRate );
    
    % build the shutter command
    shutterCommand = [shutterCommand preStimCommand stimCommand];   
    % build the current injection command
    currentInjection = [currentInjection preInjCommand injectionCommand];
end


%Shift the current injection command such that is it is decorrelated with
%the shutter:
currentInjection = circshift ( currentInjection, OFFSET_OF_CURR_INJECTION * settings.sampRate);


%  trigger digital signal should be sent as 1 = ON 5V, which will be used
%  to open the lamp shutter
out.shutterCommand = shutterCommand;

% Convert the pA value into the amount to send in Volts from the DAQ
out.command = currentInjection * settings.daq.currentConversionFactor;% send full command out, in Voltage for the daq to send

end


%% stimTrain
function [out] = stimTrain ( dur, interStimDur,  reps )
% step runs a quick trial with a single step of 
% dur = durations of the stimulation period when the shutter is open in seconds
% for as many times as is specified in reps
ephysSettings;
PRE_STIM_DURATION = interStimDur; % seconds
STIM_DURATION = dur; % seconds

POST_STIM_DURATION = 60; % sec

shutterCommand = [];
for i = 1: reps
    
    preStimCommand = zeros(1, PRE_STIM_DURATION * settings.sampRate );
    
    stimCommand = ones( 1, STIM_DURATION * settings.sampRate );
    
    shutterCommand = [shutterCommand preStimCommand stimCommand];
end

% add recording period to end of trial to look at changes after the stim
shutterCommand = [ shutterCommand zeros(1, POST_STIM_DURATION * settings.sampRate ) ];


%  trigger digital signal should be sent as 1 = ON 5V, which will be used
%  to open the lamp shutter
out.shutterCommand = shutterCommand;

% no current command
out.command = zeros(1, length(shutterCommand)) * settings.daq.currentConversionFactor ; % send full command out, in Voltage for the daq to send
end

%% Current injection Train
function [out] = currInjectTrain ( dur, interStimDur, amp, reps )
% step runs a quick trial with a single step of current injection 
%  *** no shutter opening in this function***
% dur = durations of the current injection period 
% for as many times as is specified in reps
ephysSettings;
PRE_STIM_DURATION = interStimDur; % seconds
STIM_DURATION = dur; % seconds
CURRENT_INJECTION_pA = amp; % pA

POST_INJ_DURATION = 60; % sec

currentInjection = [];
for i = 1: reps
    
    preInjCommand = zeros(1, PRE_STIM_DURATION * settings.sampRate );
    
    injectionCommand = CURRENT_INJECTION_pA * ones( 1, STIM_DURATION * settings.sampRate );
    
    % build the current injection command
    currentInjection = [currentInjection preInjCommand injectionCommand];
end

% add recording period to end of trial to look at changes after the stim
currentInjection = [ currentInjection zeros(1, POST_INJ_DURATION * settings.sampRate ) ];

% Convert the pA value into the amount to send in Volts from the DAQ
out.command = currentInjection * settings.daq.currentConversionFactor;% send full command out, in Voltage for the daq to send
end

%% stimTrain w/ simultaneous pulses of Current injection when shutter is open
function [out] = stimTrain_corrInject ( dur, interStimDur, amp, reps )
% step runs a quick trial with a single step of
% dur = durations of the stimulation period when the shutter is open in seconds
% for as many times as is specified in reps
ephysSettings;
PRE_STIM_DURATION = interStimDur; % seconds
STIM_DURATION = dur; % seconds
CURRENT_INJECTION_pA = amp; % pA
POST_STIM_DURATION = 10; % sec

shutterCommand = [];
currentInjection = [];
for i = 1: reps
    
    preStimCommand = zeros(1, PRE_STIM_DURATION * settings.sampRate );
    preInjCommand = zeros(1, PRE_STIM_DURATION * settings.sampRate );
    
    stimCommand = ones( 1, STIM_DURATION * settings.sampRate );
    injectionCommand = CURRENT_INJECTION_pA * ones( 1, STIM_DURATION * settings.sampRate );
    
    % build the shutter command
    shutterCommand = [shutterCommand preStimCommand stimCommand];
    % build the current injection command
    currentInjection = [currentInjection preInjCommand injectionCommand];
end

% add recording period to end of trial to look at changes after the stim
shutterCommand = [ shutterCommand zeros(1, POST_STIM_DURATION * settings.sampRate ) ];
currentInjection = [ currentInjection zeros(1, POST_STIM_DURATION * settings.sampRate ) ];

%  trigger digital signal should be sent as 1 = ON 5V, which will be used
%  to open the lamp shutter
out.shutterCommand = shutterCommand;

% Convert the pA value into the amount to send in Volts from the DAQ
out.command = currentInjection * settings.daq.currentConversionFactor;% send full command out, in Voltage for the daq to send
end


%% first a certain period of of stimuliation followed by stimTrain w/ simultaneous pulses of Current injection when shutter is open
function [out] = intialShutter_stimTrain_corrInject (intialStimDur, dur, interStimDur, amp, reps )
% step runs a quick trial with a single step of
% dur = durations of the stimulation period when the shutter is open in seconds
% for as many times as is specified in reps
ephysSettings;
PRE_STIM_DURATION = interStimDur; % seconds
FIRST_STIM_DURATION = intialStimDur; % seconds
STIM_DURATION = dur; % seconds
CURRENT_INJECTION_pA = amp; % pA


shutterCommand = [];
currentInjection = [];

% FIRST add the initial shutter period
preStimCommand = zeros(1, PRE_STIM_DURATION * settings.sampRate );
preInjCommand = zeros(1, PRE_STIM_DURATION * settings.sampRate );

stimCommand = ones( 1, FIRST_STIM_DURATION * settings.sampRate );
injectionCommand = zeros( 1, FIRST_STIM_DURATION * settings.sampRate ); % no current inject on this part

% build the shutter command
shutterCommand = [shutterCommand preStimCommand stimCommand];
% build the current injection command
currentInjection = [currentInjection preInjCommand injectionCommand];


% NOW add the repreated stimulation trials
for i = 1: reps
    
    preStimCommand = zeros(1, PRE_STIM_DURATION * settings.sampRate );
    preInjCommand = zeros(1, PRE_STIM_DURATION * settings.sampRate );
    
    stimCommand = ones( 1, STIM_DURATION * settings.sampRate );
    injectionCommand = CURRENT_INJECTION_pA * ones( 1, STIM_DURATION * settings.sampRate );
    
    % build the shutter command
    shutterCommand = [shutterCommand preStimCommand stimCommand];
    % build the current injection command
    currentInjection = [currentInjection preInjCommand injectionCommand];
end


%  trigger digital signal should be sent as 1 = ON 5V, which will be used
%  to open the lamp shutter
out.shutterCommand = shutterCommand;

% Convert the pA value into the amount to send in Volts from the DAQ
out.command = currentInjection * settings.daq.currentConversionFactor;% send full command out, in Voltage for the daq to send
end


%% stimTrain w/ current injection through out the whole stim Train part of trial 
function [out] = stimTrain_injectWholeTrial ( dur, interStimDur, amp, reps )
% step runs a quick trial with a single step of
% dur = durations of the stimulation period when the shutter is open in seconds
% for as many times as is specified in reps
ephysSettings;
PRE_STIM_DURATION = interStimDur; % seconds
STIM_DURATION = dur; % seconds
CURRENT_INJECTION_pA = amp; % pA
POST_STIM_DURATION = 60; % sec

shutterCommand = [];
currentInjection = [];
for i = 1: reps
    
    preStimCommand = zeros(1, PRE_STIM_DURATION * settings.sampRate );
    
    stimCommand = ones( 1, STIM_DURATION * settings.sampRate );
    % build the shutter command
    shutterCommand = [shutterCommand preStimCommand stimCommand];
end

% build current injection for full duration of the trial
currentInjection = CURRENT_INJECTION_pA * ones( 1, length ( shutterCommand ) ); % 


% add recording period to end of trial to look at changes after the stim
shutterCommand = [ shutterCommand zeros(1, POST_STIM_DURATION * settings.sampRate ) ];
currentInjection = [ currentInjection zeros(1, POST_STIM_DURATION * settings.sampRate ) ];


%  trigger digital signal should be sent as 1 = ON 5V, which will be used
%  to open the lamp shutter
out.shutterCommand = shutterCommand;


% Convert the pA value into the amount to send in Volts from the DAQ
out.command = currentInjection * settings.daq.currentConversionFactor;% send full command out, in Voltage for the daq to send
end


%% stepRamp
function [out ] = stepRamp (varargin)
fprintf('Running current Injection trial: stepRamp'); %YVETTE add in notification that uses the function name write this out each time
if( nargin == 0)
    %Default setting of current injection amplitude
    MAX_STEP_AMP = 4;%3; %pA the value you want the largest one to reach this value]
else
    MIN_STEP_AMP = varargin{1}; %pA
    MAX_STEP_AMP = varargin{2}; % set bump ampltude to the input arguement
end
ephysSettings;
%MIN_STEP_AMP = 1; %pA  5
NUMBER_OF_STEPS = 5;

PRE_STEP_DURATION = 7;% seconds
STEP_DURATION = 10;% second

stepSize = (MAX_STEP_AMP - MIN_STEP_AMP) / NUMBER_OF_STEPS ;
ampList = MIN_STEP_AMP : stepSize : MAX_STEP_AMP;
% suffle the amptude list,
% Removed randomization -11/9/16
%amp = ampList( randperm( length(ampList) ) );
amp = ampList;

% create epochs and injectionCommand variables
epochs = [];
injectionCommand = []; %create command variable
for i = 1 : NUMBER_OF_STEPS
    preStepCommand = zeros(1, PRE_STEP_DURATION * settings.sampRate );
    % pick the next amp
    stepCommand = amp(i) * ones( 1, STEP_DURATION * settings.sampRate );
    currentCommand = [preStepCommand stepCommand];
    
    % add this step to the trial
    injectionCommand = [injectionCommand currentCommand];
    
    % add epoch number for this trial to the epoch array
    thisEpoch =  i * ones(1, length (currentCommand ));
    epochs = [epochs thisEpoch];  % add current epoch to the array
end
out.command = injectionCommand * settings.daq.currentConversionFactor; % send full command out, in Voltage for the daq to send
out.epochs = epochs;
end

%% step
function [out] = step ( amp, dur )
% step runs a quick trial with a single step of 
% amp = amplitude of the step in pA
% dur = durations of the step in seconds
ephysSettings;
PRE_STEP_DURATION = 2; % seconds
STEP_DURATION = dur; % seconds
STEP_AMP = amp; % pA

preStepCommand = zeros(1, PRE_STEP_DURATION * settings.sampRate );

stepCommand = STEP_AMP * ones( 1, STEP_DURATION * settings.sampRate );

injectionCommand = [preStepCommand stepCommand];

out.command  = injectionCommand * settings.daq.currentConversionFactor; % send full command out, in Voltage for the daq to send
end

%% stepLoop
function [out] = stepLoop ( amp, dur, reps )
% step runs a quick trial with a single step of 
% amp = amplitude of the step in pA
% dur = durations of the step in seconds
% for as many times as is specified in reps
ephysSettings;
PRE_STEP_DURATION = 2; % seconds
STEP_DURATION = dur; % seconds
STEP_AMP = amp; % pA

injectionCommand = [];
for i = 1: reps
    
    preStepCommand = zeros(1, PRE_STEP_DURATION * settings.sampRate );
    
    stepCommand = STEP_AMP * ones( 1, STEP_DURATION * settings.sampRate );
    
    injectionCommand = [injectionCommand preStepCommand stepCommand];
end

out.command  = injectionCommand * settings.daq.currentConversionFactor; % send full command out, in Voltage for the daq to send
end

%% IVcurve
function [out] = IVcurve ( injAmp )
fprintf('Running current Injection trial: IVcurve'); 
ephysSettings;

STEP_DURATION = .1; % 100ms, seconds
PRE_STEP_DURATION = 1; % seconds
NUMBER_OF_STEPS = 15;
% steps from -maxInj up to +maxInj increamenting up
MAX_INJ = injAmp; %pA
MIN_INJ = -1*injAmp; %pA

stepSize = (MAX_INJ - MIN_INJ) / NUMBER_OF_STEPS ;
ampList = MIN_INJ : stepSize : MAX_INJ;


injectionCommand = [];
for i = 1 : NUMBER_OF_STEPS
    
    preStepCommand = zeros(1, PRE_STEP_DURATION * settings.sampRate );
    % pick the next amp
    stepCommand = ampList(i) * ones( 1, STEP_DURATION * settings.sampRate );
    currentCommand = [preStepCommand stepCommand];
    % add this step to the trial
    injectionCommand = [injectionCommand currentCommand];
    
end
% add final 1 sec spacer at end
injectionCommand = [injectionCommand zeros(1, PRE_STEP_DURATION * settings.sampRate )];

out.command = injectionCommand * settings.daq.currentConversionFactor; % send full command out, in Voltage for the daq to send
end 

function [] = plotCommandSignals( stimulus )
% PLOTCOMMANDSIGNALS Plotting helper function 
% Takes stimulus and parces which of these is an array
% plot all array, subfields in a figure to show the pattern to the user
% Yvette Fisher 2/2017
    figure();
    fields = fieldnames(stimulus);
    % Loop over struct and plot any field that is not itself a struct
    for i = 1:length(fields)
                % string of current Field
                currField = fields{i};
                % check that field is not a param struct or the name field
                if ( ~isstruct (stimulus.(currField) )  && ~strcmp(currField,'name') )
                    % plot array on figure
                    plot( stimulus.(currField) ); hold on;
                end
    end   
    % adds a title with stimulus' name
    title(stimulus.name);
end