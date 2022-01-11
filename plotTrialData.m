function [ ] = plotTrialData( data, stimulus, settings )
%PLOTTRIALDATA plots data from recently aquired trial
%   plot both the current, the command and the voltage trace from the recorded data
%
%
% Yvette Fisher 2/2017
% updated 8/2017
current = data.current; % pA
voltage = data.voltage; % mV

%fNum = 1; % first figure number
%close(FigHand); 
FigHand = figure('Position',[50, 50, 1800, 800]);
set(gcf, 'Color', 'w'); 

timeArray = (1  :  length(current) ) / settings.sampRate; % seconds


ax(1) = subplot(3,1,1);
% plot current trace
plot(timeArray, current); hold on;
if( isfield( stimulus, 'visualTriggerCommand' ) )
    plot(timeArray, stimulus.visualTriggerCommand);
end
%plot command trace
COMMAND_SCALE = 10000;
COMMAND_OFFSET = 50;
plot(timeArray ,(stimulus.command * COMMAND_SCALE) - COMMAND_OFFSET ); hold on;
title('Current & stimulus Command time course');
xlabel('time(s)')
ylabel('pA and AU');
ylim([-50 100]);


% plot voltage trace
ax(2) = subplot(3,1,2);
plot( timeArray, voltage); hold on;
title('voltage');
xlabel('time(s)')
ylabel('mV');

ax(3) = subplot(3,1,3);
% plot panel data if it was aquired
if(isfield( data, 'xPanelVolts') )
    
    % plot x and y panel pos decoded position values
     plot( timeArray, data.xPanelPos, 'DisplayName','panel x (pos)'); hold on;
     plot( timeArray, data.yPanelPos, 'DisplayName','panel y (pos)'); hold on;
    title('voltage');
    xlabel('time(s)')
    ylabel('Panel X and Y values (Volts)');
    legend('show')    
end

% plot panel data if it was aquired
if(isfield( data, 'ficTracAngularPosition') )

    % plot ficTrac values from the ball data
    plot( timeArray, data.ficTracAngularPosition, 'DisplayName','ficTrac Heading'); hold on;
    plot( timeArray, data.ficTracIntx, 'DisplayName','ficTrac IntX'); hold on;
    plot( timeArray, data.ficTracInty, 'DisplayName','ficTrac IntY'); hold on;   
end


% plot Shutter data if applicable
if(isfield( stimulus, 'shutterCommand') )
    
    SCALAR_FOR_PLOTTING = 72;

    plot( timeArray, SCALAR_FOR_PLOTTING*stimulus.shutterCommand, 'DisplayName','shutterCommand (high = Open)'); hold on;

    title('shutter command');
    xlabel('time(s)')
    ylabel('Shutter open/closed');
end

linkaxes(ax,'x');
end

