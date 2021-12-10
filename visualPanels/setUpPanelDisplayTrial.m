function [ ] = setUpPanelDisplayTrial( stimulus )
%SETUPPANELDISPLAYTRIAL Intializes the Panel visual display system by
%setting up which Pattern and which Position_Function will be used. 
%    
%      Get system ready for the Trigger to start display of the pattern
% Called by acquireTrial during Yvette's Ephy aquisition code
% This funciton is meant to set up a Pattern to be ready to be played using
% the Panel Arena system.   
% 
%  Following the running of the funtion the stimulus will be triggered via
%  an eternal trigger that arrives at INT3

panelParams = stimulus.panelParams;

patternNum = panelParams.patternNum;
positionFuncNumX = panelParams.positionFuncNumX;
positionFuncNumY = panelParams.positionFuncNumY;

%default behavior
FUNCFREQ_Y = 50; % Hz
FUNCFREQ_X = 50; % Hz

% If we are doing fast open loop stimuli we need this display rate to be
% faster to match the stimuli
if ( panelParams.positionFuncNumX == 22 || panelParams.positionFuncNumX == 23 || panelParams.positionFuncNumX == 24 )
    FUNCFREQ_Y = 200; % Hz
    FUNCFREQ_X = 200; % Hz
end

% If we are doing very long trials then this display rate needs to be
% slower to it doesn't pass the 1000 byte limit for functions
% faster to match the stimuli
if ( panelParams.positionFuncNumY == 31 || panelParams.positionFuncNumY == 32 )
    FUNCFREQ_Y = 5; % Hz
end

% 1:X channel    2:Y channel
X_channelNum = 1;
Y_channelNum = 2;
        
% set pattern id number
Panel_com('set_pattern_id', patternNum);
pause(.03)

% This is used if you want the user to be able to set the bar position/initial pattern position, 
% which depending on the pattern will either set the initial location in x
% but can also set the initial ypos or contrast
initPanelPosition = [0, 0]; %
if( isfield( panelParams, 'initialPosition' ))
    
    % if only x pos is specified
    if( numel(panelParams.initialPosition) == 1) % initial x-pos
        initPanelPosition(1) =  panelParams.initialPosition;
     
    % if x and y pos are specified    
    elseif (numel(panelParams.initialPosition) == 2) %intial x,y positions
        initPanelPosition(1) =  panelParams.initialPosition(1);
        initPanelPosition(2) =  panelParams.initialPosition(2);
    else
        disp('WARNING: panelParams.initialPosition did not have the expected number of elements (1 or 2), the default: [0 0] was used for intial panel positions');
    end
    
end
Panel_com('set_position',initPanelPosition + 1);% offset the position functions, add 1 to counter act Panel_com behavior
             % Caution: Panel_com automatically subtract 1 from init_pos.
pause(.03) 

% Set controller mode – sets the mode for the controller’s X and Y channels
% Arguments: 2 values to set the mode for X and Y channels. 0 – open loop, 1 – closed loop, 2 – both, closed loop plus function as bias, 3 – External input sets position, 4 – Internal function generator sets velocity/position, 5 – internal function generator debug mode.
% Usage: Panel_com(‘set_mode’, [0 1]); % X to open loop, Y to closed loop.
if( ~isfield( stimulus, 'closedLoop') ) %
    % DEFAULT behavior - open loop
    PANEL_MODE_NUMS = [4 , 4]; % Position: function X and Position function Y set ??
    
elseif (stimulus.closedLoop)
    % Closed Loop setting
    PANEL_MODE_NUMS = [3 , 0]; % ClosedLoop 3 – External input sets position using ficTrac signal
    % other logic needed here?
end

Panel_com('set_mode',PANEL_MODE_NUMS);
pause(.03)

Panel_com( 'set_funcy_freq' , FUNCFREQ_Y );
pause(.03)

% takes argeuments [channel num, positionFunc number] 
Panel_com( 'set_posfunc_id', [ X_channelNum, positionFuncNumX ] );
pause(.03)

Panel_com( 'set_funcx_freq', FUNCFREQ_X );
pause(.03)

% takes argeuments [channel num, positionFunc number] 
Panel_com( 'set_posfunc_id',[ Y_channelNum, positionFuncNumY ] );
pause(.03)
% 
% % Send voltage command out from Panels when it is on
% channelNum = 3;
% TRIGGER_10Volts = 32767; 
% TRIGGER_5V = TRIGGER_10Volts / 2; 
% Panel_com('set_ao',[channelNum ,TRIGGER_5V]); % change this to make sense

% Have panel waiting for external trigger from amp to start (INT3 - pin 18
% on back on controller)
Panel_com('enable_extern_trig');

end

