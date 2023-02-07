%%plotChrimsonTrial
% simple plotting script to display trace and when the light was on for
% chrimson stimulation
ephysSettings
FigHand = figure('Position',[50, 50, 1800, 300]);
set(gcf, 'Color', 'w');
timeArray = (1  :  length(data.current) ) / rigSettings.sampRate; % seconds
% Shade in time points when the light was on
LEDstim =  stimulus.LEDcommand.output;
LEDOnOffFrames = find(  diff( LEDstim ) ~= 0);
LEDOnOffTimes = timeArray( LEDOnOffFrames );
xcord = sort( [LEDOnOffTimes LEDOnOffTimes] );
MIN_VOLTAGE_FOR_PLOT = -80;
ycord = MIN_VOLTAGE_FOR_PLOT * repmat([0 1 1 0], 1, (length(xcord) / 4) );
patch( xcord, ycord ,'g', 'FaceAlpha',1); hold on
voltage = data.voltage; % for current clamp traces
% plot voltage trace
plot( timeArray, voltage, 'k'); hold on;
title('voltage');
ylim([ -80 0 ])
xlabel('time(s)')
ylabel('mV');
box off
title( [ num2str(exptInfo.dNum) ' fly#: ' num2str(exptInfo.flyNum) ' cell#: '  num2str(exptInfo.cellNum) ' expt#: ' num2str(exptInfo.cellExpNum) ' trial#: ' num2str(trialMeta.trialNum)])